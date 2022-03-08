#=
Simulations of biomass dynamics
=#

""" This is the original function in case I've fucked it up with my changes

function simulate(MP::ModelParameters, biomass; start::Int64=0, stop::Int64=500, use::Symbol=:nonstiff, extinction_threshold::Float64=1e-6, interval_tkeep::Number=0.25)
    @assert stop > start
    @assert length(biomass) == richness(MP.FoodWeb)
  
    @assert use ∈ vec([:stiff :nonstiff])
    alg = use == :stiff ? Rodas4(autodiff=false) : Tsit5()
  
    S = richness(MP.FoodWeb)
  
    # Pre-allocate the timeseries matrix
    tspan = (float(start), float(stop))
    t_keep = collect(start:interval_tkeep:stop)
  
    # Perform the actual integration
    prob = ODEProblem(dBdt!, biomass, tspan, MP)
    
    sol = solve(prob, alg, saveat = t_keep)
  
    B = hcat(sol.u...)'
  
    output = (
        ModelParameters = MP,
        t = sol.t,
        B = B
    )
  
    return output
  
end
"""

"""
Unlike dBdt! I have chosen to alter the simulate function as this is called by the user
The below simulate uses the default ODE code if addstochasticity = false, and SDE solvers if addstochasticity = true
"""

function simulate(MP::ModelParameters, biomass; start::Int64=0, stop::Int64=500, use::Symbol=:nonstiff, extinction_threshold::Float64=1e-6, interval_tkeep::Number=0.25, corrmat::Union{Matrix{Float64},Nothing} = nothing)
    @assert stop > start
    @assert length(biomass) == richness(MP.FoodWeb)

    # Pre-allocate the timeseries matrix
    tspan = (float(start), float(stop))
    t_keep = collect(start:interval_tkeep:stop)

    FW = MP.FoodWeb
    AS = MP.AddStochasticity
    S = MP.Stressor


    if AS.addstochasticity == false
        # Perform the actual integration

        @assert use ∈ vec([:stiff :nonstiff])
        alg = use == :stiff ? Rodas4(autodiff=false) : Tsit5()
        
        prob = ODEProblem(dBdt!, biomass, tspan, MP)
            
        sol = solve(prob, alg, saveat = t_keep)

    else
        diffparams = vcat(biomass,AS.μ)

        # Set up the noise process
        Γ = cov_matrix(FW, AS, corrmat)
        W = CorrelatedWienerProcess!(Γ, 0.0, zeros(size(Γ, 1))) 
        
        # Perform the actual integration 
        prob = SDEProblem(stochequations,noise_equations,diffparams,tspan,MP, noise = W)

        sol = solve(prob, adaptive = false, saveat = t_keep, dt = 0.01) # Do I want dt to be user determined?
    end
  
    B = hcat(sol.u...)'
  
    output = (
        ModelParameters = MP,
        t = sol.t,
        B = B
    )
  
    return output
  
end