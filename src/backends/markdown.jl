

const SPECIAL_CHARS = [
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
    php_extra::Boolean
end

function MarkdownBackend(;encoding=none, php_extra=false)
    return MarkdownBackend(encoding, php_extra)
end

default_suffix = '.md'
symbols = {
    "ndash" =>  "&ndash;",# or 'ndash': u'â€“',
    "newblock" =>  "\n",
    "nbsp" => " "
}
tags = {
    "em"     => "*",  # emphasize text
    "strong" => "**", # emphasize text even more
    "i"      => "*",  # italicize text: be careful, i is not semantic
    "b"      => "**", # embolden text: be careful, b is not semantic
    "tt"     => "`",  # make text appear as code (typically typewriter text), a little hacky
}

function format(self::MarkdownBackend, text::String)
    """Format the given string *str_*.
    Escapes special markdown control characters.
    """
    text = escape(text)
    for special_char in SPECIAL_CHARS:
        text = text.replace(special_char, u'\\' + special_char)
    return text
end
function format(self::MarkdownBackend, tag::Tag)
    tag = self.tags.get(tag_name)
    if tag is None:
        return text
    else:
        return r'{0}{1}{0}'.format(tag, text) if text else u''
end
function format(self::MarkdownBackend, url::HRef)
    return Markdown.plaininline(Markdown.Link(text,url))
end

function write_entry(self::MarkdownBackend, key, label, text):
    # Support http://www.michelf.com/projects/php-markdown/extra/#def-list
    if self.php_extra:
        self.output(u'%s\n' % label)
        self.output(u':   %s\n\n' % text)
    else:
        self.output(u'[%s] ' % label)
        self.output(u'%s  \n' % text)
    end
end
