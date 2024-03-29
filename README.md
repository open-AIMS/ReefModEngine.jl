# ReefModEngine.jl

A Julia interface to the ReefMod Engine (RME) C API.

Targets RME v1.0, and provides some convenience functions for outplanting interventions.
All other functions are accessible via the `@RME` macro.

The RME library, accompanying dataset, and RME documentation has to be requested from RME developers.

## Usage example

```julia
using ReefModEngine
using CSV, DataFrames, MAT

# Initialize RME (may take a minute or two)
init_rme("path to RME directory")
# [ Info: Loaded RME 1.0.28

# Set to use two threads
set_option("thread_count", 2)

# Load target intervention locations determined somehow (e.g., by ADRIA)
# The first column is simply the row number.
# The second column is a list of target reef ids matching the format as found in
# the id list file (the file is found under `data_files/id` of the RME data set)
deploy_loc_details = CSV.read("target_locations.csv", DataFrame, header=["index_id", "reef_id"])

name = "Example"
start_year = 2022
end_year = 2099
RCP_scen = "SSP 2.45"
gcm = "CNRM_ESM2_1"
reps = 2
n_reefs = 3806

# TODO: Make this a convenience function
reef_id_list = fill("", n_reefs);
for i in 1:n_reefs
    reef_id_list[i] = @RME reefId(i::Cint)::Cstring
end

# Reef indices and IDs
target_reef_idx = deploy_loc_details.index_id
target_reef_ids = deploy_loc_details.reef_id
n_target_reefs = length(target_reef_idx)

# Get reef areas from RME
reef_areas = zeros(n_reefs)
@RME reefAreasKm2(reef_areas::Ptr{Cdouble}, n_reefs::Cint)::Cint

# Get list of areas for the target reefs
target_reef_areas_km² = reef_areas[target_reef_idx]
d_density_m² = 6.8  # coral seeding density (per m²)

# Initialize result store
result_store = ResultStore(start_year, end_year, n_reefs, reps)
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
@RME ivRemoveAll()::Cvoid
@RME reefSetRemoveAll()::Cint

# Note: if the Julia runtime crashes, check that the specified data file location is correct
@RME runCreate(name::Cstring, start_year::Cint, end_year::Cint, RCP_scen::Cstring, gcm::Cstring, reps::Cint)::Cint

# Add 3 DHW enhancement to outplanted corals
set_option("restoration_dhw_tolerance_outplants", 3)

# Create a reef set using the target reefs
@RME reefSetAddFromIdList("iv_moore"::Cstring, target_reef_ids::Ptr{Cstring}, length(target_reef_ids)::Cint)::Cint

# Deployments occur between 2025 2030
# Year 1: 100,000 outplants; Year 2: 500,000; Year 3: 1,1M; Year 4: 1,1M; Year 5: 1,1M and Year 6: 1,1M.
set_outplant_deployment!("outplant_iv_2026", "iv_moore", 100_000, 2026, target_reef_areas_km², d_density_m²)
set_outplant_deployment!("outplant_iv_2027", "iv_moore", 500_000, 2027, target_reef_areas_km², d_density_m²)
set_outplant_deployment!("outplant_iv_2028_2031", "iv_moore", Int64(1.1 * 1e6), Int64(1.1 * 1e6)*3, 2028, 2031, 1, target_reef_areas_km², d_density_m²)

@RME runInit()::Cint

# Run all years and all reps
@time @RME runProcess()::Cint

# Collect and store results
collect_all_results!(result_store, start_year, end_year, reps)

# Save results to matfile with entries (matching ReefMod Engine standard names)
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
save_to_mat(result_store)
```
