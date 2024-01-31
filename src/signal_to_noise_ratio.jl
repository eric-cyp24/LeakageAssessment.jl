



function computesnr(vals, traces)
    #println("method with transpose")
    groups   = values(groupbyval(vals))
    groupExp = [vec(mean(traces[:,g],dims=2)) for g in groups]
    groupVar = [vec( var(traces[:,g],dims=2)) for g in groups]
    return vec(var(groupExp) ./ mean(groupVar))
end

function SNR(vals, traces)
    if ndims(vals) == 1
        traces = length(vals) == size(traces)[2] ? traces : transpose(traces)
        return computesnr(vals, traces)
    elseif ndims(vals) == 2
        if size(vals)[1] == size(traces)[1]
            vals, traces = transpose(vals), transpose(traces)
        elseif size(vals)[2] != size(traces)[2]
            return nothing
        end
        snrs = Matrix{eltype(traces)}(undef, size(traces)[1], size(vals)[1])
        for (b,val) in enumerate(eachrow(vals))
            print("calculating byte $b....                           ",'\r')
            snrs[:,b] = computesnr(val,traces)
        end
        return snrs
    else
        return nothing
    end
end

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

