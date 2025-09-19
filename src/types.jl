module Types

export Arret, Ligne, Bus

Base.@kwdef struct Arret
    id::Int
    nom::String
    latitude::Float64
    longitude::Float64
end

Base.@kwdef struct Ligne
    id::Int
    nom::String
    distance_km::Float64
end

Base.@kwdef struct Bus
    id::Int
    capacite::Int
    ligne::Int
end

end # module
