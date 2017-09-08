using BibTeXStyle
using Base.Test

base_file = dirname(dirname(@__FILE__))
import Documenter
Documenter.makedocs(
    modules = [BibTeXStyle, BibTeXStyle.Backends, BibTeXStyle.Backends.HTML,
               BibTeXStyle.RichTextElements],
    format = :html,
    sitename = "BibTeXStyle.jl",
    root = joinpath(base_file, "docs"),
    pages = Any["Home" => "index.md"],
    #strict = true,
    linkcheck = true,
    #checkdocs = :exports,
    authors = "Luciano Lorenti",
    doctest=true
)
@testset "Rich Text Utils" begin
    using BibTeX.RichTextUtils
    using BibTeX.Backends
    local t = RichText("this ", "is a ", Tag("em", "very"), RichText(" rich", " text"))
    @test render_as(t,"LaTex") == "this is a \\emph{very} rich text"
    @test convert(String,t)    == "this is a very rich text"

    local t1 = add_period(capitalize(t))
    @test render_as(t1,"latex") == "This is a \\emph{very} rich text."
    @test convert(String, t1)   == "This is a very rich text."
    @test render_as(TextSymbol("ndash"),"latex") == "--"

    local t2 = RichText("Some ", Tag("em", RichText("nested ", Tag("tt", "Text", RichText(" objects")))), ".")
    @test render_as(t2,"latex") == "Some \\emph{nested \\texttt{Text objects}}."
    @test convert(String, t2) == "Some nested Text objects."

    local t3 = uppercase(t2)
    @test render_as(t3,"latex")== "SOME \\emph{NESTED \\texttt{TEXT OBJECTS}}."
    @test convert(String ,t3) == "SOME NESTED TEXT OBJECTS."

    local t4 =  join(RichText(", "),["one", "two", Tag("em", "three")])
    @test render_as(t4,"latex") ==  "one, two, \\emph{three}"
    @test convert(String,t4)    == "one, two, three"

    local t5 = join(RichText(TextSymbol("nbsp"),["one", "two", Tag("em", "three")]))
    @test render_as(t5,"latex") == "one~two~\\emph{three}"
    @test convert(String ,t5) == "one<nbsp>two<nbsp>three"
end

struct InvalidNameString
    s::String
end
@testset "Parse Name" begin
sample_names = [
    ("A. E.                   Siegman", (["A.", "E."], [], ["Siegman"], [])),
    ("A. G. W. Cameron", (["A.", "G.", "W."], [], ["Cameron"], [])),
    ("A. Hoenig", (["A."], [], ["Hoenig"], [])),
    ("A. J. Van Haagen", (["A.", "J.", "Van"], [], ["Haagen"], [])),
    ("A. S. Berdnikov", (["A.", "S."], [], ["Berdnikov"], [])),
    ("A. Trevorrow", (["A."], [], ["Trevorrow"], [])),
    ("Adam H. Lewenberg", (["Adam", "H."], [], ["Lewenberg"], [])),
    ("Addison-Wesley Publishing Company",
    (["Addison-Wesley", "Publishing"], [], ["Company"], [])),
    ("Advogato (Raph Levien)", (["Advogato", "(Raph"], [], ["Levien)"], [])),
    ("Andrea de Leeuw van Weenen",
    (["Andrea"], ["de", "Leeuw", "van"], ["Weenen"], [])),
    ("Andreas Geyer-Schulz", (["Andreas"], [], ["Geyer-Schulz"], [])),
    ("Andr{\\'e} Heck", (["Andr{\\'e}"], [], ["Heck"], [])),
    ("Anne Br{\\\"u}ggemann-Klein", (["Anne"], [], ["Br{\\\"u}ggemann-Klein"], [])),
    ("Anonymous", ([], [], ["Anonymous"], [])),
    ("B. Beeton", (["B."], [], ["Beeton"], [])),
    ("B. Hamilton Kelly", (["B.", "Hamilton"], [], ["Kelly"], [])),
    ("B. V. Venkata Krishna Sastry",
    (["B.", "V.", "Venkata", "Krishna"], [], ["Sastry"], [])),
    ("Benedict L{\\o}fstedt", (["Benedict"], [], ["L{\\o}fstedt"], [])),
    ("Bogus{\\l}aw Jackowski", (["Bogus{\\l}aw"], [], ["Jackowski"], [])),
    ("Christina A. L.\\ Thiele",
    # (["Christina", "A.", "L.\\\"], [], ["Thiele"], [])),
    (["Christina", "A.", "L."], [], ["Thiele"], [])),  # BibTeX incompatible: treat "\ " as a space
    ("D. Men'shikov", (["D."], [], ["Men'shikov"], [])),
    ("Darko \\v{Z}ubrini{\\'c}", (["Darko"], [], ["\\v{Z}ubrini{\\'c}"], [])),
    ("Dunja Mladeni{\\'c}", (["Dunja"], [], ["Mladeni{\\'c}"], [])),
    ("Edwin V. {Bell, II}", (["Edwin", "V."], [], ["{Bell, II}"], [])),
    ("Frank G. {Bennett, Jr.}", (["Frank", "G."], [], ["{Bennett, Jr.}"], [])),
    ("Fr{\\'e}d{\\'e}ric Boulanger",
    (["Fr{\\'e}d{\\'e}ric"], [], ["Boulanger"], [])),
    ("Ford, Jr., Henry", (["Henry"], [], ["Ford"], ["Jr."])),
    ("mr Ford, Jr., Henry", (["Henry"], ["mr"], ["Ford"], ["Jr."])),
    ("Fukui Rei", (["Fukui"], [], ["Rei"], [])),
    ("G. Gr{\\\"a}tzer", (["G."], [], ["Gr{\\\"a}tzer"], [])),
    ("George Gr{\\\"a}tzer", (["George"], [], ["Gr{\\\"a}tzer"], [])),
    ("Georgia K. M. Tobin", (["Georgia", "K.", "M."], [], ["Tobin"], [])),
    ("Gilbert van den Dobbelsteen",
    (["Gilbert"], ["van", "den"], ["Dobbelsteen"], [])),
    ("Gy{\\\"o}ngyi Bujdos{\\\'o}", (["Gy{\\\"o}ngyi"], [], ["Bujdos{\\'o}"], [])),
    ("Helmut J{\\\"u}rgensen", (["Helmut"], [], ["J{\\\"u}rgensen"], [])),
    ("Herbert Vo{\\ss}", (["Herbert"], [], ["Vo{\\ss}"], [])),
    ("H{\\'a}n Th{\\^e}\\llap{\\raise 0.5ex\\hbox{\\'{\\relax}}}                  Th{\\'a}nh",
    (["H{\\'a}n", "Th{\\^e}\\llap{\\raise 0.5ex\\hbox{\\'{\\relax}}}"],
    [],
    ["Th{\\'a}nh"],
    [])),
    ("H{\\`a}n Th\\^e\\llap{\\raise0.5ex\\hbox{\\'{\\relax}}}                  Th{\\`a}nh",
    (["H{\\`a}n", "Th\\^e\\llap{\\raise0.5ex\\hbox{\\'{\\relax}}}"],
    [],
    ["Th{\\`a}nh"],
    [])),
    ("J. Vesel{\\'y}", (["J."], [], ["Vesel{\\'y}"], [])),
    ("Javier Rodr\\'{\\i}guez Laguna",
    (["Javier", "Rodr\\'{\\i}guez"], [], ["Laguna"], [])),
    ("Ji\\v{r}\\'{\\i} Vesel{\\'y}",
    (["Ji\\v{r}\\'{\\i}"], [], ["Vesel{\\'y}"], [])),
    ("Ji\\v{r}\\'{\\i} Zlatu{\\v{s}}ka",
    (["Ji\\v{r}\\'{\\i}"], [], ["Zlatu{\\v{s}}ka"], [])),
    ("Ji\\v{r}{\\'\\i} Vesel{\\'y}",
    (["Ji\\v{r}{\\'\\i}"], [], ["Vesel{\\'y}"], [])),
    ("Ji\\v{r}{\\'{\\i}}Zlatu{\\v{s}}ka",
    ([], [], ["Ji\\v{r}{\\'{\\i}}Zlatu{\\v{s}}ka"], [])),
    ("Jim Hef{}feron", (["Jim"], [], ["Hef{}feron"], [])),
    ("J{\\\"o}rg Knappen", (["J{\\\"o}rg"], [], ["Knappen"], [])),
    ("J{\\\"o}rgen L. Pind", (["J{\\\"o}rgen", "L."], [], ["Pind"], [])),
    ("J{\\'e}r\\^ome Laurens", (["J{\\'e}r\\^ome"], [], ["Laurens"], [])),
    ("J{{\\\"o}}rg Knappen", (["J{{\\\"o}}rg"], [], ["Knappen"], [])),
    ("K. Anil Kumar", (["K.", "Anil"], [], ["Kumar"], [])),
    ("Karel Hor{\\'a}k", (["Karel"], [], ["Hor{\\'a}k"], [])),
    ("Karel P\\'{\\i}{\\v{s}}ka", (["Karel"], [], ["P\\'{\\i}{\\v{s}}ka"], [])),
    ("Karel P{\\'\\i}{\\v{s}}ka", (["Karel"], [], ["P{\\'\\i}{\\v{s}}ka"], [])),
    ("Karel Skoup\\'{y}", (["Karel"], [], ["Skoup\\'{y}"], [])),
    ("Karel Skoup{\\'y}", (["Karel"], [], ["Skoup{\\'y}"], [])),
    ("Kent McPherson", (["Kent"], [], ["McPherson"], [])),
    ("Klaus H{\\\"o}ppner", (["Klaus"], [], ["H{\\\"o}ppner"], [])),
    ("Lars Hellstr{\\\"o}m", (["Lars"], [], ["Hellstr{\\\"o}m"], [])),
    ("Laura Elizabeth Jackson",
    (["Laura", "Elizabeth"], [], ["Jackson"], [])),
    ("M. D{\\'{\\i}}az", (["M."], [], ["D{\\'{\\i}}az"], [])),
    ("M/iche/al /O Searc/oid", (["M/iche/al", "/O"], [], ["Searc/oid"], [])),
    ("Marek Ry{\\'c}ko", (["Marek"], [], ["Ry{\\'c}ko"], [])),
    ("Marina Yu. Nikulina", (["Marina", "Yu."], [], ["Nikulina"], [])),
    ("Max D{\\'{\\i}}az", (["Max"], [], ["D{\\'{\\i}}az"], [])),
    ("Merry Obrecht Sawdey", (["Merry", "Obrecht"], [], ["Sawdey"], [])),
    ("Miroslava Mis{\\'a}kov{\\'a}",
    (["Miroslava"], [], ["Mis{\\'a}kov{\\'a}"], [])),
    ("N. A. F. M. Poppelier", (["N.", "A.", "F.", "M."], [], ["Poppelier"], [])),
    ("Nico A. F. M. Poppelier",
    (["Nico", "A.", "F.", "M."], [], ["Poppelier"], [])),
    ("Onofrio de Bari", (["Onofrio"], ["de"], ["Bari"], [])),
    ("Pablo Rosell-Gonz{\\'a}lez", (["Pablo"], [], ["Rosell-Gonz{\\'a}lez"], [])),
    ("Paco La                  Bruna", (["Paco", "La"], [], ["Bruna"], [])),
    ("Paul                  Franchi-Zannettacci",
    (["Paul"], [], ["Franchi-Zannettacci"], [])),
    ("Pavel \\v{S}eve\\v{c}ek", (["Pavel"], [], ["\\v{S}eve\\v{c}ek"], [])),
    ("Petr Ol{\\v{s}}ak", (["Petr"], [], ["Ol{\\v{s}}ak"], [])),
    ("Petr Ol{\\v{s}}{\\'a}k", (["Petr"], [], ["Ol{\\v{s}}{\\'a}k"], [])),
    ("Primo\\v{z} Peterlin", (["Primo\\v{z}"], [], ["Peterlin"], [])),
    ("Prof. Alban Grimm", (["Prof.", "Alban"], [], ["Grimm"], [])),
    ("P{\\'e}ter Husz{\\'a}r", (["P{\\'e}ter"], [], ["Husz{\\'a}r"], [])),
    ("P{\\'e}ter Szab{\\'o}", (["P{\\'e}ter"], [], ["Szab{\\'o}"], [])),
    ("Rafa{\\l}\\.Zbikowski", ([], [], ["Rafa{\\l}\\.Zbikowski"], [])),
    ("Rainer Sch{\\\"o}pf", (["Rainer"], [], ["Sch{\\\"o}pf"], [])),
    ("T. L. (Frank) Pappas", (["T.", "L.", "(Frank)"], [], ["Pappas"], [])),
    ("TUG 2004 conference", (["TUG", "2004"], [], ["conference"], [])),

    # von part with BibTeX special characters
    ("TUG {\\sltt DVI} Driver Standards Committee",
    (["TUG", "{\\sltt DVI}", "Driver", "Standards"], [], ["Committee"], [])),
    ("TUG {\\sltt xDVIx} Driver Standards Committee",
    (["TUG"], ["{\\sltt xDVIx}"], ["Driver", "Standards", "Committee"], [])),

    ("University of M{\\\"u}nster",
    (["University"], ["of"], ["M{\\\"u}nster"], [])),
    ("Walter van der Laan", (["Walter"], ["van", "der"], ["Laan"], [])),
    ("Wendy G.                  McKay", (["Wendy", "G."], [], ["McKay"], [])),
    ("Wendy McKay", (["Wendy"], [], ["McKay"], [])),
    ("W{\\l}odek Bzyl", (["W{\\l}odek"], [], ["Bzyl"], [])),
    ("\\LaTeX Project Team", (["\\LaTeX", "Project"], [], ["Team"], [])),
    ("\\rlap{Lutz Birkhahn}", ([], [], ["\\rlap{Lutz Birkhahn}"], [])),
    ("{Jim Hef{}feron}", ([], [], ["{Jim Hef{}feron}"], [])),
    ("{Kristoffer H\\o{}gsbro Rose}",
    ([], [], ["{Kristoffer H\\o{}gsbro Rose}"], [])),
    ("{TUG} {Working} {Group} on a {\\TeX} {Directory}                  {Structure}",
    (["{TUG}", "{Working}", "{Group}"],
    ["on", "a"],
    ["{\\TeX}", "{Directory}", "{Structure}"],
    [])),
    ("{The \\TUB{} Team}", ([], [], ["{The \\TUB{} Team}"], [])),
    ("{\\LaTeX} project team", (["{\\LaTeX}"], ["project"], ["team"], [])),
    ("{\\NTG{} \\TeX{} future working group}",
    ([], [], ["{\\NTG{} \\TeX{} future working group}"], [])),
    ("{{\\LaTeX\\,3} Project Team}",
    ([], [], ["{{\\LaTeX\\,3} Project Team}"], [])),
    ("Johansen Kyle, Derik Mamania M.",
    (["Derik", "Mamania", "M."], [], ["Johansen", "Kyle"], [])),
    ("Johannes Adam Ferdinand Alois Josef Maria Marko d'Aviano Pius von und zu Liechtenstein",
    (["Johannes", "Adam", "Ferdinand", "Alois", "Josef", "Maria", "Marko"],
    ["d'Aviano", "Pius", "von", "und", "zu"], ["Liechtenstein"],[])),

    # sort of wrong, but BibTeX parses it like this
    (r"Brand\~{a}o, F", (["F"], [], ["Brand\\", "{a}o"], [])),

    # incorrectly formatted name strings below

    # too many commas
    ("Chong, B. M., Specia, L., & Mitkov, R.",
    (["Specia", "L.", "&", "Mitkov", "R."], [], ["Chong"], ["B.", "M."]),
    [InvalidNameString("Chong, B. M., Specia, L., & Mitkov, R.")]
    ),
    # too many commas, sloppy whitespace
    ("LeCun, Y. ,      Bottou,   L . , Bengio, Y. ,  Haffner ,  P",
    (["Bottou", "L", ".", "Bengio", "Y.", "Haffner", "P"], [], ["LeCun"], ["Y."]),
    [InvalidNameString("LeCun, Y. ,      Bottou,   L . , Bengio, Y. ,  Haffner ,  P")]),
]

function parse_name(name, correct_result, expected_errors=nothing)
    if expected_errors == nothing
        expected_errors = []
    end

    local person = Person(name)

    result = (person.bibtex_first_names, person.prelast_names, person.last_names, person.lineage_names)
    @test result == correct_result
    #@test captured_errors == expected_errors
end

function test_parse_name()
    for test_args in sample_names
        parse_name(test_args...)
    end
end

end
