using LeakageAssessment
using Test, Statistics, HypothesisTests

@testset "test Student's t-test (equal variance)" begin
    t0 = zeros(8)
    t1 = [10.0^i for i in -6:1]
    for N in [10,100,1000,100000]
        X0 = randn(8,N) .+ t0
        X1 = randn(8,N) .+ t1
        @test ttest(X0,X1;testtype=:student) ≈ [EqualVarianceTTest(X0[i,:],X1[i,:]).t for i in 1:8]
    end
end

@testset "test Welch's t-test (unequal variance)" begin
    t0 = zeros(8)
    t1 = [10.0^i for i in -6:1]
    for N in [10,100,1000,100000]
        X0 =   randn(8,N) .+ t0
        X2 = 2*randn(8,N) .+ t1
        @test ttest(X0,X2;testtype=:welch) ≈ [UnequalVarianceTTest(X0[i,:],X2[i,:]).t for i in 1:8]
    end
end


