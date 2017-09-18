
function process_int_literal(value)
    return Integer(int(value.strip('#')))
end

function process_string_literal(value)
    assert value.startswith('"')
    assert value.endswith('"')
    return String(value[1:-1])
end

function process_identifier(name)
    if name[1] == "'":
        return QuotedVar(name[1:])
    else:
        return Identifier(name)
end

function process_function(toks)
    return FunctionLiteral(toks[1])
end

quote_or_comment = r"[%\"]"

"""Strip the commented part of the line."

>>> print(strip_comment('a normal line'))
a normal line
>>> print(strip_comment('%'))
<BLANKLINE>
>>> print(strip_comment('%comment'))
<BLANKLINE>
>>> print(strip_comment('trailing%'))
trailing
>>> print(strip_comment('a normal line% and a comment'))
a normal line
>>> print(strip_comment('"100% compatibility" is a myth'))
"100% compatibility" is a myth
>>> print(strip_comment('"100% compatibility" is a myth% or not?'))
"100% compatibility" is a myth

"""
function strip_comment(line)
    pos = 0
    end = len(line) - 1
    in_string = False
    while pos <= end:
        match = quote_or_comment.search(line, pos)
        if not match:
            break
        if match.group() == '%' and not in_string:
            return line[:match.start()]
        elif match.group() == '"':
            in_string = not in_string
        pos = match.end()
    return line

LBRACE = Literal('{')
RBRACE = Literal('}')
STRING = Pattern('"[^\"]*"', 'string')
INTEGER = Pattern(r'#-?\d+', 'integer')
NAME = Pattern(r'[^#\"\{\}\s]+', 'name')

COMMANDS = {
	'ENTRY': 3,
	'EXECUTE': 1,
	'FUNCTION': 2,
	'INTEGERS': 1,
	'ITERATE': 1,
	'MACRO': 2,
	'READ': 0,
	'REVERSE': 1,
	'SORT': 0,
	'STRINGS': 1,
}

LITERAL_TYPES = {
	STRING: process_string_literal,
	INTEGER: process_int_literal,
	NAME: process_identifier,
}
mutable struct BstParser
end
function parse(s::BstParser)
	while(true)
		parse_command(s)
	end
end

function parse_command(self::BstParse)
	local commands = []
	command_name = self.required([self.NAME], 'BST command', allow_eof=True).value
	try:
		arity = self.COMMANDS[command_name.upper()]
	catch e
		throw TokenRequired('BST command', self)
	end
	push!(commands, command_name)
	for i in range(arity):
		brace = self.optional([self.LBRACE])
		if not brace
			break
		end
		push!(self.parse_group())
	end
end
function parse_commad
    def parse(self):
        while True:
            try:
                yield list(self.parse_command())
            except EOFError:
                break
            except PybtexSyntaxError:
                raise
                break

    def parse_group(self):
        while True:
            token = self.required([self.NAME, self.STRING, self.INTEGER, self.LBRACE, self.RBRACE])
            if token.pattern is self.LBRACE:
                yield FunctionLiteral(list(self.parse_group()))
            elif token.pattern is self.RBRACE:
                break
            else:
                yield self.LITERAL_TYPES[token.pattern](token.value)

def parse_file(filename, encoding=None):
    with pybtex.io.open_unicode(filename, encoding=encoding) as bst_file:
        return parse_stream(bst_file, filename)

def parse_stream(stream, filename='<INPUT>'):
    bst = '\n'.join(strip_comment(line.rstrip()) for line in stream)
    return BstParser(bst, filename=filename).parse()

def parse_string(bst_string):
    bst = '\n'.join(strip_comment(line) for line in bst_string.splitlines())
    return BstParser(bst).parse()

if __name__ == '__main__':
    import sys
    from pprint import pprint
    pprint(parse_file(sys.argv[1]))
