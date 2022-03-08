"""
This function returns a vector of the species stochasticity will be added to 
It needs to be provided with:
 a FoodWeb object
 a list of which species stochasticity will be added to (wherestochasticity)
 - this can be "producers", "consumers", "allspecies", an integer or vector of integers
 how many species in the above group will stochasticity be added to
 - this can be "all", "random" or an integer

There are a lot of ifs here because there are so many options...
"""
function stochasticspecies(FW::FoodWeb, wherestochasticity::Union{String, Int64, Vector{Int64}, Nothing},
    nstochasticity::Union{Int64, String, Nothing}) 

    tr = _gettrophiclevels(FW.A)
    selectedspecies = Int64[]
    out = Int64[]

    # Collect species that match the wherestochasticity input into 'selectedspecies'

    if isnothing(wherestochasticity)
        out = Int64[]

    elseif wherestochasticity == "producers"
        for (i,j) in enumerate(tr)
            if j == 1.0
                push!(selectedspecies, i)
            end
        end

    elseif wherestochasticity == "consumers"
        for (i,j) in enumerate(tr)
            if j != 1.0
                push!(selectedspecies, i)
            end
        end
    
    elseif wherestochasticity == "allspecies"
        selectedspecies = [1:1:(richness(FW));]
    
    elseif typeof(wherestochasticity) == Vector{Int64}
        selectedspecies = wherestochasticity

    elseif typeof(wherestochasticity) == Int64
        selectedspecies = [wherestochasticity]

    else
        throw(ArgumentError("wherestochasticity group not recognised. wherestochasticity can be one of: \n producers, consumers, or allspecies, an integer or a vector of integers"))
    end

    # Sample from these selected species to get a vector of length nstochasticity

    if isnothing(nstochasticity)
        out = Int64[]

    elseif nstochasticity == "all"
        out = selectedspecies

    elseif nstochasticity == "random"
        if typeof(wherestochasticity) == Int64
            throw(ArgumentError("You can't randomly sample from 1 species"))
        end
        nstochasticity = sample(1:length(selectedspecies))
        out = sample(selectedspecies, nstochasticity, replace = false)
    
    elseif nstochasticity > length(selectedspecies)
        nstochasticity = length(selectedspecies)
        @warn "nstochasticity greater than number of species. \n Adding stochasticity to all species"
        out = sample(selectedspecies, nstochasticity, replace = false)

    else # number of species specified by nstochasticity is less than number of potential stochasticn species in selectedspecies
    out = sample(selectedspecies, nstochasticity, replace = false)
    end
end

"""
I am making three functions to check the inputted parameters θ, σd & σe
I could make 1 function and loop but that wouldn't provide as clear error messages

All of these parameters need to:
Return an empty vector if addstochasticity = false - no matter the input
If addstochasticity = true...
    No defaults are provided so need some values
    Be all positive floats (note - an integer in a vector of floats is converted into a float automatically)
    Be trimmed or repeated to be the size of stochspecies

edit: σd is edited so that it is either applied to all species or none. Therefore...
    needs an integer or vector of length richness(FW) - other lengths not allowed
    still has to be positive
    now defaults to 0.0 
"""

function thetacheck(stochspecies::Vector{Int64}
    , addstochasticity::Bool = false
    , θ::Union{Float64, Vector{Float64}, Nothing} = nothing
    )

    if addstochasticity == false
        θ = Float64[]
    else
        if isnothing(θ)
            throw(ArgumentError("There are no defaults for θ - provide a value or a vector"))
        elseif all(>=(0), θ) == false
            throw(ArgumentError("All values of θ must be positive"))
        end

        if isa(θ, Vector)
            ls = length(stochspecies)
            lθ = length(θ)
        
            if length(θ) > length(stochspecies)
                @warn "You have provided $lθ θ values and there are $ls stochastic species. \n Using the first $ls values of θ"
                θ = θ[1:length(stochspecies)]
            end
        
            if length(θ) < length(stochspecies)
                @warn "You have provided $lθ θ values and there are $ls stochastic species. \n Repeating θ until there are $ls values of θ"
                θ = repeat(θ, outer = length(stochspecies))
                θ = θ[1:length(stochspecies)]
            end
        else
            θ = repeat([θ], length(stochspecies))
        end
    end
    
    return θ
end

function sigmadcheck(stochspecies::Vector{Int64}
    , addstochasticity::Bool = false
    , σd::Union{Float64, Vector{Float64}, Nothing} = nothing)

    if addstochasticity == false
       σd  = Float64[]
    else
        if isnothing(σd)
            σd = repeat([0.0], richness(FW))
        elseif all(>=(0), σd) == false
            throw(ArgumentError("All values of σd must be positive"))
        end

        if isa(σd, Vector)
            ns = richness(FW) # For the error below
            isequal(length(σd),richness(FW)) || throw(ArgumentError("σd should be either a single value or a vector of length $ns"))
        else
            σd = repeat([σd], richness(FW))
        end
    end
    
    return σd
end

function sigmaecheck(stochspecies::Vector{Int64}
    , addstochasticity::Bool = false
    , σe::Union{Float64, Vector{Float64}, Nothing} = nothing)

    if addstochasticity == false
       σe  = Float64[]
    else
        if isnothing(σe)
            throw(ArgumentError("There are no defaults for σe - provide a value or a vector"))
        elseif all(>=(0),σe) == false
            throw(ArgumentError("All values of σe must be positive"))
        end

        if isa(σe, Vector)
            ls = length(stochspecies)
            lσe = length(σe)
        
            if length(σe) > length(stochspecies)
                @warn "You have provided $lσe σe values and there are $ls stochastic species. \n Using the first $ls values of σe"
                σe = σe[1:length(stochspecies)]
            end
        
            if length(σe) < length(stochspecies)
                @warn "You have provided $lσe σe values and there are $ls stochastic species. \n Repeating σe until there are $ls values of σe"
                σe = repeat(σe, outer = length(stochspecies))
                σe = σe[1:length(stochspecies)]
            end
        else
           σe = repeat([σe], length(stochspecies))
        end
    end
    
    return σe
end



"""
Creates an object of Type AddStochasticity to hold all parameters related to adding stochasticity into the BEFW

- FW is a FoodWeb object
- BR is a BioRates object
- addstochasticity is a boolean indicating whether stochasticity will be added or not - if true the following arguments will need to be supplied; there are no defaults
- wherestochasticity contains information about which species stochasticity will be added to
    This may be "producers", "consumers", "allspecies", or an integer or vector of integers (relating to the position of species in the interaction matrix)
- nstochasticity provides the number of species stochasticity will be added to
    This may be "all", "random" or a number

Environmental stochasticity is added using an Orstein-Uhlenbeck process with a drift term; dxt = θ(μ - xt)dt + σ dWt
- θ controls speed of return to the mean following perturbation
- μ is the mean value of the stochastic parameter (taken from BioRates)
- σe is the standard deviation of the noise process for environmental stochasticity
- σd is the standard deviation of the noise process for demographic stochasticity
"""

function AddStochasticity(FW::FoodWeb
    , BR::Union{BioRates, Nothing} = nothing
    ; addstochasticity::Bool = false
    , wherestochasticity::Union{String, Vector{String}, Int64, Vector{Int64}, Nothing} = nothing
    , nstochasticity::Union{Int64, String, Nothing} = nothing
    , θ::Union{Float64, Vector{Float64}, Nothing} = nothing
    , σe::Union{Float64, Vector{Float64}, Nothing} = nothing
    , σd::Union{Float64, Vector{Float64}, Nothing} = nothing
    )

    # Step 1: Generate a vector containing the stochastic species

    if addstochasticity == true && isnothing(BR)
        throw(ArgumentError("If adding stochasticity please provide a BioRates object"))
    elseif addstochasticity == true && isnothing(wherestochasticity)
        throw(ArgumentError("There are no defaults for wherestochasticity - provide a value or a vector"))
    elseif addstochasticity == true && isnothing(nstochasticity)
    throw(ArgumentError("There are no defaults for nstochasticity - provide a value"))
    end

    stochspecies = Int64[]

    if addstochasticity == true
        stochspecies = stochasticspecies(FW, wherestochasticity, nstochasticity)
    end

    if length(stochspecies) > 1 # stochspecies is Vector{Any}, I want it Vector{Int64}
        stochspecies = convert(Vector{Int64}, stochspecies)
    elseif length(stochspecies) == 1 && typeof(stochspecies) != Vector{Int64}
        stochspecies = [stochspecies]
    end

    # Step 2: Use the vector of stochastic species to generate the vectors for stochastic parameters

    θ = thetacheck(stochspecies, addstochasticity, θ)
    σd = sigmadcheck(stochspecies, addstochasticity, σd)
    σe = sigmaecheck(stochspecies, addstochasticity, σe)


    μ = zeros(length(stochspecies))

    if isnothing(BR)
        μ = Float64[]
    else     
        for (i,j) in enumerate(stochspecies)
            if _idproducers(FW.A)[j]
                μ[i] = BR.r[j]
            else
                μ[i] = BR.x[j]
            end
        end
    end

    #Step 3: Make vectors of stochconsumers & stochproducers

    stochconsumers = Int64[]
    stochproducers = Int64[]

    if addstochasticity == true
        for i in stochspecies
            if _idproducers(FW.A)[i]
                push!(stochproducers, i)
            else
                push!(stochconsumers, i)
            end
        end
    end
    
    return AddStochasticity(addstochasticity, θ, μ, σe, σd, stochspecies, stochconsumers, stochproducers)
end
