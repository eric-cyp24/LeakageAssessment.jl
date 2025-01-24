
### plotting functions ####

## NICV

"""
    plotNICV(nicvs, trace::AbstractVecOrMat; show::Bool=true, block::Bool=false, title="", ppc::Integer=0, kwargs...)

Plot normalized interclass variance
"""
function plotNICV(nicvs, trace::AbstractVecOrMat; show::Bool=true, block::Bool=false, title="", ppc::Integer=0, kwargs...)

    trace = trace isa AbstractMatrix ? vec(mean(trace, dims=2)) : trace
    p=plot()

    x      = ppc==0 ? (1:length(trace)) : (0:length(trace)-1)/ppc
    xlabel = ppc==0 ? "time sample"     : "clock cycle"

    # plot NICVs
    label  = nicvs isa Dict ? reshape(sort(collect(keys(nicvs))),1,length(nicvs)) : "" # row vector
    _nicvs = nicvs isa Dict ? stack([nicvs[l] for l in vec(label)])               : nicvs
    plot!(x, _nicvs; label, ylims=(-0.02,1.7), margin=8Plots.mm, xlabel, ylabel="Normalized Interclass Variance")
    plot!([]; linecolor=:blue, z_order=:back, label= nicvs isa Dict ? "power trace" : "") # phantom line for legend

    # plot power trace(s)
    lim = maximum(abs.(trace))*1.2
    plot!(twinx(), x, trace; ylims=(-5*lim, lim), ylabel="Voltage (V)", linecolor=:blue, label="")

    # swap z_order of two plot
    reverse!(p.subplots)
    p.subplots[1].attr[:background_color_inside] = :match
    p.subplots[2].attr[:background_color_inside] = RGBA{Float64}(0.0,0.0,0.0,0.0)
    plot!(;size=(1600,900), title, grid=false, framestyle=:semi, kwargs...)

    if show
        Base.invokelatest(display,p)
        if block
            print("Press Enter to continue...")
            readline()
        end
    end

    return p
end

## SNR

"""
    plotSNR(snrs, trace::AbstractVecOrMat; show::Bool=true, block::Bool=false, title="", ppc::Integer=0, kwargs...)

Plot signal to nosie ratio.
"""
function plotSNR(snrs, trace::AbstractVecOrMat; show::Bool=true, block::Bool=false, title="", ppc::Integer=0, kwargs...)

    trace = trace isa AbstractMatrix ? vec(mean(trace, dims=2)) : trace
    p=plot()

    x      = ppc==0 ? (1:length(trace)) : (0:length(trace)-1)/ppc
    xlabel = ppc==0 ? "time sample"   : "clock cycle"

    # plot SNRs
    label  = snrs isa Dict ? reshape(sort(collect(keys(snrs))),1,length(nicvs)) : ""
    _snrs  = snrs isa Dict ? stack([snrs[l] for l in vec(labels)]) : snrs
    plot(x, _snrs; label, ylims=(-0.02,maximum(snrs)*1.7), margin=8Plots.mm, xlabel, ylabel="Signal to Noise Ratio")
    plot!([]; linecolor=:blue, z_order=:back, label= nicvs isa Dict ? "power trace" : "")

    # plot power trace(s)
    lim = maximum(abs.(trace))*1.2
    plot!(twinx(), x, trace; ylims=(-5*lim, lim), yaxis="Voltage (V)", linecolor=:blue, label="")

    # swap z_order of two plot
    reverse!(p.subplots)
    p.subplots[1].attr[:background_color_inside] = :match
    p.subplots[2].attr[:background_color_inside] = RGBA{Float64}(0.0,0.0,0.0,0.0)
    plot!(;size=(1600,900), title, grid=false, framestyle=:semi, kwargs...)

    if show
        Base.invokelatest(display,p)
        if block
            print("Press Enter to continue...")
            readline()
        end
    end

    return p
end


### data read/write ####

"""
    loaddata(filename::AbstractString)

Load data from the given file name.
For .npy file, `loaddata` returns the native julia Fortran order NOT the Numpy/C order.
"""
function loaddata(filename::AbstractString; datapath=nothing)
    if !isfile(filename)
        error("$filename doesn't exist!!")
    else
        if split(filename, ".")[end] == "h5" && HDF5.ishdf5(filename)
            return h5open(filename) do f
                if isnothing(datapath)
                    return read(f, "data")
                else
                    dset = f[datapath]
                    # use memory mapping if the file is larger than 1GB
                    return length(dset) > 2^30 && HDF5.ismmappable(dset) ?
                           HDF5.readmmap(dset) : read(dset)
                end
            end
        elseif split(filename, ".")[end] == "npy" && isnpy(filename)
            # use memory mapping if the file is larger than 1GB
            return loadnpy(filename; memmap=filesize(filename)>2^30, numpy_order=false)
        else
            error("$filename is neither a .h5 nor a .npy file!!")
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


