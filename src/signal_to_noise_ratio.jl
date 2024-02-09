
### SNR

function computesnr_mthread(vals::AbstractVector, traces::AbstractMatrix)
    groupdict = groupbyval(vals)
    groups    = collect(values(groupdict))
    groupExp  = Matrix{eltype(traces)}(undef, size(traces)[1], length(groups))
    groupVar  = Matrix{eltype(traces)}(undef, size(traces)[1], length(groups))
    @sync Threads.@threads for i in 1:length(groups)
        groupExp[:,i] = mean(view(traces,:,groups[i]);dims=2)
        groupVar[:,i] =  var(view(traces,:,groups[i]);dims=2)
    end
    if isuniform(groupdict)
        return vec(var(groupExp;dims=2) ./ mean(groupVar;dims=2))
    else
        # use weighted variance if non-uniform
        w = FrequencyWeights([length(g) for g in groups])
        return vec(var(groupExp,w,2;corrected=true) ./ mean(groupVar,w,2))
    end
end

function computesnr(vals::AbstractVector, traces::AbstractMatrix)
    groupdict = groupbyval(vals)
    groups    = collect(values(groupdict))
    groupExp  = stack([vec(mean(view(traces,:,g),dims=2)) for g in groups])
    groupVar  = stack([vec( var(view(traces,:,g),dims=2)) for g in groups])
    if isuniform(groupdict)
        return vec(var(groupExp;dims=2) ./ mean(groupVar;dims=2))
    else
        # use weighted variance if non-uniform
        w = FrequencyWeights([length(g) for g in groups])
        return vec(var(groupExp,w,2;corrected=true) ./ mean(groupVar,w,2))
    end
end

"""
    SNR(vals::AbstractVector, traces::AbstractMatrix)
    SNR(vals::AbstractMatrix, traces::AbstractMatrix)

Compute signal to noise ratio.\\
Start Julia with `\$ julia -t4` to enable multithread computation.
"""
function SNR(vals::AbstractVector, traces::AbstractMatrix)
    vals, traces = sizecheck(vals, traces)
    return computesnr_mthread(vals, traces)
end

function SNR(vals::AbstractMatrix, traces::AbstractMatrix{T}) where{T}
    vals, traces = sizecheck(vals, traces)
    snrs = Matrix{T}(undef, size(traces)[1], size(vals)[1])
    for (b,val) in enumerate(eachrow(vals))
        print("calculating byte $b....                           ",'\r')
        snrs[:,b] = computesnr_mthread(val,traces)
    end
    return snrs
end

### Plotting

"""
    plotSNR(snrs, trace; show=true, pkg="pyplot")

Plot signal to nosie ratio.
"""
function plotSNR(snrs, trace; show=true, pkg="pyplot")
    if pkg == "pyplot"
        pyplotSNR(snrs, trace; show)
    end
    return
end

function pyplotSNR(snrs, trace; show=true)
    if ndims(trace) == 2
        trace = vec(mean(trace, dims=2))
    end
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

