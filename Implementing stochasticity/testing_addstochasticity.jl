
import Pkg
Pkg.activate(".")

"""
This give me a testing space for various combinations of inputs into AddStochasticity

    When addstochasticity = false, everything gets empty vectors

    nstochasticity and wherestochasticity interact to create selectedspecies, so have tried all combinations of these that I can think of 

    There are mutiple tests for θ, σd & σe. 
    These are all checked in their individual functions, which only take stochspecies as a Vector{Int64}, so I think there is no need to test between groups


Start with some packages and scripts to allow me to build my functions and object
"""

include("inclusion.jl") # Packages and scripts hidden in here 


# Do simulations still run?

FW = FoodWeb(nichemodel, 20, C = 0.2, Z = 10)
BR = BioRates(FW)
MP = ModelParameters(FW)
biomass = rand(richness(FW))
run = simulate(MP, biomass)

plot(run.t, run.B, title = "BEFWM2 with 20 species", xlab = "Time", ylab = "Biomass", xlim = (0.0, 500.0), ylim = (0.0, 1.5), label = nothing)



# Does AddStochasticity(FW) still run



AddStochasticity(FW)



# addstochasticity = false



AS = AddStochasticity(FW, nothing, addstochasticity = false
, wherestochasticity = nothing, nstochasticity = nothing
, θ = nothing, σd = nothing, σe = nothing) # RUNS

AS = AddStochasticity(FW, nothing, addstochasticity = false
, wherestochasticity = "allspecies", nstochasticity = nothing
, θ = nothing, σd = nothing, σe = nothing) # RUNS

AS = AddStochasticity(FW, nothing, addstochasticity = false
, wherestochasticity = nothing, nstochasticity = 4
, θ = nothing, σd = nothing, σe = nothing) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = false
, wherestochasticity = "consumers", nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS.addstochasticity
AS.stochconsumers
AS.stochproducers
AS.stochspecies
AS.θ
AS.σe
AS.σd



# addstochasticity = true



AS = AddStochasticity(FW, nothing, addstochasticity = true
, wherestochasticity = nothing, nstochasticity = nothing
, θ = nothing, σd = nothing, σe = nothing) # needs BioRates

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = nothing, nstochasticity = nothing
, θ = nothing, σd = nothing, σe = nothing) # needs wherestochasticity

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = nothing
, θ = nothing, σd = nothing, σe = nothing) # needs nstochasticity

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = 5
, θ = nothing, σd = nothing, σe = nothing) # needs θ

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = 5
, θ = 2.3, σd = nothing, σe = nothing) # needs σd

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = nothing) # needs σe

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS



# changing nstochasticity, wherestochasticity String



AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = "random"
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = "all"
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = 0
, θ = 2.3, σd = 2.4, σe = 1.2) # BoundsError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = -1
, θ = 2.3, σd = 2.4, σe = 1.2) # ArgumentError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = 2.3
, θ = 2.3, σd = 2.4, σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = [2,3]
, θ = 2.3, σd = 2.4, σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = "five"
, θ = 2.3, σd = 2.4, σe = 1.2) # MethodError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "consumers", nstochasticity = 21
, θ = 2.3, σd = 2.4, σe = 1.2) # Runs with warning



# Changing nstochasticity, wherestochasticity vector



AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = "random"
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = "all"
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 2
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 0
, θ = 2.3, σd = 2.4, σe = 1.2) # BoundsError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = -1
, θ = 2.3, σd = 2.4, σe = 1.2) # ArgumentError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 2.3
, θ = 2.3, σd = 2.4, σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = [2,3]
, θ = 2.3, σd = 2.4, σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = "five"
, θ = 2.3, σd = 2.4, σe = 1.2) # MethodError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 21
, θ = 2.3, σd = 2.4, σe = 1.2) # Runs with warning



# Changing nstochasticity, wherestochasticity Int64



AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = "random"
, θ = 2.3, σd = 2.4, σe = 1.2) # ArgumentError: You can't randomly sample from 1 species

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = "all"
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 0
, θ = 2.3, σd = 2.4, σe = 1.2) # BoundsError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = -1
, θ = 2.3, σd = 2.4, σe = 1.2) # ArgumentError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 2.3
, θ = 2.3, σd = 2.4, σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = [2,3]
, θ = 2.3, σd = 2.4, σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = "five"
, θ = 2.3, σd = 2.4, σe = 1.2) # MethodError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 21
, θ = 2.3, σd = 2.4, σe = 1.2) # Runs with warning

# Errors for wherestochasticity



AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = "five", nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # ArgumentError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = -2, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # BoundsError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 1.0, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [22, 3], nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # BoundsError



# Testing θ



AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 5
, θ = 0.0, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 1, σd = 2.4, σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = [2.3, 1.0], σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = [2.3, 1], σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = [2.3, -1.0], σd = 2.4, σe = 1.2) # ArgumentError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = -2.3, σd = 2.4, σe = 1.2) # ArgumentError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = "five", σd = 2.4, σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = false
, wherestochasticity = 5, nstochasticity = 5
, θ = [2.3, 1.0], σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = false
, wherestochasticity = 5, nstochasticity = 5
, θ = nothing, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 5
, θ = [2.3, 1.0], σd = 2.4, σe = 1.2) # Runs with warning

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 5
, θ = [2.3, 1.0, 2.3, 2.3], σd = 2.4, σe = 1.2) # Runs with warning



# Testing σd



AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 5
, θ = 2.3, σd = 0.0, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 1, σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = [2.4, 1.0], σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = [2.4, 1], σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = [2.4, -1.0], σe = 1.2) # ArgumentError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = -2.4, σe = 1.2) # ArgumentError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = "five", σe = 1.2) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = false
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = [2.4, 1.0], σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = false
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = nothing, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 5
, θ = 2.3, σd = [2.4, 1.0], σe = 1.2) # Runs with warning

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 5
, θ = 2.3, σd = [2.4, 1.0, 2.3, 2.3], σe = 1.2) # Runs with warning



# Testing σe



AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1.2) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 0.0) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = 1) # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = [1.2, 1.0]) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = [1.2, 1]) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = [1.2, -1.0]) # ArgumentError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = -1.2) # ArgumentError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = "five") # TypeError

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = false
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = [1.2, 1.0]) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = false
, wherestochasticity = 5, nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = nothing) # RUNS

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = [1.2, 1.0]) # Runs with warning

AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
, wherestochasticity = [2,3,4], nstochasticity = 5
, θ = 2.3, σd = 2.4, σe = [1.2, 1.0, 2.3, 2.3]) # Runs with warning

"""
I'll also throw onto the end here the script about testing the covariance matrix
"""


# Do I need 1.0 or σ values in the noise equations? ANSWER: 1.0

# Function for deterministic part of the equations

function testmod(du,u,p,t) # All zeros, straight lines
    
    du[1] = 0.0

    du[2] = 0.0

    du[3] = 0.0
end

# Function for varying noise standard deviations

function noisemod1(du,u,p,t)

    du[1] = 0.2

    du[2] = 1.0

    du[3] = 2.0
end

# Function for all same noise standard deviations

function noisemod2(du,u,p,t)

    du[1] = 1.0

    du[2] = 1.0

    du[3] = 1.0
end

# Initial conditions for all

start = [10.0, 10.0, 10.0]
tspan = (0.0, 1000.0)

noise1 = WienerProcess(0.0, 0.0) # Your standard WienerProcess

# Running and plotting WienerProcess

prob1 = SDEProblem(testmod, noisemod1, start, tspan, noise = noise1)
sol1 = solve(prob1, adaptive = false, dt = 0.01)
plot(sol1, title = "WienerProcess", label = ["σ = 0.1" "σ = 1.0" "σ = 2.0"], ylim = (-90.0, 140.0))

# Sorting out CorrelatedWienerProcess

sdmat = [0.2 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 2.0] # sd on the diagonal
corrmat = I(3) # Identity matrix
corrmat = [1.0 1.0 1.0; 1.0 1.0 1.0; 1.0 1.0 1.0]
covmat = sdmat * corrmat * sdmat
noise2 = CorrelatedWienerProcess(covmat, 0.0, zeros(3))

# noisemod1 = sd in noise du's

prob2 = SDEProblem(testmod, noisemod1, start, tspan, noise = noise2)
sol2 = solve(prob2, adaptive = false, dt = 0.01)
plot(sol2, title = "CorrelatedWienerProcess \n sd in noise model", label = ["σ = 0.1" "σ = 1.0" "σ = 2.0"], ylim = (-90.0, 140.0))

# noisemod2 = noise du's all 1.0

prob3 = SDEProblem(testmod, noisemod2, start, tspan, noise = noise2)
sol3 = solve(prob3, adaptive = false, dt = 0.01)
plot(sol3, title = "CorrelatedWienerProcess \n 1.0s in noise model", label = ["σ = 0.1" "σ = 1.0" "σ = 2.0"], ylim = (-90.0, 140.0))
