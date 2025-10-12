module MainApp

using DataFrames
using Plots


# ===== Inclusions obligatoires (ils existent déjà chez vous) =====
include(joinpath(@__DIR__, "types.jl"));         using .Types
include(joinpath(@__DIR__, "io_operations.jl")); using .IOOperations
include(joinpath(@__DIR__, "metrics.jl"));       using .Metrics
include(joinpath(@__DIR__, "optimisation.jl"));  using .Optimisation

# ===== Inclusions optionnelles (analytics de Washylatou) =====
const PATH_ANALYSE       = joinpath(@__DIR__, "analyse.jl")
const PATH_VISUALISATION = joinpath(@__DIR__, "visualisation.jl")
const PATH_RAPPORTS      = joinpath(@__DIR__, "rapports.jl")

# On inclut seulement si le fichier existe ; PAS de `using` ici.
if isfile(PATH_ANALYSE)
    include(PATH_ANALYSE)           # définit MainApp.Analyse si le fichier contient `module Analyse ... end`
    const HAS_ANALYSE = true
else
    const HAS_ANALYSE = false
end

if isfile(PATH_VISUALISATION)
    include(PATH_VISUALISATION)     # définit MainApp.Visualisation
    const HAS_VISU = true
else
    const HAS_VISU = false
end

if isfile(PATH_RAPPORTS)
    include(PATH_RAPPORTS)          # définit MainApp.Rapports
    const HAS_RAPPORTS = true
else
    const HAS_RAPPORTS = false
end

export lancer_systeme_sotraco

function lancer_systeme_sotraco()
    println("==========================================")
    println("   SOTRACO - Système d'Optimisation")
    println("==========================================")
    println("1. Charger données")
    println("2. Calculer distance + temps (exemple)")
    println("3. Optimiser fréquence pour une ligne")
    println("4. Générer les graphiques")
    if HAS_ANALYSE && HAS_VISU && HAS_RAPPORTS
        println("5. Analyses et recommandations")
    end
    println("0. Quitter")
    print("Choix: ")

    choix = try parse(Int, strip(readline())) catch; -1 end

    if choix == 1
        ar = IOOperations.charger_arrets()
        li = IOOperations.charger_lignes()
        fr = IOOperations.charger_frequentation()
        println("Arrêts=$(nrow(ar))  Lignes=$(nrow(li))  Fréquentation=$(nrow(fr))")

    elseif choix == 2
        d = Metrics.haversine_distance(12.31, -1.512, 12.387, -1.526)
        t = Metrics.temps_trajet(d, 30.0)
        println("Distance ≈ $(round(d; digits=2)) km | Temps ≈ $(round(t; digits=1)) min")

    elseif choix == 3
        fr = IOOperations.charger_frequentation()
        if isempty(fr)
            println("⚠️  Aucune donnée de fréquentation."); return
        end
        print("Id de la ligne (0 = toutes): ")
        l = try parse(Int, strip(readline())) catch; 0 end
        ligne = l > 0 ? l : nothing

        dmd = Optimisation.prepare_demande_par_heure(fr; ligne_id=ligne)
        if isempty(dmd)
            println("⚠️  Demande vide."); return
        end
        plan = Optimisation.plan_frequence(dmd)

        println("\nDemande par heure:"); show(dmd,  allrows=true, allcols=true); println()
        println("\nPlan recommandé:");  show(plan, allrows=true, allcols=true); println()

    elseif choix == 4
        # Lance scripts/plots.jl
        plots_path = normpath(joinpath(@__DIR__, "..", "scripts", "plots.jl"))
        if !isfile(plots_path)
            println("⚠️  Fichier introuvable: $(plots_path)"); return
        end
        try
            println("🟦 Génération des graphiques et exports CSV…")
            include(plots_path)
            println("✅ Graphiques générés (voir `resultats/`).")
        catch err
            println("❌ Erreur lors de l'exécution de `plots.jl` : ", err)
        end

    elseif choix == 5
        if !(HAS_ANALYSE && HAS_VISU && HAS_RAPPORTS)
            println("⚠️  Modules analytics absents. Créez: src/analyse.jl, src/visualisation.jl, src/rapports.jl")
            return
        end
        fr = IOOperations.charger_frequentation()
        if isempty(fr)
            println("⚠️ Aucune donnée."); return
        end

        # Références QUALIFIÉES (pas besoin de `using`)
        stats  = Analyse.stats_par_ligne(fr)
        heures = Analyse.heures_de_pointe(fr)
        taux   = Analyse.taux_occupation(fr)

        println("\n--- STATISTIQUES PAR LIGNE ---")
        show(stats,  allrows=true, allcols=true);  println()
        println("\n--- HEURES DE POINTE ---")
        show(heures, allrows=true, allcols=true); println()

        Rapports.generer_rapport(stats, heures)


        println("\n📊 Graphiques en cours…")
        # dossier de sortie
        outdir = normpath(joinpath(@__DIR__, "..", "resultats"))
        mkpath(outdir)

        # Plot 1 : Heures de pointe (Top 3)
        p1 = bar(heures.heure, heures.passagers,
                xlabel = "Heure", ylabel = "Passagers",
                title  = "Heures de pointe (Top 3)", legend = false)
        savefig(p1, joinpath(outdir, "demande_par_heure_wash.png"))

        # Plot 2 : Taux d’occupation (si dispo)
        if !isempty(taux)
            # si groupby par (ligne, heure) → tu peux agréger par ligne si tu préfères
            p2 = bar(taux.ligne_id, taux.taux_moyen,
                    xlabel = "Ligne", ylabel = "% d’occupation (moy.)",
                    title  = "Taux moyen d’occupation par ligne/heure", legend = false)
            savefig(p2, joinpath(outdir, "taux_par_ligne_wash.png"))
        end

        println("✅ Graphiques sauvegardés dans resultats/")

    elseif choix == 0
        println("Bye 👋")
    else
        println("Choix invalide")
    end
end

end # module
