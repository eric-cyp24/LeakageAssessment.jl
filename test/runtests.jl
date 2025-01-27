using LeakageAssessment
using HypothesisTests
using Statistics, Test

@testset verbose=true "LeakageAssessment tests" begin

    @testset verbose=true "NICV.jl tests" begin
        include("NICV_tests.jl")
    end
    @testset verbose=true "plotNICV tests" begin
        include("plotNICV_tests.jl")
    end
    @testset verbose=true "tvla.jl tests" begin
        include("tvla_tests.jl")
    end
    @testset verbose=true "plotTVLA tests" begin
        include("plotTVLA_tests.jl")
    end
end
