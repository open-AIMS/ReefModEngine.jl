@testset "Parameter System (v1.0.41)" begin
    # This tests the major new feature from v1.0.41
    name = "test run"
    start_year = 2025
    end_year = 2030
    RCP_scen = "SSP 2.45"
    gcm = "CNRM_ESM2_1"
    reps = 1

    # Define dummy run and initialize
    reset_rme()
    @RME runCreate(
        name::Cstring,
        start_year::Cint,
        end_year::Cint,
        RCP_scen::Cstring,
        gcm::Cstring,
        reps::Cint
    )::Cint
    run_init()

    @testset "Parameter Setting and Getting" begin
        # Test scalar parameter
        max_diam = get_param("coral_max_diameter_cm")
        @test max_diam == [120.0, 100.0, 50.0, 40.0, 60.0, 200.0]

        # Test vector parameter (6 coral species)
        retrieved_rates = get_param("coral_growth_rate_cm_per_6m")
        @test length(retrieved_rates) == 6
    end

    @testset "Common Parameters" begin
        # Test some commonly used parameters from the RME documentation

        # Define a reef set called "priority_reefs"
        @RME reefSetAddFromIdList("priority_reefs"::Cstring, ["10-330", "10-331"]::Ptr{Cstring}, 1::Cint)::Cint

        # Simulate some CoTS control activity on those reefs
        iv_add("strategic_control", "cots_control", "priority_reefs", 2025, 2030, 1)

        # Primary: Target high CoTS areas
        set_iv_param("strategic_control", "rank_data_code1", "cots_per_m2")
        set_iv_param("strategic_control", "rank_weight1", 0.77)
        rank_weight1 = get_iv_param("strategic_control", "rank_weight1")
        @test rank_weight1 ≈ 0.77

        set_iv_param("strategic_control", "hours", 25000)
        control_hours = get_iv_param("strategic_control", "hours")
        @test control_hours ≈ 25000
    end

    @testset "Intervention Parameter Validation" begin
        # Test that invalid parameters are rejected
        @test_throws Exception set_iv_param("invalid_parameter_name", 1.0)

        # Test incorrect use of set_iv_param
        @test_throws Exception set_iv_param("coral_growth_rate_cm_per_6m", [1.0, 2.0])
    end
end