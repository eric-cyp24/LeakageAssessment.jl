module LeakageAssessment

using HDF5, Plots, StatsBase
using HypothesisTests: ChisqTest, pvalue
using Npy

include("utils.jl")
include("signal_to_noise_ratio.jl")
include("normalized_inter_class_variance.jl")

export groupbyval, isuniform, sizecheck,
       SNR,  plotSNR,
       NICV, plotNICV

end # module LeakageAssessment
