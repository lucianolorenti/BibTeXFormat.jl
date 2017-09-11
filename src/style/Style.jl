module Style
export Config,
       format_labels,
       BaseStyle,
       AlphaStyle,
       toplevel
import TemplateEngine: @node, format_data
export format_data
using Reexport
include(joinpath(dirname(@__FILE__),"./labels.jl"))
include(joinpath(dirname(@__FILE__),"./names.jl"))
include(joinpath(dirname(@__FILE__),"./sorting.jl"))

@node function toplevel(children, data)
    return format_data(join(sep=Symbol("newblock"))[children],data)
end
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

@reexport using UNSRT

const AlphaStyle = UNSRT.Style(Config(label_style = AlphaLabelStyle(),sorting_style = AuthorYearTitleSortingStyle()))
end
