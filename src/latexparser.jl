
raw"""
```jldoctest
julia> latex_parse("abc")
Text('abc')

julia> latex_parse("abc{def}")
Text('abc', Protected('def'))

julia> latex_parse("abc{def {xyz}} !")
Text('abc', Protected('def ', Protected('xyz')), ' !')

julia> latex_parse("abc{def}}")

julia> latex_parse("abc{def}{")
```
"""
function latex_parse(str)
    return iter_string_parts(str)
end
function simplify_latex(str)
    return str
end
function iter_string_parts(str)
    parts = Any[RichText("")]
    tokens  = collect(m.match for m in eachmatch(r"[^\s\"#{}@,=\\]+|\s+|\"|#|{|}|@|,|=|\\\\", str))
    i = 1
    e = 1
    bb = []
    level = 0
    while i <= length(tokens)
	offset = tokens[i].offset+1
	endof  = tokens[i].offset+ lastindex(tokens[i])
	strtoken = str[offset:endof]
	if (String(strtoken)=="{")
	    level = level +1
	    if e<i
                append!(parts[end], RichString(simplify_latex(Base.join(tokens[e:i-1],""))))
	    end
	    e=i+1
	    protected = Protected("")
	    push!(parts[end].parts, protected)
	    push!(parts, protected)
	elseif (String(strtoken)=="}")
	    level = level -1
	    if e<i
                append!(parts[end], RichString(simplify_latex(Base.join(tokens[e:i-1],""))))
	    end
	    pop!(parts)
	    e=i+1
	end
	i=i+1
    end
    if level != 0
	throw("Unbalanced brackets")
    end
    if tokens[end] != "}"
        append!(parts[end], RichText([String(t) for t in tokens[e:end]]...))
    end
    return RichText(unpack(parts[1])...)
end
