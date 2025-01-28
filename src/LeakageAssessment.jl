module LeakageAssessment

using HDF5, Plots, StatsBase
using HypothesisTests: ChisqTest, pvalue
using Npy

include("utils.jl")
include("signal_to_noise_ratio.jl")
include("normalized_inter_class_variance.jl")
include("test_vector_leakage_assessment.jl")
include("plots.jl")

export groupbyval, isuniform, sizecheck,
       SNR,
       NICV, SNR2NICV,
       Ttest, tvla,
       plotSNR, plotNICV, plotTtest

end # module LeakageAssessment
