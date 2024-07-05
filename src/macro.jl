"""
    @plutoinclude path [kwarg1 = value1, kwarg2 = value2, ...]

This macro simplify the inclusion of the file pointed at by `path` inside a Pluto notebook, and it simply becomes a no-op when called outside of a Pluto session.

The macro simply performs the following three steps: 
1. Create an empty temporary module (outside of the Pluto workspace)
2. Include the target file within the temporary module
3. Explicitly imports (from the module created in 1.) the _names_ defined in the __included__ file in the current Pluto workspace

See the [package](https://github.com/disberd/SimplePlutoInclude.jl) README on github for more details

## Path
The path can be specified either as a plain String, or as an expression that evaluates to the string path in the caller module.

## Files containing a single module definition
Files that only contain a single module definition are treated differently. 
The macro, in this case, will import in the calling (Pluto) workspace the names extracted from this single module, instead of the names at the file top-level (which would only be the module's name).

## Optional Keyword Arguments
Apart from the path, the macro also accepts additional inputs in the form `name = value` where `value` must be a `Bool`. These values are passed internally as keyword arguments to the `Base.names` function that is called to extract all names defined in the temporary module that included the file.
"""
macro plutoinclude(args...)
    is_inside_pluto(__source__) || return nothing # Do nothing outside of Pluto
    caller = __module__
    target_ex, input_kwargs = extract_kwargs(args)
    val_from_caller = Core.eval(caller, target_ex)
    plutoinclude(target_ex, val_from_caller; input_kwargs) |> esc
end