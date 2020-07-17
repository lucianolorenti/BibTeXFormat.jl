module LaTeXAccents
export decode_Tex_Accents
"""
@encode_dict is the dictionary we need to populate; passed by refernece
@strKey is a string separated by spaces, where each string is an ascii letter
@strValue is a string seprated by spaces, where each item is the UTF8 variant of the strKey in the same position
@accent_pattern_left is a string representing the LaTex accent pattern from the left (e.g. \\", \\H{)
@accent_pattern_right is a string representing the LaTex accent pattern from the right (e.g. , } )
"""
function populate_encode_dict(encode_dict, strKey, strValue, accent_pattern_left, accent_pattern_right = "")

    s_key = split(strKey, " ")
    s_value = split(strValue, " ")

    @assert( length( s_key ) == length(s_value) )

    for (i, charKey) in enumerate(s_key)
        encode_dict[ accent_pattern_left * charKey * accent_pattern_right ] = (s_value[i], charKey)
    end
end

"""
    function create_translation_rules()


creates the rule of translation from latex accent to their equivalent UTF8
the rules are stored as (key,value) pairs in the dictionary encode_dict,
where the key is the latex accent pattern + a letter, and it's value is the corresponding UTF8 char
"""
function create_translation_rules()


    encode_dict = Dict()     # each key is an accented Ascii char (without blank space), its corresponding value is its UTF8 version
    regex_detectors = [] # each item is a regex detecting a given Latex accent pattern


    # Diaeresis (diacritic, umlatut)  \"{o}
    # each translation rule (i.e. [accent pattern + ascii char => UTF8 value] must be accompanied with a regex pattern to detect it)
    strValue_umlaut = "Ä ä B̈ b̈ C̈ c̈ Ë ë Ḧ ḧ Ï ï K̈ k̈ M̈ m̈ N̈ n̈ Ö ö P̈ p̈ Q̈ q̈ S̈ s̈ T̈ ẗ Ü ü V̈ v̈ Ẅ ẅ Ẍ ẍ Ÿ ÿ Z̈ z̈"
    strKey_umlaut   = "A a B b C c E e H h I i K k M m N n O o P p Q q S s T t U u V v W w X x Y y Z z"
    populate_encode_dict( encode_dict, strKey_umlaut, strValue_umlaut,  "{\\\"", "}")
    push!(regex_detectors, r"{ *\\\" *[a-zA-Z]{1} *}")
    populate_encode_dict( encode_dict, strKey_umlaut, strValue_umlaut,  "\\\"", ""  )
    push!(regex_detectors, r"\\\" *[a-zA-z]{1}" ) # backslash followed by " followed by any number of spaces followed by a char
    populate_encode_dict(encode_dict, strKey_umlaut, strValue_umlaut,  "\\\"{", "}" )
    push!(regex_detectors, r"\\\"{ *[a-zA-Z]{1} *}")



    # accents (acute) \'{o}
    strValue_acute = "Á á B́ b́ Ć ć D́ d́ É é F́ f́ Ǵ ǵ H́ h́ Í í J́ ȷ́ Ḱ ḱ Ĺ ĺ Ḿ ḿ Ń ń Ó ó Ṕ ṕ Q́ q́ Ŕ ŕ Ś ś T́ t́ Ú ú V́ v́ Ẃ ẃ X́ x́ Ý ý Ź ź"
    strKey_acute   = "A a B b C c D d E e F f G g H h I i J j K k L l M m N n O o P p Q q R r S s T t U u V v W w X x Y y Z z"
    populate_encode_dict( encode_dict, strKey_umlaut, strValue_umlaut,  "{\\'", "}" )
    push!(regex_detectors, r"{ *\\' *[a-zA-Z]{1} *}")
    populate_encode_dict( encode_dict, strKey_acute, strValue_acute, "\\'", "" )
    push!(regex_detectors, r"\\' *[a-zA-z]{1}" )
    populate_encode_dict( encode_dict, strKey_acute, strValue_acute, "\\'{", "}" )
    push!(regex_detectors, r"\\'{ *[a-zA-Z]{1} *}")


    # accents (double acute) \H{o} Hungarian
    strValue_hungarian = "A̋ a̋ E̋ e̋ I̋ i̋ M̋ m̋ Ő ő Ű ű"
    strKey_hungarian   = "A a E e I i M m O o U u"
    populate_encode_dict( encode_dict, strKey_hungarian, strValue_hungarian, "\\H{", "}" )
    push!(regex_detectors, r"\\H{ *[a-zA-Z]{1} *}")
    populate_encode_dict( encode_dict, strKey_hungarian, strValue_hungarian, "\\H\\", "" )
    push!(regex_detectors, r"\\H *\\[a-zA-Z]{1} *")

    # accents (grave) \`{o}
    strValue_grave = "À à Æ̀ æ̀ È è H̀ h̀ Ì ì K̀ k̀ M̀ m̀ Ǹ ǹ Ò ò R̀ r̀ S̀ s̀ T̀ t̀ Ù ù V̀ v̀ Ẁ ẁ X̀ x̀ Ỳ ỳ Z̀ z̀"
    strKey_grave   = "A a Æ æ E e H h I i K k M m N n O o R r S s T t U u V v W w X x Y y Z z"
    populate_encode_dict( encode_dict, strKey_umlaut, strValue_umlaut,  "{\\`", "}" )
    push!(regex_detectors, r"{ *\\` *[a-zA-Z]{1} *}")
    populate_encode_dict( encode_dict, strKey_grave, strValue_grave, "\\`", "" )
    push!(regex_detectors, r"\\` *[a-zA-z]{1}")
    populate_encode_dict(encode_dict, strKey_grave, strValue_grave, "\\`{", "}" )
    push!(regex_detectors, r"\\`{ *[a-zA-Z]{1} *}") 

    # circumflex \^{o}
    strValue_circumflex = "Â â B̂ b̂ Ĉ ĉ D̂ d̂ Ê ê Ĝ ĝ Ĥ ĥ Î î Ĵ ĵ K̂ k̂ L̂ l̂ M̂ m̂ N̂ n̂ Ô ô R̂ r̂ Ŝ ŝ T̂ t̂ Û û V̂ v̂ Ŵ ŵ X̂ x̂ Ŷ ŷ Ẑ ẑ"
    strKey_circumflex   = "A a B b C c D d E e G g H h I i J j K k L l M m N n O o R r S s T t U u V v W w X x Y y Z z"
    populate_encode_dict( encode_dict, strKey_umlaut, strValue_umlaut,  "{\\^", "}" )
    push!(regex_detectors, r"{ *\\^ *[a-zA-Z]{1} *}") 
    populate_encode_dict( encode_dict, strKey_circumflex, strValue_circumflex, "\\^", "" )
    push!(regex_detectors, r"\\\^ *[a-zA-z]{1}" ) 
    populate_encode_dict( encode_dict, strKey_circumflex, strValue_circumflex, "\\^{", "}" )
    push!(regex_detectors, r"\\\^{ *[a-zA-Z]{1} *}") 

    # caron hraceck \v{s}
    strValue_hraceck = "Ǎ ǎ B̌ b̌ Č č Ď ď Ě ě F̌ f̌ Ǧ ǧ Ȟ ȟ Ǐ ǐ J̌ ǰ Ǩ ǩ Ľ ľ M̌ m̌ Ň ň Ǒ ǒ P̌ p̌ Q̌ q̌ Ř ř Š š Ť ť Ǔ ǔ V̌ v̌ W̌ w̌ X̌ x̌ Y̌ y̌ Ž ž"
    strKey_hraceck   = "A a B b C c D d E e F f G g H h I i J j K k L l M m N n O o P p Q q R r S s T t U u V v W w X x Y y Z z"
    populate_encode_dict( encode_dict, strKey_hraceck, strValue_hraceck, "\\v{", "}" )
    push!(regex_detectors, r"\\v{ *[a-zA-Z]{1} *}") 
    populate_encode_dict(encode_dict, strKey_hraceck, strValue_hraceck, "\\v\\", "" )
    push!(regex_detectors, r"\\v *\\[a-zA-Z]{1} *") 

    # breve  \u{o}
    strValue_breve = "Ă ă C̆ c̆ Ĕ ĕ Ğ ğ Ĭ ĭ K̆ k̆ M̆ m̆ N̆ n̆ Ŏ ŏ P̆ p̆ R̆ r̆ T̆ t̆ Ŭ ŭ V̆ v̆ X̆ x̆ Y̆ y̆"
    strKey_breve   = "A a C c E e G g I i K k M m N n O o P p R r T t U u V v X x Y y"
    populate_encode_dict(encode_dict, strKey_breve, strValue_breve, "\\u{", "}" )
    push!(regex_detectors, r"\\u{ *[a-zA-Z]{1} *}")
    populate_encode_dict( encode_dict, strKey_breve, strValue_breve, "\\u\\", "" )
    push!(regex_detectors, r"\\u *\\[a-zA-Z]{1} *")

    # cedilla \c{c}
    strValue_cedilla = "A̧ a̧ B̧ b̧ Ç ç Ḑ ḑ Ȩ ȩ Ģ ģ Ḩ ḩ I̧ i̧ Ķ ķ Ļ ļ M̧ m̧ Ņ ņ O̧ o̧ Q̧ q̧ Ŗ ŗ Ş ş Ţ ţ U̧ u̧ X̧ x̧ Z̧ z̧"
    strKey_cedilla   = "A a B b C c D d E e G g H h I i K k L l M m N n O o Q q R r S s T t U u X x Z z"
    populate_encode_dict(encode_dict, strKey_cedilla, strValue_cedilla, "\\c{", "}" )
    push!(regex_detectors, r"\\c{ *[a-zA-Z]{1} *}")
    populate_encode_dict( encode_dict, strKey_cedilla, strValue_cedilla, "\\c\\", "" )
    push!(regex_detectors, r"\\c *\\[a-zA-Z]{1} *")

    # dot \.{o}
    strValue_dot = "Ȧ ȧ Ḃ ḃ Ċ ċ Ḋ ḋ Ė ė Ḟ ḟ Ġ ġ Ḣ ḣ İ i̇̀ K̇ k̇ L̇ l̇ Ṁ ṁ Ṅ ṅ Ȯ ȯ Ṗ ṗ Q̇ q̇ Ṙ ṙ Ṡ ṡ Ṫ ṫ U̇ u̇ V̇ v̇ Ẇ ẇ Ẋ ẋ Ẏ ẏ Ż ż"
    strKey_dot   = "A a B b C c D d E e F f G g H h I i K k L l M m N n O o P p Q q R r S s T t U u V v W w X x Y y Z z"
    populate_encode_dict( encode_dict, strKey_umlaut, strValue_umlaut,  "{\\.", "}" )
    push!(regex_detectors, r"{ *\\\. *[a-zA-Z]{1} *}") 
    populate_encode_dict( encode_dict, strKey_dot, strValue_dot, "\\.", "" )
    push!(regex_detectors, r"\\\. *[a-zA-z]{1}" ) 
    populate_encode_dict( encode_dict, strKey_dot, strValue_dot, "\\.{", "}" )
    push!(regex_detectors, r"\\\.{ *[a-zA-z]{1} *}" ) 

    # dot under the letter \d{u}
    strValue_dot_under = "Ạ ạ Ḅ ḅ C̣ c̣ Ḍ ḍ Ẹ ẹ F̣ f̣ G̣ g̣ Ḥ ḥ Ị ị J̣ j̣ Ḳ ḳ Ḷ ḷ Ṃ ṃ Ṇ ṇ Ọ ọ P̣ p̣ Q̣ q̣ Ṛ ṛ Ṣ ṣ Ṭ ṭ Ụ ụ Ṿ ṿ Ẉ ẉ X̣ x̣ Ỵ ỵ Ẓ ẓ"
    strKey_dot_under   = "A a B b C c D d E e F f G g H h I i J j K k L l M m N n O o P p Q q R r S s T t U u V v W w X x Y y Z z"
    populate_encode_dict( encode_dict, strKey_dot_under, strValue_dot_under, "\\d{", "}" )
    push!(regex_detectors, r"\\d{ *[a-zA-Z]{1} *}") 
    populate_encode_dict( encode_dict, strKey_dot_under, strValue_dot_under, "\\d\\", "" )
    push!(regex_detectors, r"\\d *\\[a-zA-Z]{1} *") 

    # ogonek \k{a}
    strValue_ogonek = "Ą ą Ę ę Į į Ǫ ǫ Ų ų Y̨ y̨"
    strKey_ogonek   = "A a E e I i O o U u Y y"
    populate_encode_dict(encode_dict, strKey_ogonek, strValue_ogonek, "\\k{", "}" )
    push!(regex_detectors, r"\\k{ *[a-zA-Z]{1} *}") 
    populate_encode_dict( encode_dict, strKey_ogonek, strValue_ogonek, "\\k\\", "" )
    push!(regex_detectors, r"\\k *\\[a-zA-Z]{1} *") 

    # tilde \~o
    strValue_tilde = "Ã ã Ẽ ẽ Ĩ ĩ Ñ ñ Õ õ Ũ ũ Ṽ ṽ Ỹ ỹ"
    strKey_tilde   = "A a E e I i N n O o U u V v Y y"
    populate_encode_dict( encode_dict, strKey_umlaut, strValue_umlaut,  "{\\~", "}" )
    push!(regex_detectors, r"{ *\\~ *[a-zA-Z]{1} *}") 
    populate_encode_dict( encode_dict, strKey_tilde, strValue_tilde, "\\~", "" )
    push!(regex_detectors, r"\\\~ *[a-zA-Z]{1}") 
    populate_encode_dict( encode_dict, strKey_tilde, strValue_tilde, "\\~{", "}" )
    push!(regex_detectors, r"\\\~{ *[a-zA-Z]{1} *}")

    # macron \=a
    strValue_macron = "Ā ā B̄ b̄ C̄ c̄ D̄ d̄ Ē ē Ḡ ḡ Ī ī J̄ j̄ K̄ k̄ M̄ m̄ N̄ n̄ Ō ō P̄ p̄ Q̄ q̄ R̄ r̄ S̄ s̄ T̄ t̄ Ū ū V̄ v̄ W̄ w̄ X̄ x̄ Ȳ ȳ Z̄ z̄"
    strKey_macron   = "A a B b C c D d E e G g I i J j K k M m N n O o P p Q q R r S s T t U u V v W w X x Y y Z z"
    populate_encode_dict( encode_dict, strKey_umlaut, strValue_umlaut,  "{\\=", "}" )
    push!(regex_detectors, r"{ *\\= *[a-zA-Z]{1} *}") 
    populate_encode_dict( encode_dict, strKey_macron, strValue_macron, "\\=", "" )
    push!(regex_detectors, r"\\\= *[a-zA-Z]{1}")
    populate_encode_dict( encode_dict, strKey_macron, strValue_macron, "\\={", "}" )
    push!(regex_detectors, r"\\\={ *[a-zA-Z]{1} *}")

    # bar under the letter \b{a}
    strValue_bar_under = "A̱ a̱ Ḇ ḇ C̱ c̱ Ḏ ḏ E̱ e̱ G̱ g̱ H̱ ẖ I̱ i̱ J̱ j̱ Ḵ ḵ Ḻ ḻ M̱ m̱ Ṉ ṉ O̱ o̱ P̱ p̱ Ṟ ṟ S̱ s̱ Ṯ ṯ U̱ u̱ X̱ x̱ Y̱ y̱ Ẕ ẕ"
    strKey_bar_under   = "A a B b C c D d E e G g H h I i J j K k L l M m N n O o P p R r S s T t U u X x Y y Z z"
    populate_encode_dict( encode_dict, strKey_bar_under, strValue_bar_under, "\\b{", "}" )
    push!(regex_detectors, r"\\b{ *[a-zA-Z]{1} *}") 
    populate_encode_dict(encode_dict, strKey_bar_under, strValue_bar_under, "\\b\\", "" )
    push!(regex_detectors, r"\\b *\\[a-zA-Z]{1} *")

    # ring over the letter \r{a}
    strValue_ring = "Å å D̊ d̊ E̊ e̊ G̊ g̊ I̊ i̊ J̊ j̊ O̊ o̊ Q̊ q̊ S̊ s̊ Ů ů V̊ v̊ W̊ ẘ X̊ x̊ Y̊ ẙ"
    strKey_ring   = "A a d d E e G g I i J j O o Q q S s U u V v W w X x Y y"
    populate_encode_dict( encode_dict, strKey_ring, strValue_ring, "\\r{", "}" )
    push!(regex_detectors,  r"\\r{ *[a-zA-Z]{1} *}")
    populate_encode_dict( encode_dict, strKey_ring, strValue_ring, "\\r\\", "" )
    push!(regex_detectors, r"\\r *\\[a-zA-Z]{1} *")

    return (encode_dict, regex_detectors)
end 



translation_rule, accent_detector = create_translation_rules()

""" takes a string input @s, replaces all TeX style accents by their equivalent UTF-8 or ASCII character
        if @utf8_or_ascii==1 replacement is by UTF-8 variant, otherwise plain ASCII will be used
    """
function decode_Tex_Accents(s, utf8=true)

    for (i, accent_pattern) in enumerate(accent_detector)       

        # we might have the same substring appearing several times.
        # Since the replacement depends only on the translation rule, we pass from
        # list to set in order to (potentially) decrease the number of string opertions
        matches = Set(findall(accent_pattern, s)) 
        for match_limits in matches
            s1 = s[match_limits]
            # remove the spaces to match the format of translation table
            x = replace(s[match_limits], " " => "")
            if x in keys(translation_rule)
                if utf8
                    s = replace(s, s1 => translation_rule[x][1])
                else
                    s = replace(s,  s1 => translation_rule[x][2])
                end
            end
        end
    end
    return s
end
end