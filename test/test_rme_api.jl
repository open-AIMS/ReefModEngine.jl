@testset "Existing API Functions" begin
    @testset "Basic Functions" begin
        @test_nowarn reef_ids()
        reef_list = reef_ids()
        @test length(reef_list) > 0
        @test all(id -> isa(id, String), reef_list)

        @test_nowarn reef_areas()
        areas = reef_areas()
        @test length(areas) == length(reef_list)
        @test all(area -> area > 0, areas)
    end

    @testset "Options System" begin
        # Test basic option setting
        @test_nowarn set_option("thread_count", 2)

        # Test renamed options (v1.0.41 change)
        @test_nowarn set_option("bleaching_enabled", 1)  # was "dhw_enabled"

        # Test new options
        @test_nowarn set_option("use_individual_random_generators", 0)
        @test_nowarn set_option("track_outplant_descendents", 1)
        @test_nowarn set_option("coral_mortality_decreases_with_size", 0)
        @test_nowarn set_option("dictyota_enabled", 0)
        @test_nowarn set_option("limit_colony_count_per_cell", 1)
    end

    @testset "Result Store" begin
        @test_nowarn ResultStore(2020, 2030)
        rs = ResultStore(2020, 2030, 100)  # 100 reefs for testing
        @test rs.start_year == 2020
        @test rs.end_year == 2030
        @test rs.n_reefs == 100
    end
end