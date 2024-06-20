# SimplePlutoInclude

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://disberd.github.io/SimplePlutoInclude.jl/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://disberd.github.io/SimplePlutoInclude.jl/dev) -->
[![Build Status](https://github.com/disberd/SimplePlutoInclude.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/disberd/SimplePlutoInclude.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/disberd/SimplePlutoInclude.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/disberd/SimplePlutoInclude.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

This packages exports a single macro `@plutoinclude` which is a simplified version of the `@plutoinclude` macro which was exported by [PlutoDevMacros.jl](https://github.com/disberd/PlutoDevMacros.jl) up to version v0.7.

- [SimplePlutoInclude](#simpleplutoinclude)
  - [Basic Functionality](#basic-functionality)
  - [Specifying the file to include](#specifying-the-file-to-include)
  - [Customizing imported names](#customizing-imported-names)
  - [Alternatives](#alternatives)

## Basic Functionality
This macro tries to simplify the process of __including__ a julia file inside a Pluto notebook with the possibility of __reloading__ the file once its contents are updated.
The target file can be any valid julia file (including another Pluto notebook), and this macro simply performs the following steps:
1. Create an empty temporary module inside the caller module
2. Include the target file within the temporary module
3. Explicitly imports the _names_ defined in the __included__ file in the current Pluto workspace

> [!NOTE]
> The temporary module is created during macro expansion time in order to be able to extract the names and explicitly import them in the expression generated by the macro. **This means that reloading the contents of the file can only be done by _manually_ reloading the cell containing the `@plutoinclude` macro**.

> [!IMPORTANT]
> Any package that is imported or used within the included file must also be present in the environment of the notebook calling the `@plutoinclude` macro. 
> This macro tries to be as simple as possible and does not handles the environment of the included file. For more complex cases, consider using the other macros defined in [PlutoDevMacros.jl](https://github.com/disberd/PlutoDevMacros.jl)

## Specifying the file to include
The path to the file to be included can be specified either as a plain `String`, or as any expression that will evaluate to a String in the caller module (i.e. the Pluto workspace where the `@plutoinclude` macro is called).

An example use of `@plutoinclude` is fed a path as input based on a variable defined in the notebook is the following:
![image](https://github.com/disberd/SimplePlutoInclude.jl/assets/12846528/3eabe137-ca4a-46a3-a68b-a1c66a18d1aa)

> [!WARNING]
> When specifying the path as an expression depending on variables/functions defined in the notebook itself, the `@plutoinclude` macro might behave strangely as the code loading is happening during macro expansion. The following two _strange_ behaviors are important to know about when using variables/functions defined within the notebook as input to the macro:
> - The cell containing the macro might error when running for the first time after opening a notebook, depending on the cell loading order within the notebook. This is because the symbol/function is evaluated during the first macro expansion, so **before** the cell definining the symbol/function is first executed. This can easily be solved by manually re-running the cell with `@plutoinclude`.
> - The `@plutoinclude` macro will not reload the contents of the file upon _reactive_ run (i.e. when the cell is ran because one of its dependencies has been changed, and not because it was manually re-run). This is because the macro is not _expanded_/_compiled_ again upon _reactive_ run, so the module containing the _included_ file will not be re-created. 

## Customizing imported names
The names to be introduced into the Pluto workspace are simply extracted from the temporary module using `Base.names(tempmodule)`, and filtering out some of the output names (e.g. `gensym`-ed names and other like `eval` and `include`).

By default, the call to `Base.names` will have the `all` keyword argument set to true in order to export all names defined directly within the _included_ file.

The `@plutoinclude` macro accepts as additional inputs any number of assignments expression of the form `name = value` where `value` must be a `Bool`. These expression are parsed at the beginning of the macro expansion and grouped as `kwargs` that are passed to the `Base.names` call. One could example set the `all` kwarg to false as in the example below:
![image](https://github.com/disberd/SimplePlutoInclude.jl/assets/12846528/3abd2ac3-ce6d-40ac-8e54-a761ae205a6a)

> [!NOTE]
> Setting `all` to `false` will not export any name defined in the _included_ file unless something is explicitly marked with `export` or `public` within the file.

> [!NOTE]
> If you want to avoid exporting some specific variables from an included Pluto notebook, like for example the variables defined with `@bind`, consider marking them in the original notebook as _Disabled in file_, so they will be commented out in the source file and will not be _included_ in the temporary module generated by `@plutoinclude`.

## Alternatives
The functionality provided by the `@plutoinclude` macro is very similar to the `@ingredients` macro from [PlutoLinks.jl](https://github.com/JuliaPluto/PlutoLinks.jl). The main difference is the fact that while `@ingredients` does not explicitly import any name inside the calling Pluto notebook, `@plutoinclude` does.
This often simplifies interactive development as one does not need to always prepend the module name to access the variables defined within the file
> [!NOTE]
> `@ingredients` also tracks changes in the file and rerun dependent cells when updating the file. While a mode supporting `Revise` is planned for the next release of SimplePlutoInclude, automatic reload of dependent cells is not planned for this macro as the reload of the file is intended to only be done manually to accidentally avoid triggering long-running cells each time a file is changed. 