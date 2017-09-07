
"""
Split a list of names, separated by ' and '.

>>> split_name_list('Johnson and Peterson')
[u'Johnson', u'Peterson']
>>> split_name_list('Johnson AND Peterson')
[u'Johnson', u'Peterson']
>>> split_name_list('Johnson AnD Peterson')
[u'Johnson', u'Peterson']
>>> split_name_list('Armand and Peterson')
[u'Armand', u'Peterson']
>>> split_name_list('Armand and anderssen')
[u'Armand', u'anderssen']
>>> split_name_list('{Armand and Anderssen}')
[u'{Armand and Anderssen}']
>>> split_name_list('What a Strange{ }and Bizzare Name! and Peterson')
[u'What a Strange{ }and Bizzare Name!', u'Peterson']
>>> split_name_list('What a Strange and{ }Bizzare Name! and Peterson')
[u'What a Strange and{ }Bizzare Name!', u'Peterson']
"""
function split_name_list(string)
    return split_tex_string(string, " [Aa][Nn][Dd] ")
end

"""Split a string using the given separator (regexp).

    Everything at brace level > 0 is ignored.
    Separators at the edges of the string are ignored.

    >>> split_tex_string('')
    []
    >>> split_tex_string('     ')
    []
    >>> split_tex_string('   ', ' ', strip=False, filter_empty=False)
    [u' ', u' ']
    >>> split_tex_string('.a.b.c.', r'\.')
    [u'.a', u'b', u'c.']
    >>> split_tex_string('.a.b.c.{d.}.', r'\.')
    [u'.a', u'b', u'c', u'{d.}.']
    >>> split_tex_string('Matsui      Fuuka')
    [u'Matsui', u'Fuuka']
    >>> split_tex_string('{Matsui      Fuuka}')
    [u'{Matsui      Fuuka}']
    >>> split_tex_string(r'Matsui\ Fuuka')
    [u'Matsui', u'Fuuka']
    >>> split_tex_string('{Matsui\ Fuuka}')
    [u'{Matsui\\ Fuuka}']
    >>> split_tex_string('a')
    [u'a']
    >>> split_tex_string('on a')
    [u'on', u'a']
"""
function split_tex_string(sstring, sep=nothing, strip=true, filter_empty=false)

    if sep  == nothing
        # "\ " is a "control space" in TeX,
        # i. e. "a space that is not to be ignored"
        # The TeXbook, Chapter 3: Controlling TeX, p 8
        sep = "(\\ |[\s~])+"
        filter_empty = true
    end

    sep_re = Regex(string("^", sep))
    brace_level = 0
    name_start = 1
    result = []
    string_len = length(sstring)
    pos = 1
    for (pos, char) in enumerate(sstring)
        if char == '{'
            brace_level += 1
        elseif char == '}'
            brace_level -= 1
        elseif brace_level == 0 && pos > 1
            m = match(sep_re,sstring[pos:end])
            if m != nothing
                sep_len = length(m.match)
                if pos + sep_len  < string_len
                    push!(result,sstring[name_start:pos-1])
                    name_start = pos + sep_len
                end
            end
        end
    end
    if name_start < string_len
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
