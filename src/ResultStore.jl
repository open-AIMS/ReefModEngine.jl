using Dates, DataFrames, YAXArrays

mutable struct ResultStore
    results::Dataset
    iv_mask::BitVector
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
        BitVector(),
        start_year,
        end_year,
        (end_year - start_year) + 1,
        n_reefs,
        0
    )
end

"""
    create_dataset(start_year::Int, end_year::Int, n_reefs::Int, reps::Int)::Dataset

Preallocate and create dataset for result variables. Only constructed when the first results
are collected.
"""
function create_dataset(start_year::Int, end_year::Int, n_reefs::Int, reps::Int)::Dataset
    year_range = (end_year - start_year) + 1

    arr_size = (year_range, n_reefs, 2 * reps)
    
    # Coral cover [% of total reef area]
    cover = DataCube(
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
    # Species cover [% of total reef area]
    n_species = 6
    arr_size = (year_range, n_reefs, n_species, 2 * reps)
    species = DataCube(
        zeros(arr_size...);
        timesteps=start_year:end_year,
        locations=1:n_reefs,
        taxa=1:n_species,
        scenarios=1:(2 * reps)
    )
    return Dataset(
        cover=cover,
        dhw=dhw,
        dhw_mortality=dhw_mortality,
        cyc_mortality=cyc_mortality,
        cyc_cat=cyc_cat,
        cots=cots,
        cots_mortality=cots_mortality,
        species=species
    )
end

function Base.show(io::IO, mime::MIME"text/plain", rs::ResultStore)::Nothing
    print("""
    ReefModEngine.jl Result Store

    Each store holds data for `:ref` and `:iv`.

    Reefs: $(length(rs.results.cover.locations))
    Range: $(rs.start_year) to $(rs.end_year) ($(rs.year_range) years)
    Repeats: $(rs.reps)
    Total repeats with ref and iv: $(2 * rs.reps)

    cover : $(size(rs.results.cover))
    dhw : $(size(rs.results.dhw))
    dhw_mortality : $(size(rs.results.dhw_mortality))
    cyc_mortality : $(size(rs.results.cyc_mortality))
    cyc_cat : $(size(rs.results.cyc_cat))
    cots : $(size(rs.results.cots))
    cots_mortality : $(size(rs.results.cots_mortality))
    species : $(size(rs.results.species))
    """)
end

"""
    preallocate_append(rs, start_year, end_year, reps::Int64)::Nothing

Allocate additional memory before adding an additional result set. Result sets must have the
same timeframe.
"""
function preallocate_append!(rs, start_year, end_year, reps::Int64)::Nothing
    if rs.start_year != start_year && rs.end_year != end_year 
        throw(ArgumentError("Results stored in the same dataset must have equal timeframes"))
    end
    # If the results dataset is empty construct the initial datset
    if length(rs.results.cubes) == 0
        rs.results = create_dataset(start_year, end_year, rs.n_reefs, reps)
        return nothing
    end

    new_n_reps::Int = length(rs.results.scenarios) + 2 * reps
    n_reefs::Int = length(rs.results.locations)

    axlist = (
        Dim{:timesteps}(start_year:end_year),
        Dim{:locations}(1:rs.n_reefs),
        Dim{:scenarios}(1:(2 * reps))
    )
    
    # Concatenate species cube seperately.
    cubes = [
        :cover,
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
        Dim{:scenarios}(1:(2 * reps))
    )
    rs.results.cubes[:species] = cat(
        rs.results.cubes[:species], 
        YAXArray(axlist, zeros(rs.year_range, n_reefs, n_species, 2 * reps)); 
        dims=Dim{:scenarios}(1:new_n_reps)
    )
    return nothing
end


"""
    append_all_results!(rs::ResultStore, start_year::Int64, end_year::Int64, reps::Int64)::Nothing

Append results for all runs/replicates. 

# Arguments
- `rs` : Result store to save data to
- `start_year` : Collect data from this year
- `end_year` : Collect data to this year
- `reps` : Total number of expected replicates
"""
function append_all_results!(
    rs::ResultStore, start_year::Int64, end_year::Int64, reps::Int64
)::Nothing
    rep_offset = length(rs.results.cubes) == 0 ? 0 : length(rs.results.scenarios)

    append!(rs.iv_mask, BitVector([i <= reps for i in 1:(2 * reps)]))
    preallocate_append!(rs, start_year, end_year, reps)

    # Temporary data store for results
    n_reefs = 3806
    n_species = length(rs.results.species.taxa)
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
            rs.results.cover[timesteps=At(yr), scenarios=rep_offset + r] = tmp

            @RME runGetData(
                "coral_pct"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.results.cover[timesteps=At(yr), scenarios=rep_offset + reps + r] = tmp

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
                rs.results.species[
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
                rs.results.species[
                    timesteps=At(yr), taxa=At(sp), scenarios=rep_offset + reps + r
                ] = tmp
            end
        end
    end

    return nothing
end

# TODO: implement equivalent for new result structure.

#"""
#    collect_rep_results!(rs::ResultStore, start_year::Int64, end_year::Int64, reps::Vector{Int64})::Nothing
#
#Collect results for a specific replicate.
#
## Arguments
#- `rs` : Result store to save data to
#- `start_year` : Collect data from this year
#- `end_year` : Collect data to this year
#- `reps` : Specific replicates to save data for
#"""
#function collect_rep_results!(
#    rs::ResultStore, start_year::Int64, end_year::Int64, reps::Vector{Int64}
#)::Nothing
#    # Temporary data store for results
#    n_reefs = 3806
#    n_species = size(rs.species[:ref], 3)
#    tmp = zeros(n_reefs)
#
#    for r in reps
#        for (i, yr) in enumerate(start_year:end_year)
#            # "" : Can specify name of a reef set, or empty to indicate all reefs
#            # 0 | 1 : without intervention; with intervention
#            @RME runGetData(
#                "coral_pct"::Cstring,
#                ""::Cstring,
#                0::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.cover[:ref][i, :, r] = tmp
#
#            @RME runGetData(
#                "coral_pct"::Cstring,
#                ""::Cstring,
#                1::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.cover[:iv][i, :, r] = tmp
#
#            @RME runGetData(
#                "max_dhw"::Cstring,
#                ""::Cstring,
#                0::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.dhw[:ref][i, :, r] = tmp
#
#            @RME runGetData(
#                "max_dhw"::Cstring,
#                ""::Cstring,
#                1::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.dhw[:iv][i, :, r] = tmp
#
#            @RME runGetData(
#                "dhw_loss_pct"::Cstring,
#                ""::Cstring,
#                0::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.dhw_mortality[:ref][i, :, r] = tmp
#
#            @RME runGetData(
#                "dhw_loss_pct"::Cstring,
#                ""::Cstring,
#                1::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.dhw_mortality[:iv][i, :, r] = tmp
#
#            @RME runGetData(
#                "cyclone_loss_pct"::Cstring,
#                ""::Cstring,
#                0::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.cyc_mortality[:ref][i, :, r] = tmp
#
#            @RME runGetData(
#                "cyclone_loss_pct"::Cstring,
#                ""::Cstring,
#                1::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.cyc_mortality[:iv][i, :, r] = tmp
#
#            @RME runGetData(
#                "cyclone_cat"::Cstring,
#                ""::Cstring,
#                0::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.cyc_cat[:ref][i, :, r] = tmp
#
#            @RME runGetData(
#                "cyclone_cat"::Cstring,
#                ""::Cstring,
#                1::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.cyc_cat[:iv][i, :, r] = tmp
#
#            # CoTS
#            @RME runGetData(
#                "cots_per_ha"::Cstring,
#                ""::Cstring,
#                0::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.cots[:ref][i, :, r] = tmp
#
#            @RME runGetData(
#                "cots_per_ha"::Cstring,
#                ""::Cstring,
#                1::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.cots[:iv][i, :, r] = tmp
#
#            @RME runGetData(
#                "cots_loss_pct"::Cstring,
#                ""::Cstring,
#                0::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.cots_mortality[:ref][i, :, r] = tmp
#
#            @RME runGetData(
#                "cots_loss_pct"::Cstring,
#                ""::Cstring,
#                1::Cint,
#                yr::Cint,
#                r::Cint,
#                tmp::Ref{Cdouble},
#                n_reefs::Cint
#            )::Cint
#            rs.cots_mortality[:iv][i, :, r] = tmp
#
#            for sp in 1:n_species
#                @RME runGetData(
#                    "species_$(sp)_pct"::Cstring,
#                    ""::Cstring,
#                    0::Cint,
#                    yr::Cint,
#                    r::Cint,
#                    tmp::Ref{Cdouble},
#                    n_reefs::Cint
#                )::Cint
#                rs.species[:ref][i, :, sp, r] = tmp
#
#                @RME runGetData(
#                    "species_$(sp)_pct"::Cstring,
#                    ""::Cstring,
#                    1::Cint,
#                    yr::Cint,
#                    r::Cint,
#                    tmp::Ref{Cdouble},
#                    n_reefs::Cint
#                )::Cint
#                rs.species[:iv][i, :, sp, r] = tmp
#            end
#        end
#    end
#
#    return nothing
#end
