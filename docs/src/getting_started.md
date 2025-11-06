# Getting Started

## Setup

Currently, this package is not registered.

```bash
# Clone the repository
git clone https://github.com/open-AIMS/ReefModEngine.jl.git
cd ReefModEngine.jl

# Activate the project environment
julia --project=.
```

Then instantiate the project as usual to install dependencies.

```julia
] instantiate
```

## Testing

As RME is a separate initiative - request a copy from its maintainers/developers
at the University of Queensland - it cannot be included/bundled with ReefModEngine.jl.
Testing can therefore only be done locally, and is achieved by first defining the path as
an environment variable.

```bash
# For linux:

# Set the environment variable (replace with your actual path)
export RME_PATH="/path/to/your/rme/installation"
```

Or, in the Julia REPL:

```julia
ENV["RME_PATH"] = "/path/to/your/rme/installation"
```

Then initiate tests via the Package Manager:

```julia
] test
```

## Usage

Use of RME with ReefModEngine.jl requires the RME library to first be initialized.

```julia
# Initialize RME
init_rme("path to RME directory")
# [ Info: Loaded RME 1.0.42
```

::: info

[ADRIA](https://github.com/open-AIMS/ADRIA.jl) is able to run GBR-wide simulations with
[CoraBlox](https://github.com/open-AIMS/CoralBlox.jl), using RME datasets to represent the
GBR. Before doing so, however, a copy of the
[Canonical Reefs](https://github.com/gbrrestoration/canonical-reefs) geopackage must be
placed inside the `data_files/region` directory with the name `reefmod_gbr.gpkg`.

This is to aid in aligning the reef ids as used by ReefMod/RME with those used by
AIMS/ADRIA/GBRMPA.

:::

### RME Documentation

The full api interface is documented in the documentation provided with the binaries. The
file `rme_matlab_api_guide.pdf` find in `documents` subdirectory of the ReefModEngine files.
The documentation provides information on how runs are setup and how functions should be
used.

::: info

The Matlab API uses the same or similar names with different capitalisation/formatting
conventions. For example matlab may invoke `rme_init` where as the c++ api function name is
`rmeInit`. For complete clarity on function names and types consult the c++ header file
`rme_ml.h` in the `lib` subdirectory.

:::

## Interface

ReefModEngine.jl provides a few convenience functions to interact with RME.
All other RME functions are available for direct use via the `@RME` macro.
Care needs to be taken to call RME functions. Specifically:

- The exact types as expected by the RME function needs to be used.
- No protection is provided if mismatched types are used (e.g., passing in a Float instead of an Integer)

A full list of ReefModEngine.jl functions is provided in [API](@ref API).

## Short list of RME interface functions
Setting options. See [RME Options](@ref Setting-RME-options) for more information.
```julia
# Set RME options by its config name
# See RME documentation for list of available options
set_option("thread_count", 2)
set_option("restoration_dhw_tolerance_outplants", 3)
set_option("use_fixed_seed", 1)  # turn on use of a fixed seed value
set_option("fixed_seed", 123)  # set the fixed seed value

```
Helpers for setting up interventions.
```julia
# Get list of reef ids as specified by ReefMod Engine
reef_id_list = reef_ids()

# Retrieve list of reef areas in km² (in same order as reef ids)
reef_area_km² = reef_areas()

# Retrieve list of reef areas in km² for specified reefs by their ids
first_10_reef_area_km² = reef_areas(reef_id_list[1:10])

# Find the index position of a reef by its GBRMPA ID
match_id("10-330")
#  1

# Calculate the minimum area required (in km²) to deploy a number of corals
# at a given density
area_needed(100_000, 6.8)

```
Handling results. See [Results Store](@ref Results) for more information.
```julia
# Create a convenient result store to help extract data from RME
result_store = ResultStore(start_year, end_year)

# Collect and store all results, where `reps` is the total number of expected runs.
concat_results!(result_store, start_year, end_year, reps)

# Save results to a given location
save_result_store(result_store, path_to_save_location)
```
```julia
# Initialize RME runs
run_init()

# Reset RME, clearing all stored data and deployment configuration.
reset_rme()
```

If more runs are desired after running RME, it is required to first clear RME's state.

```julia
reset_rme()
```

## Example usage

Starting with a simple counterfactual run.

```julia
using ReefModEngine


# Initialize RME
init_rme("path to RME directory")
# [ Info: Loaded RME 1.0.44

set_option("thread_count", 4)  # Set to use four threads
set_option("use_fixed_seed", 1)  # Turn on use of a fixed seed value
set_option("fixed_seed", 123.0)  # Set the fixed seed value

# Get list of reef ids as specified by ReefMod Engine
reef_id_list = reef_ids()

name = "Example"       # Name to associate with this set of runs
start_year = 2022
end_year = 2099
RCP_scen = "SSP 2.45"  # RCP/SSP scenario to use
gcm = "CNRM_ESM2_1"    # The target Global Climate Model (GCM) to run
reps = 2               # Number of repeats: number of random environmental sequences to run
n_reefs = length(reef_id_list)

# Get reef areas from RME
reef_area_km² = reef_areas()

# Initialize result store
result_store = ResultStore(start_year, end_year)
# Reefs: 3806
# Range: 2022 to 2099 (78 years)
# Repeats: 0
# Total repeats with ref and iv: 0

@info "Starting runs"
reset_rme()  # Reset RME to clear any previous runs

# Note: if the Julia runtime crashes, check that the specified data file location is correct
@RME runCreate(
    name::Cstring,
    start_year::Cint,
    end_year::Cint,
    RCP_scen::Cstring,
    gcm::Cstring,
    reps::Cint
)::Cint

# Initialize RME runs as defined above
run_init()

# Run all years and all reps
@time @RME runProcess()::Cint

# Collect and store results
concat_results!(result_store, start_year, end_year, reps)

# Save results
# Recommend creating a specific directory for results as it outputs a set of three files
# a netCDF, a CSV, and a JSON file of metadata
mkdir("./example")
save_result_store("./example", result_store)
```

Run outplant interventions:

```julia
using ReefModEngine

# Initialize RME
init_rme("path to RME directory")
# [ Info: Loaded RME 1.0.44

set_option("thread_count", 2)  # Set to use two threads
set_option("use_fixed_seed", 1)  # Turn on use of a fixed seed value
set_option("fixed_seed", 123.0)  # Set the fixed seed value

# Get list of reef ids as specified by ReefMod Engine
reef_id_list = reef_ids()

# For this example, simulate target first reef for deployments
target_reef_ids = [reef_id_list[1]]

name = "Example"       # Name to associate with this set of runs
start_year = 2022
end_year = 2099
RCP_scen = "SSP 2.45"  # RCP/SSP scenario to use
gcm = "CNRM_ESM2_1"    # The base Global Climate Model (GCM)
reps = 2               # Number of repeats: number of random environmental sequences to run
n_reefs = length(reef_id_list)

# Get reef areas from RME
reef_area_km² = reef_areas()

# Get list of areas for the target reefs (by ID)
target_reef_areas_km² = reef_areas(target_reef_ids)

# Define coral outplanting density (per m²)
d_density_m² = 6.8

# Initialize result store
result_store = ResultStore(start_year, end_year)

@info "Starting runs"
reset_rme()  # Reset RME to clear any previous runs

# Note: if the Julia runtime crashes, check that the specified data file location is correct
@RME runCreate(
    name::Cstring,
    start_year::Cint,
    end_year::Cint,
    RCP_scen::Cstring,
    gcm::Cstring,
    reps::Cint
)::Cint

# Create a reef set using the target reefs
@RME reefSetAddFromIdList(
    "iv_example"::Cstring, target_reef_ids::Ptr{Cstring}, length(target_reef_ids)::Cint
)::Cint

# Deployments occur between 2025 2030
# Year 1: 100,000 outplants; Year 2: 500,000; Year 3: 1,1M; Year 4: 1,1M; Year 5: 1,1M and Year 6: 1,1M.
# set_outplant_deployment!("outplant_iv_2026", "iv_example", 100_000, 2026, target_reef_areas_km², d_density_m²)
# set_outplant_deployment!("outplant_iv_2027", "iv_example", 500_000, 2027, target_reef_areas_km², d_density_m²)

# Can also specify deployments to occur over a range of years
# set_outplant_deployment!("outplant_iv_2028_2031", "iv_example", Int64(1.1e6), Int64(1.1e6), 2028, 2031, 1, target_reef_areas_km², d_density_m²)

# If no deployment density is specified, ReefModEngine.jl will attempt to calculate the
# most appropriate density to maintain the specified grid size (defaulting to 10x10).
set_outplant_deployment!(
    "outplant_iv_2026", "iv_example", 100_000, 2026, target_reef_areas_km²
)
set_outplant_deployment!(
    "outplant_iv_2027", "iv_example", 500_000, 2027, target_reef_areas_km²
)
set_outplant_deployment!(
    "outplant_iv_2028_2031",
    "iv_example",
    Int64(1.1e6),
    2028,
    2031,
    1,
    target_reef_areas_km²
)

# Add 3 DHW enhancement to outplanted corals
# set_option("restoration_dhw_tolerance_outplants", 3)
# Note: This method of adding DHW tolerance was removed in v1.0.31

# For RME v1.0.44
# Specify the mean and stdev of heat tolerance
# Note: Can only be set after named interventions are defined
set_outplant_tolerance!("outplant_iv_2026", fill(3.0, 6), fill(0.25, 6))
set_outplant_tolerance!("outplant_iv_2027", fill(3.0, 6), fill(0.25, 6))
set_outplant_tolerance!("outplant_iv_2028_2031", fill(3.0, 6), fill(0.25, 6))

# Initialize RME runs as defined above
run_init()

# Run all years and all reps
@time @RME runProcess()::Cint

# Collect and store results
concat_results!(result_store, start_year, end_year, reps)

# Save results
# Recommend creating a specific directory for results as it outputs a set of three files
# a netCDF, a CSV, and a JSON file of metadata
mkdir("./example")
save_result_store("./example", result_store)
```

The RME stores all data in memory, so for larger number of replicates it may be better
to run each replicate individually and store results as they complete.

::: warning

ReefModEngine.jl's result store is currently memory-based, so the only advantage
to this approach currently is avoiding storing results when they are no longer necessary.
Efforts will be made to move to a disk-backed store.

:::

Similarly, if cell-level data is desired, RME requires that the simulations be run on a
year-by-year basis, with results extracted every time step.

::: info

TODO: Example of running RME on a year-by-year basis.

:::


```julia
name = "Example"       # Name to associate with this set of runs
start_year = 2022
end_year = 2099
RCP_scen = "SSP 2.45"  # RCP/SSP scenario to use
gcm = "CNRM_ESM2_1"    # The base Global Climate Model (GCM)
reps = 4               # Number of repeats: number of random environmental sequences to run
n_reefs = length(reef_id_list)

# Initialize result store
result_store = ResultStore(start_year, end_year)

set_option("use_fixed_seed", 1)  # Turn on use of a fixed seed value
set_option("fixed_seed", 123.0)  # Set the fixed seed value

@info "Starting runs"
for r in 1:reps
    reset_rme()  # Reset RME to clear any previous runs

    # Note: if the Julia runtime crashes, check that the specified data file location is correct
    @RME runCreate(name::Cstring, start_year::Cint, end_year::Cint, RCP_scen::Cstring, gcm::Cstring, 1::Cint)::Cint
    # Adding dhw tolerance was removed in v1.0.31
    # @RME setOption("restoration_dhw_tolerance_outplants"::Cstring, 3::Cint)::Cint

    # Create a reef set using the target reefs
    @RME reefSetAddFromIdList("iv_example"::Cstring, target_reef_ids::Ptr{Cstring}, length(target_reef_ids)::Cint)::Cint

    # Deployments occur between 2025 2030
    # Year 1: 100,000 outplants; Year 2: 500,000; Year 3: 1,1M; Year 4: 1,1M; Year 5: 1,1M and Year 6: 1,1M.
    set_seeding_deployment("outplant_iv_2026", "iv_example", 100_000, 2026, 2026, 1, target_reef_areas_km², d_density_m²)
    set_seeding_deployment("outplant_iv_2027", "iv_example", 500_000, 2027, 2027, 1, target_reef_areas_km², d_density_m²)
    set_seeding_deployment("outplant_iv_2028_2031", "iv_example", Int64(1.1 * 1e6), 2028, 2031, 1, target_reef_areas_km², d_density_m²)

    @RME runInit()::Cint

    # Run all years
    @time @RME runProcess()::Cint

    # Collect results for this specific replicate
    concat_results!(result_store, start_year, end_year, 1)
end

# Save results
# Recommend creating a specific directory for results as it outputs a set of three files
# a netCDF, a CSV, and a JSON file of metadata
mkdir("./example")
save_result_store("./example", result_store)
```
