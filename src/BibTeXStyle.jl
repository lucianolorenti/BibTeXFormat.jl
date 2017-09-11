module BibTeXStyle

export BaseStyle,
       format_entries
using BibTeX
#push!(LOAD_PATH, joinpath(dirname(@__FILE__),"style"))
#push!(LOAD_PATH, joinpath(dirname(@__FILE__),"backends"))
include("textutils.jl")
include("utils.jl")
include("person.jl")
include("RichTextElements.jl")
include("style/Style.jl")
include("backends/Backends.jl")
end # module
