# Getting Started

## Preface

ReefMod is a coral ecology model developed at the University of Queensland (UQ) with more
than 20 years of development history. The original ReefMod model was written in MATLAB.
ReefMod has been ported to C++ to address issues and concerns around computational
efficiency. This port is referred to as the ReefMod Engine (RME).

This package, ReefModEngine.jl, provides a Julia interface to the RME, leveraging Julia's
first-class language interoperability support.

To avoid confusion, the following naming conventions are used when referring to each.

- The original MATLAB implementation is _always_ referred to as ReefMod.
- The C++ port, ReefMod Engine (RME), is referred to either as RME or its full name.
- This package, ReefModEngine.jl, is _always_ referred to by its full name.

::: info

This package does not implement ReefMod or ReefMod Engine. It is simply an interface to
allow its use in Julia.

A copy of the ReefMod Engine is available on request from its current developers at UQ.

:::

## Pre-initialization setup

Before using RME with ReefModEngine.jl, two changes must be done to the RME data files and
configuration.

1. A copy of the [Canonical Reefs](https://github.com/gbrrestoration/canonical-reefs)
   geopackage must be placed inside the `data_files/region` directory with the name
   `reefmod_gbr.gpkg`.

   This is to aid in aligning the reef ids as used by ReefMod/RME with those used by
   AIMS/ADRIA/GBRMPA.

2. Inside the `data_files/config` directory, there is a `config.xml` file.
   Make a backup of this file by making a copy of it.
   (e.g., naming it `_config.xml` or `original_config.xml`)

   Edit the `config.xml` file by removing all of the leading `../` from directory paths.
   (a simple "search and replace all" will suffice).

   The reason is that when used in MATLAB (the original intended use case for RME), the
   assumed initial start location is inside `data_files/config`. The leading `../` moves
   changes the directory up one level.

   ReefModEngine.jl on the other hand treats `data_files` as the initial library location,
   and so there is no need to move up one level.

## Initialization

Before anything can be done, the RME library has to first be initialized.

```julia
# Initialize RME (may take a minute or two)
init_rme("path to RME directory")
# [ Info: Loaded RME 1.0.28
```

## Setting RME options

RME is able to run multiple simulations at the same time via multi-threading.
The recommended value according to the RME documentation is a number equal to or less than
the number of available CPU cores.

```julia
# Set to use two threads
set_option("thread_count", 2)
```

::: tip

Do remember, however, that each process requires memory as well, so the total number of
threads should not exceed `ceil([available memory] / [memory required per thread])`.

The required memory depends on a number of factors including the represented grid size.
As a general indication, RME's memory use is ~4-5GB for a single run with a 10x10 grid.

:::

ReefModEngine.jl provides a few convenience functions to interact with RME.
All other RME functions are available for direct use via the `@RME` macro.
Care needs to be taken to call RME functions. Specifically:

- The exact types as expected by the RME function needs to be used.
- No protection is provided if mismatched types are used (e.g., passing in a Float instead of an Integer)

A full list of ReefModEngine.jl functions is provided in [API](@ref API).

## Short list of RME interface functions

```julia
# Set RME options by its config name
# See RME documentation for list of available options
set_option("thread_count", 2)
set_option("restoration_dhw_tolerance_outplants", 3)
set_option("use_fixed_seed", 1)  # turn on use of a fixed seed value
set_option("fixed_seed", 123)  # set the fixed seed value

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

# Create a convenient result store to help extract data from RME
result_store = ResultStore(start_year, end_year)

# Collect and store all results, where `reps` is the total number of expected runs.
concat_results!(result_store, start_year, end_year, reps)

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

```julia
using ReefModEngine
using CSV, DataFrames, MAT

# Initialize RME (may take a minute or two)
init_rme("path to RME directory")
# [ Info: Loaded RME 1.0.28

set_option("thread_count", 2)  # Set to use two threads
set_option("use_fixed_seed", 1)  # Turn on use of a fixed seed value
set_option("fixed_seed", 123.0)  # Set the fixed seed value

# Load target intervention locations determined somehow (e.g., by ADRIA)
# The first column is simply the row number.
# The second column is a list of target reef ids matching the format as found in
# the id list file (the file is found under `data_files/id` of the RME data set)
deploy_loc_details = CSV.read(
    "target_locations.csv",
    DataFrame,
    header=["index_id", "reef_id"],
    types=Dict(1=>Int64, 2=>String)  # Force values to be interpreted as expected types
)

# Reef indices and IDs
target_reef_idx = deploy_loc_details.index_id
target_reef_ids = deploy_loc_details.reef_id
n_target_reefs = length(target_reef_idx)

# Get list of reef ids as specified by ReefMod Engine
reef_id_list = reef_ids()

name = "Example"       # Name to associate with this set of runs
start_year = 2022
end_year = 2099
RCP_scen = "SSP 2.45"  # RCP/SSP scenario to use
gcm = "CNRM_ESM2_1"    # The base Global Climate Model (GCM)
reps = 2               # Number of repeats: number of random environmental sequences to run
n_reefs = length(reef_id_list)

# Get reef areas from RME
reef_area_km² = reef_areas()

# Get list of areas for the target reefs
target_reef_areas_km² = reef_areas(target_reef_ids)

# Define coral outplanting density (per m²)
d_density_m² = 6.8

# Initialize result store
result_store = ResultStore(start_year, end_year)
# Outputs:
# ReefModEngine Result Store
#
# Each store holds data for `:ref` and `:iv` across:
# 2022 to 2099 (78 years)
# For 2 repeats.
#
# cover : (78, 3806, 2)
# dhw : (78, 3806, 2)
# dhw_mortality : (78, 3806, 2)
# cyc_mortality : (78, 3806, 2)
# cyc_cat : (78, 3806, 2)
# cots : (78, 3806, 2)
# cots_mortality : (78, 3806, 2)
# species : (78, 3806, 6, 2)

@info "Starting runs"
reset_rme()  # Reset RME to clear any previous runs

# Note: if the Julia runtime crashes, check that the specified data file location is correct
@RME runCreate(name::Cstring, start_year::Cint, end_year::Cint, RCP_scen::Cstring, gcm::Cstring, reps::Cint)::Cint

# Add 3 DHW enhancement to outplanted corals
set_option("restoration_dhw_tolerance_outplants", 3)

# Create a reef set using the target reefs
@RME reefSetAddFromIdList("iv_example"::Cstring, target_reef_ids::Ptr{Cstring}, length(target_reef_ids)::Cint)::Cint

# Deployments occur between 2025 2030
# Year 1: 100,000 outplants; Year 2: 500,000; Year 3: 1,1M; Year 4: 1,1M; Year 5: 1,1M and Year 6: 1,1M.
# set_outplant_deployment!("outplant_iv_2026", "iv_example", 100_000, 2026, target_reef_areas_km², d_density_m²)
# set_outplant_deployment!("outplant_iv_2027", "iv_example", 500_000, 2027, target_reef_areas_km², d_density_m²)

# Can also specify deployments to occur over a range of years
# set_outplant_deployment!("outplant_iv_2028_2031", "iv_example", Int64(1.1e6), Int64(1.1e6), 2028, 2031, 1, target_reef_areas_km², d_density_m²)

# If no deployment density is specified, ReefModEngine.jl will attempt to calculate the
# most appropriate density to maintain the specified grid size (defaulting to 10x10).
set_outplant_deployment!("outplant_iv_2026", "iv_example", 100_000, 2026, target_reef_areas_km²)
set_outplant_deployment!("outplant_iv_2027", "iv_example", 500_000, 2027, target_reef_areas_km²)
set_outplant_deployment!("outplant_iv_2028_2031", "iv_example", Int64(1.1e6), 2028, 2031, 1, target_reef_areas_km²)

# Initialize RME runs as defined above
run_init()

# Run all years and all reps
@time @RME runProcess()::Cint

# Collect and store results
concat_results!(result_store, start_year, end_year, reps)

# Save results to matfile with entries (matching ReefMod Engine standard names)
# Defaults to "RME_outcomes_[today's date].mat"
# coral_cover_ref
# coral_cover_iv
# dhw_ref
# dhw_iv
# dhwloss_ref
# dhwloss_iv
# cyc_ref
# cyc_iv
# cyccat_ref
# cyccat_iv
# cots_ref
# cots_iv
# cotsloss_ref
# cotsloss_iv
# species_ref
# species_iv
# TODO: Save to result example
```

The RME stores all data in memory, so for larger number of replicates it may be better
to run each replicate individually and store results as they complete.

::: warning

ReefModEngine.jl's result store is currently memory-based as well, so the only advantage
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
    @RME setOption("restoration_dhw_tolerance_outplants"::Cstring, 3::Cint)::Cint

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
```
