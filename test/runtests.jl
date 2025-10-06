using Test, DataFrames

include(joinpath(@__DIR__,"..","src","optimisation.jl"))
using .Optimisation

@testset "Optimisation smoke" begin
    fr = DataFrame(
        id=1:4, date=["2024-09-01","2024-09-01","2024-09-01","2024-09-01"],
        heure=["07","08","08","16"], ligne_id=[14,14,14,14], arret_id=[1,2,3,4],
        montees=[120,135,80,60], descentes=[0,0,0,0], occupation_bus=[0.7,0.8,0.5,0.4], capacite_bus=[80,80,80,80]
    )
    d = prepare_demande_par_heure(fr; ligne_id=14)
    @test !isempty(d)
    p = plan_frequence(d)
    @test all(n -> n in names(p), [:heure,:passagers,:freq_recommandee,:interv_min,:capacite_theorique])
end
