module LeakageAssessment

using Statistics
using Npy
import PyPlot as plt

include("utils.jl")
include("signal_to_noise_ratio.jl")
include("normalized_inter_class_variance.jl")

export groupbyval,
       SNR,  plotSNR,
       NICV, plotNICV

end # module LeakageAssessment
