module BibTeXFormat

export BaseStyle,
       format_entries,
       Citation,
       Bibliography
using BibTeX

import Base: getindex,
             haskey,
             keys

struct Citation
    type_::Symbol
    data::Dict
end
haskey(cit::Citation, key::T) where T<:AbstractString = haskey(cit.data, key)
keys(cit::Citation) = keys(cit.data)
getindex(cit::Citation, key::T) where T<:AbstractString = getindex(cit.data, key)


function Citation(type_::Symbol)
    return Citation(type_, Dict())
end
struct Bibliography
    preamble::String
    citations::Dict{String, Citation}
end
function haskey(bib::Bibliography, key::T) where T<:AbstractString
    return haskey(bib.citations, key)
end
function keys(bib::Bibliography)
    return keys(bib.citations)
end
function getindex(bib::Bibliography, key::T) where T<:AbstractString
    return getindex(bib.citations, key)
end



function render_as() end
include("utils.jl")
include("person.jl")
include("richtextelements.jl")
include("style/style.jl")
include("backends/backends.jl")
end # module
