
### data read/write ####

"""
    loaddata(filename::AbstractString; datapath="data")

Load data from the given file name.
"""
function loaddata(filename::AbstractString; datapath="data")
    if !isfile(filename)
        error("$filename doesn't exist!!")
    else
        if split(filename, ".")[end] == "h5" && HDF5.ishdf5(filename)
            return h5open(filename) do f
                dset = f[datapath]
                # use memory mapping if the file is larger than 1GB
                return length(dset) > 2^30 && HDF5.ismmappable(dset) ?
                       HDF5.readmmap(dset) : read(dset)
            end
        else
            error("$filename is not a .h5 file!!")
        end
    end
end


### useful leakage assessment helper functions ####

"""
    groupbyval(vals::AbstractVector; minsize=0)

Given `vals` a list of intermediate values, and return a dictionary of IVs => list_of_indices.
`minsize` sets the minimum length of each list, remove the one below `minsize`.
"""
function groupbyval(vals::AbstractVector; minsize=0)
    groupdict = Dict()
    for (idx, val) in enumerate(vals)
        try
            push!(groupdict[val],idx)
        catch KeyError
            groupdict[val] = [idx]
        end
    end
    if minsize > 0  # remove groups with small sample size
        for k in keys(groupdict)
            if length(groupdict[k]) < minsize
                delete!(groupdict, k)
            end
        end
    end
    return groupdict
end

"""
    isuniform(vals::AbstractVector)
    isuniform(groupdict::Dict)

Use the Chi-square test to check if the given intermediate values in `vals`
are uniformly distributed. The intermediate values in most crypto algorithms
are usually uniformly distributed.
"""
function isuniform(groupdict::Dict)
    grouplens = [length(gl) for gl in values(groupdict)]
    return pvalue(ChisqTest(grouplens)) > 0.05
end
function isuniform(vals::AbstractVecOrMat)
    return isuniform(groupbyval(vals))
end

"""
    sizecheck(vals::AbstractVecOrMat, traces::AbstractMatrix)

Check if length of `vals` matches the length of `traces`.
Throw `DimensionMismatch` if length doesn't match
Return the transposed matrices if the matching length is at dim=1
"""
function sizecheck(vals::AbstractVecOrMat, traces::AbstractMatrix)
    if ndims(vals) == 1
        traces = length(vals) == size(traces,2) ? traces : transpose(traces)
        if length(vals) != size(traces,2)
            msg = "vals length ($(length(vals))) doesn't match traces length ($(size(traces,2)))"
            throw(DimensionMismatch(msg))
        end
    elseif ndims(vals) == 2
        if size(vals,1) == size(traces,1)
            vals, traces = transpose(vals), transpose(traces)
        end
        if size(vals,2) != size(traces,2)
            msg = "vals length ($(size(vals))) doesn't match traces length ($(size(traces)))"
            throw(DimensionMismatch(msg))
        end
    end
    return vals, traces
end


