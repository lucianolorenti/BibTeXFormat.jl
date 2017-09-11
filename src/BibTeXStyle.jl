module BibTeXStyle

export BaseStyle,
       format_entries
using BibTeX
using Reexport
push!(LOAD_PATH, joinpath(dirname(@__FILE__),"style"))
push!(LOAD_PATH, joinpath(dirname(@__FILE__),"backends"))

function citation_type(t::Citation{T}) where {T}
    return T
end
function citation_type(e::Dict{String,Any})
    return e["type"]
end
include("textutils.jl")
include("utils.jl")
include("person.jl")
include("RichTextElements.jl")
include("backends/Backends.jl")

@reexport using Style

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
        entry["key"] = label
		push!(formatted_entries,format_entry(b,label, entry))
	end
    return formatted_entries
end

function format_entry(b::T, label, entry) where T<:BaseStyle
	local context = Dict{String,Any}("entry" => entry, "style"=>b)
    local text    = ""
#	try
        get_template =  getfield(typeof(b).name.module, Symbol("get_$(entry["type"])_template"))
        text = format_data(get_template(b,entry),context)
#	catch e
#        println( catch_stacktrace())
#        println(e)
#        format_method =  getfield(BibTeXStyle.Style, Symbol("format_$(entry["type"])"))
#    	text = format_method(b,context)
#	end
    return (entry["key"], text, label)
end

"""
Format bibliography entries with the given keys and return a
``FormattedBibliography`` object.

:param bib_data: A :py:class:`pybtex.database.BibliographyData` object.
:param citations: A list of citation keys.
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

end # module
