using Dates
using Random

"""
    run_rme(rme_path::String, n_threads::Int64, reps::Int64, result_path::String; start_year::Int64=2022, end_year::Int64=2099, batch_size::Int64=10, start_batch::Int64=1, RCP_scen::String="SSP 2.45", gcm::String="CNRM_ESM2_1", rnd_seed::Int64=1234)::Nothing

Run counterfactual scenarios with ReefModEngine.jl and save result set to desired directory.

# Arguments
- `rme_path` : Path to REM folder.
- `n_threads` : Number of threads to be used with RME.
- `reps` : Total number of repetitions to be run.
- `result_path` : Path to folder where resultset should be placed.
- `start_year` : RME run start year.
- `end_year` : RME run end year.
- `batch_size` : Number of repetitions to be run in each batch.
- `RCP_scen` : RCP scenario to be used for RME runs.
- `gcm` : GCM to be used for RME runs.
- `rnd_seed` : Random seed.
"""
function run_rme(
    reps::Int64,
    result_path::String;
    start_year::Int64=2022,
    end_year::Int64=2099,
    batch_size::Int64=10,
    RCP_scen::String="SSP 2.45",
    gcm::String="CNRM_ESM2_1",
    rnd_seed::Int64=1234
)::Nothing
    # Turn on use of a fixed seed value
    set_option("use_fixed_seed", 1)

    # Reset RME to clear any previous runs
    reset_rme()

    # Initialize result store
    result_store = ResultStore(start_year, end_year)
    rme_results_dir = _resultset_dir_name()

    # Use user selected seed to generate an array of seeds for each batch run
    rnd_seeds::Vector{Int64} = _rnd_seeds(rnd_seed, batch_size, reps)

    @info "Starting runs"
    @info "Batch sizes: $batch_size"
    for (batch_idx, batch_start) in enumerate(1:(batch_size):reps)
        _run_batch(
            batch_idx,
            batch_start,
            batch_size,
            reps,
            rnd_seeds[batch_idx],
            rme_results_dir,
            start_year,
            end_year,
            RCP_scen,
            gcm,
            result_store
        )
    end
    @info "Finished running all reps."

    result_path = joinpath(result_path, rme_results_dir)
    save_result_store(result_path, result_store)

    return nothing
end

"""
    run_batch(batch_idx::Int64, batch_start::Int64, batch_size::Int64, reps::Int64, rme_results_dir::String, start_year::Int64, end_year::Int64, RCP_scen::String, gcm::String, result_store)::Nothing

Run one batch of repetitions using RME.
"""
function _run_batch(
    batch_idx::Int64,
    batch_start::Int64,
    batch_size::Int64,
    reps::Int64,
    batch_seed::Int64,
    rme_results_dir::String,
    start_year::Int64,
    end_year::Int64,
    RCP_scen::String,
    gcm::String,
    result_store
)::Nothing
    batch_end = batch_start - 1 + batch_size
    batch_reps = if batch_end > reps
        reps - (batch_start - 1)
    else
        batch_size
    end

    @info "Starting batch $batch_idx"

    # Set distinct seed for each run
    set_option("fixed_seed", batch_seed) # Set the fixed seed value

    # Note: if Julia runtime crashes, check that specified data file location is correct
    @RME runCreate(
        rme_results_dir::Cstring,
        start_year::Cint,
        end_year::Cint,
        RCP_scen::Cstring,
        gcm::Cstring,
        batch_reps::Cint
    )::Cint

    # Initialize RME runs as defined above
    run_init()

    # Run all years and all reps
    @time @RME runProcess()::Cint

    # Collect and store results
    @info "Concatenating results of batch $batch_idx..."
    concat_results!(result_store, start_year, end_year, batch_reps)

    return nothing
end

function _rnd_seeds(rnd_seed::Int64, batch_size::Int64, reps::Int64)::Vector{Int64}
    Random.seed!(rnd_seed)
    n_seeds = Int(ceil(reps / batch_size))
    return Int.(floor.(rand(n_seeds) .* 1e6))
end

function _resultset_dir_name()::String
    timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
    return "rme_results_$(timestamp)"
end
