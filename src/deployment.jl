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

    # Divide by half (i.e., `* 0.5`) as RME simulates two deployments per year
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
