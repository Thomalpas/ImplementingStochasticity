#=
Productivity
=#

function basalgrowth(biomass, FW::FoodWeb, BR::BioRates, E::Environment)
    idp = _idproducers(FW.A)
    G = (1 .- biomass ./ E.K) .* idp
    return BR.r .* G .* biomass 
end

"""
Two functions to calculate basal growth when stochasticity is in effect
 - one for the deterministic producers in the food web, one for the stochastic producers 
I can't use the pre-written function because the object 'biomass' is not what is fed into the solve function, but 'diffparams'
"""

function determbasalgrowth(diffparams, FW::FoodWeb, BR::BioRates, E::Environment)
        
    idp = _idproducers(FW.A)
    G = (1 .- diffparams[1:richness(FW)] ./ E.K) .* idp
    return BR.r .* G .* diffparams[1:richness(FW)] 
end

function stochbasalgrowth(diffparams, FW::FoodWeb, E::Environment, AS::AddStochasticity)

    G = (1 .- diffparams[AS.stochproducers] ./ E.K[AS.stochproducers])
    return diffparams[richness(FW) .+ indexin(AS.stochproducers, AS.stochspecies)] .* G .* diffparams[AS.stochproducers] 
end