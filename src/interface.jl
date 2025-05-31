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

# Parameter interface

"""
    set_iv_param(name::String, value::Union{Float64, Int64})::Nothing
    set_iv_param(name::String, value::Vector{Float64})::Nothing
    set_iv_param(name::String, value::String)::Nothing
    set_iv_param(iv_name::String, param_name::String, value::String)::Nothing
    set_iv_param(iv_name::String, param_name::String, value::Union{Float64, Int64})::Nothing

Set RME intervention parameter by name.
"""
function set_iv_param(name::String, value::Float64)::Nothing
    @RME ivSetParam(name::Cstring, value::Cdouble)::Cint

    return nothing
end
function set_iv_param(iv_name::String, value::Int64)::Nothing
    set_iv_param(iv_name, param_name, Float64(value))
end
function set_iv_param(name::String, value::Vector{Float64})::Nothing
    @RME ivSetParam(name::Cstring, value::Ptr{Cdouble})::Cint

    return nothing
end
function set_iv_param(name::String, value::String)::Nothing
    @RME ivSetParamText(name::Cstring, value::Cstring)::Cint

    return nothing
end
function set_iv_param(iv_name::String, param_name::String, value::String)::Nothing
    @RME ivSetParamText(iv_name::Cstring, param_name::Cstring, value::Cstring)::Cint

    return nothing
end
function set_iv_param(iv_name::String, param_name::String, value::Int64)::Nothing
    set_iv_param(iv_name, param_name, Float64(value))
end
function set_iv_param(iv_name::String, param_name::String, value::Float64)::Nothing
    @RME ivSetParam(iv_name::Cstring, param_name::Cstring, value::Cdouble)::Cint

    return nothing
end

"""
    get_iv_param(iv_name::String, param_name::String)

Return the current value of a parameter of an intervention.

Returns parameter `param_name` of intervention `iv_name`. The returned value can
either be a number or text depending on the type of parameter. If the intervention
does not exist, parameter is not recognized, or value is of the wrong type, an
error will be thrown.

Currently supported values for `param_name` are:
- `"second_rs"`: Secondary reef set name or empty string
- `"hours"`: Number of hours effort
- `"rank_data_code1"`: Data code to rank by or "none"
- `"rank_data_code2"`: Data code to rank by or "none"
- `"rank_weight1"`: Weight for first rank data (0-1)
- `"rank_weight2"`: Weight for second rank data (0-1)

# Examples
```julia
hours = get_iv_param("my_intervention", "hours")          # Returns Float64
reef_set = get_iv_param("my_intervention", "second_rs")   # Returns String
"""
function get_iv_param(iv_name::String, param_name::String)
    # Chain pattern!

    # Try to get as text parameter first
    text_val = @RME ivGetParamText(iv_name::Cstring, param_name::Cstring)::Cstring

    # If we got a non-empty string, return it
    if !isempty(text_val)
        return text_val
    end

    # Otherwise, try to get as numeric parameter
    value_ref = Ref{Cdouble}(0.0)
    @RME ivGetParam(
        iv_name::Cstring,
        param_name::Cstring,
        value_ref::Ref{Cdouble}
    )::Cint

    return value_ref[]
end

function _check_rme_error()
    error_msg = @RME lastError()::Cstring
    throw(ArgumentError("RME failed to get parameter.\n$(error_msg)"))
end

"""
    get_param(name::String)::Union{Float64,Vector{Float64}}

Return the current value(s) of an RME parameter.

The returned value will be a vector of length 1 or greater.
"""
function get_param(name::String)::Union{Float64,Vector{Float64}}
    # Get the size of the data or -1 if no data available
    sz = @getRME paramsGetSize(name::Cstring)::Cint
    if sz <= 0
        _check_rme_error()
    end

    # Size the output vector
    v = zeros(Float64, sz)

    # Get the data
    @RME paramsGet(name::Cstring, v::Ptr{Cdouble}, length(v)::Cint)::Cint

    if sz == 1
        return v[1]
    end

    return v
end
