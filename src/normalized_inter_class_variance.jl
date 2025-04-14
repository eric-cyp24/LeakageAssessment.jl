
### NICV

function computenicv_mthread(vals::AbstractVector, traces)
    groupdict = groupbyval(vals)
    groups    = collect(values(groupdict))
    groupExp  = Matrix{eltype(traces)}(undef, size(traces)[1], length(groups))
    @sync Threads.@threads for i in 1:length(groups)
        groupExp[:,i] = mean(view(traces,:,groups[i]),dims=2)
    end
    if isuniform(groupdict)
        return replace!(vec(var(groupExp;dims=2,corrected=false) ./ var(traces;dims=2)), NaN=>0.0)
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
    #return replace!(vec(var(groupExp;dims=2) ./ var(traces;dims=2)), NaN=>0.0)
    if isuniform(groupdict)
        return replace!(vec(var(groupExp;dims=2,corrected=false) ./ var(traces;dims=2)), NaN=>0.0)
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
    if Threads.nthreads() == 1
        return computenicv(vals, traces)
    else
        return computenicv_mthread(vals, traces)
    end
end
function NICV(vals::AbstractMatrix, traces::AbstractMatrix{T}) where{T}
    vals, traces = sizecheck(vals, traces)
    nicv = Matrix{T}(undef, size(traces)[1],size(vals)[1])
    calculatenicv = Threads.nthreads() > 1 ? computenicv_mthread : computenicv
    for (b,val) in enumerate(eachrow(vals))
        print("calculating byte $b....                          ",'\r')
        nicv[:,b] = calculatenicv(val, traces)
    end
    return nicv
end


function SNR2NICV(vals::AbstractVecOrMat, traces::AbstractMatrix)
    return SNR2NICV(SNR(vals, traces))
end
function SNR2NICV(snr)
    return replace!(1.0 ./ (1.0 .+ 1.0 ./ snr), NaN=>0.0)
end


