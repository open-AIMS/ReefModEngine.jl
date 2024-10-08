"""Methods to support Input/Output of data"""

using YAXArrays

"""
    DataCube(data::AbstractArray; kwargs...)::YAXArray

Constructor for YAXArray. When used with `axes_names`, the axes labels will be UnitRanges
from 1 up to that axis length.

# Arguments
- `data` : Array of data to be used when building the YAXArray
- `axes_names` :
"""
function DataCube(data::AbstractArray; kwargs...)::YAXArray
    return YAXArray(Tuple(Dim{name}(val) for (name, val) in kwargs), data)
end
function DataCube(data::AbstractArray, axes_names::Tuple)::YAXArray
    return DataCube(data; NamedTuple{axes_names}(1:len for len in size(data))...)
end
