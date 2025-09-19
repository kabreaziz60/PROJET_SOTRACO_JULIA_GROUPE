module Metrics

export haversine_distance, temps_trajet

# Rayon de la Terre (km)
const R = 6371.0

"Calcul de la distance (km) entre deux points GPS avec la formule de Haversine."
function haversine_distance(lat1::Float64, lon1::Float64, lat2::Float64, lon2::Float64)::Float64
    φ1 = deg2rad(lat1)
    φ2 = deg2rad(lat2)
    Δφ = deg2rad(lat2 - lat1)
    Δλ = deg2rad(lon2 - lon1)

    a = sin(Δφ/2)^2 + cos(φ1) * cos(φ2) * sin(Δλ/2)^2
    c = 2 * atan(sqrt(a), sqrt(1 - a))
    return R * c
end

"Temps de trajet (minutes) = distance / vitesse (km/h) * 60"
function temps_trajet(distance_km::Float64, vitesse_kmh::Float64=30.0)::Float64
    return (distance_km / vitesse_kmh) * 60
end

end # module
