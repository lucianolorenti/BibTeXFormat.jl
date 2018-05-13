using StringLiterals
#="""
    LaTeX Codec
    ~~~~~~~~~~~

    The :mod:`latexcodec.codec` module
    contains all classes and functions for LaTeX code
    translation. For practical use,
    you should only ever need to import the :mod:`latexcodec` module,
    which will automatically register the codec
    so it can be used by :meth:`str.encode`, :meth:`str.decode`,
    and any of the functions defined in the :mod:`codecs` module
    such as :func:`codecs.open` and so on.
    The other functions and classes
    are exposed in case someone would want to extend them.

    .. autofunction:: register

    .. autofunction:: find_latex

    .. autoclass:: LatexIncrementalEncoder
        :show-inheritance:
        :members:

    .. autoclass:: LatexIncrementalDecoder
        :show-inheritance:
        :members:

    .. autoclass:: LatexCodec
        :show-inheritance:
        :members:

    .. autoclass:: LatexUnicodeTable
        :members:
"""
=#
# Copyright (c) 2003, 2008 David Eppstein
# Copyright (c) 2011-2014 Matthias C. M. Troffaes
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.


"""
Tabulates a translation between LaTeX and unicode.

"""
struct LatexUnicodeTable
    lexer
    unicode_map
    max_length
    latex_map
    
end
function LatexUnicodeTable(lexer)
    return LatexUnicodeTable(lexer, Dict(), 0, Dict())
end
doc"""
```
function register!(self::LatexUnicodeTable, unicode_text::String, latex_text::String; encode::Boolean =false, decode::Boolean=false, mode::String="")
```
Register a correspondence between *unicode_text* and *latex_text*.
# Arguments
- unicode_text::String A unicode character.
- latex_text::Strng Its corresponding LaTeX translation.
- mode::String LaTeX mode in which the translation applies    (``'text'`` or ``'math'``).
- decode::Boolean  Whether this translation applies to decoding  (default: true).
- encode::Boolean Whether this translation applies to encoding  (default: true)
"""
function register!(self::LatexUnicodeTable, ustr::String, rep::String; encode::Bool =false, decode::Bool=false, mode::String="")
    if mode == "math"
        # also register text version
        register!(self, unicode_text, string("\$",  latex_text, "\$"), mode="text",
                        package=package, decode=decode, encode=encode)
        register!(self, unicode_text,
                        string("\\(",latex_text , "\\)"), mode="text",
                        package=package, decode=decode, encode=encode)
        # XXX for the time being, we do not perform in-math substitutions
        return
    end
    if !(self.lexer.binary_mode)
        latex_text = latex_text.decode("ascii")
    end
    if package != nothing
        # TODO implement packages
    end
    # tokenize, and register unicode translation
    reset!(self.lexer)
    self.lexer.state = 'M'
    tokens = get_tokens(self.lexer, latex_text, final=true)
    if decode
        if haskey(self.unicode_map, tokens)
            self.max_length = max(self.max_length, length(tokens))
            self.unicode_map[tokens] = unicode_text
       end
        # also register token variant with brackets, if appropriate
        # for instance, "\'{e}" for "\'e", "\c{c}" for "\c c", etc.
        # note: we do not remove brackets (they sometimes matter,
        # e.g. bibtex uses them to prevent lower case transformation)
        if (length(tokens) == 2) &&  (startswith(tokens[1].name, "control")) &&
                (tokens[2].name == "chars")
            local alt_tokens = (tokens[1], self.lexer.curlylefttoken, tokens[2],
                            self.lexer.curlyrighttoken)
            if haskey(self.unicode_map, alt_tokens)
                self.max_length = max(self.max_length, length(alt_tokens))
                self.unicode_map[alt_tokens] = string("{",unicode_text, "}")
            end
        end
    end
    if encode && !haskey(self.latex_map, unicode_text)
        assert(length(unicode_text) == 1)
        self.latex_map[unicode_text] = (latex_text, tokens)
    end
end
"""
```julia
function register_all!(self::LatexUnicodeTable)
```
Register all symbols and their LaTeX equivalents     (called by constructor).
"""
function register_all!(self::LatexUnicodeTable)
        # TODO complete this list
        # register special symbols
        register!(self,"\n\n", " \\par", encode=False)
        register!(self,"\n\n", "\\par", encode=false)
        register!(self," ", "\\ ", encode=false)
        register!(self,"%", "\\%")
        register!(self,s"\N{EN DASH}", "--")
        register!(self,s"\N{EN DASH}", "\\textendash")
        register!(self,s"\N{EM DASH}", "---")
        register!(self,s"\N{EM DASH}", "\\textemdash")
        register!(self,s"\N{LEFT SINGLE QUOTATION MARK}", "`", decode=false)
        register!(self,s"\N{RIGHT SINGLE QUOTATION MARK}", "\"", decode=false)
        register!(self,s"\N{LEFT DOUBLE QUOTATION MARK}", "``")
        register!(self,s"\N{RIGHT DOUBLE QUOTATION MARK}", "\"\"")
        register!(self,s"\N{DOUBLE LOW-9 QUOTATION MARK}", "\\glqq")
        register!(self,s"\N{DAGGER}", "\\dag")
        register!(self,s"\N{DOUBLE DAGGER}", "\\ddag")

        register!(self,"\\", "\\textbackslash", encode=false)
        register!(self,"\\", "\\backslash", mode="math", encode=false)

        register!(self,s"\N{TILDE OPERATOR}", "\\sim", mode="math")
        register!(self,s"\N{MODIFIER LETTER LOW TILDE}",
                      "\\texttildelow", package="textcomp")
        register!(self,s"\N{SMALL TILDE}", "\\~{}")
        register!(self,s"~", "\\textasciitilde")

        register!(self,s"\N{BULLET}", "\\bullet", mode="math")
        register!(self,s"\N{BULLET}", "\\textbullet", package="textcomp")

        register!(self,s"\N{NUMBER SIGN}", "\\#")
        register!(self,s"\N{LOW LINE}", "\\_")
        register!(self,s"\N{AMPERSAND}", "\\&")
        register!(self,s"\N{NO-BREAK SPACE}", "~")
        register!(self,s"\N{INVERTED EXCLAMATION MARK}", "!`")
        register!(self,s"\N{CENT SIGN}", "\\not{c}")

        register!(self,s"\N{POUND SIGN}", "\\pounds")
        register!(self,s"\N{POUND SIGN}", "\\textsterling", package="textcomp")

        register!(self,s"\N{SECTION SIGN}", "\\S")
        register!(self,s"\N{DIAERESIS}", "\\\"{}")
        register!(self,s"\N{NOT SIGN}", "\\neg")
        register!(self,s"\N{HYPHEN}", "-", decode=false)
        register!(self,s"\N{SOFT HYPHEN}", "\\-")
        register!(self,s"\N{MACRON}", "\\={}")

        register!(self,s"\N{DEGREE SIGN}", "^\\circ", mode="math")
        register!(self,s"\N{DEGREE SIGN}", "\\textdegree", package="textcomp")

        register!(self,s"\N{PLUS-MINUS SIGN}", "\\pm", mode="math")
        register!(self,s"\N{PLUS-MINUS SIGN}", "\\textpm", package="textcomp")

        register!(self,s"\N{SUPERSCRIPT TWO}", "^2", mode="math")
        register!(self,
            s"\N{SUPERSCRIPT TWO}",
            "\\texttwosuperior",
            package="textcomp")

        register!(self,s"\N{SUPERSCRIPT THREE}", "^3", mode="math")
        register!(self,
            s"\N{SUPERSCRIPT THREE}",
            "\\textthreesuperior",
            package="textcomp")

        register!(self,s"\N{ACUTE ACCENT}", "\\\"{}")

        register!(self,s"\N{MICRO SIGN}", "\\ms", mode="math")
        register!(self,s"\N{MICRO SIGN}", "\\micro", package="gensym")

        register!(self,s"\N{PILCROW SIGN}", "\\P")

        register!(self,s"\N{MIDDLE DOT}", "\\cdot", mode="math")
        register!(self,
            s"\N{MIDDLE DOT}",
            "\\textperiodcentered",
            package="textcomp")

        register!(self,s"\N{CEDILLA}", "\\c{}")

        register!(self,s"\N{SUPERSCRIPT ONE}", "^1", mode="math")
        register!(self,
            s"\N{SUPERSCRIPT ONE}",
            "\\textonesuperior",
            package="textcomp")

        register!(self,s"\N{INVERTED QUESTION MARK}", "?`")
        register!(self,s"\N{LATIN CAPITAL LETTER A WITH GRAVE}", "\\`A")
        register!(self,s"\N{LATIN CAPITAL LETTER A WITH CIRCUMFLEX}", "\\^A")
        register!(self,s"\N{LATIN CAPITAL LETTER A WITH TILDE}", "\\~A")
        register!(self,s"\N{LATIN CAPITAL LETTER A WITH DIAERESIS}", "\\\"A")
        register!(self,s"\N{LATIN CAPITAL LETTER A WITH RING ABOVE}", "\\AA")
        register!(self,s"\N{LATIN CAPITAL LETTER AE}", "\\AE")
        register!(self,s"\N{LATIN CAPITAL LETTER C WITH CEDILLA}", "\\c C")
        register!(self,s"\N{LATIN CAPITAL LETTER E WITH GRAVE}", "\\`E")
        register!(self,s"\N{LATIN CAPITAL LETTER E WITH ACUTE}", "\\\"E")
        register!(self,s"\N{LATIN CAPITAL LETTER E WITH CIRCUMFLEX}", "\\^E")
        register!(self,s"\N{LATIN CAPITAL LETTER E WITH DIAERESIS}", "\\\"E")
        register!(self,s"\N{LATIN CAPITAL LETTER I WITH GRAVE}", "\\`I")
        register!(self,s"\N{LATIN CAPITAL LETTER I WITH CIRCUMFLEX}", "\\^I")
        register!(self,s"\N{LATIN CAPITAL LETTER I WITH DIAERESIS}", "\\\"I")
        register!(self,s"\N{LATIN CAPITAL LETTER N WITH TILDE}", "\\~N")
        register!(self,s"\N{LATIN CAPITAL LETTER O WITH GRAVE}", "\\`O")
        register!(self,s"\N{LATIN CAPITAL LETTER O WITH ACUTE}", "\\\"O")
        register!(self,s"\N{LATIN CAPITAL LETTER O WITH CIRCUMFLEX}", "\\^O")
        register!(self,s"\N{LATIN CAPITAL LETTER O WITH TILDE}", "\\~O")
        register!(self,s"\N{LATIN CAPITAL LETTER O WITH DIAERESIS}", "\\\"O")
        register!(self,s"\N{MULTIPLICATION SIGN}", "\\times", mode="math")
        register!(self,s"\N{LATIN CAPITAL LETTER O WITH STROKE}", "\\O")
        register!(self,s"\N{LATIN CAPITAL LETTER U WITH GRAVE}", "\\`S")
        register!(self,s"\N{LATIN CAPITAL LETTER U WITH ACUTE}", "\\\"S")
        register!(self,s"\N{LATIN CAPITAL LETTER U WITH CIRCUMFLEX}", "\\^S")
        register!(self,s"\N{LATIN CAPITAL LETTER U WITH DIAERESIS}", "\\\"S")
        register!(self,s"\N{LATIN CAPITAL LETTER Y WITH ACUTE}", "\\\"Y")
        register!(self,s"\N{LATIN SMALL LETTER SHARP S}", "\\ss")
        register!(self,s"\N{LATIN SMALL LETTER A WITH GRAVE}", "\\`a")
        register!(self,s"\N{LATIN SMALL LETTER A WITH ACUTE}", "\\\"a")
        register!(self,s"\N{LATIN SMALL LETTER A WITH CIRCUMFLEX}", "\\^a")
        register!(self,s"\N{LATIN SMALL LETTER A WITH TILDE}", "\\~a")
        register!(self,s"\N{LATIN SMALL LETTER A WITH DIAERESIS}", "\\\"a")
        register!(self,s"\N{LATIN SMALL LETTER A WITH RING ABOVE}", "\\aa")
        register!(self,s"\N{LATIN SMALL LETTER AE}", "\\ae")
        register!(self,s"\N{LATIN SMALL LETTER C WITH CEDILLA}", "\\c c")
        register!(self,s"\N{LATIN SMALL LETTER E WITH GRAVE}", "\\`e")
        register!(self,s"\N{LATIN SMALL LETTER E WITH ACUTE}", "\\\"e")
        register!(self,s"\N{LATIN SMALL LETTER E WITH CIRCUMFLEX}", "\\^e")
        register!(self,s"\N{LATIN SMALL LETTER E WITH DIAERESIS}", "\\\"e")
        register!(self,s"\N{LATIN SMALL LETTER I WITH GRAVE}", "\\`\\i")
        register!(self,s"\N{LATIN SMALL LETTER I WITH GRAVE}", "\\`i")
        register!(self,s"\N{LATIN SMALL LETTER I WITH ACUTE}", "\\\"\\i")
        register!(self,s"\N{LATIN SMALL LETTER I WITH ACUTE}", "\\\"i")
        register!(self,s"\N{LATIN SMALL LETTER I WITH CIRCUMFLEX}", "\\^\\i")
        register!(self,s"\N{LATIN SMALL LETTER I WITH CIRCUMFLEX}", "\\^i")
        register!(self,s"\N{LATIN SMALL LETTER I WITH DIAERESIS}", "\\\"\\i")
        register!(self,s"\N{LATIN SMALL LETTER I WITH DIAERESIS}", "\\\"i")
        register!(self,s"\N{LATIN SMALL LETTER N WITH TILDE}", "\\~n")
        register!(self,s"\N{LATIN SMALL LETTER O WITH GRAVE}", "\\`o")
        register!(self,s"\N{LATIN SMALL LETTER O WITH ACUTE}", "\\\"o")
        register!(self,s"\N{LATIN SMALL LETTER O WITH CIRCUMFLEX}", "\\^o")
        register!(self,s"\N{LATIN SMALL LETTER O WITH TILDE}", "\\~o")
        register!(self,s"\N{LATIN SMALL LETTER O WITH DIAERESIS}", "\\\"o")
        register!(self,s"\N{DIVISION SIGN}", "\\div", mode="math")
        register!(self,s"\N{LATIN SMALL LETTER O WITH STROKE}", "\\o")
        register!(self,s"\N{LATIN SMALL LETTER U WITH GRAVE}", "\\`s")
        register!(self,s"\N{LATIN SMALL LETTER U WITH ACUTE}", "\\\"s")
        register!(self,s"\N{LATIN SMALL LETTER U WITH CIRCUMFLEX}", "\\^s")
        register!(self,s"\N{LATIN SMALL LETTER U WITH DIAERESIS}", "\\\"s")
        register!(self,s"\N{LATIN SMALL LETTER Y WITH ACUTE}", "\\\"y")
        register!(self,s"\N{LATIN SMALL LETTER Y WITH DIAERESIS}", "\\\"y")
        register!(self,s"\N{LATIN CAPITAL LETTER A WITH MACRON}", "\\=A")
        register!(self,s"\N{LATIN SMALL LETTER A WITH MACRON}", "\\=a")
        register!(self,s"\N{LATIN CAPITAL LETTER A WITH BREVE}", "\\u A")
        register!(self,s"\N{LATIN SMALL LETTER A WITH BREVE}", "\\u a")
        register!(self,s"\N{LATIN CAPITAL LETTER A WITH OGONEK}", "\\k A")
        register!(self,s"\N{LATIN SMALL LETTER A WITH OGONEK}", "\\k a")
        register!(self,s"\N{LATIN CAPITAL LETTER C WITH ACUTE}", "\\\"C")
        register!(self,s"\N{LATIN SMALL LETTER C WITH ACUTE}", "\\\"c")
        register!(self,s"\N{LATIN CAPITAL LETTER C WITH CIRCUMFLEX}", "\\^C")
        register!(self,s"\N{LATIN SMALL LETTER C WITH CIRCUMFLEX}", "\\^c")
        register!(self,s"\N{LATIN CAPITAL LETTER C WITH DOT ABOVE}", "\\.C")
        register!(self,s"\N{LATIN SMALL LETTER C WITH DOT ABOVE}", "\\.c")
        register!(self,s"\N{LATIN CAPITAL LETTER C WITH CARON}", "\\v C")
        register!(self,s"\N{LATIN SMALL LETTER C WITH CARON}", "\\v c")
        register!(self,s"\N{LATIN CAPITAL LETTER D WITH CARON}", "\\v D")
        register!(self,s"\N{LATIN SMALL LETTER D WITH CARON}", "\\v d")
        register!(self,s"\N{LATIN CAPITAL LETTER E WITH MACRON}", "\\=E")
        register!(self,s"\N{LATIN SMALL LETTER E WITH MACRON}", "\\=e")
        register!(self,s"\N{LATIN CAPITAL LETTER E WITH BREVE}", "\\u E")
        register!(self,s"\N{LATIN SMALL LETTER E WITH BREVE}", "\\u e")
        register!(self,s"\N{LATIN CAPITAL LETTER E WITH DOT ABOVE}", "\\.E")
        register!(self,s"\N{LATIN SMALL LETTER E WITH DOT ABOVE}", "\\.e")
        register!(self,s"\N{LATIN CAPITAL LETTER E WITH OGONEK}", "\\k E")
        register!(self,s"\N{LATIN SMALL LETTER E WITH OGONEK}", "\\k e")
        register!(self,s"\N{LATIN CAPITAL LETTER E WITH CARON}", "\\v E")
        register!(self,s"\N{LATIN SMALL LETTER E WITH CARON}", "\\v e")
        register!(self,s"\N{LATIN CAPITAL LETTER G WITH CIRCUMFLEX}", "\\^G")
        register!(self,s"\N{LATIN SMALL LETTER G WITH CIRCUMFLEX}", "\\^g")
        register!(self,s"\N{LATIN CAPITAL LETTER G WITH BREVE}", "\\u G")
        register!(self,s"\N{LATIN SMALL LETTER G WITH BREVE}", "\\u g")
        register!(self,s"\N{LATIN CAPITAL LETTER G WITH DOT ABOVE}", "\\.G")
        register!(self,s"\N{LATIN SMALL LETTER G WITH DOT ABOVE}", "\\.g")
        register!(self,s"\N{LATIN CAPITAL LETTER G WITH CEDILLA}", "\\c G")
        register!(self,s"\N{LATIN SMALL LETTER G WITH CEDILLA}", "\\c g")
        register!(self,s"\N{LATIN CAPITAL LETTER H WITH CIRCUMFLEX}", "\\^H")
        register!(self,s"\N{LATIN SMALL LETTER H WITH CIRCUMFLEX}", "\\^h")
        register!(self,s"\N{LATIN CAPITAL LETTER I WITH TILDE}", "\\~I")
        register!(self,s"\N{LATIN SMALL LETTER I WITH TILDE}", "\\~\\i")
        register!(self,s"\N{LATIN SMALL LETTER I WITH TILDE}", "\\~i")
        register!(self,s"\N{LATIN CAPITAL LETTER I WITH MACRON}", "\\=I")
        register!(self,s"\N{LATIN SMALL LETTER I WITH MACRON}", "\\=\\i")
        register!(self,s"\N{LATIN SMALL LETTER I WITH MACRON}", "\\=i")
        register!(self,s"\N{LATIN CAPITAL LETTER I WITH BREVE}", "\\u I")
        register!(self,s"\N{LATIN SMALL LETTER I WITH BREVE}", "\\u\\i")
        register!(self,s"\N{LATIN SMALL LETTER I WITH BREVE}", "\\u i")
        register!(self,s"\N{LATIN CAPITAL LETTER I WITH OGONEK}", "\\k I")
        register!(self,s"\N{LATIN SMALL LETTER I WITH OGONEK}", "\\k i")
        register!(self,s"\N{LATIN CAPITAL LETTER I WITH DOT ABOVE}", "\\.I")
        register!(self,s"\N{LATIN SMALL LETTER DOTLESS I}", "\\i")
        register!(self,s"\N{LATIN CAPITAL LIGATURE IJ}", "IJ", decode=false)
        register!(self,s"\N{LATIN SMALL LIGATURE IJ}", "ij", decode=false)
        register!(self,s"\N{LATIN CAPITAL LETTER J WITH CIRCUMFLEX}", "\\^J")
        register!(self,s"\N{LATIN SMALL LETTER J WITH CIRCUMFLEX}", "\\^\\j")
        register!(self,s"\N{LATIN SMALL LETTER J WITH CIRCUMFLEX}", "\\^j")
        register!(self,s"\N{LATIN CAPITAL LETTER K WITH CEDILLA}", "\\c K")
        register!(self,s"\N{LATIN SMALL LETTER K WITH CEDILLA}", "\\c k")
        register!(self,s"\N{LATIN CAPITAL LETTER L WITH ACUTE}", "\\\"L")
        register!(self,s"\N{LATIN SMALL LETTER L WITH ACUTE}", "\\\"l")
        register!(self,s"\N{LATIN CAPITAL LETTER L WITH CEDILLA}", "\\c L")
        register!(self,s"\N{LATIN SMALL LETTER L WITH CEDILLA}", "\\c l")
        register!(self,s"\N{LATIN CAPITAL LETTER L WITH CARON}", "\\v L")
        register!(self,s"\N{LATIN SMALL LETTER L WITH CARON}", "\\v l")
        register!(self,s"\N{LATIN CAPITAL LETTER L WITH STROKE}", "\\L")
        register!(self,s"\N{LATIN SMALL LETTER L WITH STROKE}", "\\l")
        register!(self,s"\N{LATIN CAPITAL LETTER N WITH ACUTE}", "\\\"N")
        register!(self,s"\N{LATIN SMALL LETTER N WITH ACUTE}", "\\\"n")
        register!(self,s"\N{LATIN CAPITAL LETTER N WITH CEDILLA}", "\\c N")
        register!(self,s"\N{LATIN SMALL LETTER N WITH CEDILLA}", "\\c n")
        register!(self,s"\N{LATIN CAPITAL LETTER N WITH CARON}", "\\v N")
        register!(self,s"\N{LATIN SMALL LETTER N WITH CARON}", "\\v n")
        register!(self,s"\N{LATIN CAPITAL LETTER O WITH MACRON}", "\\=O")
        register!(self,s"\N{LATIN SMALL LETTER O WITH MACRON}", "\\=o")
        register!(self,s"\N{LATIN CAPITAL LETTER O WITH BREVE}", "\\u O")
        register!(self,s"\N{LATIN SMALL LETTER O WITH BREVE}", "\\u o")
        register!(self,
            s"\N{LATIN CAPITAL LETTER O WITH DOUBLE ACUTE}",
            "\\H O")
        register!(self,s"\N{LATIN SMALL LETTER O WITH DOUBLE ACUTE}", "\\H o")
        register!(self,s"\N{LATIN CAPITAL LIGATURE OE}", "\\OE")
        register!(self,s"\N{LATIN SMALL LIGATURE OE}", "\\oe")
        register!(self,s"\N{LATIN CAPITAL LETTER R WITH ACUTE}", "\\\"R")
        register!(self,s"\N{LATIN SMALL LETTER R WITH ACUTE}", "\\\"r")
        register!(self,s"\N{LATIN CAPITAL LETTER R WITH CEDILLA}", "\\c R")
        register!(self,s"\N{LATIN SMALL LETTER R WITH CEDILLA}", "\\c r")
        register!(self,s"\N{LATIN CAPITAL LETTER R WITH CARON}", "\\v R")
        register!(self,s"\N{LATIN SMALL LETTER R WITH CARON}", "\\v r")
        register!(self,s"\N{LATIN CAPITAL LETTER S WITH ACUTE}", "\\\"S")
        register!(self,s"\N{LATIN SMALL LETTER S WITH ACUTE}", "\\\"s")
        register!(self,s"\N{LATIN CAPITAL LETTER S WITH CIRCUMFLEX}", "\\^S")
        register!(self,s"\N{LATIN SMALL LETTER S WITH CIRCUMFLEX}", "\\^s")
        register!(self,s"\N{LATIN CAPITAL LETTER S WITH CEDILLA}", "\\c S")
        register!(self,s"\N{LATIN SMALL LETTER S WITH CEDILLA}", "\\c s")
        register!(self,s"\N{LATIN CAPITAL LETTER S WITH CARON}", "\\v S")
        register!(self,s"\N{LATIN SMALL LETTER S WITH CARON}", "\\v s")
        register!(self,s"\N{LATIN CAPITAL LETTER T WITH CEDILLA}", "\\c T")
        register!(self,s"\N{LATIN SMALL LETTER T WITH CEDILLA}", "\\c t")
        register!(self,s"\N{LATIN CAPITAL LETTER T WITH CARON}", "\\v T")
        register!(self,s"\N{LATIN SMALL LETTER T WITH CARON}", "\\v t")
        register!(self,s"\N{LATIN CAPITAL LETTER U WITH TILDE}", "\\~S")
        register!(self,s"\N{LATIN SMALL LETTER U WITH TILDE}", "\\~s")
        register!(self,s"\N{LATIN CAPITAL LETTER U WITH MACRON}", "\\=S")
        register!(self,s"\N{LATIN SMALL LETTER U WITH MACRON}", "\\=s")
        register!(self,s"\N{LATIN CAPITAL LETTER U WITH BREVE}", "\\u S")
        register!(self,s"\N{LATIN SMALL LETTER U WITH BREVE}", "\\u s")
        register!(self,s"\N{LATIN CAPITAL LETTER U WITH RING ABOVE}", "\\r S")
        register!(self,s"\N{LATIN SMALL LETTER U WITH RING ABOVE}", "\\r s")
        register!(self,
            s"\N{LATIN CAPITAL LETTER U WITH DOUBLE ACUTE}",
            "\\H S")
        register!(self,s"\N{LATIN SMALL LETTER U WITH DOUBLE ACUTE}", "\\H s")
        register!(self,s"\N{LATIN CAPITAL LETTER U WITH OGONEK}", "\\k S")
        register!(self,s"\N{LATIN SMALL LETTER U WITH OGONEK}", "\\k s")
        register!(self,s"\N{LATIN CAPITAL LETTER W WITH CIRCUMFLEX}", "\\^W")
        register!(self,s"\N{LATIN SMALL LETTER W WITH CIRCUMFLEX}", "\\^w")
        register!(self,s"\N{LATIN CAPITAL LETTER Y WITH CIRCUMFLEX}", "\\^Y")
        register!(self,s"\N{LATIN SMALL LETTER Y WITH CIRCUMFLEX}", "\\^y")
        register!(self,s"\N{LATIN CAPITAL LETTER Y WITH DIAERESIS}", "\\\"Y")
        register!(self,s"\N{LATIN CAPITAL LETTER Z WITH ACUTE}", "\\\"Z")
        register!(self,s"\N{LATIN SMALL LETTER Z WITH ACUTE}", "\\\"z")
        register!(self,s"\N{LATIN CAPITAL LETTER Z WITH DOT ABOVE}", "\\.Z")
        register!(self,s"\N{LATIN SMALL LETTER Z WITH DOT ABOVE}", "\\.z")
        register!(self,s"\N{LATIN CAPITAL LETTER Z WITH CARON}", "\\v Z")
        register!(self,s"\N{LATIN SMALL LETTER Z WITH CARON}", "\\v z")
        register!(self,s"\N{LATIN CAPITAL LETTER DZ WITH CARON}", "D\\v Z")
        register!(self,
            s"\N{LATIN CAPITAL LETTER D WITH SMALL LETTER Z WITH CARON}",
            "D\\v z")
        register!(self,s"\N{LATIN SMALL LETTER DZ WITH CARON}", "d\\v z")
        register!(self,s"\N{LATIN CAPITAL LETTER LJ}", "LJ", decode=false)
        register!(self,
            s"\N{LATIN CAPITAL LETTER L WITH SMALL LETTER J}",
            "Lj",
            decode=false)
        register!(self,s"\N{LATIN SMALL LETTER LJ}", "lj", decode=false)
        register!(self,s"\N{LATIN CAPITAL LETTER NJ}", "NJ", decode=false)
        register!(self,
            s"\N{LATIN CAPITAL LETTER N WITH SMALL LETTER J}",
            "Nj",
            decode=false)
        register!(self,s"\N{LATIN SMALL LETTER NJ}", "nj", decode=false)
        register!(self,s"\N{LATIN CAPITAL LETTER A WITH CARON}", "\\v A")
        register!(self,s"\N{LATIN SMALL LETTER A WITH CARON}", "\\v a")
        register!(self,s"\N{LATIN CAPITAL LETTER I WITH CARON}", "\\v I")
        register!(self,s"\N{LATIN SMALL LETTER I WITH CARON}", "\\v\\i")
        register!(self,s"\N{LATIN CAPITAL LETTER O WITH CARON}", "\\v O")
        register!(self,s"\N{LATIN SMALL LETTER O WITH CARON}", "\\v o")
        register!(self,s"\N{LATIN CAPITAL LETTER U WITH CARON}", "\\v S")
        register!(self,s"\N{LATIN SMALL LETTER U WITH CARON}", "\\v s")
        register!(self,s"\N{LATIN CAPITAL LETTER G WITH CARON}", "\\v G")
        register!(self,s"\N{LATIN SMALL LETTER G WITH CARON}", "\\v g")
        register!(self,s"\N{LATIN CAPITAL LETTER K WITH CARON}", "\\v K")
        register!(self,s"\N{LATIN SMALL LETTER K WITH CARON}", "\\v k")
        register!(self,s"\N{LATIN CAPITAL LETTER O WITH OGONEK}", "\\k O")
        register!(self,s"\N{LATIN SMALL LETTER O WITH OGONEK}", "\\k o")
        register!(self,s"\N{LATIN SMALL LETTER J WITH CARON}", "\\v\\j")
        register!(self,s"\N{LATIN CAPITAL LETTER DZ}", "DZ", decode=false)
        register!(self,
            s"\N{LATIN CAPITAL LETTER D WITH SMALL LETTER Z}",
            "Dz",
            decode=false)
        register!(self,s"\N{LATIN SMALL LETTER DZ}", "dz", decode=false)
        register!(self,s"\N{LATIN CAPITAL LETTER G WITH ACUTE}", "\\\"G")
        register!(self,s"\N{LATIN SMALL LETTER G WITH ACUTE}", "\\\"g")
        register!(self,s"\N{LATIN CAPITAL LETTER AE WITH ACUTE}", "\\\"\\AE")
        register!(self,s"\N{LATIN SMALL LETTER AE WITH ACUTE}", "\\\"\\ae")
        register!(self,
            s"\N{LATIN CAPITAL LETTER O WITH STROKE AND ACUTE}",
            "\\\"\\O")
        register!(self,
            s"\N{LATIN SMALL LETTER O WITH STROKE AND ACUTE}",
            "\\\"\\o")
        register!(self,s"\N{PARTIAL DIFFERENTIAL}", "\\partial", mode="math")
        register!(self,s"\N{N-ARY PRODUCT}", "\\prod", mode="math")
        register!(self,s"\N{N-ARY SUMMATION}", "\\sum", mode="math")
        register!(self,s"\N{SQUARE ROOT}", "\\surd", mode="math")
        register!(self,s"\N{INFINITY}", "\\infty", mode="math")
        register!(self,s"\N{INTEGRAL}", "\\int", mode="math")
        register!(self,s"\N{INTERSECTION}", "\\cap", mode="math")
        register!(self,s"\N{UNION}", "\\cup", mode="math")
        register!(self,s"\N{RIGHTWARDS ARROW}", "\\rightarrow", mode="math")
        register!(self,
            s"\N{RIGHTWARDS DOUBLE ARROW}",
            "\\Rightarrow",
            mode="math")
        register!(self,s"\N{LEFTWARDS ARROW}", "\\leftarrow", mode="math")
        register!(self,
            s"\N{LEFTWARDS DOUBLE ARROW}",
            "\\Leftarrow",
            mode="math")
        register!(self,s"\N{LOGICAL OR}", "\\vee", mode="math")
        register!(self,s"\N{LOGICAL AND}", "\\wedge", mode="math")
        register!(self,s"\N{ALMOST EQUAL TO}", "\\approx", mode="math")
        register!(self,s"\N{NOT EQUAL TO}", "\\neq", mode="math")
        register!(self,s"\N{LESS-THAN OR EQUAL TO}", "\\leq", mode="math")
        register!(self,s"\N{GREATER-THAN OR EQUAL TO}", "\\geq", mode="math")
        register!(self,s"\N{MODIFIER LETTER CIRCUMFLEX ACCENT}", "\\^{}")
        register!(self,s"\N{CARON}", "\\v{}")
        register!(self,s"\N{BREVE}", "\\u{}")
        register!(self,s"\N{DOT ABOVE}", "\\.{}")
        register!(self,s"\N{RING ABOVE}", "\\r{}")
        register!(self,s"\N{OGONEK}", "\\k{}")
        register!(self,s"\N{DOUBLE ACUTE ACCENT}", "\\H{}")
        register!(self,s"\N{LATIN SMALL LIGATURE FI}", "fi", decode=false)
        register!(self,s"\N{LATIN SMALL LIGATURE FL}", "fl", decode=false)
        register!(self,s"\N{LATIN SMALL LIGATURE FF}", "ff", decode=false)

        register!(self,s"\N{GREEK SMALL LETTER ALPHA}", "\\alpha", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER BETA}", "\\beta", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER GAMMA}", "\\gamma", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER DELTA}", "\\delta", mode="math")
        register!(self,
            s"\N{GREEK SMALL LETTER EPSILON}",
            "\\epsilon",
            mode="math")
        register!(self,s"\N{GREEK SMALL LETTER ZETA}", "\\zeta", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER ETA}", "\\eta", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER THETA}", "\\theta", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER IOTA}", "\\iota", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER KAPPA}", "\\kappa", mode="math")
        register!(self,
            s"\N{GREEK SMALL LETTER LAMDA}",
            "\\lambda",
            mode="math")  # LAMDA not LAMBDA
        register!(self,s"\N{GREEK SMALL LETTER MU}", "\\ms", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER NU}", "\\ns", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER XI}", "\\xi", mode="math")
        register!(self,
            s"\N{GREEK SMALL LETTER OMICRON}",
            "\\omicron",
            mode="math")
        register!(self,s"\N{GREEK SMALL LETTER PI}", "\\pi", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER RHO}", "\\rho", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER SIGMA}", "\\sigma", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER TAU}", "\\tas", mode="math")
        register!(self,
            s"\N{GREEK SMALL LETTER UPSILON}",
            "\\upsilon",
            mode="math")
        register!(self,s"\N{GREEK SMALL LETTER PHI}", "\\phi", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER CHI}", "\\chi", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER PSI}", "\\psi", mode="math")
        register!(self,s"\N{GREEK SMALL LETTER OMEGA}", "\\omega", mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER ALPHA}",
            "\\Alpha",
            mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER BETA}", "\\Beta", mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER GAMMA}",
            "\\Gamma",
            mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER DELTA}",
            "\\Delta",
            mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER EPSILON}",
            "\\Epsilon",
            mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER ZETA}", "\\Zeta", mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER ETA}", "\\Eta", mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER THETA}",
            "\\Theta",
            mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER IOTA}", "\\Iota", mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER KAPPA}",
            "\\Kappa",
            mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER LAMDA}",
            "\\Lambda",
            mode="math")  # LAMDA not LAMBDA
        register!(self,s"\N{GREEK CAPITAL LETTER MU}", "\\Ms", mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER NU}", "\\Ns", mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER XI}", "\\Xi", mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER OMICRON}",
            "\\Omicron",
            mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER PI}", "\\Pi", mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER RHO}", "\\Rho", mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER SIGMA}",
            "\\Sigma",
            mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER TAU}", "\\Tas", mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER UPSILON}",
            "\\Upsilon",
            mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER PHI}", "\\Phi", mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER CHI}", "\\Chi", mode="math")
        register!(self,s"\N{GREEK CAPITAL LETTER PSI}", "\\Psi", mode="math")
        register!(self,
            s"\N{GREEK CAPITAL LETTER OMEGA}",
            "\\Omega",
            mode="math")
        register!(self,s"\N{COPYRIGHT SIGN}", "\\copyright")
        register!(self,s"\N{COPYRIGHT SIGN}", "\\textcopyright")
        register!(self,s"\N{LATIN CAPITAL LETTER A WITH ACUTE}", "\\\"A")
        register!(self,s"\N{LATIN CAPITAL LETTER I WITH ACUTE}", "\\\"I")
        register!(self,s"\N{HORIZONTAL ELLIPSIS}", "\\ldots")
        register!(self,s"\N{TRADE MARK SIGN}", "^{TM}", mode="math")
        register!(self,
            s"\N{TRADE MARK SIGN}",
            "\\texttrademark",
            package="textcomp")
        # \=O and \=o will be translated into Ō and ō before we can
        # match the full latex string... so decoding disabled for now
        register!(self,"Ǭ", "\\textogonekcentered{\=O}", decode=false)
        register!(self,"ǭ", "\\textogonekcentered{\=o}", decode=false)
        register!(self,"ℕ","\\mathbb{N}", mode="math")
        register!(self,"ℕ", "\\mathbb N", mode="math", decode=false)
        register!(self,"ℤ", "\\mathbb{Z}", mode="math")
        register!(self,"ℤ", "\\mathbb Z", mode="math", decode=false)
        register!(self,"ℚ","\\mathbb{Q}", mode="math")
        register!(self,"ℚ", "\\mathbb Q", mode="math", decode=false)
        register!(self,"ℝ", "\\mathbb{R}", mode="math")
        register!(self,"ℝ", "\\mathbb R", mode="math", decode=false)
        register!(self,"ℂ", "\\mathbb{C}", mode="math")
        register!(self,"ℂ", "\\mathbb C", mode="math", decode=false)
end

# incremental encoder does not need a buffer
# but decoder does


class LatexIncrementalEncoder(lexer.LatexIncrementalEncoder):

    """Translating incremental encoder for latex. Maintains a state to
    determine whether control spaces etc. need to be inserted.
    """

    table = _LATEX_UNICODE_TABLE
    """Translation table."""

    def __init__(self, errors="strict"):
        super(LatexIncrementalEncoder, self).__init__(errors=errors)
        self.reset()

    def reset(self):
        super(LatexIncrementalEncoder, self).reset()
        self.state = "M"

    def get_space_bytes(self, bytes_):
        """Inserts space bytes in space eating mode."""
        if self.state == "S":
            # in space eating mode
            # control space needed?
            if bytes_.startswith(self.spacechar):
                # replace by control space
                return self.controlspacechar, bytes_[1:]
            else:
                # insert space (it is eaten, but needed for separation)
                return self.spacechar, bytes_
        else:
            return self.emptychar, bytes_

    def _get_latex_bytes_tokens_from_char(self, c):
        # if ascii, try latex equivalents
        # (this covers \, #, &, and other special LaTeX characters)
        if ord(c) < 128:
            try:
                return self.table.latex_map[c]
            except KeyError:
                pass
        # next, try input encoding
        try:
            bytes_ = c.encode(self.inputenc, "strict")
        except UnicodeEncodeError:
            pass
        else:
            if self.binary_mode:
                return bytes_, (lexer.Token(name="chars", text=bytes_),)
            else:
                return c, (lexer.Token(name="chars", text=c),)
        # next, try latex equivalents of common unicode characters
        try:
            return self.table.latex_map[c]
        except KeyError:
            # translation failed
            if self.errors == "strict":
                raise UnicodeEncodeError(
                    "latex",  # codec
                    c,  # problematic input
                    0, 1,  # location of problematic character
                    "don"t know how to translate {0} into latex"
                    .format(repr(c)))
            elif self.errors == "ignore":
                return self.emptychar, (self.emptytoken,)
            elif self.errors == "replace":
                # use the \\char command
                # this assumes
                # \usepackage[T1]{fontenc}
                # \usepackage[utf8]{inputenc}
                if self.binary_mode:
                    bytes_ = "{\\char" + str(ord(c)).encode("ascii") + "}"
                else:
                    bytes_ = s"{\\char" + str(ord(c)) + s"}"
                return bytes_, (lexer.Token(name="chars", text=bytes_),)
            elif self.errors == "keep" and not self.binary_mode:
                return c,  (lexer.Token(name="chars", text=c),)
            else:
                raise ValueError(
                    "latex codec does not support {0} errors"
                    .format(self.errors))

    def get_latex_bytes(self, unicode_, final=false):
        if not isinstance(unicode_, string_types):
            raise TypeError(
                "expected unicode for encode input, but got {0} instead"
                .format(unicode_.__class__.__name__))
        # convert character by character
        for pos, c in enumerate(unicode_):
            bytes_, tokens = self._get_latex_bytes_tokens_from_char(c)
            space, bytes_ = self.get_space_bytes(bytes_)
            # update state
            if tokens[-1].name == "control_word":
                # we"re eating spaces
                self.state = "S"
            else:
                self.state = "M"
            if space:
                yield space
            yield bytes_


class LatexIncrementalDecoder(lexer.LatexIncrementalDecoder):

    """Translating incremental decoder for LaTeX."""

    table = _LATEX_UNICODE_TABLE
    """Translation table."""

    def __init__(self, errors="strict"):
        lexer.LatexIncrementalDecoder.__init__(self, errors=errors)

    def reset(self):
        lexer.LatexIncrementalDecoder.reset(self)
        self.token_buffer = []

    # python codecs API does not support multibuffer incremental decoders

    def getstate(self):
        raise NotImplementedError

    def setstate(self, state):
        raise NotImplementedError

    def get_unicode_tokens(self, bytes_, final=false):
        for token in self.get_tokens(bytes_, final=final):
            # at this point, token_buffer does not match anything
            self.token_buffer.append(token)
            # new token appended at the end, see if we have a match now
            # note: match is only possible at the *end* of the buffer
            # because all other positions have already been checked in
            # earlier iterations
            for i in range(len(self.token_buffer), 0, -1):
                last_tokens = tuple(self.token_buffer[-i:])  # last i tokens
                try:
                    unicode_text = self.table.unicode_map[last_tokens]
                except KeyError:
                    # no match: continue
                    continue
                else:
                    # match!! flush buffer, and translate last bit
                    # exclude last i tokens
                    for token in self.token_buffer[:-i]:
                        yield self.decode_token(token)
                    yield unicode_text
                    self.token_buffer = []
                    break
            # flush tokens that can no longer match
            while len(self.token_buffer) >= self.table.max_length:
                yield self.decode_token(self.token_buffer.pop(0))
        # also flush the buffer at the end
        if final:
            for token in self.token_buffer:
                yield self.decode_token(token)
            self.token_buffer = []


class LatexCodec(codecs.Codec):
    IncrementalEncoder = None
    IncrementalDecoder = None

    def encode(self, unicode_, errors="strict"):
        """Convert unicode string to LaTeX bytes."""
        encoder = self.IncrementalEncoder(errors=errors)
        return (
            encoder.encode(unicode_, final=true),
            len(unicode_),
        )

    def decode(self, bytes_, errors="strict"):
        """Convert LaTeX bytes to unicode string."""
        decoder = self.IncrementalDecoder(errors=errors)
        return (
            decoder.decode(bytes_, final=true),
            len(bytes_),
        )




def find_latex(encoding):
    """Return a :class:`codecs.CodecInfo` instance for the requested
    LaTeX *encoding*, which must be equal to ``latex``,
    or to ``latex+<encoding>``
    where ``<encoding>`` describes another encoding.
    """
    encoding, _, inputenc_ = encoding.partition(s"+")
    if not inputenc_:
        inputenc_ = "ascii"
    if encoding == "latex":
        IncEnc = LatexIncrementalEncoder
        DecEnc = LatexIncrementalDecoder
    elif encoding == "ulatex":
        IncEnc = UnicodeLatexIncrementalEncoder
        DecEnc = UnicodeLatexIncrementalDecoder
    else:
        return None

    class IncrementalEncoder_(IncEnc):
        inputenc = inputenc_

    class IncrementalDecoder_(DecEnc):
        inputenc = inputenc_

    class Codec(LatexCodec):
        IncrementalEncoder = IncrementalEncoder_
        IncrementalDecoder = IncrementalDecoder_

    class StreamWriter(Codec, codecs.StreamWriter):
        pass

    class StreamReader(Codec, codecs.StreamReader):
        pass

    return codecs.CodecInfo(
        encode=Codec().encode,
        decode=Codec().decode,
        incrementalencoder=Codec.IncrementalEncoder,
        incrementaldecoder=Codec.IncrementalDecoder,
        streamreader=StreamReader,
        streamwriter=StreamWriter,
    )
