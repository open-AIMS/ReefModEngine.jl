"""
Extension module to support saving to MAT format when the MAT.jl package is available.
"""

module MatExt

using Dates
using ReefModEngine
using MAT


"""
    save_to_mat(rs::ResultStore, fn::String)
    save_to_mat(rs::ResultStore)

Save results to MAT file following ReefMod Engine standard names.
If the filename is not provided, the default name will be "RME\\_outcomes\\_[today's date].mat"

# Arguments
- `rs` : ResultStore
- `fn` : File name to save to.
"""
function ReefModEngine.save_to_mat(rs::ResultStore, fn::String)
    all_res = ReefModEngine._extract_all_results(rs)

    # Save results to .mat file
    return matwrite(fn, all_res)
end
function ReefModEngine.save_to_mat(rs::ResultStore)
    ReefModEngine.save_to_mat(rs::ResultStore, "RME_outcomes_$(today()).mat")
end

end