using EcologicalNetworks
using SparseArrays
using DiffEqBase
using Statistics
using DifferentialEquations
using Plots
using LinearAlgebra
using SparseArrays


include("types/declaration.jl") # To have FoodWeb and BioRates objects
include("types/typedisplay.jl")

include("inputs/foodwebs.jl") # To build the food web
include("inputs/biological_rates.jl") # To fill μ with BioRates
include("inputs/environment.jl") # Need environment now to build ModelParameters
include("inputs/functional_response.jl") # Likewise need functional response
include("inputs/stochasticity.jl")
include("inputs/stressor.jl")

include("model/productivity.jl")
include("model/consumption.jl")
include("model/metaboliclosses.jl")
include("model/model_parameters.jl") # Need the model parameters funciton
include("model/dbdt.jl")
include("model/covariance_matrix.jl")
include("model/simulate.jl")

include("measures/structure.jl") # To use _gettrophiclevels
