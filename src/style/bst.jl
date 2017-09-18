abstract type Variable end
struct QuotedVar <: Variable
	value
end
struct Identifier <: Variable
	value
end

function process_int_literal(value)
    return Integer(int(value.strip('#')))
end

function process_string_literal(value)
    assert(startswith(value, "\""))
    assert(endswith(value,"\""))
    return String(value[1:-1])
end

function process_identifier(name)
    if name[1] == "'"
        return QuotedVar(name[2:end])
    else
        return Identifier(name)
	end
end

function process_function(toks)
    return FunctionLiteral(toks[1])
end

quote_or_comment = r"[%\"]"

"""Strip the commented part of the line."

>>> print(strip_comment('a normal line'))
a normal line
>>> print(strip_comment('%'))
<BLANKLINE>
>>> print(strip_comment('%comment'))
<BLANKLINE>
>>> print(strip_comment('trailing%'))
trailing
>>> print(strip_comment('a normal line% and a comment'))
a normal line
>>> print(strip_comment('"100% compatibility" is a myth'))
"100% compatibility" is a myth
>>> print(strip_comment('"100% compatibility" is a myth% or not?'))
"100% compatibility" is a myth

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
RBRACE = (r"\}", "right brace")
STRING = (r"\"[^\"]*\"", "string")
INTEGER = (r"#-?\d+", "integer")
NAME = (r"[^#\"\{\}\s]+", "name")

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

abstract type  Scanner end
mutable struct BstParser <: Scanner
	text::String
	lineno::Integer
	pos::Integer
	end_pos::Integer
end
function BstParser(text::String)
	text = join([strip_comment(rstrip(String(line))) for line in split(text, "\n")],"\n")
	return BstParser(text,1,1, length(text))
end

function parse_command(self::BstParser)
	local commands = []
	command_name = required(self, [NAME], "BST command", allow_eof=true)
	local arity = nothing
	try
        arity = COMMANDS[uppercase(command_name[1])]
	catch e
		println(e)
		throw((:TokenRequired,"BST command"))
	end
	push!(commands, command_name)
	for i =1:arity
		brace = optional(self, [LBRACE])
		println(brace)
		println(self.pos)
		if brace == nothing
			break
		end
        push!(commands, parse_group(self))
	end
	println("F")
	return commands
end
function parse(self::BstParser)
	local commands =[]
	while true
		try
			new_commands = parse_command(self)
			push!(commands,new_commands)
		catch e
			if e==:EOF
				break;
			else
				println(catch_stacktrace())
				break
			end
		end
	end
	return commands
end

function parse_group(self::BstParser)
	local endgroup = false
	local tokens = []
	println("Empieza grupo")
	while !endgroup
		token = required(self, [NAME, STRING, INTEGER, LBRACE, RBRACE])
		println(token)
		println(self.text[self.pos-2:self.pos+2])
		if token[2] == LBRACE
			push!(tokens , FunctionLiteral(list(self.parse_group())))
		elseif token[2] == RBRACE
			endgroup = true
		else
			push!(tokens, LITERAL_TYPES[token[2]](token[1]))
		end
	end
	println("CIerro Grupo")
	return tokens
end

#=def parse_file(filename, encoding=None):
    with pybtex.io.open_unicode(filename, encoding=encoding) as bst_file:
        return parse_stream(bst_file, filename)

def parse_stream(stream, filename='<INPUT>'):
    bst = '\n'.join(strip_comment(line.rstrip()) for line in stream)
    return BstParser(bst, filename=filename).parse()

def parse_string(bst_string):
    bst = '\n'.join(strip_comment(line) for line in bst_string.splitlines())
    return BstParser(bst).parse()
=#
WHITESPACE = (r"\s+", "whitespace")
NEWLINE = (r"\n|(\r\n)|\r", "newline")

function skip_to(self::Scanner, patterns)
	local end_pos = nothing
	local winning_pattern = nothing
	for pattern in patterns
		matched = match(pattern[1], self.text, self.pos)
		if (matched!=nothing) && (end_pos != nothing)  || (maximum(match) < end_pos)
			end_pos = matched.offset + length(matched.match)
			winning_pattern = pattern
		end
	end
	if winning_pattern != nothing
		value = self.text[self.pos:end]
		self.pos = end_pos
		# print '>>', value
		update_lineno(self, value)
		return (value, winning_pattern)
	end
end
function update_lineno(self::Scanner, value)
	num_newlines = length(matchall(NEWLINE[1],value))
	self.lineno =  self.lineno + num_newlines
end
function eat_whitespace(self::Scanner)
	whitespace = match(WHITESPACE[1], self.text, self.pos)
	if whitespace!=nothing
		self.pos = whitespace.offset + length(whitespace.match)
		update_lineno(self, whitespace.match)
	end
end

function eof(self::Scanner)
	return self.pos >= self.end_pos
end

function get_token(self::Scanner, patterns; allow_eof=false)
	eat_whitespace(self)
	if eof(self)
		if allow_eof
			throw(:EOF)
		else
			throw((:PrematureEOF,self))
		end
	end
	println("BUSCOOO")
	println(self.text[self.pos:end])
	for pattern in patterns
		local matched = match(pattern[1], self.text, self.pos)
		println(pattern[1], " " ,matched!=nothing)
		if matched != nothing
			value = matched.match
			self.pos = matched.offset + length(matched.match)
			# print '->', value
			return ( value, pattern)
		end
	end
end

function optional(self::Scanner, patterns; allow_eof=false)
	return get_token(self, patterns, allow_eof=allow_eof)
end

function required(self::Scanner, patterns, description=nothing; allow_eof=false)
	local token = get_token(self, patterns, allow_eof=allow_eof)
	if token == nothing
		if description != nothing
			description = join([pattern[2] for pattern in patterns], " or ")
		end
		throw((:TokenRequired,description, self))
	else
		return token
	end
end
function get_error_context_info(self::Scanner)
	return (self.lineno, self.pos)
end
function get_error_context(self::Scanner, context_info)
	error_lineno, error_pos = context_info
	if error_lineno != nothing
		error_lineno0 = error_lineno - 1
		lines = self.text.splitlines(True)
		before_error = join(lines[1:error_lineno0], " ")
		colno = error_pos - length(before_error)
		context = rstrip(lines[error_lineno0], "\r\n")
	else
		colno = nothing
		context = nothing
	end
	return context, error_lineno, colno
end
function get_remainder(self::Scanner)
	return self.text[self.pos:end]
end

content = readstring("../../test/format/small.bst")
parser = BstParser(content)
parse(parser)
