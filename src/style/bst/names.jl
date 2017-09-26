import BibTeXFormat: Person, get_part, bibtex_first_names,
                     bibtex_abbreviate
struct NamePart
	pre_text
	post_text
	tie
	format_char::Char
	abbreviate::Bool
	delimiter
end
function NamePart(format_list)
	pre_text, format_chars, delimiter, post_text = format_list
	local tie = ""
	local format_char = ""
	local abbreviate = false
	if length(format_chars)>0 && length(pre_text)>0 && length(post_text)<=0
		post_text = pre_text
		pre_text = ""
	end
	if endswith(post_text, "~~")
		tie = "~~"
	elseif endswith(post_text, "~")
		tie = "~"
	else
		tie = nothing
	end
	pre_text = pre_text
	post_text = rstrip(post_text,'~')
	if !(length(format_chars)>0)
		format_char = ""
		abbreviate = false
	else
		l = length(format_chars)
		if l == 1
			abbreviate = true
		elseif l == 2 && format_chars[1] == format_chars[2]
			abbreviate = false
		else
			throw("invalid format string")
		end
		format_char = format_chars[1]
	end
	return NamePart(pre_text, post_text, tie, format_char, abbreviate, delimiter)
end

const format_name_types = Dict{Char, String}([
            'f'=> "bibtex_first",
            'l'=> "last",
            'v'=> "prelast",
            'j'=> "lineage"
    ])
function ==(a::NamePart, b::NamePart)
	return  a.pre_text == b.pre_text  &&
            a.format_char == b.format_char  &&
            a.abbreviate == b.abbreviate &&
            a.delimiter == b.delimiter &&
            a.post_text == b.post_text
end

function format(self::NamePart, person)
    local names = []
    if self.format_char != nothing
        names = get_part(person, format_name_types[self.format_char])
    end
    if self.format_char != nothing && length(names)==0
		return ""
    end
	if self.abbreviate
		names = [bibtex_abbreviate(name, self.delimiter) for name in names]
    end
	if self.delimiter == nothing
		if self.abbreviate
			names = bst_join(names, ".~", ". ")
        else
			names = bst_join(names)
        end
	else
		names = join(names, self.delimiter)
    end
    formatted_part = string(self.pre_text, names, self.post_text)
    local discretionary = ""
	if self.tie == "~"
		discretionary = tie_or_space(formatted_part)
    elseif self.tie == "~~"
		discretionary = "~"
    end
    return string(formatted_part, discretionary)
end

module NamePatterns
const LBRACE = (r"{", "lbrace")
LBRACE[1].match_options |=  Base.PCRE.ANCHORED
const RBRACE = (r"}", "rbrace")
RBRACE[1].match_options |=  Base.PCRE.ANCHORED
const TEXT =  (r"[^{}]+", "text")
TEXT[1].match_options |=  Base.PCRE.ANCHORED
const NON_LETTERS = (r"[^{}\w]|\d+", "non-letter characters")
NON_LETTERS[1].match_options |=  Base.PCRE.ANCHORED |   Base.PCRE.CASELESS
const FORMAT_CHARS = (r"[^\W\d_]+", "format chars")
FORMAT_CHARS[1].match_options |=  Base.PCRE.ANCHORED |   Base.PCRE.CASELESS
end
doc"""
```
struct NameFormat
```
BibTeX name format string.
```jldoctest
julia> import BibTeXFormat.BST: NameFormat, NamePart

julia> f = NameFormat("{ff~}{vv~}{ll}{, jj}");

julia> f.parts == [ NamePart(["", "ff", nothing, ""]),  NamePart(["", "vv", nothing, ""]),  NamePart(["", "ll", nothing, ""]),  NamePart([", ", "jj", nothing, ""]) ]
true

julia> f = NameFormat("{{ }ff~{ }}{vv~{- Test text here -}~}{ll}{, jj}");

julia> f.parts == [NamePart(["{ }", "ff", nothing, "~{ }"]), NamePart(["", "vv", nothing, "~{- Test text here -}"]), NamePart(["", "ll", nothing, ""]),  NamePart([", ", "jj", nothing, ""]) ]
true

julia> f = NameFormat("abc def {f~} xyz {f}?");

julia> f.parts == ["abc def ", NamePart(["", "f", nothing, ""]), " xyz ", NamePart(["", "f", nothing, ""]),  "?" ]
true

julia> f = NameFormat("{{abc}{def}ff~{xyz}{#@\$}}");

julia> f.parts == [NamePart(["{abc}{def}", "ff", nothing, "~{xyz}{#@\$}"])]
true

julia> f = NameFormat("{{abc}{def}ff{xyz}{#@\${}{sdf}}}");

julia> f.parts == [NamePart(["{abc}{def}", "ff", "xyz", "{#@\${}{sdf}}"])]
true

julia> f = NameFormat("{f.~}");

julia> f.parts == [NamePart(["", "f", nothing, "."])]
true

julia> f = NameFormat("{f~.}");

julia> f.parts == [NamePart(["", "f", nothing, "~."])]
true

julia> f = NameFormat("{f{.}~}");

julia> f.parts == [NamePart(["", "f", ".", ""])]
true

```
"""
struct NameFormat
    format_string::String
    parts::Vector
end
function NameFormat(s::String)
    return NameFormat(s, parse(NameFormatParser(s)))
end
function format(self::NameFormat, name)
    local person = Person(name)
    return Base.join([format(part,person) for part in self.parts], "")
end
const enough_chars = 3

function tie_or_space(word, tie="~", space = " ")
    if bibtex_len(word) < enough_chars
        return tie
    else
        return space
    end
end

"""
```julia
function bst_join(words, tie="~", space=" ")
end
Join some words, inserting ties (~) when nessessary.
    Ties are inserted:
    - after the first word, if it is short
    - before the last word
    Otherwise space is inserted.
    Should produce the same oubput as BibTeX.
```jldoctest
julia> import BibTeXFormat.BST: bst_join

julia> print(bst_join(["a", "long", "long", "road"]))
a~long long~road

julia> print(bst_join(["very", "long", "phrase"]))
very long~phrase

julia> print(bst_join(["De", "La"]))
De~La
```
"""
function bst_join(words, tie="~", space=" ")
    if length(words) <= 2
        return Base.join(words, tie)
    else
        return string(words[1], tie_or_space(words[1], tie, space),              join(words[2:end-1], space), tie, words[end])
    end
end
function  format_name(name, fmt)
    return format(NameFormat(fmt), name)
end
mutable struct NameFormatParser <: Scanner
	text::String
	lineno::Integer
	pos::Integer
	end_pos::Integer
end

function NameFormatParser(text::String)
	return NameFormatParser(text,1,1, length(text))
end
function parse(s::NameFormatParser)
    local results = []
    while true
        try
            result = parse_toplevel(s)
            push!(results,result)
        catch e
            if e==:EOF
                break
            end
            rethrow(e)
        end
    end
    return results
end
function parse_toplevel(self::NameFormatParser)
    token = required(self, [NamePatterns.TEXT, NamePatterns.LBRACE, NamePatterns.RBRACE], allow_eof=true)
    if token[2] == NamePatterns.TEXT
        return string(token[1])
    elseif token[2] == NamePatterns.LBRACE
        return NamePart(parse_name_part(self))
    elseif token[2] == NamePatterns.RBRACE
        throw(:UnbalancedBraceError)
    end
end

function parse_braced_string(self::NameFormatParser)
    local tokens = []
	local token = nothing
    while true
        try
            token = required(self, [NamePatterns.TEXT, NamePatterns.RBRACE, NamePatterns.LBRACE])
        catch e
            if e==:PrematureEOF
                throw(:UnbalancedBraceError)
            end
        end
        if token[2] == NamePatterns.TEXT
            push!(tokens, token[1])
        elseif token[2] == NamePatterns.RBRACE
            break
        elseif token[2] == NamePatterns.LBRACE
            local v = Base.join(parse_braced_string(self), "")
            push!(tokens, "{$v}")
        else
            throw(:ValueError, token)
        end
    end
    return tokens
end
function parse_name_part(self::NameFormatParser)
    local verbatim_prefix = []
    local format_chars = nothing
    local verbatim_postfix = []
    local verbatim = verbatim_prefix
    local delimiter = nothing

    function  check_format_chars(self, value)
        value = lowercase(value)
        if format_chars != nothing || (length(value) != 1 && length(value) != 2) || value[1] != value[end] ||  !contains("flvj",string(value[1]))
#            throw(:PybtexSyntaxError, "name format string "$(self.text)" has illegal brace-level-1 letters: $(token[1])")
        end
    end
    local token =nothing
    while true
        try
            token = required(self, [NamePatterns.LBRACE, NamePatterns.NON_LETTERS, NamePatterns.FORMAT_CHARS, NamePatterns.RBRACE])
        catch e
            if e == :PrematureEOF
                throw(:UnbalancedBraceError)
            end
            rethrow(e)
        end
        if token[2] == NamePatterns.LBRACE
            local b  = Base.join(parse_braced_string(self), "")
            push!(verbatim, "{$b}")
        elseif token[2] == NamePatterns.FORMAT_CHARS
            check_format_chars(self, token[1])
            format_chars = token[1]
            verbatim = verbatim_postfix
            if optional(self, [NamePatterns.LBRACE]) != nothing
                delimiter = join(parse_braced_string(self), "")
            end
        elseif token[2] == NamePatterns.NON_LETTERS
            push!(verbatim, token[1])
        elseif token[2] == NamePatterns.RBRACE
            return (join(verbatim_prefix, ""), format_chars, delimiter, join(verbatim_postfix, ""))
        else
            throw(:ValueError, token)
        end
    end
end

function eat_whitespace(self::NameFormatParser)
end
