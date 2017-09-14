# RichTextElements

```@meta
DocTestSetup = quote
using BibTeXStyle
import BibTeXStyle: RichText, Tag, append, render_as, add_period, capfirst,
                    capitalize, typeinfo, create_similar, HRef,
                    merge_similar, render_as, Protected,
                    RichString
end
```
## Description
(simple but) rich text formatting tools

```jldoctest
julia> import BibTeXStyle.RichTextElements: Tag, RichText, render_as

julia> import BibTeXStyle.Backends: render_as

julia> t = RichText("this ", "is a ", Tag("em", "very"), RichText(" rich", " text"));

julia> render_as(t,"LaTex")
this is a \emph{very} rich text

julia> convert(String,t)
this is a very rich text

julia> t = add_period(capitalize(t));

julia> render_as(t,"latex")
This is a \emph{very} rich text.
```

## Types

```@index
Pages   = ["richtextelements.md"]
Order   = [:type]
```

## Functions

```@index
Pages   = ["richtextelements.md"]
Order   = [:function]
```

##  Reference

```@autodocs
Modules = [BibTeXStyle]
Pages   = ["richtextelements.jl"]
```
