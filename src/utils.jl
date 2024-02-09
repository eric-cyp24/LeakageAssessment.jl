
"""
    loaddata(filename::AbstractString)

Load data from the given file name.
For .npy file, `loaddata` returns the native julia Fortran order NOT the Numpy/C order.
"""
function loaddata(filename::AbstractString)
    # direct read for now... change to mmap later
    print("Loading data: $filename...                                      \r")
    if split(filename, ".")[end] == "hdf5"
        #TODO: load hdf5 format
        return nothing
    elseif split(filename, ".")[end] == "npy"
        # use memory mapping if the file is larger than 1GB
        return loadnpy(filename; memmap=filesize(filename)>1024^3, numpy_order=false)
    end
    println("Done!")
end

"""
    groupbyval(vals::AbstractArray; minsize=0)

Given `vals` a list of intermediate values, and return a dictionary of IVs => list_of_indices.
`minsize` sets the minimum length of each list, remove the one below `minsize`.
"""
function groupbyval(vals::AbstractArray; minsize=0)
    groupdict = Dict()
    for (idx, val) in enumerate(vals)
        try
            append!(groupdict[val],idx)
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
function isuniform(vals::AbstractVecOrMat)
    grouplens = [length(gl) for gl in values(groupbyval(vals))]
    return pvalue(ChisqTest(grouplens)) > 0.05
end

function isuniform(groupdict::Dict)
    grouplens = [length(gl) for gl in values(groupdict)]
    return pvalue(ChisqTest(grouplens)) > 0.05
end

"""
    sizecheck(vals::AbstractVecOrMat, traces::AbstractMatrix)

Check if length of `vals` matches the length of `traces`.
Throw `DimensionMismatch` if length doesn't match
Return the transposed matrices if the matching length is at dim=1
"""
function sizecheck(vals::AbstractVecOrMat, traces::AbstractMatrix)
    if ndims(vals) == 1
        traces = length(vals) == size(traces)[2] ? traces : transpose(traces)
        if length(vals) != size(traces)[2]
            msg = "vals length ($(length(vals))) doesn't match traces length ($(size(traces)[2]))"
            throw(DimensionMismatch(msg))
        end
    elseif ndims(vals) == 2
        if size(vals)[1] == size(traces)[1]
            vals, traces = transpose(vals), transpose(traces)
        end
        if size(vals)[2] != size(traces)[2]
            msg = "vals length ($(size(vals))) doesn't match traces length ($(size(traces)))"
            throw(DimensionMismatch(msg))
        end
    end
    return vals, traces
end



