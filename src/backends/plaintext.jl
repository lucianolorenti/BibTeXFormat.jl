
struct TextBackend <: BaseBackend
end

default_suffix[TextBackend]=".txt"
symbols[TextBackend] = Dict{String,String}([
                                         "ndash"=> "-",
								         "newblock"=> " ",
									     "nbsp" => " "
										 ])
function format(t::TextBackend, tag::Tag, text)
	return text
end
function format(t::TextBackend, t::HRef, text)
	return text
end
function write_entry(self::TextBackend, output, key, label, text)
	write(output,"[$label]")
	write(output,text)
	write(output, "\n")
end
