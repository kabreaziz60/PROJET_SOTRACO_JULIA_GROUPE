module MainApp

using DataFrames  # nrow, show, etc.

include(joinpath(@__DIR__, "types.jl"));         using .Types
include(joinpath(@__DIR__, "io_operations.jl")); import .IOOperations: charger_arrets, charger_lignes, charger_frequentation
include(joinpath(@__DIR__, "metrics.jl"));       using .Metrics
include(joinpath(@__DIR__, "optimisation.jl"));  using .Optimisation

export lancer_systeme_sotraco

function lancer_systeme_sotraco()
    println("==========================================")
    println("   SOTRACO - Système d'Optimisation")
    println("==========================================")
    println("1. Charger données")
    println("2. Calculer distance + temps (exemple)")
    println("3. Optimiser fréquence pour une ligne")
    println("0. Quitter")
    print("Choix: ")

    # ⚠️ robustesse: on strip l'entrée pour éviter "1 " ou "\r\n"
    raw = readline()
    choix = try parse(Int, strip(raw)) catch; -1 end

    if choix == 1
        ar = charger_arrets()
        li = charger_lignes()
        fr = charger_frequentation()  # auto-détection ',' / ';' dans IOOperations
        println("Arrêts=$(nrow(ar))  Lignes=$(nrow(li))  Fréquentation=$(nrow(fr))")

    elseif choix == 2
        d = haversine_distance(12.31, -1.512, 12.387, -1.526)
        t = temps_trajet(d, 30.0)
        println("Distance ≈ $(round(d; digits=2)) km | Temps ≈ $(round(t; digits=1)) min")

    elseif choix == 3
        fr = charger_frequentation()
        if isempty(fr)
            println("⚠️  Aucune donnée de fréquentation."); return
        end

        print("Id de la ligne (0 = toutes): ")
        raw_l = readline()
        l = try parse(Int, strip(raw_l)) catch; 0 end
        ligne = l > 0 ? l : nothing

        # ✅ Pipeline robuste du module Optimisation
        dmd  = Optimisation.prepare_demande_par_heure(fr; ligne_id=ligne)
        if isempty(dmd)
            println("⚠️  Demande vide (vérifie colonnes `heure`, `montees`/`passagers`, ou `occupation_bus`+`capacite_bus`).")
            return
        end
        plan = Optimisation.plan_frequence(dmd)  # (80, 0.75, 10 min par défaut)

        println("\nDemande par heure:")
        show(dmd, allrows=true, allcols=true); println()
        println("\nPlan recommandé:")
        show(plan, allrows=true, allcols=true); println()

    elseif choix == 0
        println("Bye")
    else
        println("Choix invalide")
    end
end

end # module
