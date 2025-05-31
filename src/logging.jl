"""
    log_set_all_items_enabled(enabled::Bool)

Enable or disable logging of all data items.
"""
function log_set_all_items_enabled(enabled::Bool)
    enable::Int64 = enabled ? 1 : 0
    @RME logSetAllItemsEnabled(enable::Int64)::Cvoid
end

"""
    log_set_item_enabled(name::String, enabled::Bool)

Enable or disable logging of specific data item.
"""
function log_set_item_enabled(name::String, enabled::Bool)
    enable::Int64 = enabled ? 1 : 0
    @RME logSetItemEnabled(name::Cstring, enable::Int64)::Cvoid
end

"""
    log_set_all_reefs_enabled(enabled::Bool)

Enable or disable logging for all reefs.
"""
function log_set_all_reefs_enabled(enabled::Bool)
    enable::Int64 = enabled ? 1 : 0
    @RME logSetAllReefsEnabled(enable::Int64)::Cvoid
end

"""
    log_set_reef_enabled(reef_index::Int, enabled::Bool)

Enable or disable logging for specific reef.
"""
function log_set_reef_enabled(reef_index::Int, enabled::Bool)
    enable::Int64 = enabled ? 1 : 0
    @RME logSetReefEnabled(reef_index::Cint, enable::Int64)::Cvoid
end

"""
    log_get_reef_data_ref(name::String, reef_index::Int, repeat::Int, iter::Int)

Get reef-level log data from reference run.
"""
function log_get_reef_data_ref(name::String, reef_index::Int, repeat::Int, iter::Int)::Vector{Float64}
    @RME logGetReefDataRef(name::Cstring, reef_index::Cint, repeat::Cint, iter::Cint)::Ptr{Cdouble}
end

"""
    log_get_reef_data_int(name::String, reef_index::Int, repeat::Int, iter::Int)

Get reef-level log data from intervention run.
"""
function log_get_reef_data_int(name::String, reef_index::Int, repeat::Int, iter::Int)::Vector{Float64}
    @RME logGetReefDataInt(name::Cstring, reef_index::Cint, repeat::Cint, iter::Cint)::Ptr{Cdouble}
end

"""
    log_get_run_data_ref(name::String, repeat::Int, iter::Int)

Get run-level log data from reference run.
"""
function log_get_run_data_ref(name::String, repeat::Int, iter::Int)::Vector{Float64}
    @RME logGetRunDataRef(name::Cstring, repeat::Cint, iter::Cint)::Ptr{Cdouble}
end

"""
    log_get_run_data_int(name::String, repeat::Int, iter::Int)

Get run-level log data from intervention run.
"""
function log_get_run_data_int(name::String, repeat::Int, iter::Int)::Vector{Float64}
    @RME logGetRunDataInt(name::Cstring, repeat::Cint, iter::Cint)::Ptr{Cdouble}
end
