#!/usr/bin/env julia
using Pkg
Pkg.activate(".")

using DataFrames, CSV, Plots

# — chemins robustes (peu importe d’où on lance)
const ROOT = normpath(joinpath(@__DIR__, ".."))
const OUT  = joinpath(ROOT, "resultats")
mkpath(OUT)

# — modules internes
include(joinpath(ROOT, "src", "io_operations.jl")); using .IOOperations
include(joinpath(ROOT, "src", "optimisation.jl"));  using .Optimisation

# — pipeline
println("→ Chargement fréquentation…")
fr = IOOperations.charger_frequentation()
@assert nrow(fr) > 0 "frequentation vide"

println("→ Agrégation par heure…")
dmd = Optimisation.prepare_demande_par_heure(fr)
@assert nrow(dmd) > 0 "demande vide"

println("→ Plan recommandé…")
plan = Optimisation.plan_frequence(dmd)
@assert nrow(plan) > 0 "plan vide"

# — exports CSV
CSV.write(joinpath(OUT, "demande_par_heure.csv"), dmd)
CSV.write(joinpath(OUT, "plan_recommande.csv"),    plan)

# — graphiques
bar(dmd.heure, dmd.passagers, legend=false,
    xlabel="Heure", ylabel="Passagers", title="Demande par heure")
savefig(joinpath(OUT, "demande_par_heure.png"))

plot(plan.heure, plan.freq_recommandee, legend=false, lw=2, marker=:circle,
     xlabel="Heure", ylabel="Bus/heure", title="Fréquence recommandée")
savefig(joinpath(OUT, "frequence_recommandee.png"))

plot(plan.heure, plan.passagers, lw=2, marker=:circle, label="Demande",
     xlabel="Heure", ylabel="Passagers", title="Demande vs capacité")
plot!(plan.heure, plan.capacite_theorique, lw=2, marker=:square, label="Capacité théorique")
savefig(joinpath(OUT, "demande_vs_capacite.png"))


# === Taux de charge (demande / capacité) + résumé ===
# On calcule TOUJOURS taux_charge pour éviter UndefVarError
taux_charge = if (:passagers in names(plan)) && (:capacite_theorique in names(plan))
    round.(plan.passagers ./ max.(plan.capacite_theorique, 1e-9), digits=2)
else
    fill(missing, nrow(plan))
end

# Graphe (seulement si on a des valeurs numériques)
if any(!ismissing, taux_charge)
    plt_tc = plot(plan.heure, taux_charge, lw=2, marker=:circle, legend=false,
                  xlabel="Heure", ylabel="Taux de charge",
                  title="Taux de charge (demande / capacité)")
    ylims!(plt_tc, (0, 1.2))
    savefig(joinpath(OUT, "taux_de_charge.png"))
end

# === Création du résumé CSV propre ===
resume = DataFrame(
    heure = plan.heure,
    passagers = hasproperty(plan, :passagers) ? plan.passagers : fill(missing, nrow(plan)),
    capacite_theorique = hasproperty(plan, :capacite_theorique) ? plan.capacite_theorique : fill(missing, nrow(plan)),
    taux_charge = taux_charge
)

CSV.write(joinpath(OUT, "resume_taux_de_charge.csv"), resume)



println("\n✅ Graphiques + CSV exportés dans: $OUT")
