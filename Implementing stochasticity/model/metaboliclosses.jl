#=
Metabolic losses
=#

function metaboliclosses(biomass, BR::BioRates)
    losses = biomass .* BR.x
    return losses
end

"""
Two functions to calculate metabolic losses when stochasticity is in effect
 - one for the deterministic consumers in the food web, one for the stochastic consumers 
I can't use the pre-written function because the object 'biomass' is not what is fed into the solve function, but 'diffparams'

Key idea is that 'biomass' is now 'diffparams[1:richness(FW)]'
"""

function determmetaboliclosses(diffparams, BR::BioRates)
    losses = diffparams[1:richness(FW)] .* BR.x
    return losses
end

function stochmetaboliclosses(diffparams, AS::AddStochasticity)
    losses = diffparams[AS.stochconsumers] .* diffparams[richness(FW) .+ indexin(AS.stochconsumers, AS.stochspecies)]
    return losses
end