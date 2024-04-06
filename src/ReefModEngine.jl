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
            throw(ArgumentError("Call to RME failed with message: $(unsafe_string(err_msg))"))
        end

        if typeof(err) <: Cstring
            # Output string result
            unsafe_string(err)
        end
    end
end

include("rme_init.jl")
include("interface.jl")
include("deployment.jl")
include("io.jl")
include("ResultStore.jl")

if !isdefined(Base, :get_extension)
    include("../ext/MatExt.jl")
end

# Set up and initialization
export
    init_rme, reset_rme, @RME, set_option, run_init

# Convenience/utility methods
export
    reef_ids, deployment_area, set_outplant_deployment!,
    match_id, match_ids, reef_areas

# IO
export
    ResultStore, collect_all_results!, collect_rep_results!, save_to_mat

end
