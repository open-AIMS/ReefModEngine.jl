using Dates
using MAT

struct ResultStore
    cover::Dict
    dhw::Dict
    dhw_mortality::Dict
    cyc_mortality::Dict
    cyc_cat::Dict
    cots::Dict
    cots_mortality::Dict
    species::Dict
    start_year::Int64
    end_year::Int64
    year_range::Int64
    reps::Int64
end

function ResultStore(start_year, end_year, n_reefs, reps)
    year_range = (end_year - start_year) + 1

    # Coral cover [% of total reef area]
    cover = Dict(
        :ref => zeros(year_range, n_reefs, reps),
        :iv => zeros(year_range, n_reefs, reps)
    )

    # DHW [degree heating weeks]
    dhw = Dict(
        :ref => zeros(year_range, n_reefs, reps),
        :iv => zeros(year_range, n_reefs, reps)
    )

    # DHW mortality [% of population (to be confirmed)]
    dhw_mortality = Dict(
        :ref => zeros(year_range, n_reefs, reps),
        :iv => zeros(year_range, n_reefs, reps)
    )

    # Cyclone mortality [% of population (to be confirmed)]
    cyc_mortality = Dict(
        :ref => zeros(year_range, n_reefs, reps),
        :iv => zeros(year_range, n_reefs, reps)
    )

    # Cyclone categories [0 to 5]
    cyc_cat = Dict(
        :ref => zeros(year_range, n_reefs, reps),
        :iv => zeros(year_range, n_reefs, reps)
    )

    # Crown-of-Thorn Starfish population [per ha]
    cots = Dict(
        :ref => zeros(year_range, n_reefs, reps),
        :iv => zeros(year_range, n_reefs, reps)
    )

    # Mortality caused by Crown-of-Thorn Starfish [% of population (to be confirmed)]
    cots_mortality = Dict(
        :ref => zeros(year_range, n_reefs, reps),
        :iv => zeros(year_range, n_reefs, reps)
    )

    # Species cover [% of total reef area]
    n_species = 6
    species = Dict(
        :ref => zeros(year_range, n_reefs, n_species, reps),
        :iv => zeros(year_range, n_reefs, n_species, reps)
    )

    return ResultStore(
        cover,
        dhw,
        dhw_mortality,
        cyc_mortality,
        cyc_cat,
        cots,
        cots_mortality,
        species,
        start_year,
        end_year,
        year_range,
        reps
    )
end

function Base.show(io::IO, mime::MIME"text/plain", rs::ResultStore)::Nothing
    print("""
    ReefModEngine Result Store

    Each store holds data for `:ref` and `:iv` across:
    $(rs.start_year) to $(rs.end_year) ($(rs.year_range) years)
    For $(rs.reps) repeats

    cover : $(size(rs.cover[:ref]))
    dhw : $(size(rs.dhw[:ref]))
    dhw_mortality : $(size(rs.dhw_mortality[:ref]))
    cyc_mortality : $(size(rs.cyc_mortality[:ref]))
    cyc_cat : $(size(rs.cyc_cat[:ref]))
    cots : $(size(rs.cots[:ref]))
    cots_mortality : $(size(rs.cots_mortality[:ref]))
    species : $(size(rs.species[:ref]))
    """)
end


function collect_all_results!(
    rs::ResultStore, start_year::Int64, end_year::Int64, reps::Int64
)::Nothing

    # Temporary data store for results
    n_reefs = size(rs.cover[:ref], 2)
    n_species = size(rs.species[:ref], 3)
    tmp = zeros(n_reefs)

    for r in 1:reps
        for (i, yr) in enumerate(start_year:end_year)
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
            rs.cover[:ref][i, :, r] = tmp

            @RME runGetData(
                "coral_pct"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.cover[:iv][i, :, r] = tmp

            @RME runGetData(
                "max_dhw"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.dhw[:ref][i, :, r] = tmp

            @RME runGetData(
                "max_dhw"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.dhw[:iv][i, :, r] = tmp

            @RME runGetData(
                "dhw_loss_pct"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.dhw_mortality[:ref][i, :, r] = tmp

            @RME runGetData(
                "dhw_loss_pct"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.dhw_mortality[:iv][i, :, r] = tmp

            @RME runGetData(
                "cyclone_loss_pct"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.cyc_mortality[:ref][i, :, r] = tmp

            @RME runGetData(
                "cyclone_loss_pct"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.cyc_mortality[:iv][i, :, r] = tmp

            @RME runGetData(
                "cyclone_cat"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.cyc_cat[:ref][i, :, r] = tmp

            @RME runGetData(
                "cyclone_cat"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.cyc_cat[:iv][i, :, r] = tmp

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
            rs.cots[:ref][i, :, r] = tmp

            @RME runGetData(
                "cots_per_ha"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.cots[:iv][i, :, r] = tmp

            @RME runGetData(
                "cots_loss_pct"::Cstring,
                ""::Cstring,
                0::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.cots_mortality[:ref][i, :, r] = tmp

            @RME runGetData(
                "cots_loss_pct"::Cstring,
                ""::Cstring,
                1::Cint,
                yr::Cint,
                r::Cint,
                tmp::Ref{Cdouble},
                n_reefs::Cint
            )::Cint
            rs.cots_mortality[:iv][i, :, r] = tmp

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
                rs.species[:ref][i, :, sp, r] = tmp

                @RME runGetData(
                    "species_$(sp)_pct"::Cstring,
                    ""::Cstring,
                    1::Cint,
                    yr::Cint,
                    r::Cint,
                    tmp::Ref{Cdouble},
                    n_reefs::Cint
                )::Cint
                rs.species[:iv][i, :, sp, r] = tmp
            end
        end
    end

    return nothing
end

function _extract_all_results(rs)
    all_res = Dict(
        "coral_cover_ref" => rs.cover[:ref],
        "coral_cover_iv" => rs.cover[:iv],
        "dhw_ref" => rs.dhw[:ref],
        "dhw_iv" => rs.dhw[:iv],
        "dhwloss_ref" => rs.dhw_mortality[:ref],
        "dhwloss_iv" => rs.dhw_mortality[:iv],
        "cyc_ref" => rs.cyc_mortality[:ref],
        "cyc_iv" => rs.cyc_mortality[:iv],
        "cyccat_ref" => rs.cyc_cat[:ref],
        "cyccat_iv" => rs.cyc_cat[:iv],
        "cots_ref" => rs.cots[:ref],
        "cots_iv" => rs.cots[:iv],
        "cotsloss_ref" => rs.cots_mortality[:ref],
        "cotsloss_iv" => rs.cots_mortality[:iv],
        "species_ref" => rs.species[:ref],
        "species_iv" => rs.species[:iv]
    )

    return all_res
end

"""
    save_to_mat(rs::ResultStore)
    save_to_mat(rs::ResultStore, fn::String)

Save results to MAT file following ReefMod Engine standard names.
If the filename is not provided, the default name will be "RME\\_outcomes\\_[today's date].mat"

# Arguments
- `rs` : ResultStore
- `fn` : File name to save to.
"""
function save_to_mat(rs::ResultStore)
    all_res = _extract_all_results(rs)

    # Save results to .mat file
    return matwrite("RME_outcomes_$(today()).mat", all_res)
end

function save_to_mat(rs::ResultStore, fn::String)
    all_res = _extract_all_results(rs)

    # Save results to .mat file
    return matwrite(fn, all_res)
end
