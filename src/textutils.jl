
const terminators = ['.', '?', '!']
const delimiter_re = r"([\s\-])"
const whitespace_re = r"\s+"
"""Abbreviate the given text.

>> abbreviate('Name')
u'N'
>> abbreviate('Some words')
u'S. w.'
>>> abbreviate('First-Second')
u'F.-S.'
"""

function abbreviate(text::Char)
    return text
end
function abbreviate(text, split_re=delimiter_re)
	function abbreviate(part)
        if isalpha(part)
            return string(part[1], '.')
        else
            return part
		end
	end
    return Base.join([abbreviate(part) for part in split(text,split_re)], "")
end
