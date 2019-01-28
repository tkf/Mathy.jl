using Mathy
using Test

include("../docs/utils.jl")

@testset "Mathy.jl" begin
    @test (mathy_makedocs(); true)
end
