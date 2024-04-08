"""
    density_bounds(reef_areas::Vector{Float64}, n_corals::Int)::Tuple{Float64, Float64}

Find the smallest and largest densities allowed for a list of reef areas.

# Arguments
- `reef_areas` : Area of reefs,
- `n_corals` : Number of corals to deploy in a year

# Returns
Tuple
- Smallest possible deployment density for the given area
- Largest possible deployment density to guarentee 10x10 grid size
"""
function density_bounds(reef_areas::Vector{Float64}, n_corals::Int)::Tuple{Float64, Float64}
    total_area::Float64 = sum(reef_areas)
    
    # ReefMod deploys twice a year
    # All area used
    min_density::Float64 = 0.5 * n_corals / total_area * 1e-6
    # 4% area used
    max_density::Float64 = 0.5 * n_corals / (0.04 * total_area) * 1e-6
    return min_density, max_density
end
"""
    required_reefs(
        reef_areas::Vector{Float64},
        n_corals::Int,
        target_density::Float64,
        target_proportion::Float64; 
        min_reefs::Int=1
    )::Tuple{Float64, Int}

Given a list of reef_areas ordered by seeding preference, calculate the number of reefs 
required achieve a density close to the target density. 

# Arguments
- `reef_areas` : Area of reefs ordered by selection preference.
- `n_corals` : Number of corals to deploy in a year
- `target_density` : Density of corals
- `target_proportion` : Proportion of reef to seed on

# Keywords
- `min_reefs` : Minimum number of reefs to seed


# Returns
Tuple
- Real density of deployment if the suggested number of locations are used.
- Top number of locations to use to achieve the returned density.
"""
function required_reefs(
    reef_areas::Vector{Float64},
    n_corals::Int,
    target_density::Float64,
    target_proportion::Float64; 
    min_reefs::Int=1
)::Tuple{Float64, Int}
    required_area::Float64 = area_needed(n_corals, target_density)
    # Convert from  per m^2 to per km^2
    target_density = target_density * 1e6
    
    cur_area::Float64 = (sum(reef_areas[1:min_reefs]) - reef_areas[min_reefs]) * target_proportion
    end_ind::Int = -1 
    for (ind, area) in enumerate(reef_areas[min_reefs:end])
        cur_area += target_proportion * area
        if (cur_area > required_area)
            end_ind = ind + min_reefs - 1
            break;
        end
    end
    
    # All locations are required to seed given number of corals
    if (end_ind == -1)
        @warn "Not enough space for specified target density."
        return 0.5 * n_corals / cur_area, length(reef_areas)
    end
    
    # Choose the number of locations that gives a density closest to the target density
    diff_over::Float64 = abs(
        target_density - 0.5 * n_corals / cur_area
    )
    diff_undr::Float64  = abs(
        target_density - 0.5 * n_corals / (cur_area - target_proportion * reef_areas[end_ind])
    )
    
    # Return the number of reefs corresponding to the overestimate if it is closer to target
    if diff_over < diff_undr
        return 0.5 * n_corals / cur_area * 1e-6, end_ind
    end
    return 0.5 * n_corals / (cur_area - target_proportion * reef_areas[end_ind]) * 1e-6, end_ind
end

"""
    match_density(
        reef_areas::Vector{Float64},
        n_corals::Int,
        target_density::Float64;
        max_prop::Float64 = 0.4,
        min_reefs::Int=1
    )::Tuple{Float64, Float64, Int}

Calculate the number of reefs to use given a fixed number of corals to deploy. The density 
returned should be as close as possible to the given target density.

# Arguments
- `reef_areas` : List of reef areas ordered by seeding preference [Km^2]
- `n_corals` : Number of corals to deploy
- `target_density` : Target density of corals for intervention [count / m^2]
- `max_prop` : Maximum proportion of location corals can be deployed

# Keywords
- `min_reefs` : Minimum number of reefs to deploy at

# Returns
Tuple
- Proportion of location with seeded corals
- Real density of corals to deploy at given the suggested number of locations. 
- Number of location to deploy at. 

"""
function match_density(
    reef_areas::Vector{Float64},
    n_corals::Int,
    target_density::Float64;
    max_prop::Float64 = 0.4,
    min_reefs::Int=1
)::Tuple{Float64, Float64, Int}

    results::Tuple{Float64, Int} = required_reefs(reef_areas, n_corals, target_density, 0.04, min_reefs=min_reefs)
    min_diff = abs(target_density - results[1])
    max_p = 0.04
    for p in 0.08:0.02:max_prop
        t_res = required_reefs(reef_areas, n_corals, target_density, p, min_reefs=min_reefs) 
        if abs(target_density - t_res[1]) < min_diff
            max_p = p
            results = t_res
            min_diff = abs(target_density - t_res[1])
        end
    end
    return max_p, results[1], results[2]
end
"""
    deployment_area(n_corals::Int64, max_n_corals::Int64, density::Float64, target_areas::Vector{Float64})::Tuple{Float64,Float64}

Determine deployment area for the expected number of corals to be deployed.

# Arguments
- `n_corals` : Number of corals,
- `max_n_corals` : Expected maximum deployment effort (total number of corals in intervention set)
- `density` : Stocking density per m²
- `target_areas` : Available area at target location(s)

# Returns
Tuple
- Percent area of deployment
- modified stocking density [currently no modifications are made]
"""
function deployment_area(n_corals::Int64, max_n_corals::Int64, density::Float64, target_areas::Vector{Float64})::Tuple{Float64,Float64}
    req_area = area_needed(max_n_corals, density)
    mod_density = (n_corals * 0.5) / (req_area / m2_TO_km2)
    deployment_area_pct = min((req_area / sum(target_areas)) * 100.0, 100.0)

    # Adjust grid size if needed to simulate deployment area/percent
    min_cells::Int64 = 3
    if (RME_BASE_GRID_SIZE[] * req_area / sum(target_areas)) < min_cells
        # Determine new grid resolution in terms of number of N by N cells
        target_grid_size::Float64 = 3.0 * sum(target_areas) / req_area
        cell_res::Int64 = ceil(Int64, sqrt(target_grid_size))  # new cell resolution

        # RME supported cell sizes (N by N)
        # Determine smallest appropriate grid size when larger grid sizes are set.
        # Larger grid sizes = greater cell resolution, incurring larger runtime costs.
        p::Vector{Int64} = Int64[10, 20, 25, 30, 36, 43, 55, 64, 85, 100]
        n_cells::Int64 = try
            first(p[p.>=cell_res])
        catch
            p[end-1]
        end

        RME_BASE_GRID_SIZE[] = n_cells * n_cells
        opt::String = "RMFAST$(n_cells)"
        @RME setOptionText("processing_method"::Cstring, opt::Cstring)::Cint

        @warn "Insufficient number of treatment cells. Adjusting grid size.\nSetting grid to $(n_cells) by $(n_cells) cells\nThe larger the grid size, the longer the runtime."
    end

    return deployment_area_pct, mod_density
end

"""
    deployment_area(max_n_corals::Int64, target_areas::Vector{Float64})::Tuple{Float64,Float64}

Determine deployment area for given number of corals and target area, calculating the
appropriate deployment density to maintain the specified grid size.
"""
function deployment_area(max_n_corals::Int64, target_areas::Vector{Float64})::Tuple{Float64,Float64}

    min_cells::Int64 = 3
    density::Float64 = 0.0
    req_area::Float64 = 0.0
    for d in reverse(0.05:0.1:13.0)
        req_area = area_needed(max_n_corals, d)

        if (RME_BASE_GRID_SIZE[] * req_area / sum(target_areas)) < min_cells
            continue
        end

        density = d
        break
    end

    if density == 0.0
        throw(DomainError("Could not determine adequate deployment density: $((RME_BASE_GRID_SIZE[] * req_area / sum(target_areas)))"))
    end

    @info "Determined min. deployment density to be: $(density) / m²"

    deployment_area_pct = min((req_area / sum(target_areas)) * 100.0, 100.0)

    return deployment_area_pct, density
end

"""
    set_outplant_deployment!(name::String, reefset::String, n_corals::Int64, year::Int64, area_km2::Vector{Float64}, density::Float64)::Nothing

Set outplanting deployments for a single year.

# Arguments
- `name` : Name to assign intervention event
- `reefset` : Name of pre-defined list of reefs to intervene on
- `n_corals` : Number of corals to outplant
- `year` : Year to intervene
- `area_km2` : Area to intervene [km²]
- `density` : Stocking density of intervention [corals / m²]
"""
function set_outplant_deployment!(
    name::String,
    reefset::String,
    n_corals::Int64,
    year::Int64,
    area_km2::Vector{Float64},
    density::Float64
)::Nothing
    set_outplant_deployment!(name, reefset, n_corals, n_corals, year, year, 1, area_km2, density)
end

"""
    set_outplant_deployment!(name::String, reefset::String, n_corals::Int64, max_effort::Int64, first_year::Int64, last_year::Int64, year_step::Int64, area_km2::Vector{Float64}, density::Float64)::Nothing

Set outplanting deployments across a range of years.

# Arguments
- `name` : Name to assign intervention event
- `reefset` : Name of pre-defined list of reefs to intervene on
- `n_corals` : Number of corals to outplant for a given year
- `max_effort` : Total number of corals to outplant
- `first_year` : First year to start interventions
- `last_year` : Final year of interventions
- `year_step` : Frequency of intervention (1 = every year, 2 = every second year, etc)
- `area_km2` : Intervention area [km²]
- `density` : Stocking density of intervention [corals / m²]
"""
function set_outplant_deployment!(
    name::String,
    reefset::String,
    n_corals::Int64,
    max_effort::Int64,
    first_year::Int64,
    last_year::Int64,
    year_step::Int64,
    area_km2::Vector{Float64},
    density::Float64
)::Nothing
    iv_type = "outplant"

    area_pct, mod_density = deployment_area(n_corals, max_effort, density, area_km2)

    @RME ivAdd(name::Cstring, iv_type::Cstring, reefset::Cstring, first_year::Cint, last_year::Cint, year_step::Cint)::Cint
    @RME ivSetOutplantAreaPct(name::Cstring, area_pct::Cdouble)::Cint
    @RME ivSetOutplantCountPerM2(name::Cstring, mod_density::Cdouble)::Cint

    return nothing
end

"""
    set_outplant_deployment!(name::String, reefset::String, n_corals::Int64, year::Int64, area_km2::Vector{Float64})::Nothing

Set outplanting deployments for a single year, automatically determining the coral
deployment density to maintain the set grid size.

# Arguments
- `name` : Name to assign intervention event
- `reefset` : Name of pre-defined list of reefs to intervene on
- `n_corals` : Number of corals to outplant
- `year` : Year to intervene
- `area_km2` : Area to intervene [km²]
"""
function set_outplant_deployment!(
    name::String,
    reefset::String,
    n_corals::Int64,
    year::Int64,
    area_km2::Vector{Float64}
)::Nothing
    set_outplant_deployment!(name, reefset, n_corals, year, year, 1, area_km2)
end

"""
    set_outplant_deployment!(
        name::String,
        reefset::String,
        max_effort::Int64,
        first_year::Int64,
        last_year::Int64,
        year_step::Int64,
        area_km2::Vector{Float64},
    )::Nothing

Set outplanting deployments across a range of years, automatically determining the
coral deployment density to maintain the set grid size.
"""
function set_outplant_deployment!(
    name::String,
    reefset::String,
    max_effort::Int64,
    first_year::Int64,
    last_year::Int64,
    year_step::Int64,
    area_km2::Vector{Float64},
)::Nothing
    iv_type = "outplant"

    area_pct, mod_density = deployment_area(max_effort, area_km2)

    @RME ivAdd(name::Cstring, iv_type::Cstring, reefset::Cstring, first_year::Cint, last_year::Cint, year_step::Cint)::Cint
    @RME ivSetOutplantAreaPct(name::Cstring, area_pct::Cdouble)::Cint
    @RME ivSetOutplantCountPerM2(name::Cstring, mod_density::Cdouble)::Cint

    return nothing
end

"""
    set_enrichment_deployment!(
        name::String,
        reefset::String,
        n_larvae::Int64,
        year::Int64,
        area_km2::Vector{Float64},
        density::Float64
    )::Nothing

As `set_seeding_deployment()` but for larvae enrichment (also known as assisted migration).
Set deployment for a single target year.
"""
function set_enrichment_deployment!(
    name::String,
    reefset::String,
    n_larvae::Int64,
    year::Int64,
    area_km2::Vector{Float64},
    density::Float64
)::Nothing
    set_enrichment_deployment!(name, reefset, n_larvae, n_larvae, year, year, 1, area_km2, density)
end

"""
    set_enrichment_deployment!(
        name::String,
        reefset::String,
        n_larvae::Int64,
        max_effort::Int64,
        first_year::Int64,
        last_year::Int64,
        year_step::Int64,
        area_km2::Vector{Float64},
        density::Float64
    )::Nothing

Set deployment for multiple years at a given frequency.
"""
function set_enrichment_deployment!(
    name::String,
    reefset::String,
    n_larvae::Int64,
    max_effort::Int64,
    first_year::Int64,
    last_year::Int64,
    year_step::Int64,
    area_km2::Vector{Float64},
    density::Float64
)::Nothing
    iv_type = "enrich"

    area_pct, mod_density = deployment_area(n_larvae, max_effort, density, area_km2)

    @RME ivAdd(name::Cstring, iv_type::Cstring, reefset::Cstring, first_year::Cint, last_year::Cint, year_step::Cint)::Cint
    @RME ivSetEnrichAreaPct(name::Cstring, area_pct::Cdouble)::Cint
    @RME ivSetEnrichCountPerM2(name::Cstring, mod_density::Cdouble)::Cint

    return nothing
end
