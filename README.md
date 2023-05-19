# ReefModEngine.jl

A Julia interface to the ReefMod Engine (RME) C API.

Targets RME v1.0, and provides some convenience functions for outplanting interventions.
All other functions are accessible via the `@RME` macro.

At time of writing, the RME library and accompanying dataset has to be requested from RME developers.

## Usage example

```julia
using ReefModEngine


# Initialize RME (may take a minute or two)
rme_init("path to RME directory")
# [ Info: Loaded RME 1.0.18

# Set 1 thread
set_option("thread_count", 1)

# Load target intervention locations determined somehow (e.g., by ADRIA)
deploy_loc_details = CSV.read("target_locations.csv", DataFrame)


name = "Example"
start_year = 2022
end_year = 2099
RCP_scen = "SSP 2.45"
gcm = "CNRM_ESM2_1"
reps = 10
n_reefs = 3806

# TODO: Make this a convenience function
reef_id_list = String["" for _ in 1:n_reefs];
for i in 1:n_reefs
    reef_id_list[i] = @RME reefId(i::Cint)::Cstring
end

# Initialize result stores
results_ref = zeros((end_year - start_year) + 1, n_reefs, reps)
results_iv = zeros((end_year - start_year) + 1, n_reefs, reps)

# Temporary data store for results
y1 = zeros(n_reefs)
y2 = zeros(n_reefs)  

n_species = 6
species_ref = zeros((end_year - start_year) + 1, n_reefs, n_species, reps)
species_iv = zeros((end_year - start_year) + 1, n_reefs, n_species, reps)
sp_d1 = zeros(n_reefs)
sp_d2 = zeros(n_reefs)

target_reef_idx = deploy_loc_details.index_id
target_reef_ids = deploy_loc_details.reef_id
n_target_reefs = length(target_reef_idx)

# Get reef areas from RME
reef_areas = zeros(n_reefs)
@RME reefAreasKm2(reef_areas::Ptr{Cdouble}, n_reefs::Cint)::Cint

# Get list of areas for the target reefs
target_reef_areas_km² = reef_areas[target_reef_idx]
d_density_m² = 6.8  # coral seeding density (per m²)

@info "Starting runs"
for r in 1:reps
    @RME ivRemoveAll()::Cvoid
    @RME reefSetRemoveAll()::Cint

    # Note: if the Julia runtime crashes, check that the specified data file location is correct
    @RME runCreate(name::Cstring, start_year::Cint, end_year::Cint, RCP_scen::Cstring, gcm::Cstring, 1::Cint)::Cint
    set_option("restoration_dhw_tolerance_outplants", 3)

    # Create a reef set using the target reefs
    @RME reefSetAddFromIdList("iv_moore"::Cstring, target_reef_ids::Ptr{Cstring}, length(target_reef_ids)::Cint)::Cint

    # Deployments occur between 2025 2030
    # Year 1: 100,000 outplants; Year 2: 500,000; Year 3: 1,1M; Year 4: 1,1M; Year 5: 1,1M and Year 6: 1,1M.
    set_seeding_deployment("outplant_iv_2026", "iv_moore", 100_000, 2026, 2026, 1, target_reef_areas_km², d_density_m²)
    set_seeding_deployment("outplant_iv_2027", "iv_moore", 500_000, 2027, 2027, 1, target_reef_areas_km², d_density_m²)
    set_seeding_deployment("outplant_iv_2028_2031", "iv_moore", Int64(1.1 * 1e6), 2028, 2031, 1, target_reef_areas_km², d_density_m²)

    @RME runInit()::Cint

    # Run all years
    @time @RME runProcess()::Cint

    # Collect results
    for (i, yr) in enumerate(start_year:end_year)
        # "" : Can specify name of a reef set, or empty to indicate all reefs
        # 0 | 1 : without intervention; with intervention
        @RME runResults("coral_pct"::Cstring, ""::Cstring, 0::Cint, yr::Cint, y1::Ptr{Cdouble}, n_reefs::Cint)::Cint
        results_ref[i, :, r] = y1

        @RME runResults("coral_pct"::Cstring, ""::Cstring, 1::Cint, yr::Cint, y2::Ptr{Cdouble}, n_reefs::Cint)::Cint
        results_iv[i, :, r] = y2

        for sp in 1:n_species
            @RME runResults("species_$(sp)_pct"::Cstring, ""::Cstring, 0::Cint, yr::Cint, sp_d1::Ptr{Cdouble}, n_reefs::Cint)::Cint
            species_ref[i, :, sp, r] = sp_d1

            @RME runResults("species_$(sp)_pct"::Cstring, ""::Cstring, 1::Cint, yr::Cint, sp_d2::Ptr{Cdouble}, n_reefs::Cint)::Cint
            species_iv[i, :, sp, r] = sp_d2
        end
    end
end
```
