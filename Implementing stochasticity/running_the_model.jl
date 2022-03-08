# Let's get this started

import Pkg
Pkg.activate(".")

"""
This give me a testing space for the integration of my functions within the package

Start with some packages and scripts to allow me to build my functions and object
"""

# I have hidden them all in here
include("inclusion.jl")

# Let's get solving, I'll do with and without noise to compare

# No stochasticity, default

FW = FoodWeb(nichemodel, 20, C = 0.2, Z = 10)

MP = ModelParameters(FW)

biomass = rand(richness(FW))
run = simulate(MP, biomass)

ns = richness(FW)
plot(run.t, run.B, title = "BEFWM2 with $ns species", xlab = "Time", ylab = "Biomass", xlim = (0.0, 500.0), label = nothing)

# Add stochasticity

BR = BioRates(FW)
AS = AddStochasticity(FW, BR, addstochasticity = true
    , wherestochasticity = "producers", nstochasticity = 3
    , θ = 0.6, σe = 0.0)

MP2 = ModelParameters(FW, AS = AS)

run2 = simulate(MP2, biomass)

# Quick benchmark
using BenchmarkTools
@benchmark simulate(MP2, biomass)
@benchmark simulate(MP, biomass)


ls = length(AS.stochspecies)
plot(run2.t, run2.B[:,1:richness(FW)], title = "$ns species, $ls sources of stochasticity", xlab = "Time", ylab = "Biomass", xlim = (0.0, 500.0))

start = run.B[length(run.B[:,1]),:]

run = simulate(MP, start)
plot(run.t, run.B, title = "BEFWM2 with $ns species", xlab = "Time", ylab = "Biomass", xlim = (0.0, 500.0), label = nothing)
start = run.B[length(run.B[:,1]),:]

sigmad = 0.02 .* (start ./ FW.M) .^0.5


# Testing demographic stochasticity

# Step 1: run a determinisitic model

FW = FoodWeb(nichemodel, 20, C = 0.2, Z = 10)
MP = ModelParameters(FW)
biomass = rand(richness(FW))
run = simulate(MP, biomass, stop = 1500)
plot(run.t, run.B[:,1:richness(FW)], xlab = "Time", ylab = "Biomass") # Should be all straight

# Step 2: run a deterministic model using the endpoints as starting biomass

endpoints = run.B[length(run.B[:,1]),:]
run2 = simulate(MP, endpoints)
plot(run2.t, run2.B[:,1:richness(FW)], xlab = "Time", ylab = "Biomass") # Should be all straight

# We will use these endpoints to scale demographic stochasticity
start = run2.B[length(run2.B[:,1]),:]
sigmad = 0.025 .* ((start ./ FW.M) .^0.5)
AS = AddStochasticity(FW, BR, addstochasticity = true
    , wherestochasticity = "allspecies", nstochasticity = 5
    , θ = 0.0, σe = 0.0, σd = sigmad)

MP2 = ModelParameters(FW, AS = AS)
MP2.AddStochasticity.σd
run3 = simulate(MP2, start, stop = 1500)
plot(run3.t, run3.B[:,1:richness(FW)], xlab = "Time", ylab = "Biomass")

# That looks about right now

# Let's test long term OU process

FW = FoodWeb([0 0 0; 0 0 0; 0 0 0])
E = Environment(FW, K = [900, 1000, 1100])
BR = BioRates(FW, r = [0.5, 0.75, 1.0])
AS = AddStochasticity(FW, BR, addstochasticity = true, wherestochasticity = "producers", nstochasticity = "all", θ = [5.0, 10.0, 20.0], σe = [2.5, 15.0, 25.0])
MP = ModelParameters(FW, E = E, BR = BR, AS = AS)
biomass = [500, 500, 500]
run = simulate(MP, biomass, stop = 10000, interval_tkeep = 1.0)
plot(run.t, run.B[:,[4,5,6]], xlim = (0, 200))

sigmapoint5 = run.B[:,4]
sigma1 = run.B[:,5]
sigma2 = run.B[:,6]
timesteps = [0:1:10000;]

(AS.σe[1]^2) / (2*AS.θ[1])
ℯ^(-AS.θ[1] * abs(t - s)) - ℯ^(-AS.θ[1] * (t + s))
abs()

sigmapoint5[1:99900]
sigmapoint5[101:100000]

s = [101:1:100000;]
t = [1:1:99900;]

(ℯ^(-AS.θ[1] * abs(t[1] - s[1])) - ℯ^(-AS.θ[1] * (t[1] + s[1])))

covar = []
for i in 1:length(s)
    test = ((AS.σe[1]^2) / (2 * AS.θ[1])) * (ℯ^(-AS.θ[1] * abs(t[i] - s[i])) - ℯ^(-AS.θ[1] * (t[i] + s[i])))
    push!(covar,test)
end
covar
sum(covar)
((AS.σe[1]^2) / (2*AS.θ[1]))

((AS.σe[1]^2) / (2*AS.θ[1])) * (ℯ^(-AS.θ[1] * abs(t[1] - s[1])) - ℯ^(-AS.θ[1] * (t[1] + s[1])))
cov(sigmapoint5[101:100000], sigmapoint5[1:99900])

# Mean of OU process

mean(sigmapoint5[1:100])
AS.θ
AS.μ
sigmapoint5[1] * ℯ^(-AS.θ[1] * 100) + AS.μ[1] * (1 - ℯ^(-AS.θ[1] * 100))

ℯ^(-AS.θ[1] * 100) + AS.μ[1] * (1 - ℯ^(-AS.θ[1] * 100))
sigmapoint5[1] * ℯ^(-AS.θ[1] * 100)
AS.μ[1] * (1 - ℯ^(-AS.θ[1] * 100))

ℯ^(-AS.θ[1] * 5)