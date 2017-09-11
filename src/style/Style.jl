module Style
export BaseStyle, format_labels

import TemplateEngine: @node

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

const AlphaStyle = BaseStyle(label_style = AlphaLabelStyle(),sorting_style = AuthorYearTitleSortingStyle())

@reexport using UNSRT
end
