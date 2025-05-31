
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
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/io.jl#L5-L14" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine._check_deprecated_options-Tuple{String}' href='#ReefModEngine._check_deprecated_options-Tuple{String}'><span class="jlbinding">ReefModEngine._check_deprecated_options</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
_check_deprecated_options(opt::String)::String
```


Checks option string and updates to latest (renamed) equivalent.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/rme_init.jl#L76-L80" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.append_scenarios!-Tuple{ResultStore, Int64}' href='#ReefModEngine.append_scenarios!-Tuple{ResultStore, Int64}'><span class="jlbinding">ReefModEngine.append_scenarios!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
append_scenarios!(rs::ResultStore, reps::Int)::Nothing
```


Add rows to scenario dataframe in result store.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/ResultStore.jl#L286-L290" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.area_needed-Tuple{Int64, Union{Float64, Vector{Float64}}}' href='#ReefModEngine.area_needed-Tuple{Int64, Union{Float64, Vector{Float64}}}'><span class="jlbinding">ReefModEngine.area_needed</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
area_needed(n_corals::Int64, density::Union{Float64,Vector{Float64}})::Union{Vector{Float64},Float64}
```


Determine area (in km²) needed to deploy the given the number of corals at the specified density.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/interface.jl#L1-L5" target="_blank" rel="noreferrer">source</a></Badge>

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
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/ResultStore.jl#L466-L476" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.create_dataset-NTuple{4, Int64}' href='#ReefModEngine.create_dataset-NTuple{4, Int64}'><span class="jlbinding">ReefModEngine.create_dataset</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
create_dataset(start_year::Int, end_year::Int, n_reefs::Int, reps::Int)::Dataset
```


Preallocate and create dataset for result variables. Only constructed when the first results are collected.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/ResultStore.jl#L59-L64" target="_blank" rel="noreferrer">source</a></Badge>

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
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/deployment.jl#L1-L17" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.deployment_area-Tuple{Int64, Vector{Float64}}' href='#ReefModEngine.deployment_area-Tuple{Int64, Vector{Float64}}'><span class="jlbinding">ReefModEngine.deployment_area</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
deployment_area(max_n_corals::Int64, target_areas::Vector{Float64})::Union{Tuple{Float64,Float64}, Tuple{Float64,Vector{Float64}}}
```


Determine deployment area for given number of corals and target area, calculating the appropriate deployment density to maintain the specified grid size.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/deployment.jl#L57-L62" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.get_iv_param-Tuple{String, String}' href='#ReefModEngine.get_iv_param-Tuple{String, String}'><span class="jlbinding">ReefModEngine.get_iv_param</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
get_iv_param(iv_name::String, param_name::String)
```


Return the current value of a parameter of an intervention.

Returns parameter `param_name` of intervention `iv_name`. The returned value can either be a number or text depending on the type of parameter. If the intervention does not exist, parameter is not recognized, or value is of the wrong type, an error will be thrown.

Currently supported values for `param_name` are:
- `"second_rs"`: Secondary reef set name or empty string
  
- `"hours"`: Number of hours effort
  
- `"rank_data_code1"`: Data code to rank by or &quot;none&quot;
  
- `"rank_data_code2"`: Data code to rank by or &quot;none&quot;
  
- `"rank_weight1"`: Weight for first rank data (0-1)
  
- `"rank_weight2"`: Weight for second rank data (0-1)
  

**Examples**

```julia hours = get_iv_param(&quot;my_intervention&quot;, &quot;hours&quot;)          # Returns Float64 reef_set = get_iv_param(&quot;my_intervention&quot;, &quot;second_rs&quot;)   # Returns String


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/interface.jl#L137-L159" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.get_param-Tuple{String}' href='#ReefModEngine.get_param-Tuple{String}'><span class="jlbinding">ReefModEngine.get_param</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
get_param(name::String)::Union{Float64,Vector{Float64}}
```


Return the current value(s) of an RME parameter.

The returned value will be a vector of length 1 or greater.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/interface.jl#L187-L193" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.init_rme-Tuple{String}' href='#ReefModEngine.init_rme-Tuple{String}'><span class="jlbinding">ReefModEngine.init_rme</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
init_rme(rme_path::String)::Nothing
```


Initialize ReefMod Engine for use.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/rme_init.jl#L35-L39" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.iv_add-Tuple{String, String, String, Int64, Int64, Int64, Float64, Union{Float64, Vector{Float64}}}' href='#ReefModEngine.iv_add-Tuple{String, String, String, Int64, Int64, Int64, Float64, Union{Float64, Vector{Float64}}}'><span class="jlbinding">ReefModEngine.iv_add</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
iv_add(name::String, type::String, reef_set::String, first_year::Int, last_year::Int, year_step::Int, area_pct::Float64, count_per_m2::Union{Float64, Vector{Float64}})
```


Add an outplant or enrich intervention with deployment parameters.

**Additional Arguments for &quot;outplant&quot; and &quot;enrich&quot; types**
- `area_pct`: Percentage of reef area where restoration will occur
  
- `count_per_m2`: Corals to add per m² (scalar or 6-element vector for each species)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/intervention.jl#L43-L51" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.iv_add-Tuple{String, String, String, Int64, Int64, Int64}' href='#ReefModEngine.iv_add-Tuple{String, String, String, Int64, Int64, Int64}'><span class="jlbinding">ReefModEngine.iv_add</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
iv_add(name::String, type::String, reef_set::String, first_year::Int, last_year::Int, year_step::Int)
```


Add an intervention to the current run.

**Arguments**
- `name`: Name of the intervention (must be unique)
  
- `type`: Type of intervention (see types below)
  
- `reef_set`: Name of reef set to apply intervention to
  
- `first_year`: First year intervention will be applied
  
- `last_year`: Last year intervention will be applied
  
- `year_step`: Frequency (1=every year, 2=every other year, etc.)
  

**Intervention Types**
- `cots_control`: CSIRO method CoTS control algorithm
  
- `cots_control_basic`: Original CoTS control method
  
- `prevent_anchoring`: Not implemented (no effect)
  
- `prevent_herbivore_exploitation`: Prevent herbivore exploitation
  
- `stabilise`: Rubble stabilization
  
- `outplant`: Coral outplanting (requires additional parameters)
  
- `enrich`: Larval enrichment (requires additional parameters)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/intervention.jl#L3-L24" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.log_get_reef_data_int-Tuple{String, Int64, Int64, Int64}' href='#ReefModEngine.log_get_reef_data_int-Tuple{String, Int64, Int64, Int64}'><span class="jlbinding">ReefModEngine.log_get_reef_data_int</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
log_get_reef_data_int(name::String, reef_index::Int, repeat::Int, iter::Int)
```


Get reef-level log data from intervention run.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/logging.jl#L50-L54" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.log_get_reef_data_ref-Tuple{String, Int64, Int64, Int64}' href='#ReefModEngine.log_get_reef_data_ref-Tuple{String, Int64, Int64, Int64}'><span class="jlbinding">ReefModEngine.log_get_reef_data_ref</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
log_get_reef_data_ref(name::String, reef_index::Int, repeat::Int, iter::Int)
```


Get reef-level log data from reference run.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/logging.jl#L41-L45" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.log_get_run_data_int-Tuple{String, Int64, Int64}' href='#ReefModEngine.log_get_run_data_int-Tuple{String, Int64, Int64}'><span class="jlbinding">ReefModEngine.log_get_run_data_int</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
log_get_run_data_int(name::String, repeat::Int, iter::Int)
```


Get run-level log data from intervention run.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/logging.jl#L68-L72" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.log_get_run_data_ref-Tuple{String, Int64, Int64}' href='#ReefModEngine.log_get_run_data_ref-Tuple{String, Int64, Int64}'><span class="jlbinding">ReefModEngine.log_get_run_data_ref</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
log_get_run_data_ref(name::String, repeat::Int, iter::Int)
```


Get run-level log data from reference run.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/logging.jl#L59-L63" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.log_set_all_items_enabled-Tuple{Bool}' href='#ReefModEngine.log_set_all_items_enabled-Tuple{Bool}'><span class="jlbinding">ReefModEngine.log_set_all_items_enabled</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
log_set_all_items_enabled(enabled::Bool)
```


Enable or disable logging of all data items.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/logging.jl#L1-L5" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.log_set_all_reefs_enabled-Tuple{Bool}' href='#ReefModEngine.log_set_all_reefs_enabled-Tuple{Bool}'><span class="jlbinding">ReefModEngine.log_set_all_reefs_enabled</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
log_set_all_reefs_enabled(enabled::Bool)
```


Enable or disable logging for all reefs.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/logging.jl#L21-L25" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.log_set_item_enabled-Tuple{String, Bool}' href='#ReefModEngine.log_set_item_enabled-Tuple{String, Bool}'><span class="jlbinding">ReefModEngine.log_set_item_enabled</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
log_set_item_enabled(name::String, enabled::Bool)
```


Enable or disable logging of specific data item.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/logging.jl#L11-L15" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.log_set_reef_enabled-Tuple{Int64, Bool}' href='#ReefModEngine.log_set_reef_enabled-Tuple{Int64, Bool}'><span class="jlbinding">ReefModEngine.log_set_reef_enabled</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
log_set_reef_enabled(reef_index::Int, enabled::Bool)
```


Enable or disable logging for specific reef.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/logging.jl#L31-L35" target="_blank" rel="noreferrer">source</a></Badge>

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



<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/interface.jl#L53-L85" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.n_corals_calculation-Tuple{Vector{Float64}, Vector{Float64}}' href='#ReefModEngine.n_corals_calculation-Tuple{Vector{Float64}, Vector{Float64}}'><span class="jlbinding">ReefModEngine.n_corals_calculation</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
n_corals_calculation(count_per_year::Float64, target_reef_area_km²::Vector{Float64})::Int64
```


Calculate total number of corals deployed in an intervention.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/ResultStore.jl#L269-L273" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.preallocate_concat!-Tuple{Any, Any, Any, Int64}' href='#ReefModEngine.preallocate_concat!-Tuple{Any, Any, Any, Int64}'><span class="jlbinding">ReefModEngine.preallocate_concat!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
preallocate_concat(rs, start_year, end_year, reps::Int64)::Nothing
```


Allocate additional memory before adding an additional result set. Result sets must have the same time frame.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/ResultStore.jl#L201-L206" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.reef_areas-Tuple{Any}' href='#ReefModEngine.reef_areas-Tuple{Any}'><span class="jlbinding">ReefModEngine.reef_areas</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
reef_areas(id_list)
```


Retrieve reef areas in km² for specified locations.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/interface.jl#L42-L46" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.reef_areas-Tuple{}' href='#ReefModEngine.reef_areas-Tuple{}'><span class="jlbinding">ReefModEngine.reef_areas</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
reef_areas()
```


Retrieve all reef areas in km²


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/interface.jl#L29-L33" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.reef_ids-Tuple{}' href='#ReefModEngine.reef_ids-Tuple{}'><span class="jlbinding">ReefModEngine.reef_ids</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
reef_ids()::Vector{String}
```


Get list of reef ids in the order expected by ReefMod Engine.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/interface.jl#L13-L17" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.reset_rme-Tuple{}' href='#ReefModEngine.reset_rme-Tuple{}'><span class="jlbinding">ReefModEngine.reset_rme</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
reset_rme()
```


Reset ReefModEngine, clearing any and all interventions and reef sets.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/rme_init.jl#L63-L67" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.rme_version_info-Tuple{}' href='#ReefModEngine.rme_version_info-Tuple{}'><span class="jlbinding">ReefModEngine.rme_version_info</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
rme_version_info()::VersionNumber
```


Get RME version.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/ReefModEngine.jl#L40-L44" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.run_init-Tuple{}' href='#ReefModEngine.run_init-Tuple{}'><span class="jlbinding">ReefModEngine.run_init</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
run_init()::Nothing
```


Convenience function to initialize RME runs.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/rme_init.jl#L113-L117" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.save_result_store-Tuple{String, ResultStore}' href='#ReefModEngine.save_result_store-Tuple{String, ResultStore}'><span class="jlbinding">ReefModEngine.save_result_store</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
save_result_store(dir_name::String, result_store::ResultStore)::Nothing
```


Save results to a netcdf file and a dataframe containing the scenario runs. Saved to the given directory. The directory is created if it does not exit.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/ResultStore.jl#L32-L37" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_enrichment_deployment!-Tuple{String, String, Int64, Int64, Int64, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}' href='#ReefModEngine.set_enrichment_deployment!-Tuple{String, String, Int64, Int64, Int64, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}'><span class="jlbinding">ReefModEngine.set_enrichment_deployment!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_enrichment_deployment!(name::String, reefset::String, n_larvae::Int64, max_effort::Int64, first_year::Int64, last_year::Int64, year_step::Int64, area_km2::Vector{Float64}, density::Float64)::Nothing
```


Set deployment for multiple years at a given frequency.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/deployment.jl#L266-L270" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_enrichment_deployment!-Tuple{String, String, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}' href='#ReefModEngine.set_enrichment_deployment!-Tuple{String, String, Int64, Int64, Vector{Float64}, Union{Float64, Vector{Float64}}}'><span class="jlbinding">ReefModEngine.set_enrichment_deployment!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_enrichment_deployment!(name::String, reefset::String, n_larvae::Int64, year::Int64, area_km2::Vector{Float64}, density::Float64)::Nothing
```


As `set_seeding_deployment()` but for larvae enrichment (also known as assisted migration). Set deployment for a single target year.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/deployment.jl#L247-L252" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_iv_param-Tuple{String, Float64}' href='#ReefModEngine.set_iv_param-Tuple{String, Float64}'><span class="jlbinding">ReefModEngine.set_iv_param</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_iv_param(name::String, value::Union{Float64, Int64})::Nothing
set_iv_param(name::String, value::Vector{Float64})::Nothing
set_iv_param(name::String, value::String)::Nothing
set_iv_param(iv_name::String, param_name::String, value::String)::Nothing
set_iv_param(iv_name::String, param_name::String, value::Union{Float64, Int64})::Nothing
```


Set RME intervention parameter by name.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/interface.jl#L96-L104" target="_blank" rel="noreferrer">source</a></Badge>

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


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/rme_init.jl#L93-L101" target="_blank" rel="noreferrer">source</a></Badge>

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
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/deployment.jl#L130-L145" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.set_outplant_deployment!-Tuple{String, String, Int64, Int64, Int64, Int64, Vector{Float64}}' href='#ReefModEngine.set_outplant_deployment!-Tuple{String, String, Int64, Int64, Int64, Int64, Vector{Float64}}'><span class="jlbinding">ReefModEngine.set_outplant_deployment!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
set_outplant_deployment!(name::String, reefset::String, max_effort::Int64, first_year::Int64, last_year::Int64, year_step::Int64, area_km2::Vector{Float64})::Nothing
```


Set outplanting deployments across a range of years, automatically determining the coral deployment density to maintain the set grid size.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/deployment.jl#L206-L211" target="_blank" rel="noreferrer">source</a></Badge>

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
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/deployment.jl#L104-L116" target="_blank" rel="noreferrer">source</a></Badge>

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
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/deployment.jl#L183-L195" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='ReefModEngine.@getRME-Tuple{Any}' href='#ReefModEngine.@getRME-Tuple{Any}'><span class="jlbinding">ReefModEngine.@getRME</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



Only for use when RME functions return numeric results that are not error codes.

**Examples**

```julia
count_per_m2::Float64 = @getRME ivOutplantCountPerM2("iv_name"::Cstring)::Cdouble
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/open-AIMS/ReefModEngine.jl/blob/5e0af4083db90a573a7184b60de4a6e5705e4f28/src/ReefModEngine.jl#L27-L35" target="_blank" rel="noreferrer">source</a></Badge>

</details>

