
### NICV

function SNR2NICV(snr)
    return replace!(1.0 ./ (1.0 .+ 1.0 ./ snr), NaN=>0.0)
end

function computenicv_mthread(vals::AbstractVector, traces)
    groupdict = groupbyval(vals)
    groups    = collect(values(groupdict))
    groupExp  = Matrix{eltype(traces)}(undef, size(traces)[1], length(groups))
    @sync Threads.@threads for i in 1:length(groups)
        groupExp[:,i] = mean(view(traces,:,groups[i]),dims=2)
    end
    if isuniform(groupdict)
        return replace!(vec(var(groupExp;dims=2) ./ var(traces;dims=2)), NaN=>0.0)
    else
        # use weighted variance if non-uniform
        w = FrequencyWeights([length(g) for g in groups])
        return replace!(vec(var(groupExp,w,2;corrected=true) ./ var(traces;dims=2)), NaN=>0.0)
    end
end

function computenicv(vals::AbstractVector, traces)
    groupdict = groupbyval(vals)
    groups    = collect(values(groupdict))
    groupExp  = stack([vec(mean(view(traces,:,g),dims=2)) for g in groups])
    return replace!(vec(var(groupExp;dims=2) ./ var(traces;dims=2)), NaN=>0.0)
    if isuniform(groupdict)
        return replace!(vec(var(groupExp;dims=2) ./ var(traces;dims=2)), NaN=>0.0)
    else
        # use weighted variance if non-uniform
        w = FrequencyWeights([length(g) for g in groups])
        return replace!(vec(var(groupExp,w,2;corrected=true) ./ var(traces;dims=2)), NaN=>0.0)
    end
end

"""
    NICV(vals::AbstractVector, traces::AbstractMatrix)
    NICV(vals::AbstractMatrix, traces::AbstractMatrix)

Compute normalized inter class variance. 
If `vals` is not uniformly distributed, calculate NICV with SNR.\\
Start Julia with `\$ julia -t4` to enable multithread computation.
"""
function NICV(vals::AbstractVector, traces::AbstractMatrix)
    vals, traces = sizecheck(vals, traces)
    return computenicv_mthread(vals, traces)
end

function NICV(vals::AbstractMatrix, traces::AbstractMatrix{T}) where{T}
    vals, traces = sizecheck(vals, traces)
    nicv = Matrix{T}(undef, size(traces)[1],size(vals)[1])
    for (b,val) in enumerate(eachrow(vals))
        print("calculating byte $b....                          ",'\r')
        nicv[:,b] = computenicv_mthread(val, traces)
    end
    return nicv
end

### Plotting

"""
    plotNICV(nicvs, trace; show=true, pkg="pyplot")

Plot NICV
"""
function plotNICV(nicvs, trace; show=true, pkg="pyplot")
    if pkg == "pyplot"
        pyplotNICV(nicvs, trace; show)
    end
    return
end

function pyplotNICV(nicvs, trace::AbstractVecOrMat; show=true)
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




