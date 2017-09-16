export AlphaStyle,
       format_entries
include("templateengine.jl")
include("names.jl")
include("labels.jl")
include("sorting.jl")
abstract type BaseStyle end
struct Config
 	name_style
	label_style
	sorting_style
	abbreviate_names::Bool
	min_crossrefs::Integer

        function Config(;name_style=PlainNameStyle(),
                        label_style=AlphaLabelStyle(),
                        sorting_style=AuthorYearTitleSortingStyle(),
                        abbreviate_names=false,
                        min_crossrefs=2)
		return new(name_style, label_style, sorting_style, abbreviate_names, min_crossrefs)
	end
end

function citation_type(t::Citation{T}) where {T}
    return T
end
function citation_type(e::Dict{String,Any})
    return e["type"]
end
function transform(e::Citation)
    local e_n = Dict{String,Any}()
    local e_n["persons"] = Dict{String,Vector{Person}}()
    for k in keys(e)
        e_n[k] = e[k]
    end
    e_n["type"] = citation_type(e)
    if haskey(e_n, "author")
        e_n["persons"]["author"] = [Person(p) for p in split_name_list(e["author"])]
    end
    pop!(e_n,"author")
    return e_n
end

"""
```
function format_entries(b::T, entries::Dict) where T <: BaseStyle
```
Format a Dict of `entries` with a given style `b::T where T <: BaseStyle`
```julia
using BibTeX
using BibTeXFormat
bibliography      = Bibliography(readstring("test/Clustering.bib"))
formatted_entries = format_entries(AlphaStyle,bibliography)
```
"""

function format_entries(b::T, entries) where T <: BaseStyle
    local transformed_entries = Dict()
    for k in keys(entries)
        transformed_entries[k] = transform(entries[k])
    end
    entries = transformed_entries
	local sorted_entries = sort(b.config.sorting_style, entries)
	local labels  = format_labels(b.config.label_style, sorted_entries)
    local formatted_entries = []
	for (label,entry) in zip(labels, sorted_entries)
        try
	    	push!(formatted_entries,format_entry(b,label, entry))
        catch  e
        end
	end
    return formatted_entries
end

"""
```
function format_entry(b::T, label, entry) where T <: BaseStyle
```

Format an `entry` with a given style `b::T where T <: BaseStyle`

"""
function format_entry(b::T, label, entry) where T<:BaseStyle
    entry["key"] = label
	local context = Dict{String,Any}("entry" => entry, "style"=>b)
    local text    = ""
	try
        get_template =  getfield(typeof(b).name.module, Symbol("get_$(entry["type"])_template"))
        text = format_data(get_template(b,entry),context)
	catch e
        format_method =  getfield(typeof(b).name.module, Symbol("format_$(entry["type"])"))
    	text = format_method(b,context)
	end
    return (entry["key"], text, label)
end

"""
```julia
function format_bibliography(self::T, bib_data, citations=nothing) where T<:BaseStyle
```
Format bibliography entries with the given keys and return a
`FormattedBibliography` object.

Params:
- `self::T where T<:BaseStyle`. The style
- `bib_data` A :py:class:`pybtex.database.BibliographyData` object.
- `param citations`: A list of citation keys.

```julia
using BibTeX
using BibTeXFormat
bibliography      = Bibliography(readstring("test/Clustering.bib"))

formatted_entries = format_entries(AlphaStyle,bibliography)
```
"""
function format_bibliography(self::T, bib_data, citations=nothing) where T<:BaseStyle
	if citations == nothing
		citations = keys(bib_data)
	end
	citations = bib_data.add_extra_citations(citations, self.min_crossrefs)
	entries = [bib_data.entries[key] for key in citations]
	formatted_entries = format_entries(self,entries)
	formatted_bibliography = FormattedBibliography(formatted_entries, style=self, preamble=bib_data.preamble)
	return formatted_bibliography
end

@fix_unicode_literals_in_doctest
def _expand_wildcard_citations(self, citations):
    """
    Expand wildcard citations (\citation{*} in .aux file).

    >>> from pybtex.database import Entry
    >>> data = BibliographyData((
    ...     ('uno', Entry('article')),
    ...     ('dos', Entry('article')),
    ...     ('tres', Entry('article')),
    ...     ('cuatro', Entry('article')),
    ... ))
    >>> list(data._expand_wildcard_citations([]))
    []
    >>> list(data._expand_wildcard_citations(['*']))
    [u'uno', u'dos', u'tres', u'cuatro']
    >>> list(data._expand_wildcard_citations(['uno', '*']))
    [u'uno', u'dos', u'tres', u'cuatro']
    >>> list(data._expand_wildcard_citations(['dos', '*']))
    [u'dos', u'uno', u'tres', u'cuatro']
    >>> list(data._expand_wildcard_citations(['*', 'uno']))
    [u'uno', u'dos', u'tres', u'cuatro']
    >>> list(data._expand_wildcard_citations(['*', 'DOS']))
    [u'uno', u'dos', u'tres', u'cuatro']

    """

    citation_set = CaseInsensitiveSet()
    for citation in citations:
        if citation == '*':
            for key in self.entries:
                if key not in citation_set:
                    citation_set.add(key)
                    yield key
        else:
            if citation not in citation_set:
                citation_set.add(citation)
                yield citation

def add_extra_citations(self, citations, min_crossrefs):
    expanded_citations = list(self._expand_wildcard_citations(citations))
    crossrefs = list(self._get_crossreferenced_citations(expanded_citations, min_crossrefs))
    return expanded_citations + crossrefs

"""
Expand wildcard citations (\citation{*} in .aux file).
´´´jldoctest
julia> using BibTeX

julia> data = Bibliography("", Dict{String,Citation}(
		"uno"=>Citation{:article}(),
		"dos"=>Citation{:article}(),
		"tres"=>Citation{:article}(),
		"cuatro"=>Citation{:article}()));

julia> expand_wildcard_citations(data, []
0-element Array{Any,1}

julia> print(expand_wildcard_citations(data, ["*"]))
Any["tres", "dos", "uno", "cuatro"]
julia> print(expand_wildcard_citations(data, ["uno", "*"]))
Any["uno", "dos", "tres", "cuatro"]
julia> print(expand_wildcard_citations(data, ["dos", "*"]))
Any["dos", "uno", "tres", "cuatro"]
julia> print(expand_wildcard_citations(data, ["*", "uno"]))
Any["uno", "dos", "tres", "cuatro"]
julia> print(expand_wildcard_citations(data, ["*", "DOS"]))
Any["uno", "dos", "tres", "cuatro"]
´´´
"""
function expand_wildcard_citations(entries::Bibliography, citations)
	local expanded_keys = []
    local citation_set = Set{String}()
    for citation in citations
        if citation == "*"
            for key in keys(entries)
                if !(lowercase(key) in citation_set)
                    push!(citation_set,lowercase(key))
					push!(expanded_keys, key)
				end
			end
        else
            if !(lowercase(citation) in citation_set)
                push!(citation_set,citation)
                push!(expanded_keys, citation)
			end
		end
	end
	return expanded_keys
end

function add_extra_citations(self::Bibliography, citations, min_crossrefs)
    local expanded_citations = expand_wildcard_citations(self,citations)
    local crossrefs = get_crossreferenced_citations(expanded_citations, min_crossrefs)
    return expanded_citations + crossrefs
end

include("UNSRT.jl")
const AlphaStyle = UNSRTStyle(Config(label_style = AlphaLabelStyle(),sorting_style = AuthorYearTitleSortingStyle()))
