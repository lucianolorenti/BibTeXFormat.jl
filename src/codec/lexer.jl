#This module contains all classes for lexing LaTeX code, as well as
#    general purpose base classes for incremental LaTeX decoders and
#    encoders, which could be useful in case you are writing your own
#    custom LaTeX codec.

struct Token
    name::String
    text::String
end

# implementation note: we derive from IncrementalDecoder because this
# class serves excellently as a base class for incremental decoders,
# but of course we don't decode yet until later

struct MetaLatexCoder
    emptytoken::Token
    parttoken::Token
    spacetoken::Token
    replacetoken::Token
    curlylefttoken::Token
    curylrighttoken::Token
    emptychar::Token
    spacechar::Token
    controlspacechar::Token
    binaymode::Boolean
end
function MetaLatexCoder()
    local emptytoken = Token(u"unknown", cls._fixit(b""))
    local partoken = Token("control_word", cls._fixit(b"\\par"))
    local spacetoken = Token("space", cls._fixit(b" "))
    local replacetoken = Token(
            "chars", b"?" if cls.binary_mode else u"\ufffd")
    local curlylefttoken = Token("chars", cls._fixit(b"{"))
    local curlyrighttoken = Token("chars", cls._fixit(b"}"))
    local emptychar = cls._fixit(b"")
    local spacechar = cls._fixit(b" ")
    local controlspacechar = cls._fixit(b"\\ ")
    return MetaLatexCoder(emptytoken, parttoken, spacetoken, replacetoken, curlylefttoken, curlyrighttoken, emptychar, spacechar, controlspaceshar, false)
end
function fixit!(cls::MetaLatexCoder, bytes)
    if cls.binary_mode
        return bytes
    else
        decode(bytes,"ascii")
    end
end

"""
Metaclass for :class:`RegexpLexer`. Compiles tokens into aregular expression.
"""
struct MetaRegexpLexer
    latexCoder::MetaLatexCoder
    regexp
end
function MetaRegexpLexer()
    local mlc = MetaLatexCoder()
    local regexp_string = fixit(mlc,"|".join( b"(?P<" + name.encode("ascii") + b">" + regexp + b")"  for name, regexp in cls.tokens))
    local regexp = re.compile(regexp_string, re.DOTALL)
    return MetaRegexpLexer(mlc, regexp)
end

"""
Abstract base class for regexp based lexers.
"""
struct RegexpLexer
    tokens::Vector
    erros::Any
    raw_buffer::String
end
function RegexpLexer(;errors::String="strict")
    local rl =  RegexpLexer([], errors,"")
    reset!(rl)
end
function reset!(self::RegexpLexer)
    self.raw_buffer = self.emptytoken
    self.
end
function getstate(self::RegexpLexer)
    return (self.raw_buffer.text, 0)
end

"""
Set state. The *state* must correspond to the return value    of a previous :meth:`getstate` call.
"""
function setstate(self::RegexpLexer, state)
    self.raw_buffer = "a";

    self.raw_buffer = Token('unknown', state[1])
end

"""Yield tokens without any further processing. Tokens are one of:

- ``\\<word>``: a control word (i.e. a command)
- ``\\<symbol>``: a control symbol (i.e. \\^ etc.)
- ``#<n>``: a parameter
- a series of byte characters
"""
function get_raw_tokens(self::RegexpLexer, bytes_, final=false)
    if length(self.raw_buffer.text) > 0
        bytes_ = string(self.raw_buffer.text, bytes_)
        self.raw_buffer = self.emptytoken
        for match in self.regexp.finditer(bytes_):
            # yield the buffer token
            if self.raw_buffer.text
                yield self.raw_buffer
            end
            # fill buffer with next token
            self.raw_buffer = Token(match.lastgroup, match.group(0))
        end
        if final
            for token in self.flush_raw_tokens():
                yield token
            end
        end

end

"""
Flush the raw token buffer.
"""
function flush_raw_tokens(self::)
    local buffers = []
    if length(self.raw_buffer.text)>0
        push!(buffers, self.raw_buffer)
        self.raw_buffer = self.emptytoken
    end
    return buffers
end

"""
A very simple lexer for tex/latex bytes.
"""
struct LatexLexer
    rlexer::RegexpLexer
    tokens::Vector
end
function LatexLexer()

    # implementation note: every token **must** be decodable by inputenc
    # List of token names, and the regular expressions they match.
    local tokens = [
        # comment: for ease, and for speed, we handle it as a token
        ("comment", r"(?<![\\])%[^\n]*"),
        # control tokens
        # in latex, some control tokens skip following whitespace
        # ('control-word' and 'control-symbol')
        # others do not ('control-symbol-x')
        # XXX TBT says no control symbols skip whitespace (except '\ ')
        # XXX but tests reveal otherwise?
        ("control_word", r"[\\][a-zA-Z]+"),
        ("control_symbol", r"[\\][~' br\"'\" br'\"` =^!]"),
        # TODO should only match ascii
        ("control_symbol_x", r"[\\][^a-zA-Z]"),
        # parameter tokens
        # also support a lone hash so we can lex things like b'#a'
        ("parameter", "\#[0-9]|\#"),
        # any remaining characters; for ease we also handle space and
        # newline as tokens
        # XXX TBT does not mention \t to be a space character as well
        # XXX but tests reveal otherwise?
        ("space", " |\t"),
        ("newline", "\n"),
        ("mathshift", "[\$][\$]|[\$]"),
        # note: some chars joined together to make it easier to detect
        # symbols that have a special function (i.e. --, ---, etc.)
        ("chars",
         "---|--|-|[`][`]"
         "|['][']"
         "|[?][`]|[!][`]"
         # separate chars because brackets are optional
         # e.g. fran\\c cais = fran\\c{c}ais in latex
         # so only way to detect \\c acting on c only is this way
         "|[0-9a-zA-Z{}]"
         # we have to join everything else together to support
         # multibyte encodings: every token must be decodable!!
         # this means for instance that \\c öké is NOT equivalent to
         # \\c{ö}ké
         "|[^ %#$\n\\]+"),
        # trailing garbage which we cannot decode otherwise
        # (such as a lone '\' at the end of a buffer)
        # is never emitted, but used internally by the buffer
        ("unknown", "."),
       ]
    return LatexLexer(RegexpLexer(), tokens)
end

"""
A very simple incremental lexer for tex/latex code. Roughly   follows the state machine described in Tex By Topic, Chapter 2.

    The generated tokens satisfy:

    * no newline characters: paragraphs are separated by '\\par'
    * spaces following control tokens are compressed
"""
struct  LatexIncrementalLexer
    lexer::LatexLexer
end
function reset(self::LatexIncrementalLexer)
    super(LatexIncrementalLexer, self).reset()
    # three possible states:
    # newline (N), skipping spaces (S), and middle of line (M)
    self.state = 'N'
    # inline math mode?
    self.inline_math = False
end
function getstate(self::LatexIncrementalLexer)
    # state 'M' is most common, so let that be zero
    if self.inline_math

    return (
        self.raw_buffer,
        {'M': 0, 'N': 1, 'S': 2}[self.state] |
        (4 if self.inline_math else 0)
    )
end
function setstate(self::LatexIncrementalLexer, state)
    self.raw_buffer = state[1]
    self.state = {0: 'M', 1: 'N', 2: 'S'}[state[2] & 3]
    self.inline_math = Bool(state[2] & 4)
end

"""
Yield tokens while maintaining a state. Also skip whitespace after control words and (some) control symbols.
Replaces newlines by spaces and \\par commands depending on    the context.
"""
function get_tokens(self::LatexIncrementalLexer, bytes_ final::Bool=false)

        # current position relative to the start of bytes_ in the sequence
        # of bytes that have been decoded
        pos = -length(self.raw_buffer.text)
        for token in get_raw_tokens(self, bytes_, final=final)
            pos = pos + length(token.text)
            assert(pos >= 0)  # first token includes at least self.raw_buffer
            if token.name == "newline"
                if self.state == 'N'
                    # if state was 'N', generate new paragraph
                    push!(tokens, self.parttoken)
                elseif self.state == 'S':
                    # switch to 'N' state, do not generate a space
                    self.state = 'N'
                elseif self.state == 'M':
                    # switch to 'N' state, generate a space
                    self.state = 'N'
                    push!(tokens, self.spacetoken)
                else
                    throw("unknown tex state {$self.state}")
                end
            elseif token.name == "space"
                if self.state == "N"
                    # remain in 'N' state, no space token generated
                    pass
                elseif self.state == "S"
                    # remain in 'S' state, no space token generated
                    pass
                elseif self.state == "M"
                    # in M mode, generate the space,
                    # but switch to space skip mode
                    self.state = "S"
                    push!(tokens, token)
                else
                    throw("unknown state {$self.state}")
                end
            elseif token.name == "mathshift"
                self.inline_math = ! self.inline_math
                self.state = "M"
                push!(tokens, token)
            elseif token.name == "parameter"
                self.state = "M"
                push!(tokens, token)
            elseif token.name == "control_word"
                # go to space skip mode
                self.state = "S"
                push!(tokens, token)
            elseif token.name == "control_symbol":
                # go to space skip mode
                self.state = "S"
                push!(tokens, token)
            elseif token.name == "control_symbol_x":
                # don't skip following space, so go to M mode
                self.state = "M"
                push!(tokens, token)
            elseif token.name == "comment"
                # no token is generated
                # note: comment does not include the newline
                self.state = "S"
            elseif token.name == "chars"
                self.state = "M"
                push!(tokens, token)
            elseif token.name == 'unknown'
                if self.errors == "strict"
                    # hack around a bug in Python: UnicodeDecodeError
                    # expects binary input
                    if not self.binary_mode:
                        bytes_ = bytes_.encode("utf8")
                    # current position within bytes_
                    # this is the position right after the unknown token
                    raise UnicodeDecodeError(
                        "latex",  # codec
                        bytes_,  # problematic input
                        pos - len(token.text),  # start of problematic token
                        pos,  # end of it
                        "unknown token {0!r}".format(token.text))
                elseif self.errors == "ignore"
                    # do nothing
                    pass
                elseif self.errors == "replace"
                    push!(tokens, self.replacetoken)
                    yield self.replacetoken
                else
                    throw("Not Implemented: error mode {$self.errors} not supported")
                end
            else
                throw("unknown token name {$token.name}")
            end
        end
    end
end

"""
Simple incremental decoder. Transforms lexed LaTeX tokens into
    unicode.

    To customize decoding, subclass and override
    :meth:`get_unicode_tokens`.
    """
struct LatexIncrementalDecoder
    lexer::LatexIncrementalLexer
    inputenc::String
end
function LatexIncrementalDecoder()
    return LatexIncrementalDecoder(LatexIncrementalLexer(), "ascii")
end

"""
Returns the decoded token text in :attr:`inputenc` encoding.

        .. note::

           Control words get an extra space added at the back to make
           sure separation from the next token, so that decoded token
           sequences can be :meth:`str.join`\ ed together.

           For example, the tokens ``b'\\hello'`` and ``b'world'``
           will correctly result in ``u'\\hello world'`` (remember
           that LaTeX eats space following control words). If no space
           were added, this would wrongfully result in
           ``u'\\helloworld'``.

        """
function decode_token(self::LatexIncrementalDecoder, token)
        # in python 3, the token text can be a memoryview
        # which do not have a decode method; must cast to bytes explicitly
        if self.binary_mode:
            text = binary_type(token.text).decode(self.inputenc)
        else:
            text = token.text
        end
        return text if token.name != 'control_word' else text + u' '
    end

"""
Decode every token in :attr:`inputenc` encoding. Override to
        process the tokens in some other way (for example, for token
        translation).
        """
function get_unicode_tokens(self::LatexIncrementalDecoder, bytes_, final::Bool=false)
    return [decode_token(self, token) for token in get_tokens(self, bytes_, final=final)]
end

"""
Decode LaTeX *bytes_* into a unicode string.

        This implementation calls :meth:`get_unicode_tokens` and joins
        the resulting unicode strings together.
"""
function decode(self, bytes_, final=false)
        try
            return u''.join(self.get_unicode_tokens(bytes_, final=final))
        catch e
            # API requires that the encode method raises a ValueError
            # in this case
            throw(e)
        end
    end

strcut LatexIncrementalEncoder
end
@add_metaclass(MetaLatexCoder)
class LatexIncrementalEncoder(codecs.IncrementalEncoder):

    """
    Simple incremental encoder for LaTeX. Transforms unicode into    :class:`bytes`.

    To customize decoding, subclass and override
    :meth:`get_latex_bytes`.
    """

    inputenc = "ascii"
    """Input encoding. **Must** extend ascii."""

    binary_mode = True
    """Whether this encoder processes binary data (bytes) or text data
    (unicode).
    """

    def __init__(self, errors='strict'):
        """Initialize the codec."""
        self.errors = errors
        self.reset()

    def reset(self):
        """Reset state."""
        # buffer for storing last (possibly incomplete) token
        self.buffer = u""

    def getstate(self):
        """Get state."""
        return self.buffer

    def setstate(self, state):
        """Set state. The *state* must correspond to the return value
        of a previous :meth:`getstate` call.
        """
        self.buffer = state

    def get_unicode_tokens(self, unicode_, final=False):
        """Split unicode into tokens so that every token starts with a
        non-combining character.
        """
        if not isinstance(unicode_, string_types):
            raise TypeError(
                "expected unicode for encode input, but got {0} instead"
                .format(unicode_.__class__.__name__))
        for c in unicode_:
            if not unicodedata.combining(c):
                for token in self.flush_unicode_tokens():
                    yield token
            self.buffer += c
        if final:
            for token in self.flush_unicode_tokens():
                yield token

    def flush_unicode_tokens(self):
        """Flush the buffer."""
        if self.buffer:
            yield self.buffer
            self.buffer = u""

    def get_latex_bytes(self, unicode_, final=False):
        """Encode every character in :attr:`inputenc` encoding. Override to
        process the unicode in some other way (for example, for character
        translation).
        """
        if self.binary_mode:
            for token in self.get_unicode_tokens(unicode_, final=final):
                yield token.encode(self.inputenc, self.errors)
        else:
            for token in self.get_unicode_tokens(unicode_, final=final):
                yield token

    def encode(self, unicode_, final=False):
        """Encode the *unicode_* string into LaTeX :class:`bytes`.

        This implementation calls :meth:`get_latex_bytes` and joins
        the resulting :class:`bytes` together.
        """
        try:
            return self.emptychar.join(
                self.get_latex_bytes(unicode_, final=final))
        except UnicodeEncodeError as e:
            # API requires that the encode method raises a ValueError
            # in this case
            raise ValueError(e)

function UnicodeLatexLexer()
    return LatexLexer(;binary_mode=false)
end
function UnicodeLatexIncrementalDecoder()
    return LatexIncrementalDecoder(binary_mode=false)
end
function UnicodeLatexIncrementalEncoder()
    return LatexIncrementalEncoder(binary_mode=false)
end
