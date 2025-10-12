👥 Équipe

KABRE Abdoul Aziz – Backend & architecture du système

COMPAORE Washylatou – Analyse des données, visualisations et recommandations



🧾 Rapport et vidéos

Rapport final : docs/rapport_final.pdf

Lien vidéo (Aziz – Backend) : 

Lien vidéo (Washylatou – Analytics) : 


🧩 Structure du projet

📁 PROJET_SOTRACO_JULIA_GROUPE/
├── src/                # Modules principaux (types, io, metrics, optimisation, analyse)
├── data/               # Données sources CSV
├── scripts/            # Scripts d'automatisation (plots, mkreport)
├── resultats/          # Résultats générés (CSV, PNG, rapports)
├── test/               # Tests unitaires
├── docs/               # Documentation et rapport final
└── README.md

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


🏁 Auteur & version
By KABRE ABDOUL AZIZ & COMPAORE WASHYLATOU
Version finale : v1.0 (Mars 2025)
Université Joseph Ki-Zerbo – Master 1 Data Science
Projet Julia : Optimisation des fréquences de bus urbains (SOTRACO)