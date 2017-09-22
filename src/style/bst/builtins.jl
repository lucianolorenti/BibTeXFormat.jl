
#Built-in functions for BibTeX interpreter.

#CAUTION: functions should PUSH results, not RETURN

function print_warning(msg)
    warn(msg)
end

struct Builtin
	f
end
function execute(b::Builtin, i::Interpreter)
	b.f(i)
end

builtins = Dict()
macro builtin(name, func)
	fname = func.args[1].args[1]
	quote
		$func
        builtins[$name] = Builtin($fname)
	end
end

@builtin ">" function operator_more(i::Interpreter)
    arg1 = pop!(i)
    arg2 = pop!(i)
    if arg2 > arg1
        push!(i, 1)
    else
        push!(i, 0)
	end
end

@builtin "<" function operator_less(i::Interpreter)
    arg1 = pop!(i)
    arg2 = pop!(i)
    if arg2 < arg1
        push!(i, 1)
    else
        push!(i, 0)
	end
end

@builtin "=" function operator_equals(i::Interpreter)
    local arg1 = pop!(i)
    local arg2 = pop!(i)
    if arg2 == arg1
        push!(i, 1)
    else
        push!(i, 0)
	end
end

@builtin "*" function operator_asterisk(i::Interpreter)
    local arg1 = pop!(i)
    local arg2 = pop!(i)
    push!(i, string(arg2,arg1))
end

@builtin ":=" function operator_assign(i::Interpreter)
    var = pop!(i)
    value = pop!(i)
    set(var, value)
end

@builtin "+" function operator_plus(i)
    arg1 = pop!(i)
    arg2 = pop!(i)
    push!(i,arg2 + arg1)
end
@builtin "-" function operator_minus(i)
    arg1 = pop!(i)
    arg2 = pop!(i)
    push!(i,arg2 - arg1)
end
@builtin "add.period\$" function add_period(i)
    s = pop!(i)
    if length(s)>0 && !contains(".?!", rstrip(s, "}")[end])
        s = string(s,".")
	end
    push!(i,s)
end
@builtin "call.type\$" function call_type(i)
    entry_type = i.current_entry["type"]
    try
        func = i.vars[entry_type]
    catch e
        print_warning("entry type for \"$(i.current_entry_key)\" isn\"t style-file functionined")
        try
            func = i.vars["functionault.type"]
        catch e
            return
        end
    end
    func.execute(i)
end
@builtin "change.case\$" function change_case(i)

    mode = pop!(i)
    string = pop!(i)

    if length(mode)==0
        throw("empty mode string passed to change.case\$")
	end
    mode_letter = lowercase(mode[0])
    if !contains("lut", mode_letter)
        throw("incorrect change.case\$ mode: $mode")
	end

    push!(i,change_case(string, mode_letter))
end
@builtin "chr.to.int\$" function chr_to_int(i)
    s = pop!(i)
    try
        value = ord(s)
    catch e
        throw("$s passed to chr.to.int\$")
	end
    push!(i,value)
end
@builtin "cite\$" function cite(i)
    push!(i,i.current_entry_key)
end
@builtin "duplicate\$" function duplicate(i)
    tmp = pop!(i)
    push!(i,tmp)
    push!(i,tmp)
end
@builtin "empty\$" function empty(i)
    #FIXME error checking
    s = pop!(i)
    if length(s)>0 && s!=" "
        push!(i,0)
    else
        push!(i,1)
	end
end
function _split_names(names)
    return utils.split_name_list(names)
end

function _format_name(names, n, format)
    name = _split_names(names)[n - 1]
    return format_bibtex_name(name, format)
end
@builtin "format.name\$" function format_name(i)
    format = pop!(i)
    n = pop!(i)
    names = pop!(i)
    push!(i,_format_name(names, n, format))
end
@builtin "if\$" function if_(i)
    f1 = pop!(i)
    f2 = pop!(i)
    p = pop!(i)
    if p > 0
        f2.execute(i)
    else
        f1.execute(i)
	end
end
@builtin "int.to.chr\$" function int_to_chr(i)
    local n = pop!(i)
	local char = nothing
    try
        char = six.unichr(n)
    catch e
        trhow("$n passed to int.to.chr\$")
	end
    push!(i,char)
end

@builtin "int.to.str\$" function int_to_str(i)
    push!(i,string(pop!(i)))
end
@builtin "missing\$" function missing(i)
    f = pop!(i)
    if is_missing_field(i, f)
        push!(i,1)
    else
        push!(i,0)
    end
end
@builtin "newline\$" function newline(i)
    newline(i)
end
@builtin "num.names\$" function num_names(i)
    names = pop!(i)
    push!(i,length(split_name_list(names)))
end
@builtin "pop\$" function pop!(i)
    pop!(i)
end
@builtin "preamble\$" function preamble(i)
    push!(i,i.bib_data.preamble)
end
@builtin "purify\$" function purify(i)
    s = pop!(i)
    push!(i,utils.bibtex_purify(s))
end
@builtin "quote\$" function builtin_quote(i)
    push!(i,"'")
end

@builtin "skip\$" function skip(i::Interpreter)
end

@builtin "substring\$" function substring(i)
    length = pop!(i)
    start = pop!(i)
    string = pop!(i)
    push!(i,utils.bibtex_substring(string, start, length))
end
@builtin "stack\$" function stack(i)
    while length(i.stack)>0
        print(pop!(i), file=pybtex.io.stdout)
	end
end
@builtin "swap\$" function swap(i)
    tmp1 = pop!(i)
    tmp2 = pop!(i)
    push!(i,tmp1)
    push!(i,tmp2)
end
@builtin "text.length\$" function text_length(i)
    s = pop!(i)
    push!(i,utils.bibtex_len(s))
end
@builtin "text.prefix\$" function text_prefix(i)
    l = pop!(i)
    s = pop!(i)
    push!(i,utils.bibtex_prefix(s, l))
end
@builtin "top\$" function top(i::Interpreter)
    print(pop!(i))
end
@builtin "type\$" function type_(i::Interpreter)
    push!(i, i.current_entry["type"])
end
@builtin "warning\$" function warning(i::Integer)
    msg = pop!(i)
    print_warning(msg)
end
@builtin "while\$" function while_(i)
    f = pop!(i)
    p = pop!(i)
    while true
        p.execute(i)
        if pop!(i) <= 0
            break
		end
        f.execute(i)
	end
end

@builtin "width\$" function width(i::Interpreter)
    local s = pop!(i)
    push!(i, utils.bibtex_width(s))
end
@builtin "write\$" function write(i::Interpreter)
    s = pop!(i)
    output(i, s)
end
