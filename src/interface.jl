"""
    area_needed(n_corals::Int64, density::Union{Float64,Vector{Float64}})::Union{Vector{Float64},Float64}

Determine area (in km²) needed to deploy the given the number of corals at the specified density.
"""
function area_needed(
    n_corals::Int64, density::Union{Float64,Vector{Float64}}
)::Union{Vector{Float64},Float64}
    # ReefMod deploys twice a year so halve the number of corals to deploy
    return ((n_corals * 0.5) ./ density) .* m2_TO_km2  # Convert m² to km²
end

"""
    reef_ids()::Vector{String}

Get list of reef ids in the order expected by ReefMod Engine.
"""
function reef_ids()::Vector{String}
    n_reefs = 3806
    reef_id_list = fill("", n_reefs)

    for i in 1:n_reefs
        reef_id_list[i] = @RME reefId(i::Cint)::Cstring
    end

    return reef_id_list
end

"""
    reef_areas()

Retrieve all reef areas in km²
"""
function reef_areas()
    n_reefs = 3806
    reef_areas = zeros(n_reefs)
    @RME reefAreasKm2(reef_areas::Ptr{Cdouble}, n_reefs::Cint)::Cint

    return reef_areas
end

"""
    reef_areas(id_list)

Retrieve reef areas in km² for specified locations.
"""
function reef_areas(id_list)
    areas = reef_areas()
    reef_idx = match_ids(id_list)
    return areas[reef_idx]
end

"""
    match_id(id::String)::Int64
    match_ids(ids::Vector{String})::Vector{Int64}

Find matching index position for the given ID(s) according to ReefMod Engine's reef list.

# Note

ReefMod Engine's reef list is in all upper case. The provided IDs are converted to
upper case to ensure a match.

# Examples

```julia
julia> reef_ids()
# 3806-element Vector{String}:
#  "10-330"
#  "10-331"
#  ⋮
#  "23-048"
#  "23-049"

julia> match_id("10-330")
#  1

julia> match_id("23-049")
#  3806

julia> match_ids(["23-048", "10-331"])
#  3805
#  2
```
"""
function match_id(id::String)::Int64
    rme_ids = reef_ids()
    return findfirst(==(uppercase(id)), rme_ids)
end
function match_ids(ids::Vector{String})::Vector{Int64}
    return match_id.(ids)
end
