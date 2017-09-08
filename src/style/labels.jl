import BibTeXStyle: citation_type, abbreviate
import Base.convert
function  get_longest_label(formatted_entries)
    labels = [length(entry.label) for entry in formatted_entries]
    return maximum(labels)
end

abstract type BaseLabelStyle end

const _nonalnum_pattern = r"[^A-Za-z0-9]+"

function _strip_accents(s)
	return join([c for c in Base.UTF8proc.normalize_string(s, :NFD) ])
end

const _nonalnum_pattern = r"[^A-Za-z0-9]+"
"""
Strip all non-alphanumerical characters from a list of strings.
```jldoctest
julia> import BibTeXStyle: _strip_nonalnum

julia> print(_strip_nonalnum(["ÅA. B. Testing 12+}[.@~_", " 3%"]))
AABTesting123

```

"""

function _strip_nonalnum(parts)
	local s = join(parts, "")
    return replace(_strip_accents(s),_nonalnum_pattern,"")
end

function _abbr(parts)
    return [abbreviate(part) for part in parts]
end

struct AlphaLabelStyle <: BaseLabelStyle end

function  format_labels(self::AlphaLabelStyle, sorted_entries)
	local labels = [format_label(self,entry) for entry in sorted_entries]
    count = Dict{String,Integer}()
    counted = Dict{String,Integer}()
    for l in labels
        if !(haskey(count,l))
            count[l] = 0
            counted[l] = 0
        end
        count[l]= count[l] +1
    end
   olabels = []
	for label in labels
		if count[label] == 1
            push!(olabels,label)
        else
            push!(olabel,string(label,string('a' + counted[label])))
            counted[label]=counted[label]+1
		end
	end
    return olabels
end

# note: this currently closely follows the alpha.bst code
# we should eventually refactor it

function format_label(self::AlphaLabelStyle, entry)
	# see alpha.bst calc.label
	if (citation_type(entry)== :book) || citation_type(entry) == :inbook
		label = author_editor_key_label(self,entry)
	elseif citation_type(entry) == :proceedings
		label = editor_key_organization_label(self,entry)
	elseif citation_type(entry) == :manual
		label = author_key_organization_label(self,entry)
	else
		label = author_key_label(self,entry)
	end
	if haskey(entry,"year")
		return string(label,entry["year"][end-2:end])
	else
		return label
	end
	# bst additionally sets sort.label
end

function author_key_label(self::AlphaLabelStyle, entry)
	# see alpha.bst author.key.label
    if !(haskey(entry["persons"],"author"))
		if !haskey(entry.fields,"key")
			return entry.key[1:3] # entry.key is bst cite$
		else
			# for entry.key, bst actually uses text.prefix$
			return entry.fields["key"][1:3]
		end
	else
        return format_lab_names(self,entry["persons"]["author"])
	end
end

function author_editor_key_label(self::AlphaLabelStyle, entry)
	# see alpha.bst author.editor.key.label
    if !haskey(entry["persons"],"author")
        if !haskey(entry["persons"],"editor")
			if !haskey(entry.fields,"key")
				return entry.key[1:3] # entry.key is bst cite$
			else
				# for entry.key, bst actually uses text.prefix$
				return entry.fields["key"][1:3]
			end
		else
            return format_lab_names(self,entry["persons"]["editor"])
		end
	else
        return format_lab_names(self,entry["persons"]["author"])
	end
end

function author_key_organization_label(self::AlphaLabelStyle, entry)
	if !haskey(entry.persons,"author")
		if !haskey(entry.fields,"key")
			if !haskey(entry.fields, "organization")
				return entry.key[1:3] # entry.key is bst cite$
			else
				result = entry.fields["organization"]
				if  startswith(result,"The ")
					result = result[4:end]
				end
				return result
			end
		else
			return entry.fields["key"][1:3]
		end
	else
		return self.format_lab_names(entry.persons["author"])
	end
end

function editor_key_organization_label(self::AlphaLabelStyle, entry)
	if !haskey(entry.persons,"editor")
		if !haskey(entry.fields,"key")
			if !haskey(entry.fields, "organization")
				return entry.key[1:3] # entry.key is bst cite$
			else
				local result = entry.fields["organization"]
				if result.startswith("The ")
					result = result[4:end]
				end
				return result
            end
		else
			return entry.fields["key"][1:3]
		end
	else
		return format_lab_names(self,entry.persons["editor"])
	end
end

function format_lab_names(self::AlphaLabelStyle, persons)
	# see alpha.bst format.lab.names
	# s = persons
	numnames = length(persons)
	if numnames > 1
		if numnames > 4
			namesleft = 3
		else
			namesleft = numnames
		end
		result = ""
		nameptr = 2
		while namesleft > 0
			person = persons[nameptr - 1]
			if nameptr == numnames
                println(Base.convert(String,person))
                if convert(String,person) == "others"
					result = string(result, "+")
				else
					result = string(result, _strip_nonalnum(_abbr(vcat(person.prelast_names, person.last_names))))
				end
			else
				result = string(result,_strip_nonalnum(_abbr(vcat(person.prelast_names , person.last_names))))
			end
			nameptr =  nameptr+ 1
			namesleft = namesleft -1
		end
		if numnames > 4
			result = String("+")
		end
	else
		person = persons[1]
		result = _strip_nonalnum(_abbr(vcat(person.prelast_names, person.last_names)))
		if length(result) < 2
			result = _strip_nonalnum(person.last_names)[1:3]
		end
	end
	return result
end

struct NumberLabelStyle <: BaseLabelStyle end
function  format_labels(self::NumberLabelStyle, sorted_entries)
		local labels = []
        for (number, entry) in sorted_entries
            push!(labels,number + 1)
		end
		return labels
end
