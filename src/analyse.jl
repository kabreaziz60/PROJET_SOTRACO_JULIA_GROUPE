module Analyse

using DataFrames, Statistics, Dates

export stats_par_ligne, heures_de_pointe, taux_occupation

# -------- Helpers robustes: recherche de colonnes par nom (insensible au format) --------

"""
Retourne le Symbol de la 1ère colonne trouvée dont le nom (en minuscule) est
dans `candidats`. Exemple: getcol(df, ["passagers","montees"])
"""
function getcol(df::DataFrame, candidats::Vector{String})
    nms = lowercase.(string.(names(df)))  # ex: ["id","date","heure",...]
    for want in candidats
        idx = findfirst(==(lowercase(want)), nms)
        if idx !== nothing
            return names(df)[idx]  # le Symbol réel du DataFrame
        end
    end
    return nothing
end

"Ajoute une colonne :passagers si absente (à partir de :montees ou occupation*capacité)."
function _ensure_passagers(df::DataFrame)
    df2 = copy(df)
    key_pass = getcol(df2, ["passagers"])
    key_mont = getcol(df2, ["montees", "montées", "montee", "monte"])
    key_occ  = getcol(df2, ["occupation_bus", "occupation", "charge"])
    key_cap  = getcol(df2, ["capacite_bus", "capacité_bus", "capacite", "capacity", "cap"])

    if key_pass !== nothing
        df2.passagers = df2[!, key_pass]
    elseif key_mont !== nothing
        df2.passagers = df2[!, key_mont]
    elseif (key_occ !== nothing) && (key_cap !== nothing)
        df2.passagers = round.(Int, coalesce.(df2[!, key_occ], 0) .* coalesce.(df2[!, key_cap], 0))
    else
        throw(ArgumentError("Aucune colonne de demande trouvée (attendus: passagers / montees / occupation*capacite). Colonnes: $(names(df))"))
    end
    return df2
end

"Convertit la colonne heure (Time/DateTime/String/Int) en Int64 0–23. Renvoie (df, :heure)."
function _ensure_heure_int(df::DataFrame)
    df2 = copy(df)
    key_h = getcol(df2, ["heure","hour","time","h"])
    key_h === nothing && throw(ArgumentError("Colonne `heure` absente. Colonnes: $(names(df))"))

    tohour(h) = h isa Time      ? hour(h) :
                h isa DateTime  ? hour(h) :
                h isa Integer   ? (0 <= h <= 23 ? Int(h) : missing) :
                h isa AbstractString ? try
                    s = strip(lowercase(h))
                    s = replace(s, 'h' => ':')
                    parse(Int, split(s, ":")[1])
                catch; missing end :
                missing

    df2.heure = tohour.(df2[!, key_h])
    df2 = dropmissing(df2, :heure)
    return df2, :heure
end

# --------------------------- API publique ------------------------------------

"Statistiques descriptives par ligne (moyenne, médiane, max, min) sur la demande."
function stats_par_ligne(fr::DataFrame)
    df = _ensure_passagers(fr)
    key_l = getcol(df, ["ligne_id","ligne","id_ligne"])
    key_l === nothing && throw(ArgumentError("Colonne de ligne absente (ligne_id/ligne/id_ligne). Colonnes: $(names(fr))"))
    combine(groupby(df, key_l),
        :passagers => mean    => :moyenne,
        :passagers => median  => :mediane,
        :passagers => maximum => :max,
        :passagers => minimum => :min)
end

"Top 3 heures de pointe (demande totale par heure, toutes lignes confondues)."
function heures_de_pointe(fr::DataFrame)
    df = _ensure_passagers(fr)
    dfh, keyh = _ensure_heure_int(df)
    dmd = combine(groupby(dfh, keyh), :passagers => sum => :passagers)
    sort(dmd, :passagers, rev=true)[1:min(3, nrow(dmd)), :]
end

"Taux d’occupation moyen par ligne et par heure (en %). Vide si occupation/capacité absentes."
function taux_occupation(fr::DataFrame)
    # Détection des colonnes occupation/capacité
    key_occ = getcol(fr, ["occupation_bus","occupation","charge"])
    key_cap = getcol(fr, ["capacite_bus","capacité_bus","capacite","capacity","cap"])
    if key_occ === nothing || key_cap === nothing
        return DataFrame()
    end

    # Heure → Int + présence ligne_id
    df = copy(fr)
    dfh, keyh = _ensure_heure_int(df)
    key_l = getcol(dfh, ["ligne_id","ligne","id_ligne"])
    key_l === nothing && return DataFrame()

    # Calcul du taux (%), sécurisé quand capacité = 0 / missing
    taux = 100 .* (coalesce.(dfh[!, key_occ], 0) ./ max.(coalesce.(dfh[!, key_cap], 0), 1e-9))
    dfh.taux_occupation = round.(taux, digits=1)

    # ⚠️ Utiliser Cols(...) pour grouper proprement (évite l'erreur rencontrée)
    gd = groupby(dfh, Cols(key_l, keyh))
    combine(gd, :taux_occupation => mean => :taux_moyen)
end


end # module
