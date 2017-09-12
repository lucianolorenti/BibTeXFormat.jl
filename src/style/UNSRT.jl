
function dashify(text)
    dash_re = re.compile(r"-+")
    return join(Text(TextSymbol("ndash")),split(text,dash_re))
end

pages = field("pages", apply_func=dashify)

const date = words[optional_field("month"), field("year")]

struct UNSRTStyle <: BaseStyle
    config::Config
end

function format_names(self::UNSRTStyle, role, as_sentence=true)
	formatted_names = names(role, sep=", ", sep2 = " and ", last_sep=", and ")
	if as_sentence
		return sentence[formatted_names]
	else
		return formatted_names
	end
end

function get_article_template(self::UNSRTStyle, e)
	volume_and_pages = first_of[
		# volume and pages, with optional issue number
		optional[
			join[
				field("volume"),
				optional["(", field("number"),")"],
				":", pages
			],
		],
		# pages only
		words["pages", pages],
	]
    template = toplevel[       format_names(self,"author"),
		format_title(self,e, "title"),
		sentence[tag("em")[ field("journal") ],
			optional[ volume_and_pages ],
			date],
            sentence[ optional_field("note") ],
		format_web_refs(self,e),

	]
	return template
end
function format_author_or_editor(self::UNSRTStyle, e)
	return first_of[
		optional[format_names(self,"author") ],
		format_editor(self, e),
	]
end
function format_editor(self::UNSRTStyle, e, as_sentence=true)
	editors = format_names(self, "editor", false)
	if !haskey(e["persons"],"editor")
		# when parsing the template, a FieldIsMissing exception
		# will be thrown anyway; no need to do anything now,
		# just return the template that will throw the exception
		return editors
	end
	if length(e.persons["editor"]) > 1
		word = "editors"
	else
		word = "editor"
	end
	result = join(sep=", ")[editors, word]
	if as_sentence
		return sentence[result]
	else
		return result
	end
end
function format_volume_and_series(self::UNSRTStyle, e, as_sentence=true)
	volume_and_series = optional[
		words[
			together[(if as_sentence "Volume" else "volume" end), field("volume")], optional[
				words["of", field("series")]
			]
		]
	]
	number_and_series = optional[
		words[
			join(sep=TextSymbol("nbsp"))[(if as_sentence "Number" else "number" end), field("number")],
			optional[
				words["in", field("series")]
			]
		]
	]
	series = optional_field("series")
	result = first_of[
		volume_and_series,
		number_and_series,
		series,
	]
	if as_sentence
		return sentence(capfirst=true)[result]
	else
		return result
	end
end

function format_chapter_and_pages(self::UNSRTStyle, e)
	return join(sep=", ")[
		optional[together["chapter", field("chapter")]],
		optional[together["pages", pages]],
	]
end

function format_edition(self::UNSRTStyle, e)
	return optional[
		words[
			field("edition", apply_func=lowercase),
			"edition",
		]
	]
end

function format_title(self::UNSRTStyle, e, which_field, as_sentence=true)
	formatted_title = field(which_field; apply_func=x->capitalize(x)
	)
	if as_sentence
		return sentence[ formatted_title ]
	else
		return formatted_title
	end
end
function format_btitle(self::UNSRTStyle, e, which_field, as_sentence=true)
	formatted_title = tag("em")[ field(which_field) ]
	if as_sentence
		return sentence[ formatted_title ]
	else
		return formatted_title
	end
end
function format_address_organization_publisher_date(
	self::UNSRTStyle, e, include_organization=true)
	"""Format address, organization, publisher, and date.
	Everything is optional, except the date.
	"""
	# small difference from unsrt.bst here: unsrt.bst
	# starts a new sentence only if the address is missing;
	# for simplicity here we always start a new sentence
	if include_organization
		organization = optional_field("organization")
	else
		organization = None
	end
	return first_of[
		# this will be rendered if there is an address
		optional[
			join(sep=" ")[
				sentence[
					field("address"),
					date,
				],
				sentence[
					organization,
					optional_field("publisher"),
				],
			],
		],
		# if there is no address then we have this
		sentence[
			organization,
			optional_field("publisher"),
			date,
		],
	]
end
function get_book_template(self::UNSRTStyle, e)
	template = toplevel[
		format_author_or_editor(self,e),
		format_btitle(self,e, "title"),
		format_volume_and_series(self,e),
		sentence[ field("publisher"),
			optional_field("address"),
			format_edition(self,e),
			date
		],
		optional[ sentence[ format_isbn(self,e) ] ],
		sentence[ optional_field("note") ],
		format_web_refs(self, e),
	]
	return template
end
function get_booklet_template(self::UNSRTStyle, e)
	template = toplevel[
		format_names(self,"author"),
		format_title(self,e, "title"),
		sentence[
			optional_field("howpublished"),
			optional_field("address"),
			date,
			optional_field("note"),
		],
		format_web_refs(self,e),
	]
	return template
end
function get_inbook_template(self::UNSRTStyle, e)
	template = toplevel[
		format_author_or_editor(self,e),
		sentence[
			format_btitle(self,"title", false),
			format_chapter_and_pages(self,e),
		],
		format_volume_and_series(self,e),
		sentence[
			field("publisher"),
			optional_field("address"),
			optional[
				words[field("edition"), "edition"]
			],
			date,
			optional_field("note"),
		],
		format_web_refs(self, e),
	]
	return template
end
function get_incollection_template(self::UNSRTStyle, e)
	template = toplevel[	sentence[ format_names(self,"author") ],
		format_title(self,e, "title"),
		words[			"In",
			sentence[	optional[ format_editor(self, e, false) ],
				format_btitle(self,e, "booktitle",false),
				format_volume_and_series(self,e, false),
				format_chapter_and_pages(self,e),
			],
		],
		sentence[	optional_field("publisher"),
			optional_field("address"),
			format_edition(self,e),
			date,
		],
		format_web_refs(self,e),
	]
	return template
end
function get_inproceedings_template(self::UNSRTStyle, e)
	template = toplevel[
		sentence[ format_names(self, "author") ],
		format_title(self, e, "title"),
		words[
			"In",
			sentence[
				optional[ format_editor(self,e, false) ],
				format_btitle(self,e, "booktitle", false),
				format_volume_and_series(self,e, false),
				optional[ pages ],
			],
			format_address_organization_publisher_date(self, e),
		],
		sentence[ optional_field("note") ],
		format_web_refs(self, e),
	]
	return template
end
function get_manual_template(self::UNSRTStyle, e)
	# TODO this only corresponds to the bst style if author is non-empty
	# for empty author we should put the organization first
	template = toplevel[
		optional[ sentence[ format_names(self,"author") ] ],
		format_btitle(self,e, "title"),
		sentence[
			optional_field("organization"),
			optional_field("address"),
			format_edition(self,e),
			optional[ date ],
		],
		sentence[ optional_field("note") ],
		format_web_refs(self, e),
	]
	return template
end
function get_mastersthesis_template(self::UNSRTStyle, e)
	template = toplevel[
		sentence[format_names(self,"author")],
		format_title(self,e, "title"),
		sentence[
			"Master's thesis",
			field("school"),
			optional_field("address"),
			date,
		],
		sentence[ optional_field("note") ],
		format_web_refs(self, e),
	]
	return template
end
function get_misc_template(self::UNSRTStyle, e)
	template = toplevel[
		optional[ sentence[format_names(self, "author")] ],
		optional[ format_title(self, e, "title") ],
		sentence[
			optional[ field("howpublished") ],
			optional[ date ],
		],
		sentence[ optional_field("note") ],
		format_web_refs(self, e),
	]
	return template
end
function get_phdthesis_template(self::UNSRTStyle, e)
	template = toplevel[
		sentence[format_names(self, "author")],
		format_btitle(self, e, "title"),
		sentence[
			"PhD thesis",
			field("school"),
			optional_field("address"),
			date,
		],
		sentence[ optional_field("note") ],
		format_web_refs(self, e),
	]
	return template
end
function get_proceedings_template(self::UNSRTStyle, e)
	template = toplevel[
		first_of[
			# there are editors
			optional[
				join(" ")[
					format_editor(self, e),
					sentence[
						format_btitle(self, e, "title", false),
						format_volume_and_series(self, e, false),
						format_address_organization_publisher_date(self, e),
					],
				],
			],
			# there is no editor
			optional_field("organization"),
			sentence[
				format_btitle(self, e, "title", false),
				format_volume_and_series(self, e,false),
				format_address_organization_publisher_date(self,
					e, include_organization=false),
			],
		],
		sentence[ optional_field("note") ],
		format_web_refs(self, e),
	]
	return template
end
function get_techreport_template(self::UNSRTStyle, e)
	template = toplevel[
		sentence[format_names(self, "author")],
		format_title(self, e, "title"),
		sentence[
			words[
				first_of[
					optional_field("type"),
					"Technical Report",
				],
				optional_field("number"),
			],
			field("institution"),
			optional_field("address"),
			date,
		],
		sentence[ optional_field("note") ],
		format_web_refs(self, e),
	]
	return template
end
function get_unpublished_template(self::UNSRTStyle, e)
	template = toplevel[
        sentence[format_names(self, "author")],
		format_title(self, e, "title"),
		sentence[
			field("note"),
			optional[ date ]
		],
		format_web_refs(self, e),
	]
	return template
end
function format_web_refs(self::UNSRTStyle, e)
	# based on urlbst output.web.refs
	return sentence[
		optional[ format_url(self, e) ],
		optional[ format_eprint(self, e) ],
		optional[ format_pubmed(self, e) ],
		optional[ format_doi(self, e) ],
		]
end
function format_url(self::UNSRTStyle, e)
	# based on urlbst format.url
	return words[
		"URL:",
		href[
			field("url", raw=true),
			field("url", raw=true)
			]
	]
end

function format_pubmed(self::UNSRTStyle, e)
	# based on urlbst format.pubmed
	return href[
		join[
			"https://www.ncbi.nlm.nih.gov/pubmed/",
			field("pubmed", raw=true)
			],
		join[
			"PMID:",
			field("pubmed", raw=true)
			]
		]
end
function format_doi(self::UNSRTStyle, e)
	# based on urlbst format.doi
	return href[
		join[
			"https://doi.org/",
			field("doi", raw=true)
			],
		join[
			"doi:",
			field("doi", raw=true)
			]
		]
end
function format_eprint(self::UNSRTStyle, e)
	# based on urlbst format.eprint
	return href[
		join[
			"https://arxiv.org/abs/",
			field("eprint", raw=true)
			],
		join[
			"arXiv:",
			field("eprint", raw=true)
			]
		]
end
function format_isbn(self::UNSRTStyle, e)
	return join(sep=" ")[ "ISBN", field("isbn") ]
end
