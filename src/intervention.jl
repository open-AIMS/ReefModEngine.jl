"""Helper methods to add intervention types to a given simulation."""

"""
    iv_add(name::String, type::String, reef_set::String, first_year::Int, last_year::Int, year_step::Int)

Add an intervention to the current run.

# Arguments
- `name`: Name of the intervention (must be unique)
- `type`: Type of intervention (see types below)
- `reef_set`: Name of reef set to apply intervention to
- `first_year`: First year intervention will be applied
- `last_year`: Last year intervention will be applied
- `year_step`: Frequency (1=every year, 2=every other year, etc.)

# Intervention Types
- `cots_control`: CSIRO method CoTS control algorithm
- `cots_control_basic`: Original CoTS control method
- `prevent_anchoring`: Not implemented (no effect)
- `prevent_herbivore_exploitation`: Prevent herbivore exploitation
- `stabilise`: Rubble stabilization
- `outplant`: Coral outplanting (requires additional parameters)
- `enrich`: Larval enrichment (requires additional parameters)
"""
function iv_add(
    name::String,
    type::String,
    reef_set::String,
    first_year::Int,
    last_year::Int,
    year_step::Int
)
    @RME ivAdd(
        name::Cstring,
        type::Cstring,
        reef_set::Cstring,
        first_year::Cint,
        last_year::Cint,
        year_step::Cint
    )::Cint
end

"""
    iv_add(name::String, type::String, reef_set::String, first_year::Int, last_year::Int, year_step::Int, area_pct::Float64, count_per_m2::Union{Float64, Vector{Float64}})

Add an outplant or enrich intervention with deployment parameters.

# Additional Arguments for "outplant" and "enrich" types
- `area_pct`: Percentage of reef area where restoration will occur
- `count_per_m2`: Corals to add per m² (scalar or 6-element vector for each species)
"""
function iv_add(
    name::String,
    type::String,
    reef_set::String,
    first_year::Int,
    last_year::Int,
    year_step::Int,
    area_pct::Float64,
    count_per_m2::Union{Float64,Vector{Float64}}
)
    # Validate intervention type
    if !(type in ["outplant", "enrich"])
        throw(
            ArgumentError(
                "area_pct and count_per_m2 parameters only valid for 'outplant' and 'enrich' interventions"
            )
        )
    end

    # Handle scalar vs vector count_per_m2
    if isa(count_per_m2, Float64)
        # Convert scalar to 6-element vector (equal for all species)
        count_vector = fill(count_per_m2, 6)
    elseif length(count_per_m2) == 6
        count_vector = Vector{Float64}(count_per_m2)
    else
        throw(ArgumentError("count_per_m2 must be a scalar or 6-element vector"))
    end

    @RME ivAdd(
        name::Cstring,
        type::Cstring,
        reef_set::Cstring,
        first_year::Cint,
        last_year::Cint,
        year_step::Cint,
        area_pct::Cdouble,
        count_vector::Ptr{Cdouble},
        length(count_vector)::Cint
    )::Cint
end

"""
    set_outplant_tolerance!(
        iv_name::String,
        dhw_mean::Float64,
        dhw_std::Float64;
        n_groups=6
    )

    set_outplant_tolerance!(
        iv_name::String,
        dhw_mean::Vector{Float64},
        dhw_std::Vector{Float64};
        n_groups=6
    )

Set heat tolerance of outplanting interventions.

# Arguments
- `iv_name`: Name of defined deployment as set by `set_outplant_deployment!()`
- `dhw_mean`: Mean of DHW tolerance (for each coral functional group)
- `dhw_std`: Standard deviation of DHW tolerance (for each coral functional group)
- `n_groups`: Number of coral groups (default: 6). \
              This should not change unless RME adds more coral groups.

# Returns
Nothing
"""
function set_outplant_tolerance!(
    iv_name::String,
    dhw_mean::Float64,
    dhw_std::Float64;
    n_groups=6
)
    dhw_mean_vals = fill(dhw_mean, n_groups)
    dhw_stdev_vals = fill(dhw_std, n_groups)
    set_outplant_tolerance(iv_name, dhw_mean_vals, dhw_stdev_vals; n_groups=n_groups)

    return nothing
end
function set_outplant_tolerance!(
    iv_name::String,
    dhw_mean::Vector{Float64},
    dhw_std::Vector{Float64};
    n_groups=6
)
    @RME ivSetOutplantHeatToleranceMeanDhw(
        iv_name::Cstring, dhw_mean::Ptr{Cdouble}, n_groups::Cint
    )::Cint

    @RME ivSetOutplantHeatToleranceSdDhw(
        iv_name::Cstring, dhw_std::Ptr{Cdouble}, n_groups::Cint
    )::Cint

    return nothing
end
