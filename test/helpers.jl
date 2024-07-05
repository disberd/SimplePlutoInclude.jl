using Test
import Pkg
import Pkg.Types: Context, EnvCache
# We instantiate the test env
function instantiate_from_path(path::AbstractString; resolve = true)
    c = Context(;env = EnvCache(Base.current_project(path)))
    resolve && Pkg.resolve(c)
    Pkg.instantiate(c; update_registry = false, allow_build = false, allow_autoprecomp = false)
end
instantiate_from_path(@__DIR__)