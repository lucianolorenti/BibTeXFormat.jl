struct BaseWriter
end
function write_file(bib_data, filename)
        open_file = pybtex.io.open_unicode if self.unicode_io else pybtex.io.open_raw
        mode = 'w' if self.unicode_io else 'wb'
        with open_file(filename, mode, encoding=self.encoding) as stream:
            self.write_stream(bib_data, stream)
            if hasattr(stream, 'getvalue'):
                return stream.getvalue()
            end
end
function _to_string_or_bytes(self, bib_data)
        stream = io.StringIO() if self.unicode_io else io.BytesIO()
        self.write_stream(bib_data, stream)
        return stream.getvalue()
end            
function to_string(self, bib_data)
        result = self._to_string_or_bytes(bib_data)
            return result if self.unicode_io else result.decode(self.encoding)
end               

function to_bytes(self, bib_data)
     result = self._to_string_or_bytes(bib_data)
    return result.encode(self.encoding) if self.unicode_io else result
end

struct Writer <: BaseWriter
end
"""
```julia
function quote(self::Writer, s)
```

        >>> w = Writer()
        >>> print(w.quote('The World'))
        "The World"
        >>> print(w.quote(r'The \emph{World}'))
        "The \emph{World}"
        >>> print(w.quote(r'The "World"'))
        {The "World"}
        >>> try:
        ...     print(w.quote(r'The {World'))
        ... except BibTeXError as error:
        ...     print(error)
        String has unmatched braces: The {World
        """
function quote(self::Writer, s)
        check_braces(self, s)
        if !('"' in s)
            return "\"${s}\""
        else:
            return '\{${s}\}'
        end
    end
"""
```julia
function check_braces(self::Writer, s)
```

        Raise an exception if the given string has unmatched braces.

        >>> w = Writer()
        >>> w.check_braces('Cat eats carrots.')
        >>> w.check_braces('Cat eats {carrots}.')
        >>> w.check_braces('Cat eats {carrots{}}.')
        >>> w.check_braces('')
        >>> w.check_braces('end}')
        >>> try:
        ...     w.check_braces('{')
        ... except BibTeXError as error:
        ...     print(error)
        String has unmatched braces: {
        >>> w.check_braces('{test}}')
        >>> try:
        ...     w.check_braces('{{test}')
        ... except BibTeXError as error:
        ...     print(error)
        String has unmatched braces: {{test}
"""
function check_braces(self::Writer, s)
    tokens = scan_bibtex_string(s)
    if tokens
        end_brace_level = tokens[-1][1]
        if end_brace_level != 0
            throw("String has unmatched braces: ${s}")
        end
    end
end

    function _encode(self::Writer, text)
        r"""Encode text as LaTeX.

        >>> w = Writer(encoding='ASCII')
        >>> print(w._encode(u'1970â€“1971.'))
        1970--1971.

        >>> w = Writer(encoding='UTF-8')
        >>> print(w._encode(u'1970â€“1971.'))
        1970â€“1971.

        >>> w = Writer(encoding='UTF-8')
        >>> print(w._encode(u'100% noir'))
        100\% noir
        """

        return codecs.encode(text, 'ulatex+{}'.format(self.encoding))
end
function _encode_with_comments(self, text)
        r"""Encode text as LaTeX, preserve comments.

        >>> w = Writer(encoding='ASCII')
        >>> print(w._encode_with_comments(u'1970â€“1971.  %% â€  RIP â€ '))
        1970--1971.  %% \dag\ RIP \dag

        >>> w = Writer(encoding='UTF-8')
        >>> print(w._encode_with_comments(u'1970â€“1971.  %% â€  RIP â€ '))
        1970â€“1971.  %% â€  RIP â€ 
        """
        return u'%'.join(self._encode(part) for part in text.split(u'%'))
end
function _write_field(self, stream, type, value)
        stream.write(u',\n    %s = %s' % (type, self.quote(self._encode(value))))
end
function _format_name(self, stream, person)
        function join(l)
    return ' '.join([name for name in l if name])
    end
        first = person.get_part_as_text('first')
        middle = person.get_part_as_text('middle')
        prelast = person.get_part_as_text('prelast')
        last = person.get_part_as_text('last')
        lineage = person.get_part_as_text('lineage')
        s = ''
        if last:
            s += join([prelast, last])
        end
        if lineage:
            s += ', %s' % lineage
        end
        if first or middle:
            s += ', '
            s += join([first, middle])
        end
    return s
end   

function    def _write_persons(self, stream, persons, role)
        # persons = getattr(entry, role + 's')
        if persons:
            names = u' and '.join(self._format_name(stream, person) for person in persons)
            self._write_field(stream, role, names)
        end
    end
function    def _write_preamble(self, stream, preamble)
        if preamble:
            stream.write(u'@preamble{%s}\n\n' % self.quote(self._encode_with_comments(preamble)))
        end
    end

function    def write_stream(self, bib_data, stream)

        self._write_preamble(stream, bib_data.preamble)

        first = True
        for key, entry in bib_data.entries.items():
            if not first:
                stream.write(u'\n')
            end
            first = False

            stream.write(u'@%s' % entry.original_type)
            stream.write(u'{%s' % key)
#            for role in ('author', 'editor'):
            for role, persons in entry.persons.items():
                         self._write_persons(stream, persons, role)
                      end
            for type, value in entry.fields.items():
                         self._write_field(stream, type, value)
                         end
                         stream.write(u'\n}\n')
        end
    end
