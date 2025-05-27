using CSV, Dates, DataFrames, NetCDF, YAXArrays, Statistics, JSON

using Base: num_bit_chunks

mutable struct ResultStore
    results::Dataset
    iv_yearly_scenario::DataFrame
    scenario_info_dict::Dict
    start_year::Int
    end_year::Int
    year_range::Int
    n_reefs::Int
    reps::Int
end

function ResultStore(start_year, end_year)
    return ResultStore(start_year, end_year, 3806)
end
function ResultStore(start_year, end_year, n_reefs)
    return ResultStore(
        Dataset(),
        DataFrame(),
        Dict(),
        start_year,
        end_year,
        (end_year - start_year) + 1,
        n_reefs,
        0
    )
end

"""
    save_result_store(dir_name::String, result_store::ResultStore)::Nothing

Save results to a netcdf file and a dataframe containing the scenario runs. Saved to the
given directory. The directory is created if it does not exit.
"""
function save_result_store(dir_name::String, result_store::ResultStore)::Nothing
    mkpath(dir_name)

    # Save model outputs as netcdf
    result_path = joinpath(dir_name, "results.nc")
    savedataset(result_store.results; path=result_path, driver=:netcdf)

    # Save dataframe of yearly intervention levels as csv
    iv_scenario_path = joinpath(dir_name, "iv_yearly_scenarios.csv")
    CSV.write(iv_scenario_path, result_store.iv_yearly_scenario)

    # Save scenario info in json file
    scenario_info_path = joinpath(dir_name, "scenario_info.json")
    si_json_string = JSON.json(result_store.scenario_info_dict)
    open(scenario_info_path, "w") do f
        write(f, si_json_string)
    end
    return nothing
end

"""
    create_dataset(start_year::Int, end_year::Int, n_reefs::Int, reps::Int)::Dataset

Preallocate and create dataset for result variables. Only constructed when the first results
are collected.
"""
function create_dataset(start_year::Int, end_year::Int, n_reefs::Int, reps::Int)::Dataset
    year_range = (end_year - start_year) + 1

    arr_size = (year_range, n_reefs, 2 * reps)

    # Total Coral cover [% of total reef area]
    total_cover = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        scenarios=1:(2 * reps)
    )
    # Number of juvenile corals
    nb_coral_juv = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        scenarios=1:(2 * reps)
    )
    # Percentage rubble cover
    rubble = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        scenarios=1:(2 * reps)
    )
    # Percentage rubble cover
    relative_shelter_volume = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        scenarios=1:(2 * reps)
    )
    # DHW [degree heating weeks]
    dhw = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        scenarios=1:(2 * reps)
    )
    # DHW mortality [% of population (to be confirmed)]
    dhw_mortality = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        scenarios=1:(2 * reps)
    )
    # Cyclone mortality [% of population (to be confirmed)]
    cyc_mortality = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        scenarios=1:(2 * reps)
    )
    # Cyclone categories [0 to 5]
    cyc_cat = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        scenarios=1:(2 * reps)
    )
    # Crown-of-Thorn Starfish population [per ha]
    cots = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        scenarios=1:(2 * reps)
    )
    # Mortality caused by Crown-of-Thorn Starfish [% of population (to be confirmed)]
    cots_mortality = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        scenarios=1:(2 * reps)
    )
    # Total Species cover [% of total reef area]
    n_species = 6
    arr_size = (year_range, n_reefs, n_species, 2 * reps)
    total_taxa_cover = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        taxa=1:n_species,
        scenarios=1:(2 * reps)
    )

    return Dataset(;
        total_cover=total_cover,
        nb_coral_juv=nb_coral_juv,
        relative_shelter_volume=relative_shelter_volume,
        rubble=rubble,
        dhw=dhw,
        dhw_mortality=dhw_mortality,
        cyc_mortality=cyc_mortality,
        cyc_cat=cyc_cat,
        cots=cots,
        cots_mortality=cots_mortality,
        total_taxa_cover=total_taxa_cover
    )
end

function Base.show(io::IO, mime::MIME"text/plain", rs::ResultStore)::Nothing
    if length(rs.results.cubes) == 0
        print("""
        Reefs: $(rs.n_reefs)
        Range: $(rs.start_year) to $(rs.end_year) ($(rs.year_range) years)
        Repeats: $(rs.reps)
        Total repeats with ref and iv: $(2 * rs.reps)
              """)

        return nothing
    end
    return print("""
           ReefModEngine.jl Result Store

           Each store holds data for `:ref` and `:iv`.

           Reefs: $(length(rs.results.total_cover.locations))
           Range: $(rs.start_year) to $(rs.end_year) ($(rs.year_range) years)
           Repeats: $(rs.reps)
           Total repeats with ref and iv: $(2 * rs.reps)

           total_cover : $(size(rs.results.total_cover))
           nb_coral_juv : $(size(rs.results.nb_coral_juv))
           relative_shelter_volume : $(size(rs.results.relative_shelter_volume))
           rubble : $(size(rs.results.rubble))
           dhw : $(size(rs.results.dhw))
           dhw_mortality : $(size(rs.results.dhw_mortality))
           cyc_mortality : $(size(rs.results.cyc_mortality))
           cyc_cat : $(size(rs.results.cyc_cat))
           cots : $(size(rs.results.cots))
           cots_mortality : $(size(rs.results.cots_mortality))
           total_taxa_cover : $(size(rs.results.total_taxa_cover))
           """)
end

"""
    preallocate_concat(rs, start_year, end_year, reps::Int64)::Nothing

Allocate additional memory before adding an additional result set. Result sets must have the
same time frame.
"""
function preallocate_concat!(rs, start_year, end_year, reps::Int64)::Nothing
    if rs.start_year != start_year || rs.end_year != end_year
        throw(
            ArgumentError("Results stored in the same dataset must have equal timeframes")
        )
    end
    # If the results dataset is empty construct the initial dataset
    if length(rs.results.cubes) == 0
        rs.results = create_dataset(start_year, end_year, rs.n_reefs, reps)

        return nothing
    end

    prev_reps::Int = length(rs.results.scenarios)
    new_n_reps::Int = prev_reps + 2 * reps
    n_reefs::Int = length(rs.results.locations)

    axlist = (
        Dim{:timesteps}(start_year:end_year),
        Dim{:locations}(1:(rs.n_reefs)),
        Dim{:scenarios}((prev_reps + 1):new_n_reps)
    )

    # Concatenate total_taxa_cover cube separately.
    cubes = [
        :total_cover,
        :nb_coral_juv,
        :relative_shelter_volume,
        :rubble,
        :dhw,
        :dhw_mortality,
        :cyc_mortality,
        :cyc_cat,
        :cots,
        :cots_mortality
    ]
    for cube_name in cubes
        rs.results.cubes[cube_name] = cat(
            rs.results.cubes[cube_name],
            YAXArray(axlist, zeros(rs.year_range, n_reefs, 2 * reps));
            dims=Dim{:scenarios}(1:new_n_reps)
        )
    end

    n_species = 6
    axlist = (
        Dim{:timesteps}(start_year:end_year),
        Dim{:locations}(1:(rs.n_reefs)),
        Dim{:taxa}(1:n_species),
        Dim{:scenarios}((prev_reps + 1):new_n_reps)
    )
    rs.results.cubes[:total_taxa_cover] = cat(
        rs.results.cubes[:total_taxa_cover],
        YAXArray(axlist, zeros(rs.year_range, n_reefs, n_species, 2 * reps));
        dims=Dim{:scenarios}(1:new_n_reps)
    )
    # Axes stored in the dataset are separate from the Cubes and must be updated.
    rs.results.axes[:scenarios] = Dim{:scenarios}(1:new_n_reps)

    return nothing
end

"""
    n_corals_calculation(count_per_year::Float64, iv_area::Float64, target_reef_area_km²::Vector{Float64}, n_years::Int64)::Int64

Calculate total number of corals deployed in an intervention.
"""
function n_corals_calculation(
    count_per_year::Vector{Float64},
    target_reef_area_km²::Vector{Float64}
)::Int64
    return round(
        Int,
        (
            sum(count_per_year)* # Density in restoration area
            (
                sum(target_reef_area_km²) * # restoration area (iv_pct / 100) *
                (1 / m2_TO_km2)
            )
        )
    )

end

"""
    append_scenarios!(rs::ResultStore, reps::Int)::Nothing

Add rows to scenario dataframe in result store.
"""
function append_scenarios!(rs::ResultStore, reps::Int)::Nothing
    n_reefs::Int64 = @getRME unitCount()::Cint
    iv_reef_ids_idx::Vector{Int64} = zeros(Int64, n_reefs)

    # Get GCM being used for this run
    GCM_name::String = @RME runGcm()::Cstring

    # This for loop accounts for more complex intervention patterns.
    n_iv::Int = @getRME ivCount()::Cint

    # Setup iv scenario storage dataframe
    iv_df_cols = [
        "intervention id",
        "GCM name",
        "type",
        "reefset",
        "year",
        "rep",
        "number of corals",
        "corals per m2",
        "intervention area km2"
    ]
    types_iv_df = [
        Int64[], String[], String[], String[], Int64[], Int64[], Float64[], Float64[],
        Float64[]
    ]
    iv_df = DataFrame([
        iv_col => types_iv_df[iv_col_idx] for (iv_col_idx, iv_col) in enumerate(iv_df_cols)
    ])

    # Get intervention id which corresponds to a unique intervention/climate model run
    if isempty(rs.iv_yearly_scenario)
        iv_id = 1
    else
        iv_id = maximum(rs.iv_yearly_scenario[:, "intervention id"]) + 1
    end

    # Setup reefsets storage
    scenario_dict = rs.scenario_info_dict

    for iv_idx in 1:n_iv
        name::String = @RME ivName(iv_idx::Cint)::Cstring # Intervention name
        type::String = @RME ivType(name::Cstring)::Cstring # Intervention type
        last_year::Int64 = @getRME ivLastYear(name::Cstring)::Cint # Last year of intervention
        first_year::Int64 = @getRME ivFirstYear(name::Cstring)::Cint # First year of intervention
        year_step::Int64 = @getRME ivYearStep(name::Cstring)::Cint # Frequency of intervention

        # Intervention reeefset name
        reefset_name::String = @RME ivReefSet(name::Cstring)::Cstring

        # Get reefids for intervention reefset
        @getRME reefSetGetAsVector(
            reefset_name::Cstring, iv_reef_ids_idx::Ptr{Cint}, length(iv_reef_ids_idx)::Cint
        )::Cint
        iv_reef_ids = reef_ids()[iv_reef_ids_idx .!== 0]
        scenario_dict[reefset_name] = iv_reef_ids

        # Get reef areas for intervention reefset
        target_reef_area_km² = reef_areas(iv_reef_ids)

        if type == "outplant"
            # Extract proportion of reef area intervened over
            iv_outplant_pct::Float64 = @getRME ivOutplantAreaPct(name::Cstring)::Cdouble
            iv_years = collect(first_year:year_step:last_year) # intervention years
            n_outplants = zeros(length(iv_reef_ids))

            for yr in iv_years
                for rep in 1:reps
                    # Get actual corals outplanted per m2 for each year
                    @RME runGetData(
                        "outplant_count_per_m2"::Cstring,
                        reefset_name::Cstring,
                        1::Cint,
                        yr::Cint,
                        rep::Cint,
                        n_outplants::Ptr{Cdouble},
                        length(n_outplants)::Cint
                    )::Cint

                    # Transform to total number of corals and store
                    n_corals = n_corals_calculation(n_outplants, target_reef_area_km²)

                    # Add to scenario df [unique intervention/climate model id, intervention type, reefset name, intervention year, rep, intervention volume]
                    push!(
                        iv_df,
                        [
                            iv_id,
                            GCM_name,
                            type,
                            reefset_name,
                            yr,
                            rep,
                            n_corals,
                            sum(n_outplants),
                            sum(target_reef_area_km²) * (iv_outplant_pct / 100)
                        ]
                    )
                end
            end

        elseif type == "enrich"
            # Extract proportion of reef area intervened over
            iv_enrich_pct::Float64 = @getRME ivEnrichAreaPct(name::Cstring)::Cdouble
            iv_years = collect(first_year:year_step:last_year)
            n_enrich = zeros(length(iv_reef_ids))

            for yr in iv_years
                for rep in 1:reps
                    @RME runGetData(
                        "enrich_count_per_m2"::Cstring,
                        reefset_name::Cstring,
                        1::Cint,
                        yr::Cint,
                        rep::Cint,
                        n_enrich::Ptr{Cdouble},
                        length(n_enrich)::Cint
                    )::Cint
                    n_corals = n_corals_calculation(n_enrich, target_reef_area_km²)
                    push!(
                        iv_df,
                        [
                            iv_id,
                            GCM_name,
                            type,
                            reefset_name,
                            yr,
                            rep,
                            n_corals,
                            sum(n_enrich),
                            sum(target_reef_area_km²) * (iv_enrich_pct / 100)
                        ]
                    )
                end
            end
        end
    end

    # Create vector for compatibility with C++ pointers.
    dhw_tolerance_outplants::Vector{Float64} = [0.0]

    has_outplants = try
        @RME getOption(
            "restoration_dhw_tolerance_outplants"::Cstring,
            dhw_tolerance_outplants::Ptr{Cdouble}
        )::Cint

        true
    catch err
        if !(err isa ArgumentError)
            rethrow(err)
        end

        false
    end

    if size(rs.iv_yearly_scenario) == (0, 0)
        scenario_dict[:counterfactual] = vcat(fill(1, reps), fill(0, reps))
        scenario_dict[:dhw_tolerance] = repeat(dhw_tolerance_outplants, 2 * reps)
        rs.iv_yearly_scenario = iv_df

    else
        scenario_dict[:counterfactual] = vcat(
            rs.scenario_info_dict[:counterfactual], fill(1, reps), fill(0, reps)
        )
        scenario_dict[:dhw_tolerance] = vcat(
            rs.scenario_info_dict[:dhw_tolerance], repeat(dhw_tolerance_outplants, 2 * reps)
        )
        rs.iv_yearly_scenario = vcat(rs.iv_yearly_scenario, iv_df)
    end

    rs.scenario_info_dict = scenario_dict

    return nothing
end

"""
    concat_results!(rs::ResultStore, start_year::Int64, end_year::Int64, reps::Int64)::Nothing

Append results for all runs/replicates.

# Arguments
- `rs` : Result store to save data to
- `start_year` : Collect data from this year
- `end_year` : Collect data to this year
- `reps` : Total number of expected replicates
"""
function concat_results!(
    rs::ResultStore, start_year::Int64, end_year::Int64, reps::Int64
)::Nothing
    rep_offset = length(rs.results.cubes) == 0 ? 0 : length(rs.results.scenarios)

    preallocate_concat!(rs, start_year, end_year, reps)
    append_scenarios!(rs, reps)
    rs.reps += reps

    # Temporary data store for results
    n_reefs = 3806
    reef_area_m² = reef_areas().*(1000)^2
    n_species = length(rs.results.total_taxa_cover.taxa)
    tmp = zeros(n_reefs)

    for r in 1:reps
        for yr in start_year:end_year
            # "" : Can specify name of a reef set, or empty to indicate all reefs
            # 0 | 1 : without intervention; with intervention
            @RME runGetData(
                "coral_pct"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.total_cover[timesteps=At(yr), scenarios=rep_offset + r] = tmp

            @RME runGetData(
                "coral_pct"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.total_cover[timesteps=At(yr), scenarios=rep_offset + reps + r] = tmp

            # Number of juveniles
            @RME runGetData(
                "coral_juvenile_count_per_m2"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.nb_coral_juv[timesteps=At(yr), scenarios=rep_offset + r] = tmp.*reef_area_m²

            @RME runGetData(
                "coral_juvenile_count_per_m2"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.nb_coral_juv[timesteps=At(yr), scenarios=rep_offset + reps + r] = tmp.*reef_area_m²

            # Rubble pct
            @RME runGetData(
                "rubble_pct"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.rubble[timesteps=At(yr), scenarios=rep_offset + r] = tmp

            @RME runGetData(
                "rubble_pct"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.rubble[timesteps=At(yr), scenarios=rep_offset + reps + r] = tmp

            # Relative shelter volume
            @RME runGetData(
                "relative_shelter_volume"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.relative_shelter_volume[timesteps=At(yr), scenarios=rep_offset + r] = tmp

            @RME runGetData(
                "relative_shelter_volume"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.relative_shelter_volume[timesteps=At(yr), scenarios=rep_offset + reps + r] = tmp

            # DHWs
            @RME runGetData(
                "max_dhw"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.dhw[timesteps=At(yr), scenarios=rep_offset + r] = tmp

            @RME runGetData(
                "max_dhw"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.dhw[timesteps=At(yr), scenarios=rep_offset + reps + r] = tmp

            @RME runGetData(
                "dhw_loss_pct"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.dhw_mortality[timesteps=At(yr), scenarios=rep_offset + r] = tmp

            @RME runGetData(
                "dhw_loss_pct"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.dhw_mortality[timesteps=At(yr), scenarios=rep_offset + reps + r] =
                tmp

            # Cyclones
            @RME runGetData(
                "cyclone_loss_pct"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.cyc_mortality[timesteps=At(yr), scenarios=rep_offset + r] = tmp

            @RME runGetData(
                "cyclone_loss_pct"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.cyc_mortality[timesteps=At(yr), scenarios=rep_offset + reps + r] =
                tmp

            @RME runGetData(
                "cyclone_cat"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.cyc_cat[timesteps=At(yr), scenarios=rep_offset + r] = tmp

            @RME runGetData(
                "cyclone_cat"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.cyc_cat[timesteps=At(yr), scenarios=rep_offset + reps + r] = tmp

            # CoTS
            @RME runGetData(
                "cots_per_ha"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.cots[timesteps=At(yr), scenarios=rep_offset + r] = tmp

            @RME runGetData(
                "cots_per_ha"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.cots[timesteps=At(yr), scenarios=rep_offset + reps + r] = tmp

            @RME runGetData(
                "cots_loss_pct"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.cots_mortality[timesteps=At(yr), scenarios=rep_offset + r] = tmp

            @RME runGetData(
                "cots_loss_pct"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.cots_mortality[
                timesteps=At(yr), scenarios=rep_offset + reps + r
            ] = tmp

            # Species level cover
            for sp in 1:n_species
                @RME runGetData(
                    "species_$(sp)_pct"::Cstring,
                    ""::Cstring,
                    0::Cint,
                    yr::Cint,
                    r::Cint,
                    tmp::Ref{Cdouble},
                    n_reefs::Cint
                )::Cint
                rs.results.total_taxa_cover[
                    timesteps=At(yr), taxa=At(sp), scenarios=rep_offset + r
                ] = tmp

                @RME runGetData(
                    "species_$(sp)_pct"::Cstring,
                    ""::Cstring,
                    1::Cint,
                    yr::Cint,
                    r::Cint,
                    tmp::Ref{Cdouble},
                    n_reefs::Cint
                )::Cint
                rs.results.total_taxa_cover[
                    timesteps=At(yr), taxa=At(sp), scenarios=rep_offset + reps + r
                ] = tmp
            end
        end
    end

    return nothing
end
function concat_results!(
    rs::ResultStore, coral_outplant_df::DataFrame
)::Nothing
end
