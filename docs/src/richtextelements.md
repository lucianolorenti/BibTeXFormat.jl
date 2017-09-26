# RichTextElements

```@meta
DocTestSetup = quote
import BibTeXFormat.RichTextElements: RichText, Tag, append, render_as, add_period, capfirst,
                    capitalize, typeinfo, create_similar, HRef,
                    merge_similar, render_as, Protected,
                    RichString
end
```
## Description
(simple but) rich text formatting tools

```jldoctest
julia> import BibTeXFormat: RichText, Tag, render_as

julia> import BibTeXFormat.RichTextElements: add_period, capitalize

julia> t = RichText("this ", "is a ", Tag("em", "very"), RichText(" rich", " text"));

julia> render_as(t,"LaTex")
"this is a \\emph{very} rich text"

julia> convert(String,t)
"this is a very rich text"

julia> t = add_period(capitalize(t));

julia> render_as(t,"latex")
"This is a \\emph{very} rich text."
```

## Types

```@index
Modules = [BibTeXFormat.RichTextElements]
Order   = [:type]
```

## Functions

```@index
Modules = [BibTeXFormat.RichTextElements]
Order   = [:function]
```

##  Reference

```@autodocs
Modules = [BibTeXFormat.RichTextElements]
Pages   = ["richtextelements.jl"]
```
