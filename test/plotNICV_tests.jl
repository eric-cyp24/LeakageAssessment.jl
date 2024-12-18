using LeakageAssessment
using Test, HDF5


f = h5open(joinpath(@__DIR__,"nicv_data.h5"))
traceavg = read(f,"traceavg")
nicvs    = read(f,"nicvs")
nicvs_dict = Dict(i=>n for (i,n) in enumerate(eachcol(nicvs)))
close(f)



@testset "plotNICV" begin
    LeakageAssessment.plotNICV(nicvs,traceavg; backend=:gr)
end

@testset "plotNICV with Dict" begin
    LeakageAssessment.plotNICV(nicvs_dict,traceavg; backend=:gr)
end

@testset "plotNICV pythonplot backend" begin
    print("Close the figure window to continue...")
    LeakageAssessment.plotNICV(nicvs,traceavg;backend=:pythonplot)
    println()
end

@testset "pyplotNICV" begin
    print("Close the figure window to continue...")
    LeakageAssessment.pyplotNICV(nicvs,traceavg)
    println()
end

