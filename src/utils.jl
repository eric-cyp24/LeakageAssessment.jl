
function loaddata(filename)
    # direct read for now... change to mmap later
    print("Loading data: $filename...                                      \r")
    if split(filename, ".")[end] == "hdf5"
        #TODO: load hdf5 format
        return nothing
    elseif split(filename, ".")[end] == "npy"
        return loadnpy(filename; memmap=filesize(filename)>1024^3, numpy_order=false)
    end
    println("Done!")
end

function groupbyval(vals ; minsize=0)
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

