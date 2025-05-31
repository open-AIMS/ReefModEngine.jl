@testset "New v1.0.42 API Features" begin
    @testset "Enhanced Logging Options" begin
        # Test new logging system options
        @test_nowarn set_option("log_reef_data_enabled", 1)
        @test_nowarn set_option("log_run_data_enabled", 1)

        # Test connectivity options
        @test_nowarn set_option("coral_connectivity_uses_actual_year", 0)
        @test_nowarn set_option("cots_connectivity_uses_actual_year", 0)
    end

    @testset "New System Options" begin
        # Test options that can be changed between iterations (v1.0.41)
        @test_nowarn set_option("cots_enabled", 1)
        @test_nowarn set_option("bleaching_enabled", 1)
        @test_nowarn set_option("cyclones_enabled", 1)

        # Test deployment reassessment
        @test_nowarn set_option("reassess_deployment", 0)
    end
end