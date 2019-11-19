import Documenter

Documenter.deploydocs(
    deps = nothing,
    make = nothing,
    repo = "github.com/lucianolorenti/BibTeXFormat.jl.git",
    target = "build",
    branch = "gh-pages"

)
