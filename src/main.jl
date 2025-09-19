module MainApp

using DataFrames: nrow

include("types.jl");         using .Types
include("io_operations.jl"); using .IOOperations
include("metrics.jl");       using .Metrics

export lancer_systeme_sotraco

function lancer_systeme_sotraco()
    println("========================================")
    println("   SOTRACO - Système d'Optimisation")
    println("========================================")
    println("1. Charger données")
    println("2. Calculer distance + temps (exemple)")
    println("0. Quitter")
    print("Choix: "); choix = try parse(Int, readline()) catch; -1 end

    if choix == 1
        ar = charger_arrets(); li = charger_lignes(); fr = charger_frequentation()
        println("Arrêts=$(nrow(ar))  Lignes=$(nrow(li))  Fréquentation=$(nrow(fr))")
    elseif choix == 2
        d = haversine_distance(12.31, -1.512, 12.387, -1.526)
        t = temps_trajet(d, 30.0)
        println("Distance ≈ $(round(d,digits=2)) km | Temps ≈ $(round(t,digits=1)) min")
    elseif choix == 0
        println("Bye")
    else
        println("Choix invalide")
    end
end

end # module
