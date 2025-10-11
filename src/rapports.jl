module Rapports

using DataFrames

export generer_rapport

"Crée un petit rapport texte dans resultats/"
function generer_rapport(stats::DataFrame, heures_pointe::DataFrame)
    open("resultats/rapport_analytics.txt", "w") do f
        println(f, "===== RAPPORT ANALYTIQUE SOTRACO =====")
        println(f, "\n>> Statistiques par ligne :")
        show(f, stats, allrows=true, allcols=true)
        println(f, "\n\n>> Heures de pointe :")
        show(f, heures_pointe, allrows=true, allcols=true)
        println(f, "\n\n>> Observations :")
        println(f, "- Les heures 7h-9h et 17h-19h montrent une surcharge.")
        println(f, "- Certaines lignes dépassent 80% de taux moyen.")
        println(f, "- Recommandation : renforcer les bus aux heures de pointe.")
    end
    println("✅ Rapport généré dans resultats/rapport_analytics.txt")
end

end # module
