module Optimisation

using DataFrames
using Dates: Time, DateTime, hour   # ⬅️ AJOUT

export prepare_demande_par_heure, recommande_frequence, plan_frequence, optimiser_ligne

tostr(x) = String(x)
function _getcol(df::DataFrame, want::AbstractString)
    idx = findfirst(==(want), lowercase.(tostr.(names(df))))
    return idx === nothing ? nothing : names(df)[idx]
end

function prepare_demande_par_heure(fr::DataFrame; ligne_id::Union{Int,Nothing}=nothing)::DataFrame
    isempty(fr) && return DataFrame()
    df = copy(fr)

    hcol = _getcol(df, "heure")
    pcol = _getcol(df, "passagers")
    mcol = _getcol(df, "montees")
    occ  = _getcol(df, "occupation_bus")
    cap  = _getcol(df, "capacite_bus")
    hcol === nothing && return DataFrame()

    tohour(h) = h isa Time      ? hour(h) :
                h isa DateTime  ? hour(h) :
                h isa Integer   ? (0 <= h <= 23 ? h : missing) :
                h isa AbstractString ? try
                    s = strip(lowercase(h)); s = replace(s, 'h' => ':')
                    parse(Int, split(s, ":")[1])
                catch; missing end :
                missing

    if pcol !== nothing
        df.passagers = df[!, pcol]
    elseif mcol !== nothing
        df.passagers = df[!, mcol]
    elseif (occ !== nothing) && (cap !== nothing)
        df.passagers = round.(Int, coalesce.(df[!, occ], 0) .* coalesce.(df[!, cap], 0))
    else
        return DataFrame()
    end

    if ligne_id !== nothing
        lcol = _getcol(df, "ligne_id")
        if lcol !== nothing
            df = filter(lcol => ==(ligne_id), df)
        end
    end

    df.heure = tohour.(df[!, hcol])
    df = dropmissing(df, :heure)
    isempty(df) && return DataFrame()

    combine(groupby(df, :heure, sort=true), :passagers => sum => :passagers)
end

function recommande_frequence(demande_h::Real;
                              capacite_bus::Int=80,
                              taux_charge_cible::Float64=0.75,
                              attente_max_min::Int=10)::Int
    d = max(0, demande_h)
    min_freq  = max(1, ceil(Int, 60 / max(attente_max_min, 1)))
    freq_need = ceil(Int, d / (capacite_bus * max(taux_charge_cible, 1e-6)))
    max(min_freq, freq_need)
end

function plan_frequence(dmd::DataFrame;
                        capacite_bus::Int=80,
                        taux_charge_cible::Float64=0.75,
                        attente_max_min::Int=10)::DataFrame
    isempty(dmd) && return DataFrame()
    df = copy(dmd)

    hcol = _getcol(df, "heure")
    pcol = _getcol(df, "passagers")
    if hcol === nothing || pcol === nothing
        return DataFrame()
    end

    out = DataFrame(heure = df[!, hcol], passagers = Int.(df[!, pcol]))
    out.freq_recommandee = [recommande_frequence(p;
        capacite_bus=capacite_bus,
        taux_charge_cible=taux_charge_cible,
        attente_max_min=attente_max_min) for p in out.passagers]

    out.interv_min = round.(60 ./ out.freq_recommandee, digits=1)
    out.capacite_theorique = round.(out.freq_recommandee .* capacite_bus .* taux_charge_cible, digits=0)
    out
end

function optimiser_ligne(fr::DataFrame;
                         ligne_id::Union{Int,Nothing}=nothing,
                         capacite_bus::Int=80,
                         taux_charge_cible::Float64=0.75,
                         attente_max_min::Int=10)::DataFrame
    dmd = prepare_demande_par_heure(fr; ligne_id=ligne_id)
    plan_frequence(dmd; capacite_bus=capacite_bus,
                       taux_charge_cible=taux_charge_cible,
                       attente_max_min=attente_max_min)
end

end # module
