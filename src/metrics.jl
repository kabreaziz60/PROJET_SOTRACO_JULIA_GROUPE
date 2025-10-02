module Metrics
export haversine_distance, temps_trajet

const R = 6371.0
deg2rad(x) = x * (pi/180)

function haversine_distance(lat1::Real, lon1::Real, lat2::Real, lon2::Real)::Float64
    φ1 = deg2rad(lat1)
    φ2 = deg2rad(lat2)
    dφ = deg2rad(lat2 - lat1)
    dλ = deg2rad(lon2 - lon1)
    a = sin(dφ/2)^2 + cos(φ1) * cos(φ2) * sin(dλ/2)^2
    c = 2 * atan(sqrt(a), sqrt(1 - a))
    return R * c
end

temps_trajet(distance_km::Real, vitesse_kmh::Real=30.0)::Float64 =
    (distance_km / vitesse_kmh) * 60

end # module
