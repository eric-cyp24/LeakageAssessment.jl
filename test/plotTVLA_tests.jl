using LeakageAssessment
using Test, HDF5


f = h5open(joinpath(@__DIR__,"plotTVLA_data.h5"))
tval = read(f,"t-value")
trfixedavg = read(f,"trfixedavg")
trrandavg  = read(f,"trrandavg")
close(f)

@testset "plotTVLA" begin
    print("plotting TVLA                           ")
    plotTVLA(tval, trfixedavg, trrandavg; block=true, title="TVLA fixed vs. random")
end

@testset "plotTVLA with marked leakage" begin
    print("plotting TVLA with marked leakage       ")
    plotTVLA(tval, trfixedavg, trrandavg; block=true, mark=true, title="TVLA marked leakage")
end

@testset "plotTVLA by clock cycle" begin
    print("plotting TVLA with ppc=4                ")
    plotTVLA(tval, trfixedavg, trrandavg; block=true, ppc=4, title="test xlabel: 'time sample' -> 'clock cycle'")
end


@testset "tvla" begin
    X0 =   randn(16,100000) .+ zeros(16)
    X2 = 2*randn(16,100000) .+ [[10.0^i for i in -6:1];[10.0^i for i in 1:-1:-6]]
    p = tvla(X0, X2; markleakages=true)
    print("plotting tvla                           ")
    display(p)
    print("Press Enter to continue...")
    readline()
end


