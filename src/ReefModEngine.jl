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

function _associate_rme(rme_path::String)
    if Sys.iswindows()
        libext = ".dll"
    elseif Sys.islinux()
        libext = ".so"
    # elseif Sys.isapple()  # No apple version of RME as of yet
    #     libext = ".dynlib"
    else
        throw(DomainError("Unsupported platform"))
    end

    rme_path = replace(rme_path, "/" => path_separator, "\\" => path_separator)
    lib_path = joinpath(rme_path, "lib", "librme_ml$(libext)")

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
    @RME init(joinpath(rme_path, "data_files", "config", "config.xml")::Cstring)::Cint

    rme_vers = @RME version()::Cstring
    @info "Loaded RME $rme_vers"
end

function reset_rme()
    RME_BASE_GRID_SIZE[] = 100

    @RME ivRemoveAll()::Cvoid
    @RME reefSetRemoveAll()::Cint
end

function set_option(opt::String, val::Float64)
    @RME setOption(opt::Cstring, val::Cdouble)::Cint
end
function set_option(opt::String, val::Int)
    return set_option(opt, Float64(val))
end
function set_option(opt::String, val::String)
    @RME setOptionText(opt::Cstring, val::Cstring)::Cint
end

function area_needed(n_corals::Int64, density::Float64)::Float64
    # ReefMod deploys twice a year so halve the number of corals to deploy
    return ((n_corals * 0.5) / density) * m2_TO_km2  # Convert m² to km²
end


"""
    deployment_area(n_corals::Int64, max_n_corals::Int64, density::Float64, target_areas::Vector{Float64})::Tuple{Float64,Float64}

Determine deployment area for the expected number of corals to be deployed.

# Arguments
- `n_corals` : Number of corals,
- `max_n_corals` : Expected maximum deployment effort (total number of corals in intervention set)
- `density` : Stocking density
- `target_areas` : Available area at target location(s)

# Returns
Tuple
- Percent area of deployment
- modified stocking density
"""
function deployment_area(n_corals::Int64, max_n_corals::Int64, density::Float64, target_areas::Vector{Float64})::Tuple{Float64,Float64}
    req_area = area_needed(max_n_corals, density)
    mod_density = (n_corals * 0.5) / (req_area / m2_TO_km2)
    d_area_pct = min((req_area / sum(target_areas)) * 100.0, 100.0)

    min_cells::Int64 = 3
    if (RME_BASE_GRID_SIZE[] * req_area / sum(target_areas)) < min_cells
        # Determine new grid resolution in terms of number of N by N cells
        target_grid_size::Float64 = 3.0 * sum(target_areas) / req_area
        cell_res::Int64 = ceil(Int64, sqrt(target_grid_size))  # new cell resolution

        # RME supported cell sizes (N by N)
        # Determine smallest appropriate grid size when larger grid sizes are set.
        p::Vector{Int64} = Int64[10, 20, 25, 30, 36, 43, 55, 64, 85, 100]
        n_cells::Int64 = try
            first(p[p.>=cell_res])
        catch
            p[end-1]
        end

        RME_BASE_GRID_SIZE[] = n_cells * n_cells
        opt::String = "RMFAST$(n_cells)"
        @RME setOptionText("processing_method"::Cstring, opt::Cstring)::Cint

        @warn "Insufficient number of treatment cells. Adjusting grid size.\nSetting grid to $(n_cells) by $(n_cells) cells"
    end

    return d_area_pct, mod_density
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
    year::Int64,
    area_km2::Vector{Float64},
    density::Float64
)::Nothing
    set_outplant_deployment!(name, reefset, n_corals, n_corals, year, year, 1, area_km2, density)
end
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
    set_enrichment_deployment!()

As `set_seeding_deployment` but for larvae enrichment (also known as assisted migration).
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


include("io.jl")
include("ResultStore.jl")

if !isdefined(Base, :get_extension)
    include("../ext/MatExt.jl")
end

export
    init_rme, reset_rme, @RME,
    set_option,
    deployment_area, set_outplant_deployment!,
    ResultStore, collect_all_results!,
    save_to_mat


end
