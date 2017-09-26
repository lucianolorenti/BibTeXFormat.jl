abstract type  Scanner end
function skip_to(self::Scanner, patterns)
	local end_pos = nothing
	local winning_pattern = nothing
	for pattern in patterns
		matched = match(pattern[1], self.text, self.pos)
		if (matched!=nothing) && (end_pos != nothing)  || (maximum(match) < end_pos)
			end_pos = matched.offset + length(matched.match)
			winning_pattern = pattern
		end
	end
	if winning_pattern != nothing
		value = self.text[self.pos:end]
		self.pos = end_pos
		# print '>>', value
		update_lineno(self, value)
		return (value, winning_pattern)
	end
end
function update_lineno(self::Scanner, value)
	num_newlines = length(matchall(NEWLINE[1],value))
	self.lineno =  self.lineno + num_newlines
end
function eat_whitespace(self::Scanner)
	whitespace = match(WHITESPACE[1], self.text, self.pos)
	if whitespace!=nothing
		self.pos = whitespace.offset + length(whitespace.match)
		update_lineno(self, whitespace.match)
	end
end

function eof(self::Scanner)
	return self.pos > self.end_pos
end

function get_token(self::Scanner, patterns; allow_eof=false)
	eat_whitespace(self)
	if eof(self)
		if allow_eof
			throw(:EOF)
		else
			throw((:PrematureEOF))
		end
	end
	for pattern in patterns
		local matched = match(pattern[1], self.text, self.pos)
		if matched != nothing
			value = matched.match
			self.pos = matched.offset + length(matched.match)
			# print '->', value
			return ( value, pattern)
		end
	end
end

function optional(self::Scanner, patterns; allow_eof=false)
	return get_token(self, patterns, allow_eof=allow_eof)
end

function required(self::Scanner, patterns, description=nothing; allow_eof=false)
	local token = get_token(self, patterns, allow_eof=allow_eof)
	if token == nothing
		if description != nothing
			description = join([pattern[2] for pattern in patterns], " or ")
		end
		throw((:TokenRequired,description, self))
	else
		return token
	end
end
function get_error_context_info(self::Scanner)
	return (self.lineno, self.pos)
end
function get_error_context(self::Scanner, context_info)
	error_lineno, error_pos = context_info
	if error_lineno != nothing
		error_lineno0 = error_lineno - 1
		lines = self.text.splitlines(True)
		before_error = join(lines[1:error_lineno0], " ")
		colno = error_pos - length(before_error)
		context = rstrip(lines[error_lineno0], "\r\n")
	else
		colno = nothing
		context = nothing
	end
	return context, error_lineno, colno
end
function get_remainder(self::Scanner)
	return self.text[self.pos:end]
end
