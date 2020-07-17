import Documenter
import Documenter
Documenter.makedocs(
    modules = [BibTeXFormat],
    format = Documenter.HTML(),
    sitename = "BibTeXFormat.jl",
    root = joinpath(base_file, "docs"),
    pages = Any[
                "Home" => "index.md",
                "Public Components" => Any[
                    "Style"    => "style.md"
                    "Backends" => "backends.md"
                                         ],
                "Private Components" => Any[
                    "Person" => "person.md",
                    "Rich Text Elements" => "richtextelements.md",
                    "Template Engine" => "templateengine.md",
                    "Utilities"=>"utils.md",
                 ]
               ],
    #strict = true,
    #linkcheck = true,
    #checkdocs = :exports,
    authors = "Luciano Lorenti",
    doctest=true
)
Documenter.deploydocs(
    deps = nothing,
    make = nothing,
    repo = "github.com/lucianolorenti/BibTeXFormat.jl.git",
    target = "build",
    branch = "gh-pages"

)
