
const terminators = ['.', '?', '!']
const delimiter_re = r"([\s\-])"
const whitespace_re = r"\s+"
"""
Split a text keep the separators
```jldoctest
julia> import BibTeXStyle.split_keep_separator

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
julia> import BibTeXStyle.abbreviate

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
