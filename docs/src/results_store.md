# Results

Reefmod Engine Outputs and scenario information are recorded from the ReefMod Engine API
after each scenario(s) run, not before.

## ResultStore Struct

The results stores holds all model outputs from both counterfactuals and interventions.
Information about scenarios is stored in the scenario field of the result store.

Model inputs are stored in the`results` field of the store and contains the following
variables:

 - `total_cover`      ~ Total Coral Cover (% of total reef area)
 - `dhw`              ~ Degree Heating Weeks (°C weeks)
 - `dhw_mortality`    ~ DHW Mortality (% of population*)
 - `cyc_mortality`    ~ Cyclone Mortality (% of population*)
 - `cyc_cat`          ~ Cyclone Category
 - `cots`             ~ COTS Population (per ha)
 - `cots_mortality`   ~ Mortality caused by COTS (% of population*)
 - `total_taxa_cover` ~ Total Species Cover (% of total reef area)

*\* not formally confirmed*

## Usage

A side effect of the c++ API structure means that each intervention scenario must be
executed separately (**Intervention scenario** meaning a run with a specific intervention
strategy, not referring to runs with differing environmental inputs called repeats).

1. Before storing any results, create the results struct.
```julia
result_store = ResultStore(start_year, end_year)
```
2. Perform model run

```julia
...

# Initializing Run
@RME runInit()::Cint

# Starting Run
@RME runProcess()::Cint
```

3. Store results

`reps` is the number of repeats executed in the run.
```julia
concat_results!(result_store, start_year, end_year, reps)
```

## Saving Results

Results can be saved using `save_result_store`.
```julia
save_result_store(<result_store>, <dir_name>)
```

If no directory name is provided the results will be saved to a directory named
`RME_outcomes_yyyy-mm-dd-HH-MM-SS`.

The results directory will contain two files `results.nc` and `scenarios.csv`.

The NetCDF file contains all the model inputs and outputs described above and the scenarios
csv file details the intervention parameters used in the model runs and is in the same order
as the scenario dimension in the netcdf fie.

**Warning: If there is already a scenarios Dataframe in the directory being saved to it will
be overwritten**
