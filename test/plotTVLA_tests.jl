using LeakageAssessment
using Test, HDF5


f = h5open(joinpath(@__DIR__,"plotTVLA_data.h5"))
tval = read(f,"t-value")
trfixedavg = read(f,"trfixedavg")
trrandavg  = read(f,"trrandavg")
close(f)

@testset "plotTtest" begin
    print("plotting Ttest                          ")
    plotTtest(tval, trfixedavg, trrandavg; block=true, title="t-test fixed vs. random")
end

@testset "plotTtest with marked leakage" begin
    print("plotting Ttest with marked leakage      ")
    plotTtest(tval, trfixedavg, trrandavg; block=true, mark=true, title="t-test marked leakage")
end

@testset "plotTtest by clock cycle" begin
    print("plotting Ttest with ppc=4               ")
    plotTtest(tval, trfixedavg, trrandavg; block=true, ppc=4, title="test xlabel: 'time sample' -> 'clock cycle'")
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


