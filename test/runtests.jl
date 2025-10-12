# =========================================================
# test/runtests.jl — Tests unitaires pour le projet SOTRACO
# =========================================================

using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
Pkg.instantiate()

using Test
using DataFrames, CSV, Dates, Statistics, StatsBase

# === Chargement des modules internes ===
include(joinpath(@__DIR__, "..", "src", "optimisation.jl"));  using .Optimisation
include(joinpath(@__DIR__, "..", "src", "io_operations.jl")); using .IOOperations
include(joinpath(@__DIR__, "..", "src", "metrics.jl"));       using .Metrics
include(joinpath(@__DIR__, "..", "src", "analyse.jl"));       using .Analyse
include(joinpath(@__DIR__, "..", "src", "main.jl"));          using .MainApp


# ---------------------------------------------------------
# 🧩 TEST 1 : Module Optimisation (Préparation & Fréquences)
# ---------------------------------------------------------
@testset "Optimisation" begin
    # Données de test simples
    df = DataFrame(
        ligne_id = [1, 1, 1],
        heure    = [Time("06:00"), Time("07:00"), Time("08:00")],
        montees  = [10, 20, 30],
    )

    # Préparation de la demande
    dmd = Optimisation.prepare_demande_par_heure(df; ligne_id=1)
    @test :heure in Symbol.(names(dmd))
    @test :passagers in Symbol.(names(dmd))
    @test sum(dmd.passagers) == sum(df.montees)

    # Calcul du plan
    plan = Optimisation.plan_frequence(dmd)

    # ✅ convertit les noms en Symbol pour le test
    required = [:heure, :passagers, :freq_recommandee, :interv_min, :capacite_theorique]
    cols_sym = Symbol.(names(plan))
    @test all(n -> n in cols_sym, required)
    @test nrow(plan) == nrow(dmd)
end


# ---------------------------------------------------------
# 🧩 TEST 2 : Module IOOperations (Chargement des CSV)
# ---------------------------------------------------------
@testset "IOOperations" begin
    ar = IOOperations.charger_arrets()
    li = IOOperations.charger_lignes()
    fr = IOOperations.charger_frequentation()
    @test nrow(ar) > 0
    @test nrow(li) > 0
    @test nrow(fr) > 0
end


# ---------------------------------------------------------
# 🧩 TEST 3 : Vérification du menu principal
# ---------------------------------------------------------
@testset "Main menu (smoke)" begin
    @test isa(MainApp.lancer_systeme_sotraco, Function)
end

println("\n✅ Tous les tests ont été exécutés.")
