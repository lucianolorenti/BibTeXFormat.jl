abstract type BaseSortingStyle end
import Base.sort
function Base.sort(self::T, entries) where T <: BaseSortingStyle
    local entry_dict =Dict([sorting_key(self, entry) => entry for entry in values(entries)])
	sorted_keys = sort(collect(keys(entry_dict)))
	return  [entry_dict[key] for key in sorted_keys]
end
import BibTeXStyle: citation_type
type AuthorYearTitleSortingStyle <: BaseSortingStyle end

function sorting_key(self::AuthorYearTitleSortingStyle, entry)
    local author_key = nothing
    if citation_type(entry) in Set([:book, :inbook])
		author_key = author_editor_key(self,entry)
    elseif haskey(entry["persons"],"author")
        author_key = persons_key(self,entry["persons"]["author"])
	else
		author_key = ""
	end
	return (author_key, get(entry,"year", ""), get(entry,"title", ""))
end
function persons_key(self::AuthorYearTitleSortingStyle, persons)
	return Base.join([person_key(self,person) for person in persons],  "   ")
end

function person_key(self::AuthorYearTitleSortingStyle, person)
	return lowercase(Base.join([
		Base.join(string(person.prelast_names , person.last_names), " "),
		Base.join(string(person.first_names , person.middle_names), " "),
	    Base.join(person.lineage_names, " "),
	], "  "))
end

function author_editor_key(self::AuthorYearTitleSortingStyle, entry)
    if haskey(entry["persons"],"author")
        return persons_key(self,entry["persons"]["author"])
    elseif haskey(entry["persons"],"editor")
        return persons_key(self,entry["persons"]["editor"])
	else
		return ""
	end
end
