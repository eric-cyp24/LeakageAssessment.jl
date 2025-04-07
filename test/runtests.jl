using LeakageAssessment
using HDF5, HypothesisTests
using Statistics, Test

@testset verbose=true "LeakageAssessment tests" begin

    @testset verbose=true "uitls.jl tests" begin
        include("utils_tests.jl")
    end
    @testset verbose=true "NICV.jl tests" begin
        include("NICV_tests.jl")
    end
    @testset verbose=true "plotNICV tests" begin
        include("plotNICV_tests.jl")
    end
    @testset verbose=true "TVLA.jl tests" begin
        include("TVLA_tests.jl")
    end
    @testset verbose=true "plotTtest tests" begin
        include("plotTtest_tests.jl")
    end
end
