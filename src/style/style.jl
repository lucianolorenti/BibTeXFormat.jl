export AlphaStyle,
       format_entries,
       BST,
       format_entry,
       UNSRTAlphaStyle,
       PlainAlphaStyle
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
"""
```
function transform(e::Citation, label)
```
Add some information to a BibTeX.Citation.
"""
function transform(e::Citation, label)
    local e_n = Dict{String,Any}()
    local e_n["persons"] = Dict{String,Vector{Person}}()
    for k in keys(e)
        e_n[k] = e[k]
    end
    e_n["type"] = citation_type(e)
    e_n["key"] = label
    if haskey(e_n, "author")
        e_n["persons"]["author"] = [Person(p) for p in split_name_list(e["author"])]
    end
    pop!(e_n,"author")
    return e_n
end
function transform_entries(entries)
    local transformed_entries = Dict()
    for k in keys(entries)
        transformed_entries[k] = transform(entries[k], k)
    end
    return  transformed_entries
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
    entries = transform_entries(entries)
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
function format_entry(b::T, label, entry::Citation) where T <: BaseStyle
```
"""
function format_entry(b::T, label, entry::Citation) where T <: BaseStyle
    local t_entry = transform(entry, label)
    return format_entry(b, label, t_entry)
end

"""
```
function format_entry(b::T, label, entry) where T <: BaseStyle
```

Format an `entry` with a given style `b::T where T <: BaseStyle`

"""
function format_entry(b::T, label, entry::Dict{String,Any}) where T<:BaseStyle
	local context = Dict{String,Any}("entry" => entry, "style"=>b)
    local text    = ""
	try
        get_template =  getfield(typeof(b).name.module, Symbol("get_$(entry["type"])_template"))

        text = TemplateEngine.format_data(get_template(b,entry),context)
	catch e
        warn(e)
        println(catch_stacktrace())
        format_method =  getfield(typeof(b).name.module, Symbol("format_$(entry["type"])"))
    	text = format_method(b,context)
	end
    return (entry["key"], text, label)
end

"""
```julia
function format_bibliography(self::T, bib_data, citations=nothing) where T<:BaseStyle
```
Format bibliography entries with the given keys
Params:
- `self::T where T<:BaseStyle`. The style
- `bib_data` BibTeX.Bibliography
- `param citations`: A list of citation keys.

```julia
using BibTeX
using BibTeXFormat
bibliography      = Bibliography(readstring("test/Clustering.bib"))

formatted_entries = format_entries(AlphaStyle,bibliography)
```
"""
function format_bibliography(style::T, bib_data::Bibliography, citations=nothing) where T<:BaseStyle
	if citations == nothing
		citations = keys(bib_data)
	end
	citations = add_extra_citations(bib_data, citations, self.min_crossrefs)
	entries = [bib_data[key] for key in citations]
	formatted_entries = format_entries(style,entries)
	return (formatted_entries, style)
end

"""
Get cititations not cited explicitly but referenced by other citations.

```jldoctest
julia> using BibTeX

julia> import BibTeXFormat: get_crossreferenced_citations

julia> data = Bibliography("", Dict{String,Citation}("main_article"=>Citation{:article}(Dict("crossref"=>"xrefd_article")),"xrefd_article"=>Citation{:article}()));

julia> print(get_crossreferenced_citations(data, [], min_crossrefs=1))
Any[]
julia> print(get_crossreferenced_citations(data, ["main_article"], min_crossrefs=1))
Any["xrefd_article"]
julia> print(get_crossreferenced_citations(data,["Main_article"], min_crossrefs=1))
Any["xrefd_article"]
julia> print(get_crossreferenced_citations(data, ["main_article"], min_crossrefs=2))
Any[]
julia> print(get_crossreferenced_citations(data, ["xrefd_arcicle"], min_crossrefs=1))
Any[]
```

"""
function  get_crossreferenced_citations(entries, citations; min_crossrefs::Integer=1)

	canonical_crossrefs = []
    crossref_count = Dict{String,Int}()
    citation_set = Set{String}([lowercase(c) for c in citations])
	local crossref = nothing
    for citation in [lowercase(c) for c in citations]
		if haskey(entries, citation) &&  haskey(entries[citation], "crossref")
            if haskey(entries, entries[citation]["crossref"])
                local entry     = entries[citation]
                crossref = entry["crossref"]
                local crossref_entry = entries[crossref]
                local canonical_crossref = lowercase(crossref)
                if !haskey(crossref_count, canonical_crossref)
                    crossref_count[canonical_crossref] = 1
                else
                    crossref_count[canonical_crossref] = crossref_count[canonical_crossref] + 1
                end
                if crossref_count[canonical_crossref] >= min_crossrefs && !(canonical_crossref in citation_set)
                    push!(citation_set, canonical_crossref)
                    push!(canonical_crossrefs, canonical_crossref)
                end
            else
                warn("bad cross-reference: entry \"$citation\" refers to
                    entry \"$crossref\" which does not exist.")
                continue
            end
        end
	end
	return canonical_crossrefs
end

"""
Expand wildcard citations (\citation{*} in .aux file).
```jldoctest
julia> using BibTeX

julia> import BibTeXFormat: expand_wildcard_citations

julia> data = Bibliography("", Dict{String,Citation}("uno"=>Citation{:article}(),"dos"=>Citation{:article}(),"tres"=>Citation{:article}(),	"cuatro"=>Citation{:article}()));

julia> expand_wildcard_citations(data, [])
0-element Array{Any,1}

julia> print(expand_wildcard_citations(data, ["*"]))
Any["tres", "dos", "uno", "cuatro"]
julia> print(expand_wildcard_citations(data, ["uno", "*"]))
Any["uno", "tres", "dos", "cuatro"]
julia> print(expand_wildcard_citations(data, ["dos", "*"]))
Any["dos", "tres", "uno", "cuatro"]
julia> print(expand_wildcard_citations(data, ["*", "uno"]))
Any["tres", "dos", "uno", "cuatro"]
julia> print(expand_wildcard_citations(data, ["*", "DOS"]))
Any["tres", "dos", "uno", "cuatro"]
```
"""
function expand_wildcard_citations(entries, citations)
	local expanded_keys = []
    local citation_set = Set{String}()
    if isa(citations, Dict)
        citations_keys = keys(citations)
    else
        citations_keys = citations
    end
    for citation in citations_keys
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

function add_extra_citations(entries, citations; min_crossrefs::Integer=0)
    local expanded_citations = expand_wildcard_citations(entries,citations)
    local crossrefs = get_crossreferenced_citations(entries, expanded_citations, min_crossrefs=min_crossrefs)
    return vcat(expanded_citations, crossrefs)
end

include("UNSRT.jl")
"""
Alpha Style

`Config(label_style = AlphaLabelStyle(),sorting_style = AuthorYearTitleSortingStyle())`
"""
const AlphaStyle = UNSRTStyle(Config(label_style = AlphaLabelStyle(),sorting_style = AuthorYearTitleSortingStyle()))
"""
UNSRTAlphaStyle

`Config(label_style = AlphaLabelStyle())`

"""
const UNSRTAlphaStyle = UNSRTStyle(Config(label_style = AlphaLabelStyle()))
"""
PlainAlphaStyle
"""
const PlainAlphaStyle = UNSRTStyle(Config())

include("bst/bst.jl")

