using SafeTestsets

@safetestset "Aqua" begin
    using SimplePlutoInclude
    using Aqua
    Aqua.test_all(SimplePlutoInclude)
end