"""
A template engine for bibliography entries and more.

Inspired by BrevÃ© -- http://breve.twisty-industries.com/

>>> from pybtex.database import Entry, Person
>>> author = Person(first='First', last='Last', middle='Middle')
>>> fields = {
...         'title': 'The Book',
...         'year': '2000',
... }
>>> e = Entry('book', fields=fields)
>>> book_format = sentence(capfirst=True, sep=', ') [
...     field('title'), field('year'), optional [field('sdf')]
... ]
>>> print(six.text_type(book_format.format_data({'entry': e})))
The Book, 2000.
>>> print(six.text_type(words ['one', 'two', words ['three', 'four']].format_data(e)))
one two three four
"""

struct Node
	name::String
	f::Function
	args::Vector
	kwargs::Dict
	children::Vector
end
function Node(name::String, f::Function)
	return Node(name,f, [],Dict(),[])
end
function clone(n::Node)
	return Node(n.name, n.f, copy(n.args), copy(n.kwargs), copy(n.children))
end
function (n::Node)(args...;kwargs...)
	local result = clone(n)
	append!(result.args, args)
	for (k,v) in kwargs
		result.kwargs[k] = v
	end
    return result
end
macro node(func)
	name = func.args[1].args[1]
	hiddenname = gensym()
	func.args[1].args[1] = hiddenname
	quote
		$func
		$(esc(name)) = Node($(string(name)),$hiddenname)
	end
end

function Base.getindex(n::Node, childrens...)
	result = clone(n)
    for children in childrens
    if isa(children, Array) || isa(children, Tuple)
        append!(result.children,children)
    else
        push!(result.children,children)
	end
end
    return result
end

"""
Format the given data into a piece of richtext.Text
"""
function format_data(n::Node, data)
    local args = []
    if (data != nothing)
        push!(args, data)
    end
    append!(args, n.args)

    if (length(args)>0)
    	return n.f(n.children, args...;n.kwargs...)
    else
    	return n.f(n.children, nothing;n.kwargs...)
    end
end

"""
A convenience function to be used instead of format_data
when no data is needed.
"""
function format(n::Node)
	return format_data(n,nothing)
end

function  _format_list(list_, data)
    local formatted_list  =  [_format_data(part, data) for part in list_]
    return formatted_list
end

function _format_data(node::Node, data)
    return format_data(node,data)
end
function _format_data(n,data)
    return n
end
function tie_or_space(word, tie="~", space=" "; enough_chars=3, other_word=nothing)
    local n_chars = length(word)
    if other_word != nothing
        n_chars = min(n_chars, length(other_word))
	end
    if n_chars < enough_chars
        return tie
    else
        return space
	end
end

@node  function join(children, data; sep="", sep2=nothing, last_sep=nothing)
	local lsep =  sep
	local lsep2 = sep2
	local llast_sep = last_sep
	if sep2 == nothing
		lsep2 = sep
	end
	if last_sep == nothing
		llast_sep = sep
	end
    parts = [part for part in _format_list(children, data) if length(part)>0]
    if length(parts) == 0
        return RichText("")
    elseif length(parts) == 1
        return RichText(parts[1])
    elseif length(parts) == 2
        return Base.join(RichText(lsep2),parts)
    else
        return Base.join(RichText(llast_sep),[Base.join(RichText(lsep),parts[1:end-1]), parts[end]])
	end
end

#"""Join text fragments with spaces or something else."""
@node function words(children, data; sep= ' ')
    return format_data(join(;sep=sep)[children],data)
end

#="""
Try to keep words together, like BibTeX does.

"""=#
@node function together(children, data; last_tie=false)
    local tie   = nbsp
    local space = RichText(" ")
	local tie2  = nothing
	if length(children)>0
end
    local parts = [part for part in _format_list(children, data) if length(part)>0]
    if length(parts)==0
        return RichText("")
    elseif length(parts) <= 2
		if last_tie
			tie2 = tie
		else
			tie2 = tie_or_space(parts[1], tie, space, other_word=parts[end])
		end
		return Base.join(tie2,parts)
    else
        local llast_tie = nothing
		if last_tie
			llast_tie = tie
		else
			llast_tie = tie_or_space(parts[end], tie, space)
		end
        return RichText( parts[1], tie_or_space(parts[1], tie, space),
			Base.join(space, parts[2:end-1]), llast_tie, parts[end])

	end
end

#="""
Join text fragments, capitalyze the first letter, add a period to the end.

"""=#
@node function sentence(children, data; capfirst=false, capitalize=false, add_period=true, sep=", ")
    local text = format_data(join(;sep=sep)[children],data)
    if capfirst
        text = capfirst(text)
    end
    if capitalize
        text = BibTeXFormat.capitalize(text)
    end

    if add_period
        text = BibTeXFormat.add_period(text)
    end
    return text
end

struct FieldIsMissing
    field_name::String
end

#="""
Return the contents of the bibliography entry field.
"""=#
@node function field(children, ocontext, name; apply_func=nothing, raw=false)
    assert(length(children)==0)
    entry = ocontext["entry"]
    try
        local ff = nothing
        if raw
            ff = entry[name]
        else
            ff = latex_parse(entry[name])
        end
        if apply_func != nothing
            ff = apply_func(ff)
        end
        return ff
    catch e
        throw(FieldIsMissing(string("field: ",name)))
    end
end

#="""
Return formatted names.
"""=#
@node function names(children, context, role;kwargs...)
    assert(length(children)==0)
    local persons = nothing
    try
        persons = context["entry"]["persons"][role]
    catch e
        throw(FieldIsMissing(string("names:",role)))
    end
    local style = context["style"]
    formatted_names = [format(style.config.name_style,person, style.config.abbreviate_names) for person in persons]
    return format_data(join(;kwargs...)[formatted_names],context)
end

#="""If children contain a missing bibliography field, return None.
Else return formatted children.

>>> from pybtex.database import Entry
>>> template = optional [field('volume'), optional['(', field('number'), ')']]
>>> template.format_data({'entry': Entry('article')})
Text()

"""=#
@node function optional(children, data)
    try
        return RichText(_format_list(children, data)...)
    catch e
        return RichText("")
    end
end
@node function optional_field(children, data, args...;kwargs...)
    assert(length(children)==0)
    return format_data(optional[field(args..., kwargs...)],data)
end

#="""Wrap text into a tag.

>>> print(tag('em') ['important'].format().render_as('html'))
<em>important</em>
>>> print(sentence ['ready', 'set', tag('em') ['go']].format().render_as('html'))
ready, set, <em>go</em>.
>>> print(sentence(capitalize=True) ['ready', 'set', tag('em') ['go']].format().render_as('html'))
Ready, set, <em>go</em>.
"""=#
@node function  tag(children, data, name)

    parts = _format_list(children, data)
    return Tag(name, parts...)
end
#="""Wrap text into a href.

>>> print(href ['www.test.org', 'important'].format().render_as('html'))
<a href="www.test.org">important</a>
>>> print(sentence ['ready', 'set', href ['www.test.org', 'go']].format().render_as('html'))
ready, set, <a href="www.test.org">go</a>.
"""=#
@node function href(children, data)
    parts = _format_list(children, data)
    return HRef(parts...)
end

#"""Return first nonempty child."""
@node function first_of(children, data)
    for child in _format_list(children, data)
        if !isempty(child)
            return child
		end
	end
    return ""
end

@node function toplevel(children, data)
    return format_data(join(;sep=TextSymbol("newblock"))[children],data)
end
using Base.Test
@testset "RichTextElements" begin
	import BibTeXFormat: format, words, sentence, together
	@testset "join" begin
		@test convert(String, format(BibTeXFormat.join())) == ""
		@test convert(String, format(BibTeXFormat.join["a","b","c","d","e"])) == "abcde"
		@test convert(String, format(BibTeXFormat.join(sep=", ", sep2=" and ", last_sep=", and ")["Tom", "Jerry"])) == "Tom and Jerry"
		@test convert(String, format(BibTeXFormat.join(sep=", ", sep2=" and ", last_sep=", and ")["Billy", "Willy", "Dilly"])) == "Billy, Willy, and Dilly"
	end
	@testset "words" begin
        @test convert(String,format(words["Tom", "Jerry"])) == "Tom Jerry"
	end
	@testset "together" begin
		@test convert(String, format(together["very", "long", "road"])) == "very long road"
		@test convert(String,format(together(last_tie=true)["very", "long", "road"])) =="very long<nbsp>road"
		@test convert(String,format(together["a", "very", "long", "road"])) == "a<nbsp>very long road"
		@test convert(String,format(together["chapter", "8"])) == "chapter<nbsp>8"
		@test convert(String,format(together["chapter", "666"])) == "chapter 666"
	end
	@testset "sentence" begin
    	@test convert(String, format(sentence)) == ""
    	@test convert(String, format(sentence(capitalize=true, sep=" ")["mary", "had", "a", "little", "lamb"])) == "Mary had a little lamb."
		@test convert(String , format(sentence(capitalize=false, add_period=false)["uno", "dos", "tres"])) == "uno, dos, tres"
	end
end
