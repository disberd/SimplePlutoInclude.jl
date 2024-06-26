using SafeTestsets
import Pkg
# We instantiate the test env
function instantiate(path)
    curr_proj = Base.active_project()
    try
        Pkg.activate(path)
        Pkg.instantiate()
    finally
        Pkg.activate(curr_proj)
    end
end
instantiate(@__DIR__)

@safetestset "Aqua" begin
    using SimplePlutoInclude
    using Aqua
    Aqua.test_all(SimplePlutoInclude)
end

@safetestset "Without Pluto Session" begin
    using SimplePlutoInclude
    using SimplePlutoInclude: plutoinclude, is_inside_pluto, extract_kwargs
    using Test

    # Outside of Pluto this must return nothing
    @test Core.eval(@__MODULE__, :(@plutoinclude "something")) === nothing
    @test is_inside_pluto() === false

    # Test the extract_kwargs throws
    @test_throws "@plutoinclude macro is not supported" extract_kwargs((:a, :b), Main)
end

@safetestset "With Pluto Session" begin include("with_pluto_session.jl") end