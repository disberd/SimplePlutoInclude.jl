using TestItemRunner

@testitem "Aqua" begin
    using SimplePlutoInclude
    using Aqua
    Aqua.test_all(SimplePlutoInclude)
end

@testitem "Without Pluto Session" begin
    include(joinpath(@__DIR__, "helpers.jl"))
    using SimplePlutoInclude
    using SimplePlutoInclude: plutoinclude, is_inside_pluto, extract_kwargs
    using Test

    # Outside of Pluto this must return nothing
    @test Core.eval(@__MODULE__, :(@plutoinclude "something")) === nothing
    @test is_inside_pluto() === false

    # Test the extract_kwargs throws
    @test_throws "@plutoinclude macro is not supported" extract_kwargs((:a, :b))
end

include("with_pluto_session.jl")

@run_package_tests verbose=true