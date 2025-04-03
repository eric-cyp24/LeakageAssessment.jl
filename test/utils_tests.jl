
using LeakageAssessment:loaddata
@testset "test loaddata" begin
    A, path = rand(5,4), "test_loaddata.h5"
    h5open(path,"w") do f write(f,"data",A) end
    A_load = loaddata(path)
    @test A_load == A && !(A_load === A)
    rm(path)
end

@testset "test groupbyval" begin
    N, nlabels = 100, 5
    labels = Vector{Int8}(undef,N)
    gsize  = N ÷ nlabels
    # test interleaved labels
    for i in 1:N labels[i] = i % nlabels end
    groupdict = groupbyval(labels)
    for i in 1:nlabels
        @test groupdict[i%nlabels] == collect(i:nlabels:N)
    end
    # test segmented grouping and small group removal
    for i in 1:N labels[i] = i ÷ gsize end
    groupdict = groupbyval(labels; minsize=2)
    @test groupdict[0] == collect(1:gsize-1)
    for i in 1:nlabels-1
        @test groupdict[i] == collect(gsize*i:gsize*(i+1)-1)
    end
    @test_throws KeyError groupdict[nlabels]
end

@testset "test sizecheck" begin
    # test vals::Vector
    vals, traces = sizecheck(zeros(3),ones(10,3))
    @test size(vals,1)== size(traces,2)
    vals, traces = sizecheck(zeros(3),ones(3,10))
    @test size(vals,1)== size(traces,2)
    @test_throws DimensionMismatch sizecheck(zeros(5),ones(10,3))
    # test vals::Matrix
    vals, traces = sizecheck(zeros(5,3),ones(10,3))
    @test size(vals,2)== size(traces,2)
    vals, traces = sizecheck(zeros(3,5),ones(3,10))
    @test size(vals,2)== size(traces,2)
    @test_throws DimensionMismatch sizecheck(zeros(5,5),ones(10,3))
end

