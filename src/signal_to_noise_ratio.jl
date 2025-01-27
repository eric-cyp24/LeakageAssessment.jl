
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
    snrs = Matrix{T}(undef, size(traces,1), size(vals,1))
    for (b,val) in enumerate(eachrow(vals))
        print("calculating byte $b....                           ",'\r')
        snrs[:,b] = computesnr_mthread(val,traces)
    end
    return snrs
end

