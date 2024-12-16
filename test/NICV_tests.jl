
@testset "test NICV uniform" begin
    N, noisevar = 1000000, [100, 10, 1, 0.1, 0.01]
    noisestd = sqrt.(noisevar)
    IV = rand(0:8,N)
    tr = reduce(hcat,[iv.+rand(-4:4)*noisestd for iv in IV])

    nicv = LeakageAssessment.SNR2NICV(1 ./ noisevar)
    @test isapprox(nicv, LeakageAssessment.computenicv_mthread(IV, tr); rtol=0.01)
    @test isapprox(nicv, LeakageAssessment.computenicv(IV, tr); rtol=0.01)
    @test isapprox(nicv, NICV(IV, tr); rtol=0.01)

end

@testset "test NICV non-uniform" begin
    N, noisevar = 1000000, [100, 10, 1, 0.1, 0.01]
    noisestd = sqrt.(noisevar)
    IV = count_ones.(rand(0:255,N))
    tr = reduce(hcat,[iv.+(count_ones(rand(0:255))-4)*noisestd for iv in IV])

    nicv = LeakageAssessment.SNR2NICV(1 ./ noisevar)
    @test isapprox(nicv, LeakageAssessment.computenicv_mthread(IV, tr); rtol=0.01)
    @test isapprox(nicv, LeakageAssessment.computenicv(IV, tr); rtol=0.01)
    @test isapprox(nicv, NICV(IV, tr); rtol=0.01)

end
