
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
        #Base.invokelatest(display,p)
        display(p)
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

## TVLA

function plotTVLA(trace1::AbstractMatrix, trace2::AbstractMatrix; testtype=:welch, show::Bool=true, block::Bool=false, title="", ppc::Integer=0,
                                                                  threshold::Real=4.5, leakages=[], mark::Bool=false, kwargs...)
    return plotTVLA(tstatistics(trace1, trace2; testtype)...; show, block, ppc, title, threshold, leakages, mark, kwargs...)
end
function plotTVLA(tvalue::T, trace1::T, trace2::T; show::Bool=true, block::Bool=false, ppc::Integer=0, title="",
                                                   threshold=4.5, leakages=[], mark::Bool=false, kwargs...) where{T <: AbstractVector}
    p = plot()

    x         = ppc==0 ? (1:length(trace1)) : (0:length(trace1)-1)/ppc
    xlabel    = ppc==0 ? "time sample"     : "clock cycle"
    ymax,ymin = max(maximum(tvalue)*1.2,10), min(minimum(tvalue)*1.2,-10)
    leakages  = mark ? [findall(>(threshold), tvalue);findall(<(-threshold), tvalue)] : leakages
    
    # plot t-value trace
    plot!(x, tvalue; ylims=(ymin,ymax+0.3*(ymax-ymin)), label="t-value", margin=8Plots.mm, xlabel, ylabel="t-value")
    plot!([]; z_order=:back, label="trace group 2")
    plot!([]; z_order=:back, label="trace group 1")
    # checkout: https://docs.juliaplots.org/dev/attributes/
    # line=(-seriestype-, style, -arrow-, alpha, width, color)
    hline!([ threshold]; label="", line=(:dash, 1.0, 2, :red)) 
    hline!([-threshold]; label="", line=(:dash, 1.0, 2, :red))
    # marker=(-shape-, size, alpha, color, stroke=(width, alpha, color, style) )
    isempty(leakages) || scatter!(x[leakages], tvalue[leakages]; marker=(:utriangle, 5, :red, stroke(0)), label="leakage points")

    # plot traces
    ymax       = maximum(abs.([trace1 trace2]))*1.2
    ax2, ylims = twinx(), (-5*ymax, ymax)
    plot!(ax2, x, trace2; linecolor=2, ylims, ylabel="voltage (V)", label="")
    plot!(ax2, x, trace1; linecolor=3, label="")

    # swap z_order of two plot
    reverse!(p.subplots)
    p.subplots[1].attr[:background_color_inside] = :match
    p.subplots[2].attr[:background_color_inside] = RGBA{Float64}(0.0,0.0,0.0,0.0)
    plot!(;size=(1600,900), title, grid=false, framestyle=:semi, kwargs...)

    if show
        #Base.invokelatest(display,p)
        display(p)
        if block
            print("Press Enter to continue...")
            readline()
        end
    end

    return p
end

