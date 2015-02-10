module EGR

import Base.size

export get_f_g_cs, get_f_pcc, get_g_from_cs, MinusPlusOneVector

include("MinusPlusOneVectorModule.jl")
include("BinaryLogisticRegressionModule.jl")

# importall BinaryLogisticRegressionModule

end # module