🎯 Objectif du projet

Ce projet vise à concevoir un système d’aide à la décision pour la gestion du transport urbain (cas de la SOTRACO).
L’objectif est de modéliser, analyser et optimiser la fréquence des bus à partir de données de fréquentation réelles ou simulées.

Le système :

traite les données d’arrêts, de lignes et de fréquentation ;

calcule les distances, temps de trajet et demandes horaires ;

recommande la fréquence optimale de bus ;

génère des graphiques et rapports d’analyse pour appuyer les décisions de planification.



👥 Équipe

KABRE Abdoul Aziz – Backend & architecture du système

COMPAORE Washylatou – Analyse des données, visualisations et recommandations



🧾 Rapport et vidéos

Rapport final : docs/rapport_final.pdf

Lien vidéo (Aziz – Backend) : 

Lien vidéo (Washylatou – Analytics) : 


🧩 Structure du projet

📁 PROJET_SOTRACO_JULIA_GROUPE/
│
├── src/
│   ├── types.jl             # Définition des structures et types
│   ├── io_operations.jl     # Chargement et normalisation des données CSV
│   ├── metrics.jl           # Calculs de distances et temps de trajet
│   ├── optimisation.jl      # Cœur du système d’optimisation (fréquences, demandes)
│   ├── analyse.jl           # Analyses statistiques et rapport
│   └── main.jl              # Menu principal du système
│
├── scripts/
│   └── plots.jl             # Génération automatique des graphiques et exports
│
├── test/
│   └── runtests.jl          # Tests unitaires du projet
│
├── data/                    # Données d’entrée (arrêts, lignes, fréquentation)
├── resultats/               # Exports (CSV, PNG, rapports)
├── Manifest.toml            # Dépendances techniques
├── Project.toml             # Métadonnées du projet
└── README.md                # Documentation principale


⚙️ Dépendances

Le projet s’exécute sous Julia ≥ 1.8.
Bibliothèques nécessaires (automatiquement installées via Pkg.instantiate()):

[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

🚀 Installation et exécution

Depuis le terminal (PowerShell ou bash) :

⚙️ Installation
Tapper les commande suivant dans le terminal
git clone https://github.com/kabreaziz60/PROJET_SOTRACO_JULIA_GROUPE.git
cd PROJET_SOTRACO_JULIA_GROUPE
julia --project=. -e "using Pkg; Pkg.instantiate()"


▶️ Exécution

Pour Lancer le menu principal taper:
include("src/main.jl")
using .MainApp
MainApp.lancer_systeme_sotraco()

Menu affiché :

=========================================
   SOTRACO - Système d’Optimisation
=========================================
1. Charger les données
2. Calculer distance + temps (exemple)
3. Optimiser fréquence pour une ligne
4. Générer les graphiques (Washylatou)
5. Analyses et recommandations
0. Quitter

Choisir le menu souhaité

📊 Sorties générées en fonction de votre choix

Tous les résultats sont enregistrés dans resultats/ :

demande_par_heure.csv, plan_recommande.csv

stats_par_ligne.csv, taux_moyen_par_ligne_heure.csv

demande_par_heure.png, frequence_recommandee.png, demande_vs_capacite.png, taux_de_charge.png

rapport_analytics.txt, rapport_analytics.md, recommandations.txt


🧪 Tests unitaires

Exécution :

julia --project=. -e "using Pkg; Pkg.test()"

                OU

julia test/runtests.jl

Les tests valident les modules :

Optimisation (calculs de fréquences, plan)

Metrics (distance et temps)

Analyse (stats par ligne, heures de pointe, taux d’occupation)


📊 Résultats

📂 Fichiers produits automatiquement :

resultats/demande_par_heure.csv

resultats/plan_recommande.csv

resultats/rapport_analytics.txt

resultats/*.png (graphiques)

🕐 Exemples de résultats :

Heures de pointe : 7h, 17h, 6h

Ligne la plus fréquentée : Ligne 1

Fréquence moyenne recommandée : 52 bus/h

🧭 Conclusion

Le projet SOTRACO démontre la mise en œuvre complète d’un pipeline de données en Julia, de la collecte à la visualisation.
Il illustre la collaboration efficace entre les membres de l’équipe et l’intégration de pratiques professionnelles : versioning Git, modularité, tests et reporting.


🏁 Auteur & version
By KABRE ABDOUL AZIZ & COMPAORE WASHYLATOU
Version finale : v1.0 (Mars 2025)
Université Joseph Ki-Zerbo – Master 1 Data Science
Projet Julia : Optimisation des fréquences de bus urbains (SOTRACO)