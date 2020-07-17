module BibTeXFormat

export BaseStyle,
       format_entries,
       Citation,
       Bibliography
using BibTeX

import Base: getindex,
             haskey,
             keys


struct Citation{Type}
    data::Dict
end
haskey(cit::Citation, key::T) where T<:AbstractString = haskey(cit.data, key)
keys(cit::Citation) = keys(cit.data)
getindex(cit::Citation, key::T) where T<:AbstractString = getindex(cit.data, key)
citation_type(c::Citation{T}) where T= string(T) 

function Citation(d::Dict=Dict())
    return Citation{Symbol(d["type"])}(d)
end
function Citation{T}() where T
    return Citation{T}(Dict())
end
struct Bibliography
    preamble::String
    citations::Dict{String, Citation}
end

function Bibliography(preamble::String, citations::Dict)
    d = Dict{String, Citation}()
    for k in keys(citations)
        d[k] = Citation(citations[k])
    end
    return Bibliography(preamble,  d)
end
Bibliography(bibtexfile::String) = Bibliography(parse_bibtex(bibtexfile)...)
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
include("accents.jl")
include("utils.jl")
include("person.jl")
include("richtextelements.jl")
include("style/style.jl")
include("backends/backends.jl")
end # module
