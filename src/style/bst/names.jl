
struct NamePart
	pre_text::String
	post_text::String
	tie::String
	format_char::Char
	abbreviate::Bool
end
function NamePart(format_list)
	pre_text, format_chars, self.delimiter, post_text = format_list
	local tie = ""
	local format_char = ""
	local abbreviate = false
	if length(format_chars)>0 && length(pre_text)>0 && length(post_text)<=0
		post_text = pre_text
		pre_text = ""
	end

	if endswith(post_text, "~~")
		tie = "~~"
	elseif post_text.endswith('~')
		tie = "~"
	else
		tie = nothing
	end

	pre_text = pre_text
	post_text = rstrip(post_text,"~")

	if !(length(format_chars)>0)
		format_char = ""
		abbreviate = false
	else
		l = length(format_chars)
		if l == 1
			abbreviate = true
		elseif l == 2 && format_chars[1] == format_chars[2]
			abbreviate = false
		else
			throw("invalid format string")
		end
		format_char = format_chars[1]
	end
	return NamePart(pre_text, post_text, tie, format_char, abbreviate)
end
function ==(a::NamePart, b::NamePart)
	return  a.pre_text == b.pre_text
            && a.format_char == b.format_char
            && a.abbreviate == b.abbreviate
            && a.delimiter == b.delimiter
            && a.post_text == b.post_text
end
    def __repr__(self):
        format_chars = self.format_char * (1 if self.abbreviate else 2)
        format_list = [self.pre_text, format_chars, self.delimiter, self.post_text]
        return u'{0}({1})'.format(type(self).__name__, repr(format_list))

const format_name_ types = Dict{Char, String}([
            'f'=> "bibtex_first",
            'l'=> "last'"
            'v'=> "prelast",
            'j'=> "lineage"
    ])
function format(self::NamePart, person)

	local names = get_part(person, format_name_types[self.format_char]) if self.format_char else []

	if self.format_char and not names:
		return ''

	if self.abbreviate:
		names = [bibtex_abbreviate(name, self.delimiter) for name in names]
	if self.delimiter is None:
		if self.abbreviate:
			names = join(names, '.~', '. ')
		else:
			names = join(names)
	else:
		names = self.delimiter.join(names)
	formatted_part = self.pre_text + names + self.post_text

	if self.tie == '~':
		discretionary = tie_or_space(formatted_part)
	elif self.tie == '~~':
		discretionary = '~'
	else:
		discretionary = ''

	return formatted_part + discretionary

    def to_python(self):
        from pybtex.style.names import name_part
        class NamePart(object):
            def __init__(self, part, abbr=False):
                self.part = part
                self.abbr = abbr
            def __repr__(self):
                abbr = 'abbr' if self.abbr else ''
                return 'person.%s(%s)' % (self.part, abbr)

        kwargs = {}
        if self.pre_text:
            kwargs['before'] = self.pre_text
        if self.tie:
            kwargs['tie'] = True

        return repr(name_part(**kwargs) [
            NamePart(self.types[self.format_char], self.abbreviate)
        ])

class NameFormat(object):
    """
    BibTeX name format string.

    >>> f = NameFormat('{ff~}{vv~}{ll}{, jj}')
    >>> f.parts == [
    ...     NamePart(['', 'ff', None, '']),
    ...     NamePart(['', 'vv', None, '']),
    ...     NamePart(['', 'll', None, '']),
    ...     NamePart([', ', 'jj', None, ''])
    ... ]
    True
    >>> f = NameFormat('{{ }ff~{ }}{vv~{- Test text here -}~}{ll}{, jj}')
    >>> f.parts == [
    ...     NamePart(['{ }', 'ff', None, '~{ }']),
    ...     NamePart(['', 'vv', None, '~{- Test text here -}']),
    ...     NamePart(['', 'll', None, '']),
    ...     NamePart([u', ', 'jj', None, ''])
    ... ]
    True
    >>> f = NameFormat('abc def {f~} xyz {f}?')
    >>> f.parts == [
    ...     Text('abc def '),
    ...     NamePart(['', 'f', None, '']),
    ...     Text(' xyz '),
    ...     NamePart(['', 'f', None, '']),
    ...     Text('?'),
    ... ]
    True
    >>> f = NameFormat('{{abc}{def}ff~{xyz}{#@$}}')
    >>> f.parts == [NamePart(['{abc}{def}', 'ff', None, '~{xyz}{#@$}'])]
    True
    >>> f = NameFormat('{{abc}{def}ff{xyz}{#@${}{sdf}}}')
    >>> f.parts == [NamePart(['{abc}{def}', 'ff', 'xyz', '{#@${}{sdf}}'])]
    True
    >>> f = NameFormat('{f.~}')
    >>> f.parts == [NamePart(['', 'f', None, '.'])]
    True
    >>> f = NameFormat('{f~.}')
    >>> f.parts == [NamePart(['', 'f', None, '~.'])]
    True
    >>> f = NameFormat('{f{.}~}')
    >>> f.parts == [NamePart(['', 'f', '.', ''])]
    True

    """

    def __init__(self, format):
        self.format_string = format
        self.parts = list(NameFormatParser(format).parse())

    def format(self, name):
        person = Person(name)
        return ''.join(part.format(person) for part in self.parts)

    def to_python(self):
        """Convert BibTeX name format to Python (inexactly)."""
        parts = ',\n'.join(' ' * 8 + part.to_python() for part in self.parts)
        comment = ' ' * 4 + (
            '"""Format names similarly to %s in BibTeX."""' % self.format_string
        )
        body = ' ' * 4 + 'return join [\n%s,\n]' % parts
        return '\n'.join([
            'def format_names(person, abbr=False):',
            comment,
            body,
        ])

enough_chars = 3

def tie_or_space(word, tie='~', space = ' '):
    if bibtex_len(word) < enough_chars:
        return tie
    else:
        return space

def join(words, tie='~', space=' '):
    """Join some words, inserting ties (~) when nessessary.
    Ties are inserted:
    - after the first word, if it is short
    - before the last word
    Otherwise space is inserted.
    Should produce the same oubput as BibTeX.

    >>> print(join(['a', 'long', 'long', 'road']))
    a~long long~road
    >>> print(join(['very', 'long', 'phrase']))
    very long~phrase
    """

    if len(words) <= 2:
        return tie.join(words)
    else:
        return (words[0] + tie_or_space(words[0], tie, space) +
                space.join(words[1:-1]) +
                tie + words[-1])

def format_name(name, format):
    return NameFormat(format).format(name)

class UnbalancedBraceError(PybtexSyntaxError):
    def __init__(self, parser):
        message = u'name format string "{0}" has unbalanced braces'.format(parser.text)
        super(UnbalancedBraceError, self).__init__(message, parser)

class NameFormatParser(Scanner):
    LBRACE = Literal(u'{')
    RBRACE = Literal(u'}')
    TEXT = Pattern(r'[^{}]+', 'text')
    NON_LETTERS = Pattern(r'[^{}\w]|\d+', 'non-letter characters', flags=re.IGNORECASE | re.UNICODE)
    FORMAT_CHARS = Pattern(r'[^\W\d_]+', 'format chars', flags=re.IGNORECASE | re.UNICODE)

    lineno = None

    def parse(self):
        while True:
            try:
                result = self.parse_toplevel()
                yield result
            except EOFError:
                break

    def parse_toplevel(self):
        token = self.required([self.TEXT, self.LBRACE, self.RBRACE], allow_eof=True)
        if token.pattern is self.TEXT:
            return Text(token.value)
        elif token.pattern is self.LBRACE:
            return NamePart(self.parse_name_part())
        elif token.pattern is self.RBRACE:
            raise UnbalancedBraceError(self)

    def parse_braced_string(self):
        while True:
            try:
                token = self.required([self.TEXT, self.RBRACE, self.LBRACE])
            except PrematureEOF:
                raise UnbalancedBraceError(self)
            if token.pattern is self.TEXT:
                yield token.value
            elif token.pattern is self.RBRACE:
                break
            elif token.pattern is self.LBRACE:
                yield u'{{{0}}}'.format(''.join(self.parse_braced_string()))
            else:
                raise ValueError(token)

    def parse_name_part(self):
        verbatim_prefix = []
        format_chars = None
        verbatim_postfix = []
        verbatim = verbatim_prefix
        delimiter = None

        def check_format_chars(value):
            value = value.lower()
            if (
                format_chars is not None
                or len(value) not in [1, 2]
                or value[0] != value[-1]
                or value[0] not in 'flvj'
            ):
                raise PybtexSyntaxError(u'name format string "{0}" has illegal brace-level-1 letters: {1}'.format(self.text, token.value), self)

        while True:
            try:
                token = self.required([self.LBRACE, self.NON_LETTERS, self.FORMAT_CHARS, self.RBRACE])
            except PrematureEOF:
                raise UnbalancedBraceError(self)

            if token.pattern is self.LBRACE:
                verbatim.append(u'{{{0}}}'.format(''.join(self.parse_braced_string())))
            elif token.pattern is self.FORMAT_CHARS:
                check_format_chars(token.value)
                format_chars = token.value
                verbatim = verbatim_postfix
                if self.optional([self.LBRACE]):
                    delimiter = ''.join(self.parse_braced_string())
            elif token.pattern is self.NON_LETTERS:
                verbatim.append(token.value)
            elif token.pattern is self.RBRACE:
                return ''.join(verbatim_prefix), format_chars, delimiter, ''.join(verbatim_postfix)
            else:
                raise ValueError(token)

    def eat_whitespace(self):
        pass
	end
end
