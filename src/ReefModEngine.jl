module ReefModEngine

using Base.Filesystem: path_separator

const RME_BASE_GRID_SIZE = Ref(100)
const m2_TO_km2 = 0.000001

macro RME(func)
    local m = esc(Meta.parse("@ccall RME.$(func)"))
    return quote
        local err = $m

        if !(typeof(err) <: Cstring) && err != 0 && !(typeof(err) <: Cvoid)
            local err_msg = @ccall RME.lastError()::Cstring
            throw(
                ArgumentError("Call to RME failed with message: $(unsafe_string(err_msg))")
            )
        end

        if typeof(err) <: Cstring
            # Output string result
            unsafe_string(err)
        end
    end
end

"""
Only for use when RME functions return numeric results that are not error codes.

# Examples

```julia
count_per_m2::Float64 = @getRME ivOutplantCountPerM2("iv_name"::Cstring)::Cdouble
```
"""
macro getRME(func)
    return esc(Meta.parse("@ccall RME.$(func)"))
end

"""
    rme_version_info()::VersionNumber

Get RME version.
"""
function rme_version_info()::VersionNumber
    rme_ver = @RME version()::Cstring
    return VersionNumber(rme_ver)
end

export rme_version_info

include("rme_init.jl")
include("interface.jl")
include("deployment.jl")
include("intervention.jl")
include("io.jl")
include("ResultStore.jl")
include("logging.jl")
include("run_reps.jl")

# Set up and initialization
export
    init_rme, reset_rme, @RME, @getRME, set_option, run_init, RME_PATH, RME

# Parameter interface
export set_iv_param, get_iv_param, get_param, iv_add

# Convenience/utility methods
export
    reef_ids, deployment_area, set_outplant_deployment!, set_enrichment_deployment!,
    match_id, match_ids, reef_areas

# IO
export
    ResultStore, concat_results!, save_result_store

# Logging
export
    log_set_all_items_enabled, log_set_item_enabled,
    log_set_all_reefs_enabled, log_set_reef_enabled,
    log_get_reef_data_ref, log_get_reef_data_int,
    log_get_run_data_ref, log_get_run_data_int
# Run reps
export run_rme

end
