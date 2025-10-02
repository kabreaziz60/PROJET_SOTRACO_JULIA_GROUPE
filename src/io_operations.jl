module IOOperations

using CSV, DataFrames
export charger_arrets, charger_lignes, charger_frequentation

const DEFAULT_ARRETS = joinpath(@__DIR__, "..", "data", "arrets.csv")
const DEFAULT_LIGNES = joinpath(@__DIR__, "..", "data", "lignes_bus.csv")
const DEFAULT_FREQ   = joinpath(@__DIR__, "..", "data", "frequentation.csv")

# Lecture CSV avec auto-détection du séparateur (',' ou ';') + normalisation des noms
function _read_csv(path::AbstractString; delim::Union{Char,Nothing}=nothing)
    if !isfile(path)
        @warn "Fichier introuvable: $path — DataFrame() vide."
        return DataFrame()
    end
    d = delim
    if d === nothing
        open(path, "r") do io
            line = readline(io; keep=true)
            d = count(==(';'), line) > count(==(','), line) ? ';' : ','
        end
    end
    df = CSV.read(path, DataFrame; delim=d)
    newnames = Symbol.(replace.(lowercase.(strip.(String.(names(df)))),
                                r"[^a-z0-9]+" => "_"))
    rename!(df, Dict(names(df) .=> newnames))
    return df
end

charger_arrets(path::AbstractString=DEFAULT_ARRETS; kwargs...)        = _read_csv(path; kwargs...)
charger_lignes(path::AbstractString=DEFAULT_LIGNES; kwargs...)        = _read_csv(path; kwargs...)
charger_frequentation(path::AbstractString=DEFAULT_FREQ; kwargs...)   = _read_csv(path; kwargs...)

end # module
