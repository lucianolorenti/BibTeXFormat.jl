# Markdown backend
Markdown output backend.
```jldoctest
julia> import BibTeXFormat.RichTextElements: Tag, HRef

julia> import BibTeXFormat: MarkdownBackend, render

julia> markdown = MarkdownBackend();

julia> print(render(Tag("em", ""),markdown))

julia> print(render(Tag("em", "Non-", "empty"),markdown))
*Non\-empty*

julia> print(render(HRef("/", ""),markdown))

julia> print(render(HRef("/", "Non-", "empty"),markdown))
[Non\-empty](/)

```
