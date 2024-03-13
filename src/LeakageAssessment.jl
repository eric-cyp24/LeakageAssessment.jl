module LeakageAssessment

ENV["MPLBACKEND"]="TkAgg" # dirty hack, set this ENV variable to help PythonPlot find a interactive backend on my computer (callas)
using StatsBase, Plots
using HypothesisTests: ChisqTest, pvalue
using Npy
import PythonPlot as plt

include("utils.jl")
include("signal_to_noise_ratio.jl")
include("normalized_inter_class_variance.jl")

export groupbyval, isuniform, sizecheck,
       SNR,  plotSNR,
       NICV, plotNICV

end # module LeakageAssessment
