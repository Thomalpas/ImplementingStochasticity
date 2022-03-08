#=
Core functions of the model

I leave this alone as it is needed for determinisitic simulations
=#

function dBdt!(du, biomass, MP::ModelParameters, t)

    for i in 1:length(biomass)
        biomass[i] = biomass[i] <= 0 ? 0.0 : biomass[i]
    end

    FW = MP.FoodWeb
    BR = MP.BioRates
    E = MP.Environment
    FR = MP.FunctionalResponse

    prod_growth = basalgrowth(biomass, FW, BR, E)
    cons_gain, cons_loss = consumption(biomass, FW, BR, FR, E)
    metab_loss = metaboliclosses(biomass, BR)

    dbdt = prod_growth .+ cons_gain .- cons_loss .- metab_loss
    for i in eachindex(dbdt)
        du[i] = dbdt[i] #can't return du directly, have to have 2 different objects dbdt and du for some reason... 
    end 
    
    return dbdt
end

"""
Creating the dbdt object for when stochasticity is being applied.

This should create an equation (du) for every species and every stochastic parameter

if S.addstressor == true then this will also add a linear stressor to a random producer carrying capacity
"""

function stochequations(du, diffparams, MP::ModelParameters, t)

    FW = MP.FoodWeb
    BR = MP.BioRates
    E = MP.Environment
    FR = MP.FunctionalResponse
    AS = MP.AddStochasticity
    S = MP.Stressor

    for i in eachindex(diffparams)
        diffparams[i] = diffparams[i] <= 0 ? 0.0 : diffparams[i] # this bit I can leave
    end

    if S.addstressor == true # This is all it needs to make a stressor
        E.K = convert(Vector{Float64}, E.K)
        E.K[first(S.stressed_species)] = 1 + (S.slope * t)
        if all(<=(0), E.K[first(S.stressed_species)])
            E.K[first(S.stressed_species)] = 1
            diffparams[first(S.stressed_species)] = 0.0
        end
    end

    prod_growth = determbasalgrowth(diffparams, FW, BR, E)
    cons_gain, cons_loss = stochconsumption(diffparams, FW, BR, FR, AS)
    metab_loss = determmetaboliclosses(diffparams, BR)
    stoch_prod_growth = stochbasalgrowth(diffparams, FW, E, AS)
    stoch_metab_loss = stochmetaboliclosses(diffparams, AS)

    dbdt = prod_growth .+ cons_gain .- cons_loss .- metab_loss

    dpdt = AS.θ .* (AS.μ .- last(diffparams, length(AS.stochspecies)))

    dbdt = vcat(dbdt,dpdt)
    
    #= When you enumerate the vectors AS.stochproducers & AS.stochconsumers,
    i gives you the position in the vector (e.g. species 5 in the food web may be stochastic producer 1)
        This is needed for stoch_prod_growth & stoch_prod_growth 
        as these vectors only have values for stochastic species

    j gives you the value (position in interaction matrix)
        This needed for cons_gain and cons_loss 
        as these vectors have values for all species =#

    for (i,j) in enumerate(AS.stochproducers)
        dbdt[j] = stoch_prod_growth[i] - cons_loss[j]
    end

    for (i,j) in enumerate(AS.stochconsumers)
        dbdt[j] = cons_gain[j] - stoch_metab_loss[i] - cons_loss[j]
    end

    for i in eachindex(dbdt)
        du[i] = dbdt[i] #can't return du directly, have to have 2 different objects dbdt and du for some reason... 
    end 
    
    return dbdt
end

"""
I also need a function for the stochastic equations

Important to take into account if a stochastic species goes extinct that demographic noise doesn't divide by 0    

So if CorrelatedWienerProcess holds all the standard deviations, this should be filled with 1s - except for demographic noise
I think if the covariance matrix has 0s then no noise will be added?
"""


function noise_equations(du,diffparams,MP::ModelParameters,t)

    FW = MP.FoodWeb
    AS = MP.AddStochasticity

    dWdt = ones(length(diffparams))

    for i in 1:richness(FW) # These will be the biomass dynamics, and demographic stochasticity
        if diffparams[i] <= 0
            dWdt[i] = 0
        else
            dWdt[i] = 1 / sqrt(diffparams[i] / FW.M[i])
        end
    end

    for i in eachindex(dWdt)
        du[i] = dWdt[i] #can't return du directly, have to have 2 different objects dWdt and du for some reason... 
    end 

    return dWdt

end
