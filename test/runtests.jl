include(joinpath(@__DIR__, "..", "src", "metrics.jl"))
using .Metrics

@testset "Metrics" begin
    d = haversine_distance(12.31, -1.512, 12.387, -1.526)
    @test d > 0
    t = temps_trajet(d, 30.0)
    @test t > 0
end
