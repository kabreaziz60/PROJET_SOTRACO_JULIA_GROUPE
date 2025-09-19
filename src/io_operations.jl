module IOOperations

using CSV, DataFrames
export charger_arrets, charger_lignes, charger_frequentation

"Lecture CSV tolérante : renvoie DataFrame() si le fichier manque."
function _load_csv(path::AbstractString)
    if !isfile(path)
        @warn "Fichier introuvable: $path — DataFrame() vide renvoyé."
        return DataFrame()
    end
    df = CSV.read(path, DataFrame)
    # Noms de colonnes en minuscules/symboles
    rename!(df, Symbol.(lowercase.(String.(names(df)))))
    return df
end

charger_arrets(path::AbstractString="data/arrets.csv") = _load_csv(path)
charger_lignes(path::AbstractString="data/lignes_bus.csv") = _load_csv(path)
charger_frequentation(path::AbstractString="data/frequentation.csv") = _load_csv(path)

end # module
