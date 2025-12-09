const MIN_CELLS = 1

"""
    deployment_area(n_corals::Int64, max_n_corals::Int64, density::Union{Float64, Vector{Float64}}, target_areas::Vector{Float64})::Union{Tuple{Float64,Float64},Tuple{Float64,Vector{Float64}}}

Determine deployment area for the expected number of corals to be deployed.

# Arguments
- `n_corals` : Number of corals,
- `max_n_corals` : Expected maximum deployment effort (total number of corals in intervention set)
- `density` : Stocking density per m². In RME versions higher than v1.0.28 density needs to be a vector
    with each element representing the density per functional group
- `target_areas` : Available area at target location(s)

# Returns
Tuple
- Percent area of deployment
- modified stocking density [currently no modifications are made]
"""
function deployment_area(
    n_corals::Int64,
    max_n_corals::Int64,
    density::Union{Float64,Vector{Float64}},
    target_areas::Vector{Float64}
)::Union{Tuple{Float64,Float64},Tuple{Float64,Vector{Float64}}}
    # Total area needed to outplant corals at target density
    summed_req_area = area_needed(max_n_corals, sum(density))

    # Modifies the density to fit within deployment area
    deployment_area_pct = min((summed_req_area / sum(target_areas)) * 100.0, 100.0)
    mod_density = density .* (deployment_area_pct/ 100)

    # Adjust grid size if needed to simulate deployment area/percent
    if (RME_BASE_GRID_SIZE[] * summed_req_area / sum(target_areas)) < MIN_CELLS
        # Determine new grid resolution in terms of number of N by N cells
        target_grid_size::Float64 = MIN_CELLS * (sum(target_areas) / summed_req_area)
        cell_res::Int64 = ceil(Int64, sqrt(target_grid_size))  # new cell resolution

        # RME supported cell sizes (N by N)
        # Determine smallest appropriate grid size when larger grid sizes are set.
        # Larger grid sizes = greater cell resolution, incurring larger runtime costs.
        p::Vector{Int64} = Int64[10, 20, 25, 30, 36, 43, 55, 64, 85, 100]
        n_cells::Int64 = try
            first(p[p .>= cell_res])
        catch
            p[end - 1]
        end

        RME_BASE_GRID_SIZE[] = n_cells * n_cells
        opt::String = "RMFAST$(n_cells)"

        @RME setOptionText("processing_method"::Cstring, opt::Cstring)::Cint
        @warn "Insufficient number of treatment cells. Adjusting grid size.\nSetting grid to $(n_cells) by $(n_cells) cells\nThe larger the grid size, the longer the runtime."
    end

    @info "Determined min. deployment density to be: $(sum(mod_density)) / m²"

    return deployment_area_pct, mod_density
end

"""
    deployment_area(max_n_corals::Int64, target_areas::Vector{Float64})::Union{Tuple{Float64,Float64}, Tuple{Float64,Vector{Float64}}}

Determine deployment area for given number of corals and target area, calculating the
appropriate deployment density, limiting
deployment density to be <40m2 for each coral species.
"""
function deployment_area(
    max_n_corals::Int64,
    target_areas::Vector{Float64}
)::Union{Tuple{Float64,Float64},Tuple{Float64,Vector{Float64}}}

    m2_per_cell = 1 / RME_BASE_GRID_SIZE[]*sum(target_areas).*1e6

    num_cells = MIN_CELLS
    density = (max_n_corals*0.5) ./ (num_cells*m2_per_cell)

    while (density > 40) && (num_cells < RME_BASE_GRID_SIZE[])
        num_cells = num_cells + 1
        density = (max_n_corals*0.5) ./ (num_cells*m2_per_cell)
    end

    @info "Determined min. deployment density to be: $(density) / m²"
    deployment_area_pct = min((num_cells*m2_per_cell*m2_TO_km2 / sum(target_areas)) * 100.0, 100.0)
    @info "Determined deployment area percent to be: $deployment_area_pct"

    # In RME versions higher than 1.0.28 density needs to be a vector with each element representing density per species
    rme_version = rme_version_info()
    density =
        if (rme_version.major == 1) && (rme_version.minor == 0) && (rme_version.patch <= 28)
            density
        else
            fill(density / 6, 6)
        end

    return deployment_area_pct, density .* deployment_area_pct / 100
end

"""
    set_outplant_deployment!(name::String, reefset::String, n_corals::Int64, year::Int64, area_km2::Vector{Float64}, density::Union{Float64, Vector{Float64}})::Nothing

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
    density::Union{Float64,Vector{Float64}}
)::Nothing
    return set_outplant_deployment!(
        name, reefset, n_corals, n_corals, year, year, 1, area_km2, density
    )
end

"""
    set_outplant_deployment!(name::String, reefset::String, n_corals::Int64, max_effort::Int64, first_year::Int64, last_year::Int64, year_step::Int64, area_km2::Vector{Float64}, density::Union{Vector{Float64}, Float})::Nothing

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
    density::Union{Vector{Float64},Float64}
)::Nothing
    iv_type = "outplant"

    area_pct, mod_density = deployment_area(n_corals, max_effort, density, area_km2)
    @RME ivAdd(
        name::Cstring,
        iv_type::Cstring,
        reefset::Cstring,
        first_year::Cint,
        last_year::Cint,
        year_step::Cint
    )::Cint
    @RME ivSetOutplantAreaPct(name::Cstring, area_pct::Cdouble)::Cint

    rme_version = rme_version_info()
    if !((rme_version.major == 1) && (rme_version.minor == 0) && (rme_version.patch <= 28))
        @RME ivSetOutplantCountPerM2(
            name::Cstring, mod_density::Ptr{Cdouble}, length(mod_density)::Cint
        )::Cint
    else
        @RME ivSetOutplantCountPerM2(name::Cstring, mod_density::Cdouble)::Cint
    end

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
    return set_outplant_deployment!(name, reefset, n_corals, year, year, 1, area_km2)
end

"""
    set_outplant_deployment!(name::String, reefset::String, max_effort::Int64, first_year::Int64, last_year::Int64, year_step::Int64, area_km2::Vector{Float64})::Nothing

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
    area_km2::Vector{Float64}
)::Nothing
    iv_type = "outplant"

    area_pct, mod_density = deployment_area(max_effort, area_km2)

    @RME ivAdd(
        name::Cstring,
        iv_type::Cstring,
        reefset::Cstring,
        first_year::Cint,
        last_year::Cint,
        year_step::Cint
    )::Cint
    @RME ivSetOutplantAreaPct(name::Cstring, area_pct::Cdouble)::Cint

    rme_version = rme_version_info()
    if !((rme_version.major == 1) && (rme_version.minor == 0) && (rme_version.patch <= 28))
        @RME ivSetOutplantCountPerM2(
            name::Cstring, mod_density::Ptr{Cdouble}, length(mod_density)::Cint
        )::Cint
    else
        @RME ivSetOutplantCountPerM2(name::Cstring, mod_density::Cdouble)::Cint
    end

    return nothing
end

"""
    set_enrichment_deployment!(name::String, reefset::String, n_larvae::Int64, year::Int64, area_km2::Vector{Float64}, density::Float64)::Nothing

As `set_seeding_deployment()` but for larvae enrichment (also known as assisted migration).
Set deployment for a single target year.
"""
function set_enrichment_deployment!(
    name::String,
    reefset::String,
    n_larvae::Int64,
    year::Int64,
    area_km2::Vector{Float64},
    density::Union{Vector{Float64},Float64}
)::Nothing
    return set_enrichment_deployment!(
        name, reefset, n_larvae, n_larvae, year, year, 1, area_km2, density
    )
end

"""
    set_enrichment_deployment!(name::String, reefset::String, n_larvae::Int64, max_effort::Int64, first_year::Int64, last_year::Int64, year_step::Int64, area_km2::Vector{Float64}, density::Float64)::Nothing

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
    density::Union{Vector{Float64},Float64}
)::Nothing
    iv_type = "enrich"

    area_pct, mod_density = deployment_area(n_larvae, max_effort, density, area_km2)

    @RME ivAdd(
        name::Cstring,
        iv_type::Cstring,
        reefset::Cstring,
        first_year::Cint,
        last_year::Cint,
        year_step::Cint
    )::Cint
    @RME ivSetEnrichAreaPct(name::Cstring, area_pct::Cdouble)::Cint

    rme_version = rme_version_info()
    if !((rme_version.major == 1) && (rme_version.minor == 0) && (rme_version.patch <= 28))
        @RME ivSetEnrichCountPerM2(
            name::Cstring, mod_density::Ptr{Cdouble}, length(mod_density)::Cint
        )::Cint
    else
        @RME ivSetEnrichCountPerM2(name::Cstring, mod_density::Cdouble)::Cint
    end

    return nothing
end
