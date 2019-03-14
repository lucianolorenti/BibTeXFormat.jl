using Markdown

""" A backend to support markdown output. It implements the same
features as the HTML backend.

In addition to that, you can use the keyword php_extra=True to enable
the definition list extension of php-markdown. The default is not to use
it, since we cannot be sure that this feature is implemented on all
systems.

More information:
http://www.michelf.com/projects/php-markdown/extra/#def-list

"""
struct MarkdownBackend <: BaseBackend
    encondig::String
    php_extra::Bool
end

const SPECIAL_CHARS= [
    '\\',  # backslash
    '`',   # backtick
    '*',   # asterisk
    '_',   # underscore
    '{',   # curly braces
    '}',   # curly braces
    '[',   # square brackets
    ']',   # square brackets
    '(',   # parentheses
    ')',   # parentheses
    '#',   # hash mark
    '+',   # plus sign
    '-',   # minus sign (hyphen)
    '.',   # dot
    '!',   # exclamation mark
]
function MarkdownBackend(;encoding="utf-8", php_extra=false)
    return MarkdownBackend(encoding, php_extra)
end

default_suffix[MarkdownBackend] = ".md"
symbols[MarkdownBackend] = Dict{String,String}(
    "ndash" =>  "&ndash;",# or 'ndash': u'â€“',
    "newblock" =>  "\n",
    "nbsp" => " "
   )
tags[MarkdownBackend] = Dict{String,String}(
    "em"     => "*",  # emphasize text
    "strong" => "**", # emphasize text even more
    "i"      => "*",  # italicize text: be careful, i is not semantic
    "b"      => "**", # embolden text: be careful, b is not semantic
    "tt"     => "`",  # make text appear as code (typically typewriter text), a little hacky
   )

"""Format the given string *str_*.
Escapes special markdown control characters.
"""
function format(self::MarkdownBackend, text::String)
    text = escape_string(text)
    for special_char in SPECIAL_CHARS
        text = replace(text,special_char=>string('\\',special_char))
    end
    return text
end
function format(self::MarkdownBackend, tag::Tag, text)
    tag = get(tags[typeof(self)],tag.name,nothing)
    if tag == nothing
        return text
    else
        if length(text) > 0
            return "$tag$text$tag"
        else
            return ""
        end
    end
end
function format(self::MarkdownBackend, url::HRef, text)
    if (text!="")
        return Markdown.plaininline(Markdown.Link(text,url.url))
    else
        return ""
    end
end

function write_entry(self::MarkdownBackend, output, key, label, text)
    # Support http://www.michelf.com/projects/php-markdown/extra/#def-list
    if self.php_extra
        write(output, "$label\n")
        write(output,":    $text\n\n")
    else
        write(output,"[$label] ")
        write(output,"$text   \n\n")
    end
end
