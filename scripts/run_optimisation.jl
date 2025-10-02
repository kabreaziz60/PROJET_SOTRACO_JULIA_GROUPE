#!/usr/bin/env julia
using Pkg; Pkg.activate(".")
using DataFrames, Dates

# --- charge nos modules ---
include(joinpath(@__DIR__, "..", "src", "io_operations.jl")); using .IOOperations
include(joinpath(@__DIR__, "..", "src", "optimisation.jl"));  using .Optimisation

# --- CONFIG: mets ; si ton CSV est Excel/point-virgule ---
const CSV_PATH = joinpath(@__DIR__, "..", "data", "frequentation.csv")
const USE_SEMICOLON = false  # <-- passe à true si séparateur ';'

fr = USE_SEMICOLON ?
     IOOperations.charger_frequentation(CSV_PATH; delim=';') :
     IOOperations.charger_frequentation(CSV_PATH)

if isempty(fr)
    println("❌ frequentation.csv vide ou introuvable à: ", CSV_PATH)
    exit(1)
end

# --- helpers : accepter String ou Symbol pour les noms de colonnes ---
tostr(x) = String(x)
function getcol(df::DataFrame, want::AbstractString)
    idx = findfirst(==(want), lowercase.(tostr.(names(df))))
    return idx === nothing ? nothing : names(df)[idx]
end

df = copy(fr)

# ---- construire la demande :passagers ----
key_pass = getcol(df, "passagers")
key_mont = getcol(df, "montees")
key_occ  = getcol(df, "occupation_bus")
key_cap  = getcol(df, "capacite_bus")

if key_pass !== nothing
    df.passagers = df[!, key_pass]
elseif key_mont !== nothing
    df.passagers = df[!, key_mont]
elseif (key_occ !== nothing) && (key_cap !== nothing)
    df.passagers = round.(Int, coalesce.(df[!, key_occ], 0) .* coalesce.(df[!, key_cap], 0))
else
    println("❌ Demande introuvable (attendus: `montees` OU `passagers` OU `occupation_bus`+`capacite_bus`).")
    println("   Colonnes: ", names(df)); exit(2)
end

# ---- convertir 'heure' -> Int (0..23) hyper tolérant ----
key_h = getcol(df, "heure")
if key_h === nothing
    println("❌ Colonne `heure` absente. Colonnes: ", names(df)); exit(3)
end

function _tohour(h)::Union{Int,Missing}
    if h isa Integer
        return (0 <= h <= 23) ? Int(h) : missing
    elseif h isa Real
        v = Int(floor(h)); return (0 <= v <= 23) ? v : missing
    elseif h isa Time
        return hour(h)
    elseif h isa DateTime
        return hour(h)
    elseif h isa AbstractString
        s = strip(lowercase(h))
        s = replace(s, 'h' => ':', 'H' => ':', '−' => '-', '–' => '-', '—' => '-')
        m = match(r"\b([01]?\d|2[0-3])\b", s)  # capte 0..23 n'importe où
        return m === nothing ? missing : parse(Int, m.captures[1])
    else
        return missing
    end
end

df.heure = _tohour.(df[!, key_h])
df = dropmissing(df, :heure)

if nrow(df) == 0
    println("❌ Aucune heure valide après conversion (ex: 7, 07, 07:00, 07:00:00, 7h, 07h-08h).")
    # essaye diagnostic: montre 10 valeurs brutes
    raw = fr[!, key_h]
    println("   Exemples bruts d'heure: ", unique(raw)[1:min(end, 10)])
    exit(4)
end

# ---- agrégat par heure ----
dmd = combine(groupby(df, :heure, sort=true), :passagers => sum => :passagers)
if nrow(dmd) == 0
    println("❌ Demande vide après agrégation. Vérifie les colonnes de fréquentation.")
    exit(5)
end

# ---- calcul du plan (par défaut: capacité 80, charge 0.75, attente max 10) ----
plan = Optimisation.plan_frequence(dmd)
if isempty(plan)
    println("❌ Plan vide (inattendu).")
    exit(6)
end

println("✅ Aperçu du plan (10 premières lignes) :")
show(first(plan, 10), allcols=true, allrows=true)

# (optionnel) export CSV horodaté
try
    using Dates
    mkpath(joinpath(@__DIR__, "..", "resultats"))
    out = joinpath(@__DIR__, "..", "resultats", "plan_frequences_" * Dates.format(Dates.now(), "yyyymmdd_HHMMSS") * ".csv")
    using CSV
    CSV.write(out, plan)
    println("\n💾 Exporté vers: ", out)
catch e
    @warn "Export CSV non effectué" e
end
