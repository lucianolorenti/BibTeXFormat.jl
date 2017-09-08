module BibTeXStyle

export BaseStyle,
       format_entries
using BibTeX
include("textutils.jl")
include("utils.jl")
include("person.jl")
include("RichTextUtils.jl")
include("backends/Backends.jl")
include("style/Format.jl")

end # module
