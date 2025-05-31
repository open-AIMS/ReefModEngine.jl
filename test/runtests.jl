using ReefModEngine
using Test

init_rme(ENV["RME_PATH"])

function get_rme_path()
    rme_path = get(ENV, "RME_PATH", "")
    if isempty(rme_path)
        error("""
        RME_PATH environment variable not set!

        Please set it to your RME installation directory:
        export RME_PATH="/path/to/your/rme"

        Or in Julia:
        ENV["RME_PATH"] = "/path/to/your/rme"
        """)
    end

    if !isdir(rme_path)
        error("RME_PATH directory does not exist: $rme_path")
    end

    return rme_path
end

@testset "ReefModEngine.jl initialization and backwards compatibility" begin
    rme_path = get_rme_path()

    @testset "Basic Initialization" begin
        @test isnothing(reset_rme())

        # Test version detection
        version_info = rme_version_info()
        @test version_info.major >= 1
        @test version_info.minor >= 0

        println("Testing with RME version: $(version_info)")

        # Warn if version is too old
        if version_info.patch < 42
            @warn "RME version $(version_info) < 1.0.42. Some tests may fail."
        end
    end

    @testset "New v1.0.42 Features" begin
        include("test_new_features.jl")
    end
end

@testset "RME API Compatibility" begin
    include("test_rme_api.jl")
    include("test_parameter_interface.jl")
    include("test_logging.jl")
end

@testset "Usage examples" begin
    include("test_integration.jl")
end