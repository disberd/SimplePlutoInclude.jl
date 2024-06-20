module SimplePlutoInclude

export @plutoinclude

# Custom function to check if we are inside Pluto
is_inside_pluto() = isdefined(Main, :PlutoRunner) && 
Main.PlutoRunner isa Module && 
"Pluto" in Main.PlutoRunner |> pkgdir |> splitpath

function extract_names(m::Module; imported=false, all=true, kwargs...)
    nms = names(m; all, imported, kwargs...)
    # Exclude PlutoPkg names and `eval` and `include` from exporting
    excluded = (:PLUTO_PROJECT_TOML_CONTENTS, :PLUTO_MANIFEST_TOML_CONTENTS, :eval, :include, Symbol("@bind"))
    filter(nms) do nm
        nm ∉ excluded && !Base.isgensym(nm)
    end
end

function extract_kwargs(inputs, caller::Module)
    kwargs = Dict{Symbol,Bool}()
    # Create a function that will evaluate the path expression in the caller module
    resolve_path(ex) = Core.eval(caller, ex) |> abspath
    # If there is only one input, simply assume no kwargs
    if length(inputs) === 1
        return only(inputs) |> resolve_path, kwargs
    end
    iskwarg(ex) = Meta.isexpr(ex, :(=))
    kwargs_idxs = findall(iskwarg, inputs)
    nkwargs = isnothing(kwargs_idxs) ? 0 : length(kwargs_idxs)
    @assert nkwargs === length(inputs) - 1 "The set of inputs provided to the @plutoinclude macro is not supported.
The supported inputs to the macro are:
- One single input representing the path to file to include, which will be evaluated during macro expansion in the calling module
- Any number of assignment expression of the form `name = value::Bool` which will be interpretd as keyword argument to use for extracting names from the file."
    for idx in kwargs_idxs
        ex = inputs[idx]
        name, value = ex.args
        @assert value isa Bool "The kwarg associated to the name $name does not have a Boolean value."
        kwargs[name] = value
    end
    # Find the input arg which shall be interpreted as path
    path_idx = setdiff(1:length(inputs), kwargs_idxs) |> only
    path = resolve_path(inputs[path_idx])
    return path, kwargs
end

# This function will just warns that no names were extracted
function warn_no_names()
    msg = "No names were extracted from the generated module.\nConsider setting the `all` kwarg to `true` or specifically mark names with `export` within the included file"
    @warn msg
    "WARNING: $msg" |> Text
end

function plutoinclude(path::AbstractString, caller::Module; kwargs...)
    is_inside_pluto() || return nothing # Do nothing outside of Pluto
    @assert isabspath(path) "The plutoinclude function must be called with an absolute path as input"
    modname = Symbol(basename(path)) |> gensym
    modex = :(module $modname
    include($path)
    end)
    # Create module
    generated_module = Core.eval(caller, modex)
    # Extract names
    nms = extract_names(generated_module; kwargs...)
    # Return nothing if no names have been extracted
    isempty(nms) && return :($warn_no_names())
    nms_expr = map(nm -> Expr(:., nm), nms)
    modexpr = Expr(:., fullname(caller)..., modname)
    ex = Expr(:import, Expr(:(:), modexpr, nms_expr...))
end

macro plutoinclude(args...)
    caller = __module__
    path, kwargs = extract_kwargs(args, caller)
    plutoinclude(path, caller; kwargs...) |> esc
end

end # module SimplePlutoInclude
