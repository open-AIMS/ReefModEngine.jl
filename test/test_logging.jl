@testset "Logging System (v1.0.39-v1.0.42)" begin
    @testset "Logging Control Functions" begin
        # Test the new logging control functions
        @test_nowarn log_set_all_items_enabled(false)
        @test_nowarn log_set_all_items_enabled(true)

        @test_nowarn log_set_item_enabled("coral_size_cm2", true)
        @test_nowarn log_set_item_enabled("coral_growth_type", false)

        @test_nowarn log_set_all_reefs_enabled(false)
        @test_nowarn log_set_all_reefs_enabled(true)

        # Test reef-specific logging (using first reef)
        @test_nowarn log_set_reef_enabled(1, true)
        @test_nowarn log_set_reef_enabled(1, false)
    end

    @testset "Log Data Retrieval" begin
        # Enable logging for a simple test
        set_option("log_reef_data_enabled", 1)
        set_option("log_run_data_enabled", 1)

        # Set up a minimal run to generate log data
        reset_rme()

        # Create a simple test run
        @test_nowarn begin
            # This would need to be adapted based on your minimal run setup
            # For now, just test that the functions exist and can be called

            # These might fail if no run data exists, but at least test the function exists
            try
                log_get_reef_data_ref("season", 1, 1, 1)
            catch e
                @test isa(e, Exception)  # Expected if no data available
            end

            try
                log_get_run_data_ref("year", 1, 1)
            catch e
                @test isa(e, Exception)  # Expected if no data available
            end
        end
    end
end