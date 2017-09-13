module BibTeXStyle

export BaseStyle,
       format_entries
using BibTeX
include("utils.jl")
include("person.jl")
include("richtextelements.jl")
include("style/style.jl")
include("backends/backends.jl")
end # module
