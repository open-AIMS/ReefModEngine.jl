
# API {#API}
<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.DataCube-Tuple{AbstractArray}' href='#ReefModEngine.DataCube-Tuple{AbstractArray}'><span class="jlbinding">ReefModEngine.DataCube</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
DataCube(data::AbstractArray; kwargs...)::YAXArray
```


Constructor for YAXArray. When used with `axes_names`, the axes labels will be UnitRanges from 1 up to that axis length.

**Arguments**
- `data` : Array of data to be used when building the YAXArray
  
- `axes_names` :
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/io.jl#L5-L14" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.append_scenarios!-Tuple{ResultStore, Int64}' href='#ReefModEngine.append_scenarios!-Tuple{ResultStore, Int64}'><span class="jlbinding">ReefModEngine.append_scenarios!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
append_scenarios!(rs::ResultStore, reps::Int)::Nothing
```


Add rows to scenario dataframe in result store.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/ResultStore.jl#L285-L289" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.area_needed-Tuple{Int64, Union{Float64, Vector{Float64}}}' href='#ReefModEngine.area_needed-Tuple{Int64, Union{Float64, Vector{Float64}}}'><span class="jlbinding">ReefModEngine.area_needed</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
area_needed(n_corals::Int64, density::Union{Float64,Vector{Float64}})::Union{Vector{Float64},Float64}
```


Determine area (in km²) needed to deploy the given the number of corals at the specified density.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/interface.jl#L1-L5" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.concat_results!-Tuple{ResultStore, Int64, Int64, Int64}' href='#ReefModEngine.concat_results!-Tuple{ResultStore, Int64, Int64, Int64}'><span class="jlbinding">ReefModEngine.concat_results!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
concat_results!(rs::ResultStore, start_year::Int64, end_year::Int64, reps::Int64)::Nothing
```


Append results for all runs/replicates.

**Arguments**
- `rs` : Result store to save data to
  
- `start_year` : Collect data from this year
  
- `end_year` : Collect data to this year
  
- `reps` : Total number of expected replicates
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/ResultStore.jl#L465-L475" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.create_dataset-NTuple{4, Int64}' href='#ReefModEngine.create_dataset-NTuple{4, Int64}'><span class="jlbinding">ReefModEngine.create_dataset</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
create_dataset(start_year::Int, end_year::Int, n_reefs::Int, reps::Int)::Dataset
```


Preallocate and create dataset for result variables. Only constructed when the first results are collected.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/ResultStore.jl#L58-L63" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.deployment_area-Tuple{Int64, Int64, Union{Float64, Vector{Float64}}, Vector{Float64}}' href='#ReefModEngine.deployment_area-Tuple{Int64, Int64, Union{Float64, Vector{Float64}}, Vector{Float64}}'><span class="jlbinding">ReefModEngine.deployment_area</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
deployment_area(n_corals::Int64, max_n_corals::Int64, density::Union{Float64, Vector{Float64}}, target_areas::Vector{Float64})::Union{Tuple{Float64,Float64},Tuple{Float64,Vector{Float64}}}
```


Determine deployment area for the expected number of corals to be deployed.

**Arguments**
- `n_corals` : Number of corals,
  
- `max_n_corals` : Expected maximum deployment effort (total number of corals in intervention set)
  
- `density` : Stocking density per m². In RME versions higher than v1.0.28 density needs to be a vector   with each element representing the density per functional group
  
- `target_areas` : Available area at target location(s)
  

**Returns**

Tuple
- Percent area of deployment
  
- modified stocking density [currently no modifications are made]
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/deployment.jl#L1-L17" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.deployment_area-Tuple{Int64, Vector{Float64}}' href='#ReefModEngine.deployment_area-Tuple{Int64, Vector{Float64}}'><span class="jlbinding">ReefModEngine.deployment_area</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
deployment_area(max_n_corals::Int64, target_areas::Vector{Float64})::Union{Tuple{Float64,Float64}, Tuple{Float64,Vector{Float64}}}
```


Determine deployment area for given number of corals and target area, calculating the appropriate deployment density to maintain the specified grid size.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/deployment.jl#L57-L62" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.init_rme-Tuple{String}' href='#ReefModEngine.init_rme-Tuple{String}'><span class="jlbinding">ReefModEngine.init_rme</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
init_rme(rme_path::String)::Nothing
```


Initialize ReefMod Engine for use.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/rme_init.jl#L30-L34" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.match_id-Tuple{String}' href='#ReefModEngine.match_id-Tuple{String}'><span class="jlbinding">ReefModEngine.match_id</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
match_id(id::String)::Int64
match_ids(ids::Vector{String})::Vector{Int64}
```


Find matching index position for the given ID(s) according to ReefMod Engine&#39;s reef list.

**Note**

ReefMod Engine&#39;s reef list is in all upper case. The provided IDs are converted to upper case to ensure a match.

**Examples**

```julia
julia> reef_ids()
# 3806-element Vector{String}:
#  "10-330"
#  "10-331"
#  ⋮
#  "23-048"
#  "23-049"

julia> match_id("10-330")
#  1

julia> match_id("23-049")
#  3806

julia> match_ids(["23-048", "10-331"])
#  3805
#  2
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/interface.jl#L53-L85" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.n_corals_calculation-Tuple{Vector{Float64}, Vector{Float64}}' href='#ReefModEngine.n_corals_calculation-Tuple{Vector{Float64}, Vector{Float64}}'><span class="jlbinding">ReefModEngine.n_corals_calculation</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
n_corals_calculation(count_per_year::Float64, target_reef_area_km²::Vector{Float64})::Int64
```


Calculate total number of corals deployed in an intervention.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/ResultStore.jl#L268-L272" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.preallocate_concat!-Tuple{Any, Any, Any, Int64}' href='#ReefModEngine.preallocate_concat!-Tuple{Any, Any, Any, Int64}'><span class="jlbinding">ReefModEngine.preallocate_concat!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
preallocate_concat(rs, start_year, end_year, reps::Int64)::Nothing
```


Allocate additional memory before adding an additional result set. Result sets must have the same time frame.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/ResultStore.jl#L200-L205" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.reef_areas-Tuple{Any}' href='#ReefModEngine.reef_areas-Tuple{Any}'><span class="jlbinding">ReefModEngine.reef_areas</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
reef_areas(id_list)
```


Retrieve reef areas in km² for specified locations.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/interface.jl#L42-L46" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.reef_areas-Tuple{}' href='#ReefModEngine.reef_areas-Tuple{}'><span class="jlbinding">ReefModEngine.reef_areas</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
reef_areas()
```


Retrieve all reef areas in km²


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/interface.jl#L29-L33" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.reef_ids-Tuple{}' href='#ReefModEngine.reef_ids-Tuple{}'><span class="jlbinding">ReefModEngine.reef_ids</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
reef_ids()::Vector{String}
```


Get list of reef ids in the order expected by ReefMod Engine.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/interface.jl#L13-L17" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.reset_rme-Tuple{}' href='#ReefModEngine.reset_rme-Tuple{}'><span class="jlbinding">ReefModEngine.reset_rme</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
reset_rme()
```


Reset ReefModEngine, clearing any and all interventions and reef sets.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/rme_init.jl#L59-L63" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.rme_version_info-Tuple{}' href='#ReefModEngine.rme_version_info-Tuple{}'><span class="jlbinding">ReefModEngine.rme_version_info</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
rme_version_info()::@NamedTuple{major::Int64, minor::Int64, patch::Int64}
```


Get RME version


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/ReefModEngine.jl#L40-L44" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.run_init-Tuple{}' href='#ReefModEngine.run_init-Tuple{}'><span class="jlbinding">ReefModEngine.run_init</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
run_init()::Nothing
```


Convenience function to initialize RME runs.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/rme_init.jl#L90-L94" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.save_result_store-Tuple{String, ResultStore}' href='#ReefModEngine.save_result_store-Tuple{String, ResultStore}'><span class="jlbinding">ReefModEngine.save_result_store</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
save_result_store(dir_name::String, result_store::ResultStore)::Nothing
```


Save results to a netcdf file and a dataframe containing the scenario runs. Saved to the given directory. The directory is created if it does not exit.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/ResultStore.jl#L32-L37" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_enrichment_deployment!-Tuple{String, String, Int64, Int64, Int64, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}' href='#ReefModEngine.set_enrichment_deployment!-Tuple{String, String, Int64, Int64, Int64, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}'><span class="jlbinding">ReefModEngine.set_enrichment_deployment!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_enrichment_deployment!(name::String, reefset::String, n_larvae::Int64, max_effort::Int64, first_year::Int64, last_year::Int64, year_step::Int64, area_km2::Vector{Float64}, density::Float64)::Nothing
```


Set deployment for multiple years at a given frequency.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/deployment.jl#L266-L270" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_enrichment_deployment!-Tuple{String, String, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}' href='#ReefModEngine.set_enrichment_deployment!-Tuple{String, String, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}'><span class="jlbinding">ReefModEngine.set_enrichment_deployment!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_enrichment_deployment!(name::String, reefset::String, n_larvae::Int64, year::Int64, area_km2::Vector{Float64}, density::Float64)::Nothing
```


As `set_seeding_deployment()` but for larvae enrichment (also known as assisted migration). Set deployment for a single target year.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/deployment.jl#L247-L252" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_option-Tuple{String, Float64}' href='#ReefModEngine.set_option-Tuple{String, Float64}'><span class="jlbinding">ReefModEngine.set_option</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_option(opt::String, val::Float64)
set_option(opt::String, val::Int)
set_option(opt::String, val::String)
```


Set RME option.

See RME documentation for full list of available options.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/rme_init.jl#L71-L79" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_outplant_deployment!-Tuple{String, String, Int64, Int64, Int64, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}' href='#ReefModEngine.set_outplant_deployment!-Tuple{String, String, Int64, Int64, Int64, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}'><span class="jlbinding">ReefModEngine.set_outplant_deployment!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_outplant_deployment!(name::String, reefset::String, n_corals::Int64, max_effort::Int64, first_year::Int64, last_year::Int64, year_step::Int64, area_km2::Vector{Float64}, density::Union{Vector{Float64}, Float})::Nothing
```


Set outplanting deployments across a range of years.

**Arguments**
- `name` : Name to assign intervention event
  
- `reefset` : Name of pre-defined list of reefs to intervene on
  
- `n_corals` : Number of corals to outplant for a given year
  
- `max_effort` : Total number of corals to outplant
  
- `first_year` : First year to start interventions
  
- `last_year` : Final year of interventions
  
- `year_step` : Frequency of intervention (1 = every year, 2 = every second year, etc)
  
- `area_km2` : Intervention area [km²]
  
- `density` : Stocking density of intervention [corals / m²]
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/deployment.jl#L130-L145" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_outplant_deployment!-Tuple{String, String, Int64, Int64, Int64, Int64, Vector{Float64}}' href='#ReefModEngine.set_outplant_deployment!-Tuple{String, String, Int64, Int64, Int64, Int64, Vector{Float64}}'><span class="jlbinding">ReefModEngine.set_outplant_deployment!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_outplant_deployment!(name::String, reefset::String, max_effort::Int64, first_year::Int64, last_year::Int64, year_step::Int64, area_km2::Vector{Float64})::Nothing
```


Set outplanting deployments across a range of years, automatically determining the coral deployment density to maintain the set grid size.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/deployment.jl#L206-L211" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_outplant_deployment!-Tuple{String, String, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}' href='#ReefModEngine.set_outplant_deployment!-Tuple{String, String, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}'><span class="jlbinding">ReefModEngine.set_outplant_deployment!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_outplant_deployment!(name::String, reefset::String, n_corals::Int64, year::Int64, area_km2::Vector{Float64}, density::Union{Float64, Vector{Float64}})::Nothing
```


Set outplanting deployments for a single year.

**Arguments**
- `name` : Name to assign intervention event
  
- `reefset` : Name of pre-defined list of reefs to intervene on
  
- `n_corals` : Number of corals to outplant
  
- `year` : Year to intervene
  
- `area_km2` : Area to intervene [km²]
  
- `density` : Stocking density of intervention [corals / m²]
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/deployment.jl#L104-L116" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_outplant_deployment!-Tuple{String, String, Int64, Int64, Vector{Float64}}' href='#ReefModEngine.set_outplant_deployment!-Tuple{String, String, Int64, Int64, Vector{Float64}}'><span class="jlbinding">ReefModEngine.set_outplant_deployment!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_outplant_deployment!(name::String, reefset::String, n_corals::Int64, year::Int64, area_km2::Vector{Float64})::Nothing
```


Set outplanting deployments for a single year, automatically determining the coral deployment density to maintain the set grid size.

**Arguments**
- `name` : Name to assign intervention event
  
- `reefset` : Name of pre-defined list of reefs to intervene on
  
- `n_corals` : Number of corals to outplant
  
- `year` : Year to intervene
  
- `area_km2` : Area to intervene [km²]
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/deployment.jl#L183-L195" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.@getRME-Tuple{Any}' href='#ReefModEngine.@getRME-Tuple{Any}'><span class="jlbinding">ReefModEngine.@getRME</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



Only for use when RME functions return non-error numeric results.

**Examples**

```julia
count_per_m2::Float64 = @getRME ivOutplantCountPerM2("iv_name"::Cstring)::Cdouble
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5ecdbc53af11682e5074acc2fd9828e72c535f70/src/ReefModEngine.jl#L27-L35" target="_blank" rel="noreferrer">source</a></Badge>

</details>

