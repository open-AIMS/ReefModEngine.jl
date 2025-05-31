@testset "Integration Examples" begin
    name = "test run"
    start_year = 2025
    end_year = 2030
    RCP_scen = "SSP 2.45"
    gcm = "CNRM_ESM2_1"
    reps = 1

    @testset "Simple Run" begin
        reset_rme()

        # Define dummy run and initialize
        @RME runCreate(name::Cstring, start_year::Cint, end_year::Cint, RCP_scen::Cstring, gcm::Cstring, reps::Cint)::Cint
        run_init()

        # Test new options
        set_option("use_individual_random_generators", 0)
        set_option("track_outplant_descendents", 1)
        set_option("fixed_seed", 123)

        # Test that we can still create basic structures
        @test_nowarn ResultStore(2020, 2025, 10)  # Small test with 10 reefs

        # Test reef functions still work
        reef_list = reef_ids()
        @test length(reef_list) > 10

        # Test area functions
        areas = reef_areas(reef_list[1:10])
        @test length(areas) == 10
    end

    @testset "Version-Specific Features" begin
        version_info = rme_version_info()

        # Define dummy run and initialize
        @RME runCreate(name::Cstring, start_year::Cint, end_year::Cint, RCP_scen::Cstring, gcm::Cstring, reps::Cint)::Cint
        run_init()

        if version_info.patch >= 42
            @test_nowarn log_set_all_items_enabled(true)
            @test_nowarn log_set_all_reefs_enabled(true)
        end

        if version_info.patch >= 40
            @test_nowarn set_option("log_reef_data_enabled", 1)
            @test_nowarn set_option("coral_connectivity_uses_actual_year", 0)
        end
    end
end