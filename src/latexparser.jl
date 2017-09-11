
"""
>>> from nose.tools import assert_raises
i
>>> LaTeXParser('abc').parse()
Text('abc')

>>> LaTeXParser('abc{def}').parse()
Text('abc', Protected('def'))

>>> LaTeXParser('abc{def {xyz}} !').parse()
Text('abc', Protected('def ', Protected('xyz')), ' !')

>>> assert_raises(PybtexSyntaxError, LaTeXParser('abc{def}}').parse)
>>> assert_raises(PybtexSyntaxError, LaTeXParser('abc{def}{').parse)
"""
function latex_parse(str, level=0)
	return RichText(iter_string_parts(level)...)
end

function iter_string_parts(str, level=0)
	parts = Any[RichText("")]
	tokens  = matchall(r"[^\s\"#{}@,=\\]+|\s+|\"|#|{|}|@|,|=|\\", str)
	i = 1
	e = 1
	bb = []
	level = 0
	while i <= length(tokens)
		offset = tokens[i].offset+1
		endof  = tokens[i].offset+ tokens[i].endof
		strtoken = str[offset:endof]
		println(strtoken)
		println(e, " ", i)
		if (String(strtoken)=="{")
			level = level +1
			if e<i
				 push!(parts[end].parts, RichText(join(tokens[e:i-1],"")))
			end
			e=i+1
			protected = Protected("")
			push!(parts[end].parts, protected)
			push!(parts, protected)
		elseif (String(strtoken)=="}")
			level = level -1
			if e<i
				 push!(parts[end].parts, RichText(join(tokens[e:i-1],"")))
			end
			println(length(parts))
			pop!(parts)
			e=i+1
		end
		i=i+1
	end
	if level != 0
		throw("Unbalanced brackets")
	end
	push!(parts[end].parts, RichText(String(tokens[end])))
	return parts[1]
end
