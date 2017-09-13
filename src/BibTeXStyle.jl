module BibTeXStyle

export BaseStyle,
       format_entries
using BibTeX
include("textutils.jl")
include("utils.jl")
include("person.jl")
include("RichTextElements.jl")
include("style/Style.jl")
include("backends/Backends.jl")
end # module
