using LeakageAssessment
using Test, HDF5


f = h5open(joinpath(@__DIR__,"nicv_data.h5"))
traceavg = read(f,"traceavg")
nicvs    = read(f,"nicvs")
nicvs_dict = Dict(i=>n for (i,n) in enumerate(eachcol(nicvs)))
close(f)



@testset "plotNICV" begin
    print("plotting NICV without label    ")
    LeakageAssessment.plotNICV(nicvs,traceavg; block=true, title="NICV without labels")
end

@testset "plotNICV with Dict" begin
    print("plotting NICV with label (isa Dict())   ")
    LeakageAssessment.plotNICV(nicvs_dict,traceavg; block=true, title="NICV with labels")
end

@testset "plotNICV with Dict" begin
    print("plotting NICV with ppc=20   ")
    LeakageAssessment.plotNICV(nicvs_dict,traceavg; block=true, ppc=20, title="test ppc=20")
end

