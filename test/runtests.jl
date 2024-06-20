using SafeTestsets

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
    @test Core.eval(Main, :(@plutoinclude "something")) === nothing
    @test is_inside_pluto() === false

    # Test the extract_kwargs throws
    @test_throws "@plutoinclude macro is not supported" extract_kwargs((:a, :b), Main)
end