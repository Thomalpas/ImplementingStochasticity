#=
Consumption
=#

function consumption(biomass, FW::FoodWeb, BR::BioRates, FR::FunctionalResponse, E::Environment)

    xyb = BR.x .* BR.y .* biomass
    Fij = FR.functional_response(biomass, FW, FR.ω, FR.B0, FR.hill_exponent, FR.c)
    feeding = xyb .* Fij
    assim = (feeding ./ FR.e) .* FW.A
    loss = vec(sum(assim, dims = 1))
    gain = vec(sum(feeding, dims = 2))

    return (gain, loss)
end

"""
Only one new function here because every species has the potential to be eaten by a stochastic consumer

All species need to be in terms of diffparams[1:richness(FW)] rather than biomass
Stochastic consumers also need their x from diffparams
"""

function stochconsumption(diffparams, FW::FoodWeb, BR::BioRates, FR::FunctionalResponse, AS::AddStochasticity)

    xyb = BR.x .* BR.y .* diffparams[1:richness(FW)]

    for i in AS.stochconsumers # Change the xyb calculation for stochastic consumers - they need x from diffparams
        xyb[i] = diffparams[richness(FW) .+ indexin(i, AS.stochspecies)] * BR.y[i] * diffparams[i]
    end

    Fij = FR.functional_response(diffparams[1:richness(FW)], FW, FR.ω, FR.B0, FR.hill_exponent, FR.c)
    feeding = xyb .* Fij
    assim = (feeding ./ FR.e) .* FW.A
    loss = vec(sum(assim, dims = 1))
    gain = vec(sum(feeding, dims = 2))

    return (gain, loss)
end