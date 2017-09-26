module BST
using BibTeX
import Base.==
import Base.parse
import Base.eof
import Base.push!
import Base.pop!
import Base.length
import Base.isequal
import Base.hash
import Base.string
import BibTeXFormat: BaseStyle, format_bibliography,
                     format_entries, add_extra_citations,
                     transform_entries
include("scanner.jl")
include("names.jl")
"""
```
type Style <: BaseStyle
```
A Style obtained from a .bst file
"""
type Style <: BaseStyle
    commands
end
mutable struct Interpreter
	bst_style::Style
	bib_encoding
	stack::Array
	vars::Dict
	macros::Dict
	output_buffer::Array
	output_lines::Array
    citations
    bib_files
    min_crossrefs::Integer
    bib_data
    current_entry_key::String
    current_entry
    entries_var::Dict{String,Dict}
end

include("builtins.jl")
function Interpreter(bib_format, bib_encoding)
    local int  = Interpreter(bib_format, bib_encoding, [], copy(builtins), Dict(), [],[], nothing, nothing, true, nothing, "", nothing, Dict{String,Dict}())
	add_variable(int,"global.max\$", BSTInteger(20000))
	add_variable(int,"entry.max\$", BSTInteger(250))
	add_variable(int, "sort.key\$", EntryString(int, "sort.key\$"))
	return int
end
abstract type Variable end

function value_type(n::T) where T<:Variable
    return typeof(n.value).super
end
function hash(x::T) where T<:Variable
    return hash(x.value)
end
function isequal(x::T, y::T) where T <: Variable
    return x.value ==  y.value
end
function set(self::Variable, value)
	if (value == nothing)
		value = default(typeof(self))
	end
	validate(self, value)
	self.value = value
end
function validate(self::Variable, value)
    println(typeof(value), " ", value_type(self))
	if ! (isa(value, value_type(self)) || value == nothing)
		throw("Invalid value for BibTeX $(typeof(self))")
	end
end
function execute(self::Variable, interpreter)
    push!(interpreter, value(self))
end
function value(self::Variable)
	return self.value
end
function ==(a::T, b::T) where T<:Variable
    return a.value == b.value
end
mutable struct QuotedVar <: Variable
	value
end

function execute(self::QuotedVar, interpreter)
	#try
		var = interpreter.vars[self.value]
	#catch e
		#throw("can not push undefined variable %(self.value)")
	#end
	push!(interpreter, var)
end
mutable struct Identifier <: Variable
	value
end
function execute(self::Identifier, interpreter)
	#try
        f = interpreter.vars[value(self)]
        println(value(self))
		execute(f, interpreter)
#	catch e
 #       println(e)
  #      throw("can not execute undefined function $(self.value)")
#	end
end

abstract type   EntryVariable <: Variable end
function set(self::T, value) where T<:EntryVariable
	if value != nothing
		validate(self, value)
        local current_entry = self.interpreter.current_entry
        local entries_var   = self.interpreter.entries_var
        if !haskey(entries_var, current_entry["key"])
            entries_var[current_entry["key"]]=Dict()
        end
		entries_var[current_entry["key"]][self.name] = value
	end
end
function value(self::EntryVariable)
	return get(self.interpreter.entries_var,self.name, default(self))
end
mutable struct BSTInteger <: Variable
    value::Integer
end
function default(n::BSTInteger)
	return 0
end
mutable struct  BSTString <: Variable
    value::String
end
function default(a::BSTString)
	return ""
end
mutable struct EntryInteger <: EntryVariable
	interpreter::Interpreter
	name::String
end

function value_type(n::EntryInteger)
	return Integer
end
function default(n::EntryInteger)
	return 0
end

mutable struct EntryString <: EntryVariable
	interpreter::Interpreter
	name::String
    value::String
end
function EntryString(interpreter::Interpreter, name::String)
    return EntryString(interpreter, name, "")
end

function default(a::EntryVariable)
	return ""
end
function value_type(a::EntryVariable)
	return AbstractString
end

abstract type AbstractParsedFunction end
function ==(a::AbstractParsedFunction, b::AbstractParsedFunction)
	return typeof(a) == typeof(B) && a.body == b.body
end
type ParsedFunction <: AbstractParsedFunction
	body
end

function  execute(self::ParsedFunction, interpreter)
    for element in self.body
    	execute(element, interpreter)
	end
end
struct FunctionLiteral <: AbstractParsedFunction
    body
end
function ==(a1::FunctionLiteral, a2::FunctionLiteral)
    return a1.body==a2.body
end

function  execute(self::FunctionLiteral, interpreter)
        push!(interpreter, ParsedFunction(self.body))
end
function process_int_literal(value)
    return BSTInteger(Base.parse(Int32,string(strip(value,'#'))))
end

function process_string_literal(value)
    assert(startswith(value, "\""))
    assert(endswith(value,"\""))
    return BSTString(String(value[2:end-1]))
end

function process_identifier(name)
    if name[1] == '\''
        return QuotedVar(String(name[2:end]))
    else
        return Identifier(String(name))
	end
end

function process_function(toks)
    return FunctionLiteral(toks[1])
end

quote_or_comment = r"[%\"]"

"""Strip the commented part of the line."
´´´jldoctest
julia> print(strip_comment("a normal line"))
a normal line
julia> print(strip_comment("%"))

julia> print(strip_comment("%comment"))

julia> print(strip_comment("trailing%"))
trailing
julia> print(strip_comment("a normal line% and a comment"))
a normal line
julia> print(strip_comment("\"100% compatibility\" is a myth"))
"100% compatibility" is a myth
julia> print(strip_comment("\"100% compatibility\" is a myth% or not?"))
"100% compatibility" is a myth
´´´
"""
function strip_comment(line)
    local pos = 1
    local end_pos = length(line)
    local in_string = false
    while pos <= end_pos
        local matched = match(quote_or_comment,line, pos)
        if matched == nothing
            break
        end
        if matched.match == "%" && !in_string
            return line[1:matched.offset-1]
        elseif matched.match == "\""
            in_string = !in_string
        end
        pos = matched.offset + length(matched.match)
    end
    return line
end
LBRACE = (r"\{", "left brace")
LBRACE[1].match_options |=  Base.PCRE.ANCHORED
RBRACE = (r"\}", "right brace")
RBRACE[1].match_options |= Base.PCRE.ANCHORED
STRING = (r"\"[^\"]*\"", "string")
STRING[1].match_options |= Base.PCRE.ANCHORED
INTEGER = (r"#-?\d+", "integer")
INTEGER[1].match_options |= Base.PCRE.ANCHORED
NAME = (r"[^#\"\{\}\s]+", "name")
NAME[1].match_options |= Base.PCRE.ANCHORED

COMMANDS = Dict{String,Integer}(
	"ENTRY" => 3,
	"EXECUTE" => 1,
	"FUNCTION" =>  2,
	"INTEGERS" => 1,
	"ITERATE" => 1,
	"MACRO" => 2,
	"READ" => 0,
	"REVERSE" => 1,
	"SORT" => 0,
	"STRINGS" => 1,
   )

LITERAL_TYPES = Dict{Any, Function}(
	STRING=> process_string_literal,
	INTEGER=> process_int_literal,
	NAME=> process_identifier,
)
mutable struct Parser <: Scanner
	text::String
	lineno::Integer
	pos::Integer
	end_pos::Integer
end
function Parser(text::String)
	text = join([strip_comment(rstrip(String(line))) for line in split(text, "\n")],"\n")
	return Parser(text,1,1, length(text))
end

function parse_command(self::Parser)
	local commands = []
	command_name = required(self, [NAME], "BST command", allow_eof=true)
	local arity = nothing
	#try
        arity = COMMANDS[uppercase(command_name[1])]
#	catch e
#		throw((:TokenRequired,"BST command"))
#	end
    push!(commands, command_name[1])
	for i =1:arity
		brace = optional(self, [LBRACE])
		if brace == nothing
			break
		end
        push!(commands, parse_group(self))
	end
	return commands
end

function parse(self::Parser)
	local commands =[]
	while true
		try
			new_commands = parse_command(self)
			push!(commands,new_commands)
		catch e
			if e==:EOF
				break;
			else
                throw(e)
				break
			end
		end
    end
    return Style(commands)
end
"""
```
function parse_string(content::String)
```
"""
function parse_string(content::String)
    return parse(Parser(content))
end
"""
```
function parse_file(filename::String)
```
"""
function parse_file(filename::String)
    return parse_string(readall(filename))
end

function parse_group(self::Parser)
	local endgroup = false
	local tokens = []
	while !endgroup
		token = required(self, [NAME, STRING, INTEGER, LBRACE, RBRACE])
		if token[2] == LBRACE
			push!(tokens , FunctionLiteral(parse_group(self)))
		elseif token[2] == RBRACE
			endgroup = true
		else
			push!(tokens, LITERAL_TYPES[token[2]](token[1]))
		end
	end
	return tokens
end

WHITESPACE = (r"\s+", "whitespace")
WHITESPACE[1].match_options |= Base.PCRE.ANCHORED
NEWLINE = (r"\n|(\r\n)|\r", "newline")
NEWLINE[1].match_options |= Base.PCRE.ANCHORED

function parse_file(filename::String)
    local content  = readstring(filename)
    return parse_string(content)
end
function parse_string(content::String)
        parser = Parser(content)
        return parse(parser)
end

struct MissingField <: AbstractString
	name
end
import Base.endof
import Base.next
function endof(m::MissingField)
    return endof(m.name)
end
function next(m::MissingField, state)
    return next(m.name, state)
end
function length(m::MissingField)
    return 1
end
function string(m::MissingField)
    return m.name
end
abstract type AbstractField end
function execute(self::T, interpreter) where T<:AbstractField
	push!(self.interpreter, value(self))
end
mutable struct Field <: AbstractField
	interpreter
	name::String
end

function value(self::Field)
	try
		return self.interpreter.current_entry[self.name]
	catch e
		return MissingField(self.name)
	end
end

mutable struct Crossref <: AbstractField
	interpreter::Interpreter
	name::String
end
function value(self::Crossref)
#	try
		value = self.interpreter.current_entry.fields[self.name]
		crossref_entry = self.interpreter.bib_data.entries[value]
		return crossref_entry.key
#	catch e
 #       println(e)
#		return MissingField(self.name)
#	end

end

function push!(self::Interpreter, value)
	push!(self.stack,value)
    println(length(self.stack))
end
function pop!(self::Interpreter)
	try
        println(length(self.stack))
        value = pop!(self.stack)
		return value
	catch e
        println(e)
		throw("pop from empty stack")
	end
end
function get_token(self::Interpreter)
	return next(self.bst_script)
end
function add_variable(self::Interpreter, name, val)
	if haskey(self.vars, name)
		throw("variable $name already declared")
	end
	self.vars[name] = val
end
function output(self::Interpreter, str)
	push!(self.output_buffer,str)
end
function newline(self::Interpreter)
	output = Base.join(self.output_buffer,"")
	push!(self.output_lines,output)
	push!(self.output_lines, "\n")
	self.output_buffer = []
end

"""
```
function run(self, citations, bib_files, min_crossrefs):
```
Run bst script and return formatted bibliography.
"""
function run(self::Interpreter,  citations, bib_files, min_crossrefs::Integer=1)
	self.citations = citations
	self.bib_files = bib_files
	self.min_crossrefs = min_crossrefs
	for command in self.bst_style.commands
		name = command[1]
		args = command[2:end]
		method = string("command_", lowercase(name))
		#try
			f = getfield(BST, Symbol(method))
			f(self,args...)
	#	catch e
     #       println(e)
    #		println("Unknown command", name)
	#	end
	end
	return Base.join(self.output_lines, "")
end
function command_entry(self::Interpreter, fields, ints, strings)
	for id in fields
        name = value(id)
		add_variable(self, name, Field(self, name))
	end
	add_variable(self, "crossref", Crossref(self, "crossref"))
	for id in ints
        name = value(id)
		add_variable(self, name, EntryInteger(self, name))
	end
	for id in strings
        name = String(value(id))
		add_variable(self, name, EntryString(self, name))
	end
end
function command_execute(self::Interpreter, command_)
	execute(command_[1],self)
end
function command_function(self::Interpreter, name_, body)
    name = value(name_[1])
	add_variable(self, name, ParsedFunction(body))
end
function command_integers(self::Interpreter, identifiers)
	for identifier in identifiers
        self.vars[value(identifier)] = BSTInteger(0)
	end
end

function command_iterate(self::Interpreter, function_group)
    f = value(function_group[1])
	_iterate(self, f, self.citations)
end

function _iterate(self::Interpreter, ff, citations)
	f = self.vars[ff]
	for key in citations
		self.current_entry_key = key
		self.current_entry = self.bib_data[key]
		execute(f, self)
	end
	self.current_entry = nothing
end
function value(a::T) where T<:AbstractString
    return String(a)
end
function value(a::T) where T<:Variable
    return a.value
end
function command_macro(self::Interpreter, name_, value_)
    local name = value(name_[1])
    local val = value(value_[1])
	self.macros[name] = val
end
function  command_read(self::Interpreter)
    self.bib_data =  self.bib_files
	self.citations = add_extra_citations(self.bib_data, self.citations; min_crossrefs= self.min_crossrefs)
	self.citations = remove_missing_citations(self, self.citations)
end
function remove_missing_citations(self::Interpreter, citations)
	cit = []
	for citation in citations
		if haskey(self.bib_data, citation)
			push!(cit,citation)
		else
			warning("missing database entry for \"$citation\"")
		end
	end
    return cit
end
function command_reverse(self, function_group)
    f = value(function_group[1])
	_iterate(self, f, reverse(self.citations))
end
function command_sort(self::Interpreter)
	function key(citation)
		return self.entries_var[citation]["sort.key\$"]
	end
	sort(self.citations, by=key)
end

function command_strings(self::Interpreter, identifiers)
	for identifier in identifiers
        self.vars[value(identifier)] = BSTString("")
	end
end

"""
```julia
function format_bibliography(self::Style, bib_data, citations=nothing)
```
Format bibliography entries with the given keys

Params:
- `style::Style`. The BST style
- `bib_data`
- `param citations`: A list of citation keys.

"""
function format_bibliography(style::Style, bib_data::Bibliography, citations=nothing)
    println("aa")
end

"""
```
function format_entries(b::Style, entries::Dict)
```
Format a Dict of `entries` with a given style `b::Style`
```julia
using BibTeX
using BibTeXFormat
bibliography      = Bibliography(readstring("test/Clustering.bib"))
style        = BST.parse_file(joinpath(Pkg.dir("BibTeXFormat"),"test/format/apacite.bst"))
formatted_entries = format_entries(style, bibliography)
```
"""

function format_entries(b::Style, entries)
    run(Interpreter(b, "utf-8"), ["*"], transform_entries(entries))
end
end
