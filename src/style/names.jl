
abstract type BaseNameStyle end

@node function  name_part(children, data, before="", tie=false, abbr=false)
    if abbr
        children = [abbreviate(child) for child in children]
	end
    parts = format_data(together(last_tie=true)[children],data)
    if not parts
        return RichText()
	end
    if tie
        return RichText(before, parts, tie_or_space(parts, nbsp, " "))
    else
        return RichText(before, parts)
	end
end

struct LastFirstNameStyle <: BaseNameStyle end

"""
Format names similarly to {vv~}{ll}{, jj}{, f.} in BibTeX.

>>> from pybtex.database import Person
>>> name = Person(string=r"Charles Louis Xavier Joseph de la Vall{\'e}e Poussin")
>>> lastfirst = NameStyle().format

>>> print(lastfirst(name).format().render_as('latex'))
de~la Vall{é}e~Poussin, Charles Louis Xavier~Joseph
>>> print(lastfirst(name).format().render_as('html'))
de&nbsp;la Vall<span class="bibtex-protected">é</span>e&nbsp;Poussin, Charles Louis Xavier&nbsp;Joseph

>>> print(lastfirst(name, abbr=True).format().render_as('latex'))
de~la Vall{é}e~Poussin, C.~L. X.~J.
>>> print(lastfirst(name, abbr=True).format().render_as('html'))
de&nbsp;la Vall<span class="bibtex-protected">é</span>e&nbsp;Poussin, C.&nbsp;L. X.&nbsp;J.

>>> name = Person(first='First', last='Last', middle='Middle')
>>> print(lastfirst(name).format().render_as('latex'))
Last, First~Middle
>>> print(lastfirst(name, abbr=True).format().render_as('latex'))
Last, F.~M.

"""
function format(self::LastFirstNameStyle, person, abbr=false)
	return join[
		name_part(tie=true)[person.rich_prelast_names],
		name_part[person.rich_last_names],
		name_part(before=", ")[person.rich_lineage_names],
        name_part(before=", ",abbr=abbr)[string(rich_first_names(person),rich_middle_names(person))],
	]
end

struct PlainNameStyle <: BaseNameStyle end

"""
Format names similarly to {ff~}{vv~}{ll}{, jj} in BibTeX.

>>> from pybtex.database import Person
>>> name = Person(string=r"Charles Louis Xavier Joseph de la Vall{\'e}e Poussin")
>>> plain = NameStyle().format

>>> print(plain(name).format().render_as('latex'))
Charles Louis Xavier~Joseph de~la Vall{é}e~Poussin
>>> print(plain(name).format().render_as('html'))
Charles Louis Xavier&nbsp;Joseph de&nbsp;la Vall<span class="bibtex-protected">é</span>e&nbsp;Poussin

>>> print(plain(name, abbr=True).format().render_as('latex'))
C.~L. X.~J. de~la Vall{é}e~Poussin
>>> print(plain(name, abbr=True).format().render_as('html'))
C.&nbsp;L. X.&nbsp;J. de&nbsp;la Vall<span class="bibtex-protected">é</span>e&nbsp;Poussin

>>> name = Person(first='First', last='Last', middle='Middle')
>>> print(plain(name).format().render_as('latex'))
First~Middle Last

>>> print(plain(name, abbr=True).format().render_as('latex'))
F.~M. Last

>>> print(plain(Person('de Last, Jr., First Middle')).format().render_as('latex'))
First~Middle de~Last, Jr.

"""
function format(self::PlainNameStyle, person, abbr=false)
	return join[
             name_part(tie=true, abbr=abbr)[string(rich_first_names(person),rich_middle_names(person))],
             name_part(tie=true)[rich_prelast_names(person)],
             name_part[rich_last_names(person)],
             name_part(before=", ")[rich_lineage_names(person)]
	]
end
