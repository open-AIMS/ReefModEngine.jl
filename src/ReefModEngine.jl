module ReefModEngine

using Base.Filesystem: path_separator

global RME_BASE_GRID_SIZE = 100


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

function _associate_rme(rme_path::String)
    rme_path = replace(rme_path, "/" => path_separator, "\\" => path_separator)
    lib_path = joinpath(rme_path, "lib", "librme_ml.dll")

    if !@isdefined(RME)
        # For internal use
        @eval const RME_PATH = $(rme_path)
        @eval const RME = $(lib_path)

        # For external use
        const Main.RME_PATH = rme_path
        const Main.RME = lib_path
    end
end

function init_rme(rme_path::String)
    _associate_rme(rme_path)

    data_fp = joinpath(rme_path, "data_files")

    @RME setDataFilesPath(data_fp::Cstring)::Cint
    @RME init("config.xml"::Cstring)::Cint

    rme_vers = @RME version()::Cstring
    @info "Loaded RME $rme_vers"
end

function reset_rme()
    global RME_BASE_GRID_SIZE = 100

    @RME ivRemoveAll()::Cvoid
    @RME reefSetRemoveAll()::Cint
end

function area_needed(n_corals::Int64, density::Float64)::Float64
    # ReefMod deploys twice a year so halve the number of corals to deploy
    return ((n_corals * 0.5) / density) * m2_TO_km2  # Convert m² to km²
end

function deployment_area(n_corals::Int64, max_n_corals::Int64, density::Float64, target_areas::Vector{Float64})::Tuple{Float64,Float64}
    req_area = area_needed(max_n_corals, density)
    mod_density = (n_corals * 0.5) / (req_area / m2_TO_km2)
    d_area_pct = (req_area / sum(target_areas)) * 100.0

    # Using a global var here to stop inappropriate small grid size from
    # being selected once a larger grid size is set.
    # TODO: Should be an input.
    global RME_BASE_GRID_SIZE
    min_cells::Int64 = 3
    if (RME_BASE_GRID_SIZE * req_area / sum(target_areas)) < min_cells
        # Determine new grid resolution in terms of number of N by N cells
        target_grid_size::Float64 = 3.0 * sum(target_areas) / req_area
        cell_res::Int64 = ceil(Int64, sqrt(target_grid_size))  # new cell resolution

        # RME supported cell sizes (N by N)
        p::Vector{Int64} = Int64[10, 20, 25, 30, 36, 43, 55, 64, 85, 100]
        n_cells::Int64 = first(p[p.>=cell_res])
        RME_BASE_GRID_SIZE = n_cells * n_cells
        opt::String = "RMFAST$(first(p[p .>= cell_res]))"
        @RME setOptionText("emulation_method"::Cstring, opt::Cstring)::Cint

        @warn "Insufficient number of treatment cells. Adjusting grid size.\nSetting grid to $(n_cells) by $(n_cells) cells"
    end

    return d_area_pct, mod_density
end

function set_seeding_deployment(name::String, reefset::String, n_corals::Int64, max_effort::Int64, first_year::Int64, last_year::Int64, year_step::Int64, area_km2::Vector{Float64}, density::Float64)
    iv_type = "outplant"

    area_pct, mod_density = deployment_area(n_corals, max_effort, density, area_km2)

    @RME ivAdd(name::Cstring, iv_type::Cstring, reefset::Cstring, first_year::Cint, last_year::Cint, year_step::Cint)::Cint
    @RME ivSetOutplantAreaPct(name::Cstring, area_pct::Cdouble)::Cint
    @RME ivSetOutplantCountPerM2(name::Cstring, mod_density::Cdouble)::Cint
end

export init_rme, reset_rme, @RME
export deployment_area, set_seeding_deployment

end
