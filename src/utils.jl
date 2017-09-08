
"""

Split a list of names, separated by ' and '.
```jldoctest
julia> import BibTeXStyle.split_name_list

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
julia> import BibTeXStyle.split_tex_string

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
struct BibTeXString
	level::Integer
	is_closed::Bool
	contents::Vector
end
function BibTeXString(chars, level=0, max_level=100)
	if level > max_level
		throw("too many nested braces")
	end
	return BibTeXString(level,false,find_closing_brace(chars))
end

function find_closing_brace( chars)
	bibtex_strings = []
	for char in chars
		if char == '{'
			push!(bibtex_strings,BibTeXString(chars, self.level + 1))
		elseif char == '}' && self.level > 0
			self.is_closed = true
			return
		else
			push!(bibtex_strings,char)
		end
	end
	return bibtex_strings
end

function is_special_char(self::BibTeXString)
	return self.level == 1 && self.contents && self.contents[1] == '\\'
end

function traverse(self::BibTeXString; open=nothing, f=Function, close=nothing)
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
				for result in traverse(child,open, f, close)
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
	return join([six.text_type(child) for child in self.contents], "")
end

""" Yield (char, brace_level) tuples.

"Special characters", as in bibtex_len, are treated as a single character

"""
function scan_bibtex_string(string)
    return traverse(BibTeXString(string),
        open=s-> ('{', s.level),
        f=(c,s)->(c, s.level),
        close=s-> ('}', s.level - 1),
    )
end
