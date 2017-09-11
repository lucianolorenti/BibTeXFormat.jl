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

function Base.getindex(n::Node, children...)
	result = clone(n)
    if isa(children, Array) || isa(children, Tuple)
        append!(result.children,children)
    else
        push!(result.children,children)
	end
    return result
end
#="""
>>> join(', ')
join(u', ')
>>> join
join
>>> join ['a']
join [u'a']
>>> join ['a', 'b', 'c']
join [u'a', u'b', u'c']
>>> join(' ') [u'a', u'b', u'c']
join(u' ') [u'a', u'b', u'c']
>>> join(sep=' ') [u'a', u'b', u'c']
join(sep=u' ') [u'a', u'b', u'c']
join(sep=u' ') [tag(u'em') [u'a', u'b', u'c']]

"""
function Base.show(io, n::Node)
	local params = []
	local args_repr = join([show(io,arg) for arg in n.args],", ")
	if length(args_repr)>0
		append!(params,args_repr)
	end
	local kwargs_repr = join(
		["$key=$(repr(value))" for (key, value) in n.kwargs], ", ")
	if length(kwargs_repr)> 0
		append!(params,kwargs_repr)
	end
	if length(params)>0
		params_repr = string("(", Base.join(params, ", "), ")")
	else
		params_repr = ""
	end

	if length(n.children)>0
		children_repr = string("[", Base.join([show(io,child) for child in n.children] ,"]"))
	else
		children_repr = ""
	end
	show(io,join([self.name,params_repr, children_repr],""))
end
function Base.Multimedia.display(n::Node)
	local s =""
	show(s,n)
	return s
end=#

"""
Format the given data into a piece of richtext.Text
"""
function format_data(n::Node, data)
	return n.f(n.children, data, n.args...;n.kwargs...)
end

"""
A convenience function to be used instead of format_data
when no data is needed.
"""
function format(n::Node)
	return format_data(n,nothing)
end

function  _format_list(list_, data)
    return vcat([_format_data(part, data) for part in list_])
end

function _format_data(node::Node, data)
    return format_data(node,data)
end
function _format_data(n::Array,data)
    return _format_list(n,data)
end
function tie_or_space(word, tie="~", space=" ", enough_chars=3, other_word=nothing)
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
#="""Join text fragments together.
>>> print(six.text_type(join.format()))
<BLANKLINE>
>>> print(six.text_type(join ['a', 'b', 'c', 'd', 'e'].format()))
abcde
>>> format(join(sep=", ", sep2=" and ", last_sep=", and ")["Tom", "Jerry"])
Tom and Jerry
>>> format(join(sep=", ", sep2=" and ", last_sep=", and ")["Billy", "Willy", "Dilly"])
Billy, Willy, and Dilly
"""
=#
@node  function join(children, data; sep=" ", sep2=nothing, last_sep=nothing)
	local lsep = sep
	local lsep2 = sep2
	local llast_sep = last_sep
	if sep2 == nothing
		lsep2 = sep
	end
	if last_sep == nothing
		llast_sep = sep
	end
    parts = [part for part in _format_list(children, data) if !isempty(part)]
    if length(parts) <= 1
        return RichText(parts...)
    elseif length(parts) == 2
        return join(RichText(sep2),parts)
    else
        return join(RichText(last_sep),[join(RichText(sep),parts[1:end-1]), parts[end]])
	end
end

#"""Join text fragments with spaces or something else."""
@node function words(children, data; sep= ' ')
	return join(sep)[children].format_data(data)
end

#="""
Try to keep words together, like BibTeX does.

"""=#
@node function together(children, data; last_tie=false)
    local tie   = nbsp
    local space = " "
	local tie2  = nothing
    local parts = [part for part in _format_list(children, data) if !isempty(part)]
    if length(parts)==0
        return ""
	end
    if length(parts) <= 2
		if last_tie
			tie2 = tie
		else
			tie2 = tie_or_space(parts[1], tie, space, other_word=parts[end])
		end
		return Base.join(parts, tie2)
    else
        local llast_tie = nothing
		if last_tie
			llast_tie = tie
		else
			llast_tie = tie_or_space(parts[end], tie, space)
		end
        return Base.join([ parts[1], tie_or_space(parts[1], tie, space),
			Base.join(parts[2:end-1], space), llast_tie, parts[end] ],"")

	end
end
#=
using Base.Test
@testset "TogetherNode" begin
	@test format(together["very", "long", "road"]) == "very long road"
	@test format(together(last_tie=true)["very", "long", "road"]) =="very long<nbsp>road"
end=#
#=
>>> print(six.text_type(together ['a', 'very', 'long', 'road'].format()))
a<nbsp>very long road
>>> print(six.text_type(together ['chapter', '8'].format()))
chapter<nbsp>8
>>> print(six.text_type(together ['chapter', '666'].format()))
chapter 666=#

#="""
Join text fragments, capitalyze the first letter, add a period to the end.

    >>> print(six.text_type(sentence.format()))
    <BLANKLINE>
    >>> print(six.text_type(sentence(capitalize=True, sep=' ') ['mary', 'had', 'a', 'little', 'lamb'].format()))
    Mary had a little lamb.
    >>> print(six.text_type(sentence(capitalize=False, add_period=False) ['uno', 'dos', 'tres'].format()))
    uno, dos, tres

"""=#
@node function sentence(children, data; capfirst=false, capitalize=false, add_period=true, sep=", ")

    local text = format_data(join(;sep=sep)[children],data)
    if capfirst
        text = capfirst(text)
    end
    if capitalize
        text = capitalize(text)
    end
    if add_period
        text = add_period(text, text)
    end
    return text
end
#=
class FieldIsMissing(PybtexError):
    def __init__(self, field_name, entry):
        self.field_name = field_name
        super(FieldIsMissing, self).__init__(
            u'missing {0} in {1}'.format(field_name, getattr(entry, 'key', '<unnamed>'))
        )
end
=#
#="""
Return the contents of the bibliography entry field.
"""=#
@node function field(children, context, name; apply_func=nothing, raw=false)

    assert(length(children)==0)
    entry = context["entry"]
    try
        local field = nothing
        if raw
            field = entry.fields[name]
        else
            field = entry.rich_fields[name]
        end
        if apply_func
            field = apply_func(field)
        end
        return field
    catch e
        throw((name, entry))
    end
end

#="""
Return formatted names.
"""=#
@node function  names(children, context, role;kwargs...)

    assert(length(children)==0)
    local persons = nothing
    try
        persons = context["entry"]["persons"][role]
    catch e
        throw((role, context["entry"]))
    end

    local style = context["style"]
    formatted_names = [format(style.config.name_style,person, style.config.abbreviate_names) for person in persons]
    return format_data(join(kwargs...)[formatted_names],context)
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
        return MultiPartText(_format_list(children, data)...)
    catch e
        return MultiPartText()
    end
end
@node function optional_field(children, data, args...;kwargs...)
    assert(length(children)==0)
    return format_data(optional[field(args, kwargs)],data)
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
    return format_data(join(sep=TextSymbol("newblock"))[children],data)
end
