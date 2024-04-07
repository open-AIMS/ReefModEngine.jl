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

    if !isdir(rme_path)
        throw(ArgumentError("Provided path to RME does not exist: $(rme_path)"))
    end

    if !isfile(lib_path)
        throw(ArgumentError("Could not find RME library: $(lib_path)"))
    end

    if !@isdefined(RME)
        # For internal use
        @eval const RME_PATH = $(rme_path)
        @eval const RME = $(lib_path)

        # For external use
        const Main.RME_PATH = rme_path
        const Main.RME = lib_path
    end
end

"""
    init_rme(rme_path::String)::Nothing

Initialize ReefMod Engine for use.
"""
function init_rme(rme_path::String)::Nothing
    _associate_rme(rme_path)

    data_fp = joinpath(rme_path, "data_files")

    @RME setDataFilesPath(data_fp::Cstring)::Cint
    @RME init(joinpath(rme_path, "data_files", "config", "config.xml")::Cstring)::Cint

    rme_vers = @RME version()::Cstring
    @info "Loaded RME $rme_vers"

    return nothing
end

"""
    reset_rme()

Reset ReefModEngine, clearing any and all interventions and reef sets.
"""
function reset_rme()
    RME_BASE_GRID_SIZE[] = 100

    @RME ivRemoveAll()::Cvoid
    @RME reefSetRemoveAll()::Cint
end

"""
    set_option(opt::String, val::Float64)
    set_option(opt::String, val::Int)
    set_option(opt::String, val::String)

Set RME option.

See RME documentation for full list of available options.
"""
function set_option(opt::String, val::Float64)
    @RME setOption(opt::Cstring, val::Cdouble)::Cint
end
function set_option(opt::String, val::Int)
    return set_option(opt, Float64(val))
end
function set_option(opt::String, val::String)
    @RME setOptionText(opt::Cstring, val::Cstring)::Cint
end

"""
    run_init()::Nothing

Convenience function to initialize RME runs.
"""
function run_init()::Nothing
    @RME runInit()::Cint

    return nothing
end
