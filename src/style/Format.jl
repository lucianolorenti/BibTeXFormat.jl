
include(joinpath(dirname(@__FILE__),"./template.jl"))
include(joinpath(dirname(@__FILE__),"./labels.jl"))
include(joinpath(dirname(@__FILE__),"./names.jl"))
include(joinpath(dirname(@__FILE__),"./sorting.jl"))

@node function toplevel(children, data)
    return format_data(join(sep=Symbol("newblock"))[children],data)
end

struct BaseStyle
	name_style
	label_style
	sorting_style
	abbreviate_names::Bool
	min_crossrefs::Integer

    function BaseStyle(;name_style=PlainNameStyle(),
                        label_style=AlphaLabelStyle(),
                        sorting_style=AuthorYearTitleSortingStyle(),
                        abbreviate_names=false,
                        min_crossrefs=2)
		return new(name_style, label_style, sorting_style, abbreviate_names, min_crossrefs)
	end
end
function format_entries(b::BaseStyle, entries)
	local formatted_entries = []
	local sorted_entries = sort(b.sorting_style, entries)
	local labels  = format_labels(b.label_style, sorted_entries)
	for (label,entry) in zip(labels, sorted_entries)
		push!(formatted_entries,format_entry(self, label, entry))
	end
end

function format_entry(b::BaseStyle, label, entry)
		context = Dict{String,String}("entry" => entry, "style"=>self)
		try
			get_template = getattr(self, "get_{}_template".format(entry.ttype))
			text = format_data(get_template(entry),context)
		catch AttributeError
			format_method = getattr(self, "format_" + entry.ttype)
			text = format_method(context)
		end
		return (entry.key, text, label)
end

"""
Format bibliography entries with the given keys and return a
``FormattedBibliography`` object.

:param bib_data: A :py:class:`pybtex.database.BibliographyData` object.
:param citations: A list of citation keys.
"""
function format_bibliography(self::BaseStyle, bib_data, citations=nothing)

	if citations == nothing
		citations = keys(bib_data)
	end
	citations = bib_data.add_extra_citations(citations, self.min_crossrefs)
	entries = [bib_data.entries[key] for key in citations]
	formatted_entries = format_entries(self,entries)
	formatted_bibliography = FormattedBibliography(formatted_entries, style=self, preamble=bib_data.preamble)
	return formatted_bibliography
end

const AlphaStyle = BaseStyle(label_style = AlphaLabelStyle(),sorting_style = AuthorYearTitleSortingStyle())
