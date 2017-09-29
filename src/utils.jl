"""

Split a list of names, separated by ' and '.
```jldoctest
julia> import BibTeXFormat.split_name_list

julia> split_name_list("Johnson and Peterson")
2-element Array{String,1}:
 "Johnson"
 "Peterson"

julia> split_name_list("Johnson AND Peterson")
2-element Array{String,1}:
 "Johnson"
 "Peterson"

julia> split_name_list("Johnson AnD Peterson")
2-element Array{String,1}:
 "Johnson"
 "Peterson"

julia> split_name_list("Armand and Peterson")
2-element Array{String,1}:
 "Armand"
 "Peterson"

julia> split_name_list("Armand and anderssen")
2-element Array{String,1}:
 "Armand"
 "anderssen"

julia> split_name_list("{Armand and Anderssen}")
1-element Array{String,1}:
 "{Armand and Anderssen}"

julia> split_name_list("What a Strange{ }and Bizzare Name! and Peterson")
2-element Array{String,1}:
 "What a Strange{ }and Bizzare Name!"
 "Peterson"

julia> split_name_list("What a Strange and{ }Bizzare Name! and Peterson")
2-element Array{String,1}:
 "What a Strange and{ }Bizzare Name!"
 "Peterson"
```
"""
function split_name_list(string)
    return split_tex_string(string, " [Aa][Nn][Dd] ")
end

"""
Split a string using the given separator (regexp).

Everything at brace level > 0 is ignored.
Separators at the edges of the string are ignored.

```jldoctest
julia> import BibTeXFormat.split_tex_string

julia> split_tex_string("")
0-element Array{Any,1}

julia> split_tex_string("     ")
0-element Array{String,1}

julia> split_tex_string("   ", " ", strip=false, filter_empty=false)
2-element Array{Any,1}:
 " "
 " "

julia> split_tex_string(".a.b.c.", r"\\.")
3-element Array{String,1}:
 ".a"
 "b"
 "c."

julia> split_tex_string(".a.b.c.{d.}.", r"\\.")
4-element Array{String,1}:
 ".a"
 "b"
 "c"
 "{d.}."

julia> split_tex_string("Matsui      Fuuka")
2-element Array{String,1}:
 "Matsui"
 "Fuuka"

julia> split_tex_string("{Matsui      Fuuka}")
1-element Array{String,1}:
 "{Matsui      Fuuka}"

julia> split_tex_string(r"Matsui\ Fuuka")
2-element Array{String,1}:
 "Matsui"
 "Fuuka"

julia> split_tex_string("{Matsui\ Fuuka}")
1-element Array{String,1}:
 "{Matsui\ Fuuka}"

julia> split_tex_string("a")
1-element Array{String,1}:
 "a"

julia> split_tex_string("on a")
2-element Array{String,1}:
 "on"
 "a"

```
"""
function split_tex_string(sstring, sep=nothing; strip=true, filter_empty=false)

    if sep  == nothing
        # "\ " is a "control space" in TeX,
        # i. e. "a space that is not to be ignored"
        # The TeXbook, Chapter 3: Controlling TeX, p 8
        sep = r"(\\ |[\s~])+"
        filter_empty = true
    end
	if isa(sep, Regex)
		sep = sep.pattern
	end
	local sep_re      = Regex(string("^", sep))
    local brace_level = 0
    local name_start  = 1
    local result      = []
    local string_len  = length(sstring)
    local pos         = 1
    for (pos, char) in enumerate(sstring)
        if char == '{'
            brace_level += 1
        elseif char == '}'
            brace_level -= 1
        elseif brace_level == 0 && pos > 1
            m = match(sep_re,sstring[pos:end])
            if m != nothing
                sep_len = length(m.match)
                if pos + sep_len  <= string_len
                    push!(result,sstring[name_start:pos-1])
                    name_start = pos + sep_len
                end
            end
        end
    end
    if name_start <= string_len
        push!(result,sstring[name_start:end])
    end
    if strip
        result = [Base.strip(part) for part in result]
    end
    if filter_empty
        result = [part for part in result if length(part)>0]
    end
    return result
end
function split_tex_string(sstring::Regex, sep=nothing; strip=true, filter_empty=false)
	return split_tex_string(sstring.pattern,sep,strip=strip,filter_empty=filter_empty)
end

mutable struct StringIterator
    str::String
    pos::Integer
end
function StringIterator(s::String)
    return StringIterator(s,start(s))
end
import Base.next
import Base.done
function done(self::StringIterator)
    return done(self.str, self.pos)
end
function next(self::StringIterator)
    (elem, self.pos) = next(self.str, self.pos)
    return elem
end
mutable struct BibTeXString
	level::Integer
	is_closed::Bool
	contents::Vector
end

function BibTeXString(chars, level::Integer=0, max_level::Integer=100)
	return BibTeXString(string(chars), level, max_level)
end
function BibTeXString(chars::String, level::Integer=0, max_level::Integer=100)
    return BibTeXString(StringIterator(chars), level, max_level)
end
import Base.string
function string(a::BibTeXString)
    return Base.join(traverse(a, open=x->'{', close=x->'}'), "")
end
"""
```jldoctest
julia> import BibTeXFormat: BibTeXString

julia> a = BibTeXString("{aaaa{bbbb{cccc{dddd}}}ffff}");

julia> convert(String,a ) == "{aaaa{bbbb{cccc{dddd}}}ffff}"
true
```
"""
function BibTeXString(chars::StringIterator, level::Integer=0, max_level::Integer=100)
	if level > max_level
		throw("too many nested braces")
	end
    local bibs =  BibTeXString(level,false,[])
    bibs.contents = find_closing_brace(bibs,chars, level)
    return bibs
end
import Base.convert
function convert(::Type{String}, s::BibTeXString)
    output = ""
    if s.level > 0
        output="{"
    end
    for c in s.contents
        if isa(c,Char)
            output=string(output, string(c))
        else
            output = string(output,convert(String,c))
        end
    end
    if s.level > 0
        output = string(output, "}")
    end
    return output
end
function find_closing_brace(self::BibTeXString, chars::StringIterator,  level)
	bibtex_strings = []
    while !done(chars)
        local char = next(chars)
		if char == '{'
            push!(bibtex_strings,BibTeXString(chars,  self.level + 1))
		elseif char == '}' && level > 0
			self.is_closed = true
			return bibtex_strings
		else
			push!(bibtex_strings,char)
		end
	end
	return bibtex_strings
end

function is_special_char(self::BibTeXString)
    return self.level == 1 && length(self.contents)>0 && self.contents[1] == '\\'
end

function traverse(self::BibTeXString; open=nothing, f=(x,y)->x, close=nothing)
	t = []
	if open != nothing && self.level > 0
		push!(t,open(self))
	end
	for child in self.contents
		if isa(child,BibTeXString)
			if is_special_char(child)
				if open!=nothing
					push!(t,open(child))
				end
				push!(t, f(inner_string(child), child))
				if close != nothing
					push!(t,close(child))
				end
			else
				for result in traverse(child,open=open, f=f, close=close)
					push!(t, result)
				end
			end
		else
			push!(t,f(child, self))
		end
	end

	if close !=nothing && self.level > 0 && self.is_closed
		push!(t, close(self))
	end
	return t
end

#=def __str__(self):
	return ''.join(self.traverse(open=lambda string: '{', close=lambda string: '}'))=#

function inner_string(self::BibTeXString)
    return   Base.join([string(child) for child in self.contents], "")
end

""" Yield (char, brace_level) tuples.

"Special characters", as in bibtex_len, are treated as a single character

"""
function scan_bibtex_string(string)
    return traverse(BibTeXString(string);
        open=s-> ('{', s.level),
        f=(c,s)->(c, s.level),
        close=s-> ('}', s.level - 1),
    )
end

# Text utils

const terminators = ['.', '?', '!']
const delimiter_re = r"([\s\-])"
const whitespace_re = r"\s+"
"""
Split a text keep the separators
```jldoctest
julia> import BibTeXFormat.split_keep_separator

julia> split_keep_separator("Some words-words")
5-element Array{Any,1}:
 "Some"
 ' '
 "words"
 '-'
 "words"

```
"""
function split_keep_separator(s::String, sep=delimiter_re)
    local output = []
    local start = 1
    for m in eachmatch(sep,s)
        push!(output,s[start:m.offset-1])
        push!(output,s[m.offset])
        start = m.offset + 1
    end
    push!(output, s[start:end])
    return output
end
"""
Abbreviate the given text.
```jldoctest
julia> import BibTeXFormat.abbreviate

julia> abbreviate("Name")
"N."

julia> abbreviate("Some words")
"S. w."

julia> abbreviate("First-Second")
"F.-S."

```
"""
function abbreviate(text, split_re=delimiter_re)
	function abbreviate(part)
        if all(isalpha,part)
            return string(part[1], '.')
        else
            return part
		end
	end
    return Base.join([abbreviate(part) for part in split_keep_separator(text,split_re)], "")
end

import Base.replace
function replace(c::Char, r::Regex, s::String)
	replace(string(c),r,s)
end
import Base.startswith
function startswith(c::Char,b::Char)
	return c==b
end
const purify_special_char_re = r"^\\[A-Za-z]+"
doc"""
```julia
function bibtex_purify(str)
```
Strip special characters from the string.
```jldoctest
julia> import BibTeXFormat: bibtex_purify

julia> print(bibtex_purify("Abc 1234"))
Abc 1234
julia> print(bibtex_purify("Abc  1234"))
Abc  1234
julia> print(bibtex_purify("Abc-Def"))
Abc Def
julia> print(bibtex_purify("Abc-~-Def"))
Abc   Def
julia> print(bibtex_purify("{XXX YYY}"))
XXX YYY
julia> print(bibtex_purify("{XXX {YYY}}"))
XXX YYY
julia> print(bibtex_purify("XXX {\\YYY} XXX"))
XXX  XXX
julia> print(bibtex_purify("{XXX {\\YYY} XXX}"))
XXX YYY XXX
julia> print(bibtex_purify("\\abc def"))
abc def
julia> print(bibtex_purify("a@#\$@#\$b@#\$@#\$c"))
abc
julia> print(bibtex_purify("{\\noopsort{1973b}}1973"))
1973b1973
julia> print(bibtex_purify("{sort{1973b}}1973"))
sort1973b1973
julia> print(bibtex_purify("{sort{\\abc1973b}}1973"))
sortabc1973b1973
julia> print(bibtex_purify("{\\noopsort{1973a}}{\\switchargs{--90}{1968}}"))
1973a901968
```
"""
function bibtex_purify(str)

    # FIXME BibTeX treats some accented and foreign characterss specially
    function purify_iter(str)
		local chars = []
        for (token, brace_level) in scan_bibtex_string(str)
			b = brace_level ==  1
            b = b && startswith(token, '\\')
			if (b)
                for char in replace(token, purify_special_char_re, "")
    	            if isalnum(char)
        	            push!(chars, char)
					end
				end
            else
                if isalnum(token)
                   push!(chars, token)
                elseif (isspace(token)) || (isa(token,Char) && (contains("-~", string(token))) || contains("-~", string(token)))
                    push!(chars, " ")
				end
			end
		end
		return chars
	end
    return Base.join(purify_iter(str),"")
end
doc"""
```julia
function change_case(string, mode)
```
```
julia> import BibTeXFormat: change_case

julia> print(change_case("aBcD", 'l'))
abcd
julia> print(change_case("aBcD", 'u'))
ABCD
julia> print(change_case("ABcD", 't'))
Abcd
julia> change_case("The {\\TeX book \\noop}", 'u')
"THE {\\TeX BOOK \\noop}"

julia> change_case("And Now: BOOO!!!", 't')
"And now: Booo!!!"

julia> change_case("And {Now: BOOO!!!}", 't')
"And {Now: BOOO!!!}"

julia> change_case("And {Now: {BOOO}!!!}", 'l')
"and {Now: {BOOO}!!!}"

julia> change_case("And {\\Now: BOOO!!!}", 't')
"And {\\Now: booo!!!}"

julia> change_case("And {\\Now: {BOOO}!!!}", 'l')
"and {\\Now: {booo}!!!}"

julia> change_case("{\\TeX\\ and databases\\Dash\\TeX DBI}", 't')
"{\\TeX\\ and databases\\Dash\\TeX DBI}"

```
"""
function change_case(string::String, mode::Char)
    function title(char, state)
        if state == "start"
            return char
        else
            return lowercase(char)
		end
	end
    lower = (char,state)-> lowercase(char)
    upper = (char,state)-> uppercase(char)

    convert = Dict{Char, Function}(['l'=> lower,
                                    'u'=> upper,
                                    't'=> title])[mode]

    function convert_special_char(special_char, state)
        # FIXME BibTeX treats some accented and foreign characterss specially
        function convert_words(words)
			local w = []
            for word in words
                if startswith(word, '\\')
                    push!(w,word)
                else
                    push!(w,convert(word, state))
				end
			end
			return w
		end
        return Base.join(convert_words(split(special_char," ")), " ")
	end

    function change_case_iter(string, mode)
		local chars = []
        local state = "start"
        for (char, brace_level) in scan_bibtex_string(string)
            if brace_level == 0
                push!(chars, convert(char, state))
                if char == ':'
                    state = "after colon"
                elseif isspace(char) && state == "after colon"
                    state = "start"
                else
                    state = "normal"
				end
            else
                if brace_level == 1 && startswith(char, '\\')
                    push!(chars, convert_special_char(char, state))
                else
                    push!(chars,  char)
				end
			end
		end
		return chars
	end

    return Base.join(change_case_iter(string, mode), "")
end

"""
```
function bibtex_substring(string, start, length)
```
Return a substring of the given length, starting from the given position.

start and length are 1-based. If start is < 0, it is counted from the end
of the string. If start is 0, an empty string is returned.

```jldoctest
julia> import BibTeXFormat: bibtex_substring

julia> print(bibtex_substring("abcdef", 1, 3))
abc
julia> print(bibtex_substring("abcdef", 2, 3))
bcd
julia> print(bibtex_substring("abcdef", 2, 1000))
bcdef
julia> print(bibtex_substring("abcdef", 0, 1000))

julia> print(bibtex_substring("abcdef", -1, 1))
f
julia> print(bibtex_substring("abcdef", -1, 2))
ef
julia> print(bibtex_substring("abcdef", -2, 3))
cde
julia> print(bibtex_substring("abcdef", -2, 1000))
abcde
```
"""
function bibtex_substring(string, start, len)
    if start > 0
        start0 = start
        end0 = Base.min(start0 + len - 1, length(string))
    elseif start < 0
        end0 = length(string) + start + 1
        start0 = max(1,end0 - len + 1)
    else # start == 0:
        return ""
	end
    return string[start0:end0]
end

doc"""
Return the number of characters in the string.
```
function bibtex_len(string)
```

Braces are ignored. "Special characters" are ignored. A "special character"
is a substring at brace level 1, if the first character after the opening
brace is a backslash, like in "de la Vall{\'e}e Poussin".
```jldoctest
julia> import BibTeXFormat: bibtex_len

julia> print(bibtex_len("de la Vall{\\'e}e Poussin"))
20
julia> print(bibtex_len("de la Vall{e}e Poussin"))
20
julia> print(bibtex_len("de la Vallee Poussin"))
20
julia> print(bibtex_len("\\ABC 123"))
8
julia> print(bibtex_len("{\\abc}"))
1
julia> print(bibtex_len("{\\abc"))
1
julia> print(bibtex_len("}\\abc"))
4
julia> print(bibtex_len("\\abc}"))
4
julia> print(bibtex_len("\\abc{"))
4
julia> print(bibtex_len("level 0 {1 {2}}"))
11
julia> print(bibtex_len("level 0 {\\1 {2}}"))
9
julia> print(bibtex_len("level 0 {1 {\\2}}"))
12
```
"""
function bibtex_len(string)
    local length = 0
    for (char, brace_level) in scan_bibtex_string(string)
        if char != '{' && char != '}'
            length += 1
		end
	end
    return length
end

doc"""
```julia
function  bibtex_first_letter(string)
```
Return the first letter or special character of the string.
```jldoctest
julia> import BibTeXFormat: bibtex_first_letter

julia> print(bibtex_first_letter("Andrew Blake"))
A
julia> print(bibtex_first_letter("{Andrew} Blake"))
A
julia> print(bibtex_first_letter("1Andrew"))
A
julia> print(bibtex_first_letter("{\\TeX} markup"))
{\TeX}
julia> print(bibtex_first_letter(""))

julia> print(bibtex_first_letter("123 123 123 {}"))

julia> print(bibtex_first_letter("\\LaTeX Project Team"))
L
```
"""
function  bibtex_first_letter(str)
    for char in traverse(BibTeXString(str))
		b = string(char)
        if startswith(b,"\\") && b != "\\"
            return "{$char}"
        elseif isalpha(char)
            return char
		end
	end
    return ""
end

"""
```julia
function bibtex_abbreviate(string, delimiter=None, separator='-')
```
Abbreviate string.
```jldoctest
julia> import BibTeXFormat: bibtex_abbreviate

julia> print(bibtex_abbreviate("Andrew Blake"))
A
julia> print(bibtex_abbreviate("Jean-Pierre"))
J.-P
julia> print(bibtex_abbreviate("Jean--Pierre"))
J.-P
```
"""
function bibtex_abbreviate(string, delimiter=nothing, separator='-')
    function _bibtex_abbreviate()
		local letters = []
        for token in split_tex_string(string, separator)
            letter = bibtex_first_letter(token)
            if length(letter) != 0
                push!(letters, letter)
			end
		end
		return letters
	end

    if delimiter ==nothing
        delimiter = ".-"
	end
    return Base.join(_bibtex_abbreviate(), delimiter)
end
