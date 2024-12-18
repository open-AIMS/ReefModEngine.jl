using CSV, Dates, DataFrames, NetCDF, YAXArrays

using Base: num_bit_chunks
mutable struct ResultStore
    results::Dataset
    scenario::DataFrame
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

    result_path = joinpath(dir_name, "results.nc")
    savedataset(result_store.results; path=result_path, driver=:netcdf)

    scenario_path = joinpath(dir_name, "scenarios.csv")
    CSV.write(scenario_path, result_store.scenario)

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

    return Dataset(
        total_cover=total_cover,
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
    print("""
    ReefModEngine.jl Result Store

    Each store holds data for `:ref` and `:iv`.

    Reefs: $(length(rs.results.total_cover.locations))
    Range: $(rs.start_year) to $(rs.end_year) ($(rs.year_range) years)
    Repeats: $(rs.reps)
    Total repeats with ref and iv: $(2 * rs.reps)

    total_cover : $(size(rs.results.total_cover))
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
        throw(ArgumentError("Results stored in the same dataset must have equal timeframes"))
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
        Dim{:locations}(1:rs.n_reefs),
        Dim{:scenarios}(prev_reps+1:new_n_reps)
    )

    # Concatenate total_taxa_cover cube separately.
    cubes = [
        :total_cover,
        :dhw,
        :dhw_mortality,
        :cyc_mortality,
        :cyc_cat,
        :cots,
        :cots_mortality,
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
        Dim{:locations}(1:rs.n_reefs),
        Dim{:taxa}(1:n_species),
        Dim{:scenarios}(prev_reps+1:new_n_reps)
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
    append_scenarios!(rs::ResultStore, reps::Int)::Nothing

Add rows to scenario dataframe in result store.
"""
function append_scenarios!(rs::ResultStore, reps::Int)::Nothing
    n_reefs::Int64 = @getRME unitCount()::Cint
    iv_reef_ids_idx::Vector{Int64} = zeros(Int64, n_reefs)

    # Use the number of intervention years to calculate an average
    n_outplant_iv::Float64 = 0
    # Count per m2
    outplant_count::Float64 = 0.0
    # Count per m2 per year
    outplant_count_per_year::Vector{Float64} = zeros(6)
    # Area percentage
    outplant_area::Float64 = 0.0
    # Number of locations
    outplant_locs::Float64 = 0.0

    # Starting years in which outplanting occured
    outplant_first_years::Vector{Union{Int64,Any}} = []
    # Final years in which outplanting occured
    outplant_last_years::Vector{Union{Int64,Any}} = []
    # Frequency with which outplanting occured
    outplant_years_step::Vector{Union{Int64,Any}} = []
    # Number of corals outplanted each year
    outplant_corals_per_year::Vector{Union{Int64,Any}} = []

    n_enrichment_iv::Float64 = 0
    # Count per m2
    enrichment_count::Float64 = 0.0
    # Area percentage
    enrichment_area::Float64 = 0.0
    # Number of locations
    enrichment_locs::Float64 = 0.0

    n_locs::Vector{Float64} = [0.0]
    # This for loop accounts for more complex intervention patterns.
    n_iv::Int = @getRME ivCount()::Cint
    for iv_idx in 1:n_iv
        name::String = @RME ivName(iv_idx::Cint)::Cstring
        reef::String = @RME ivReefSet(name::Cstring)::Cstring
        type::String = @RME ivType(name::Cstring)::Cstring
        n_years = (
            (1 + @getRME ivLastYear(name::Cstring)::Cint) - (@getRME ivFirstYear(name::Cstring)::Cint)
        ) / (@getRME ivYearStep(name::Cstring)::Cint)
        @RME reefSetReefCount(reef::Cstring, n_locs::Ptr{Cdouble})::Cint
        if type == "outplant"
            n_outplant_iv += n_years
            outplant_count += n_years * @getRME ivOutplantCountPerM2(name::Cstring)::Cdouble
            outplant_area += n_years * @getRME ivOutplantAreaPct(name::Cstring)::Cdouble
            outplant_locs += n_years * n_locs[1]
        elseif type == "enrich"
            n_enrichment_iv += n_years
            enrichment_count += n_years * @getRME ivEnrichCountPerM2(name::Cstring)::Cdouble
            enrichment_area += n_years * @getRME ivEnrichAreaPct(name::Cstring)::Cdouble
            enrichment_locs += n_years * n_locs[1]
        end
    end

    # Avoid division by zero errors
    n_outplant_iv = max(1, n_outplant_iv)
    n_enrichment_iv = max(1, n_enrichment_iv)

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

    df_cf::DataFrame = DataFrame(
        counterfactual=fill(1, reps),
        dhw_tolerance=repeat(dhw_tolerance_outplants, reps),
        outplant_count_per_m2=0,
        outplant_area_pct=0,
        n_outplant_locs=0,
        enrichment_count_per_m2=0,
        enrichment_area_pct=0,
        n_enrichment_locs=0,
    )
    df_iv::DataFrame = DataFrame(
        counterfactual=fill(0, reps),
        dhw_tolerance=repeat(dhw_tolerance_outplants, reps),
        outplant_count_per_m2=outplant_count / n_outplant_iv,
        outplant_area_pct=outplant_area / n_outplant_iv,
        n_outplant_locs=outplant_locs / n_outplant_iv,
        enrichment_count_per_m2=enrichment_count / n_enrichment_iv,
        enrichment_area_pct=enrichment_area / n_enrichment_iv,
        n_enrichment_locs=enrichment_locs / n_enrichment_iv,
    )

    if size(rs.scenario) == (0, 0)
        rs.scenario = vcat(df_cf, df_iv);
    else
        rs.scenario = vcat(rs.scenario, df_cf, df_iv)
    end

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
            rs.results.dhw_mortality[timesteps=At(yr), scenarios=rep_offset +reps + r] = tmp

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
            rs.results.cyc_mortality[timesteps=At(yr), scenarios=rep_offset + reps + r] = tmp

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
