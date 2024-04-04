"""
    area_needed(n_corals::Int64, density::Float64)::Float64

Determine area needed to deploy the given number of corals at the specified density.
"""
function area_needed(n_corals::Int64, density::Float64)::Float64
    # ReefMod deploys twice a year so halve the number of corals to deploy
    return ((n_corals * 0.5) / density) * m2_TO_km2  # Convert m² to km²
end

"""
    reef_ids()::Vector{String}

Get list of reef ids in the order expected by ReefMod Engine.
"""
function reef_ids()::Vector{String}
    n_reefs = 3806
    reef_id_list = fill("", n_reefs);

    for i in 1:n_reefs
        reef_id_list[i] = @RME reefId(i::Cint)::Cstring
    end

    return reef_id_list
end