
# checkout: https://en.wikipedia.org/wiki/Welch%27s_t-test#Calculations
"""
    welchststatistics(X1::AbstractMatrix, X2::AbstractMatrix)

Welch's t-test is a nearly exact test for the case where the data are normal but the variances may differ.
"""
function welchststatistics(X1::AbstractMatrix, X2::AbstractMatrix)
    Na, Nb  = size(X1,2), size(X2,2)
    Xa, S2a = vec(mean(X1;dims=2)), vec(var(X1;dims=2))
    Xb, S2b = vec(mean(X2;dims=2)), vec(var(X2;dims=2))
    tstat   =  @. (Xa - Xb) / sqrt(S2a/Na + S2b/Nb)
    return (tstat, Xa, Xb)
end

# checkout: https://en.wikipedia.org/wiki/Student%27s_t-test#Equal_or_unequal_sample_sizes,_similar_variances_(%E2%81%A01/2%E2%81%A0_%3C_%E2%81%A0sX1/sX2%E2%81%A0_%3C_2)
"""
    studentststatistics(X1::AbstractMatrix, X2::AbstractMatrix)

Student's t-test is an exact test for the equality of the means of two i.i.d. normal populations
with unknown, but equal, variances.
"""
function studentststatistics(X1::AbstractMatrix, X2::AbstractMatrix)
    Na, Nb  = size(X1,2), size(X2,2)
    Xa, S2a = vec(mean(X1;dims=2)), vec(var(X1;dims=2))
    Xb, S2b = vec(mean(X2;dims=2)), vec(var(X2;dims=2))
    S2p     = @. sqrt((((Na-1)*S2a+(Nb-1)*S2b)*(Na+Nb))/((Na+Nb-2)*(Na*Nb)))
    tstat   = @. (Xa - Xb) / S2p
    return (tstat, Xa, Xb)
end

function tstatistics(X1::AbstractMatrix, X2::AbstractMatrix; testtype=:welch)
    if testtype==:student
        return studentststatistics(X1, X2)
    else
        return welchststatistics(X1, X2)
    end
end

# checkout: https://stats.stackexchange.com/questions/313471/always-use-welch-t-test-unequal-variances-t-test-instead-of-student-t-or-mann
function tstatistic(X1::AbstractMatrix, X2::AbstractMatrix; testtype=:welch)
    return tstatistics(X1,X2;testtype)[1]
end
const Ttest=tstatistic

# checkout: https://www.rambus.com/wp-content/uploads/2015/08/TVLA-DTR-with-AES.pdf
"""
    TVLA(traces1::AbstractMatrix, traces2::AbstractMatrix; show::Bool=true, block::Bool=true, threshold=4.5,
                                                           markleakages::Bool=false, testrange=:middle, kwargs...)

Test Vector Leakage Assessment (TVLA). test the dataset twice for higher confidence.
"""
function TVLA(traces1::AbstractMatrix, traces2::AbstractMatrix; show::Bool=true, block::Bool=true, threshold=4.5,
                                                                markleakages::Bool=false, testrange=:middle, kwargs...)

    # calculate t-statistics (x2 times)
    tr1N, tr2N     = size(traces1,2), size(traces2,2)
    ttrace1, tr1avg1, tr2avg1 = @views tstatistics(traces1[:,        1:tr1N÷2], traces2[:,        1:tr2N÷2])
    ttrace2, tr1avg2, tr2avg2 = @views tstatistics(traces1[:, tr1N÷2+1:end   ], traces2[:, tr2N÷2+1:end   ])

    # analysis (optional): find and mark leakages
    if markleakages
        if testrange==:middle
            len = size(traces1,1)
            leakagepoints1 = [findall(>( threshold), view(ttrace1,len÷3+1:2*len÷3)) .+ (len÷3);
                              findall(<(-threshold), view(ttrace1,len÷3+1:2*len÷3)) .+ (len÷3)]
            leakagepoints2 = [findall(>( threshold), view(ttrace2,len÷3+1:2*len÷3)) .+ (len÷3);
                              findall(<(-threshold), view(ttrace2,len÷3+1:2*len÷3)) .+ (len÷3)]
        else
            leakagepoints1 = [findall(>(threshold), ttrace1);findall(<(-threshold), ttrace1)]
            leakagepoints2 = [findall(>(threshold), ttrace2);findall(<(-threshold), ttrace2)]
        end
    else
        leakagepoints1, leakagepoints2 = [], []
    end

    # plot TVLA result
    block && print("plotting TVLA test 1    ")
    p1 = plotTtest(ttrace1, tr1avg1, tr2avg1; threshold, leakages=leakagepoints1, title="TVLA test 1", show, block, kwargs...)
    block && print("plotting TVLA test 2    ")
    p2 = plotTtest(ttrace2, tr1avg2, tr2avg2; threshold, leakages=leakagepoints2, title="TVLA test 2", show, block, kwargs...)

    return plot(p1,p2)
end



