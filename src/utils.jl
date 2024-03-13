
## plotting functions ####

### NICV

"""
    plotNICV(nicvs, trace::AbstractVecOrMat; show::Bool=true, pkg=:pythonplot)

Plot NICV
"""
function plotNICV(nicvs, trace::AbstractVecOrMat; show::Bool=true, backend="pyplot", block::Bool=true)

    if backend == :gr # recommended non-interactive plot method
        gr(); margin=8Plots.mm
    elseif backend == :pythonplot # not recommended on callas
        pythonplot(); margin=0.05Plots.mm
        # Warning: this is a dirty hack to make PythonPlot work on my computer (callas)
        # PythonPlot is unable to find "Qt5Agg" as an interactive backend
        # Hense use ENV["MPLBACKEND"]="TkAgg" to setup a interactive backend
        # The "TkAgg" plot is transparent, showing background onto the plot... maybe a bug in PythonPlot
        Plots.PythonPlot.matplotlib.use("Qt5Agg") # a python call to switch matplotlib to Qt5Agg backend
    elseif backend == "pyplot"
        return pyplotNICV(nicvs, trace; show)
    end

    trace = trace isa AbstractMatrix ? vec(mean(trace, dims=2)) : trace

    # plot NICVs
    label  = nicvs isa Dict ? sort(collect(keys(nicvs)))'      : "" # row vector
    _nicvs = nicvs isa Dict ? stack([nicvs[l] for l in label']) : nicvs
    plot(_nicvs; size=(1600,900), label, ylims=(-0.02,1.7), ticks=:native, margin,
                 xlabel="Time Sample", ylabel="Normalized Interclass Variance")
    
    # plot power trace(s)
    lim   = maximum(abs.(trace))*1.2
    p = plot!(twinx(), trace; ylims=(-5*lim, lim), ylabel="Voltage (V)", #ticks=:native,
                              linecolor=:blue, z_order=:back, label="")
    

    if show 
        Base.invokelatest(display,p)
        if backend == :pythonplot
            Plots.PythonPlot.plotshow() # plotshow() already block program until window closes.
        elseif block
            print("Press Enter to continue...")
            readline() 
        end
    end

    return p
end

# this function is written to work directly with PythonPlot package
# this is the prefered method for interactive plot
function pyplotNICV(nicvs, trace::AbstractVecOrMat; show::Bool=true)
    # Warning: this is a dirty hack to make PythonPlot work on my computer (callas)
    # PythonPlot is unable to find "Qt5Agg" as an interactive backend
    # That's why ENV["MPLBACKEND"]="TkAgg" is set in Leakageassessment.jl
    # this is basically a python call to tell matplotlib to switch backend to Qt5Agg
    plt.matplotlib.use("Qt5Agg") 
    
    trace = trace isa AbstractMatrix ? vec(mean(trace, dims=2)) : trace
    fig, ax1 = plt.subplots(figsize=(16,9))
 
    # plot power trace(s)
    ax2 = ax1.twinx()
    lim = maximum(abs.(trace))*1.2
    ax2.set_ylabel("Voltage (V)")
    ax2.set_ylim(-5*lim,lim)
    ax2.plot(trace, color="blue")
        
    # plot SNR
    ax1.set_zorder(ax2.get_zorder()+1)
    ax1.patch.set_visible(false)
    ax1.set_xlabel("Time Sample")
    ax1.set_ylabel("Normalized Interclass Variance")
    ax1.set_ylim(-0.02,1.7)
    
    if nicvs isa Dict
        ax1.plot([None],color="blue",label="power trace")
        for (name,nicv) in nicvs
            ax1.plot(nicv,label=name)
        end
        ax1.legend()
    else
        if ndims(nicvs) == 1
            nicvs = reshape(nicvs,length(nicvs),1)
        end
        for nicv in eachcol(nicvs)
            ax1.plot(nicv)
        end
    end
    
    plt.tight_layout()
    if show
        plt.show()
    end
    
    return fig
end

### SNR

"""
    plotSNR(snrs, trace; show=true, pkg="pyplot")

Plot signal to nosie ratio.
"""
function plotSNR(snrs, trace::AbstractVecOrMat; show::Bool=true, backend=:pythonplot)
    if backend == :gr
        gr(); margin=8Plots.mm
    elseif backend == :pythonplot
        pythonplot(); margin=0Plots.mm
        # Warning: this is a dirty hack to make PythonPlot work on my computer (callas)
        # PythonPlot is unable to find "Qt5Agg" as an interactive backend
        # Hense use ENV["MPLBACKEND"]="TkAgg" to setup a interactive backend
        # The "TkAgg" plot is transparent, showing background onto the plot... maybe a bug in PythonPlot
        Plots.PythonPlot.matplotlib.use("Qt5Agg") # a python call to switch matplotlib to Qt5Agg backend
    elseif backend == "pyplot"
        return pyplotSNR(snrs, trace; show)
    end

    trace = trace isa AbstractMatrix ? vec(mean(trace, dims=2)) : trace
    
    # plot SNRs
    labels = snrs isa Dict ? sort(collect(keys(snrs)))'       : ""
    _snrs  = snrs isa Dict ? stack([snrs[l] for l in labels']) : snrs
    plot(_snrs; size=(1600,900), label=labels, ylims=(-0.02,maximum(snrs)*1.7), margin,
                ticks=:native, xaxis="Time Sample", yaxis="Signal to Noise Ratio")
    
    # plot power trace(s)
    lim   = maximum(abs.(trace))*1.2
    p = plot!(twinx(), trace; ylims=(-5*lim, lim), yaxis="Voltage (V)", 
                              linecolor=:blue, z_order=:back, label="")
    
    if show 
        Base.invokelatest(display,p)
        if backend == :pythonplot
            Plots.PythonPlot.plotshow() # plotshow() already block program until window closes.
        elseif block
            print("Press Enter to continue...")
            readline() 
        end
    end
    
    return p
end

function pyplotSNR(snrs, trace::AbstractVecOrMat; show::Bool=true)
    # Warning: this is a dirty hack to make PythonPlot work on my computer (callas)
    # PythonPlot is unable to find "Qt5Agg" as an interactive backend
    # That's why ENV["MPLBACKEND"]="TkAgg" is set in Leakageassessment.jl
    # this is basically a python call to tell matplotlib to switch backend to Qt5Agg
    plt.matplotlib.use("Qt5Agg") 

    trace = trace isa AbstractMatrix ? vec(mean(trace, dims=2)) : trace
    fig, ax1 = plt.subplots(figsize=(16,9))
    
    # plot power trace(s)
    ax2 = ax1.twinx()
    lim = maximum(abs.(trace))*1.2
    ax2.set_ylabel("Voltage (V)")
    ax2.set_ylim(-5*lim,lim)
    ax2.plot(trace, color="blue")
        
    # plot SNR
    ax1.set_zorder(ax2.get_zorder()+1)
    ax1.patch.set_visible(false)
    ax1.set_xlabel("Time Sample")
    ax1.set_ylabel("Signal to Noise Ratio")
    lim = maximum(snrs)*1.7
    ax1.set_ylim(-0.02,lim)
    
    if snrs isa Dict
        ax1.plot([None],color="blue",label="power trace")
        for (name,snr) in snrs
            ax1.plot(snr,label=name)
        end
        ax1.legend()
    else
        if ndims(snrs) == 1
            snrs = reshape(snrs,length(snrs),1)
        end
        for snr in eachcol(snrs)
            ax1.plot(snr)
        end
    end
    
    plt.tight_layout()
    if show
        plt.show()
    end
    
    return fig
end


## data read/write ####

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


## useful leakage assessment helper functions ####

"""
    groupbyval(vals::AbstractVector; minsize=0)

Given `vals` a list of intermediate values, and return a dictionary of IVs => list_of_indices.
`minsize` sets the minimum length of each list, remove the one below `minsize`.
"""
function groupbyval(vals::AbstractVector; minsize=0)
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



