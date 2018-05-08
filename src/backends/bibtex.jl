import BibTeXFormat: scan_bibtex_string
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

struct Writer 
end
doc"""
```julia
function quote(self::Writer, s)
```
```jldoctest
julia> w = Writer()
julia> println(quote(w,"The World"))
"The World"
julia> println(quote(w,"The \\emph{World}"))
"The \emph{World}"
julia> println(quote(w,"The \"World\""))
{The "World"}
julia> try
          println(quote(w,"The {World"))
       catch e
          println(error)
        end
String has unmatched braces: The {World
```
        """
function bibtex_quote(self::Writer, s)
        check_braces(self, s)
        if !('"' in s)
            return "\"$s\""
        else
            return "{$s}"
        end
    end
doc"""
```julia
function check_braces(self::Writer, s)
```
Raise an exception if the given string has unmatched braces.

```jldoctest
julia> w = Writer()
julia> check_braces(w, "Cat eats carrots.")
julia> check_braces(w, "Cat eats {carrots}.")
julia> check_braces(w, "Cat eats {carrots{}}.")
julia> check_braces(w, "")
julia> check_braces(w, "end}")
julia> try
     check_braces(w, "{")
 catch e
     println(error)
end
String has unmatched braces: {
julia> check_braces(w, "{test}}")
julia> try
     w.check_braces("{{test}")
 catch e
     println(error)
end
String has unmatched braces: {{test}
```
"""
function check_braces(self::Writer, s)
    tokens = scan_bibtex_string(s)
    if length(tokens)>0
        end_brace_level = tokens[end][2]
        if end_brace_level != 0
            throw("String has unmatched braces: $s")
        end
    end
end

"""
```
   function _encode(self::Writer, text)
```
Encode text as LaTeX.

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
    function _encode(self::Writer, text)

        return codecs.encode(text, 'ulatex+{}'.format(self.encoding))
    end
    
"""
```julia
function _encode_with_comments(self, text)
```
Encode text as LaTeX, preserve comments.

julia> w = Writer(encoding='ASCII')
julia> print(w._encode_with_comments(u'1970â€“1971.  %% â€  RIP â€ '))
1970--1971.  %% \dag\ RIP \dag

julia> w = Writer(encoding='UTF-8')
julia> print(w._encode_with_comments(u'1970â€“1971.  %% â€  RIP â€ '))
1970â€“1971.  %% â€  RIP â€ 
"""
function _encode_with_comments(self, text)
        return u'%'.join(self._encode(part) for part in text.split(u'%'))
end
function _write_field(self, stream, ttype, value)
    local quoted = bibtex_quote(self, _encode(self, value))
    write(stream, ",\n    $ttype = $quoted")
end
function _format_name(self, stream, person)
    function join(l)
        return join([name for name in l if name], ' ')
    end
    local first   = get_part_as_text(person, "first")
    local middle  = get_part_as_text(person, "middle")
    local prelast = get_part_as_text(person, "prelast")
    local last    = get_part_as_text(person, "last")
    local lineage = get_part_as_text(person, "lineage")
    local s = ""
        if length(last)>0
            s = string(s,join([prelast, last]))
        end
        if length(lineage)>0
            s = string(s,", $lineage")
        end
        if length(first)>0 ||  length(middle)>0
            s = string(s,", " )
            s = string(s,join([first, middle]))
        end
    return s
end   

function    _write_persons(self, stream, persons, role)
        # persons = getattr(entry, role + 's')
        if persons:
            names = u' and '.join(self._format_name(stream, person) for person in persons)
            self._write_field(stream, role, names)
        end
    end
function    _write_preamble(self::Writer, stream::IOStream, preamble)
        if preamble:
            stream.write(u'@preamble{%s}\n\n' % self.quote(self._encode_with_comments(preamble)))
        end
    end

function write_stream(self::Writer, bib_data, stream::IOStream)
    _write_preamble(self, stream, bib_data.preamble)
    first = true
    for (key, entry) in values(bib_data.entries)
        if !first
            write(stream, "\n")
        end
        first = false
        write(stream,"@$(entry.original_type)")
        write(stream, "{$key")
        for role, persons in values(entry.persons)
            _write_persons(self, stream, persons, role)
        end
        for ttype, value in values(entry.fields)
            _write_field(self, stream, ttype, value)                
        end        
        write(stream,"\n}\n")
    end    
end
    
