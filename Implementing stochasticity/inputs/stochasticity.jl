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
I am making three functions to check the inputted parameters ??, ??d & ??e
I could make 1 function and loop but that wouldn't provide as clear error messages

All of these parameters need to:
Return an empty vector if addstochasticity = false - no matter the input
If addstochasticity = true...
    No defaults are provided so need some values
    Be all positive floats (note - an integer in a vector of floats is converted into a float automatically)
    Be trimmed or repeated to be the size of stochspecies

edit: ??d is edited so that it is either applied to all species or none. Therefore...
    needs an integer or vector of length richness(FW) - other lengths not allowed
    still has to be positive
    now defaults to 0.0 
"""

function thetacheck(stochspecies::Vector{Int64}
    , addstochasticity::Bool = false
    , ??::Union{Float64, Vector{Float64}, Nothing} = nothing
    )

    if addstochasticity == false
        ?? = Float64[]
    else
        if isnothing(??)
            throw(ArgumentError("There are no defaults for ?? - provide a value or a vector"))
        elseif all(>=(0), ??) == false
            throw(ArgumentError("All values of ?? must be positive"))
        end

        if isa(??, Vector)
            ls = length(stochspecies)
            l?? = length(??)
        
            if length(??) > length(stochspecies)
                @warn "You have provided $l?? ?? values and there are $ls stochastic species. \n Using the first $ls values of ??"
                ?? = ??[1:length(stochspecies)]
            end
        
            if length(??) < length(stochspecies)
                @warn "You have provided $l?? ?? values and there are $ls stochastic species. \n Repeating ?? until there are $ls values of ??"
                ?? = repeat(??, outer = length(stochspecies))
                ?? = ??[1:length(stochspecies)]
            end
        else
            ?? = repeat([??], length(stochspecies))
        end
    end
    
    return ??
end

function sigmadcheck(stochspecies::Vector{Int64}
    , addstochasticity::Bool = false
    , ??d::Union{Float64, Vector{Float64}, Nothing} = nothing)

    if addstochasticity == false
       ??d  = Float64[]
    else
        if isnothing(??d)
            ??d = repeat([0.0], richness(FW))
        elseif all(>=(0), ??d) == false
            throw(ArgumentError("All values of ??d must be positive"))
        end

        if isa(??d, Vector)
            ns = richness(FW) # For the error below
            isequal(length(??d),richness(FW)) || throw(ArgumentError("??d should be either a single value or a vector of length $ns"))
        else
            ??d = repeat([??d], richness(FW))
        end
    end
    
    return ??d
end

function sigmaecheck(stochspecies::Vector{Int64}
    , addstochasticity::Bool = false
    , ??e::Union{Float64, Vector{Float64}, Nothing} = nothing)

    if addstochasticity == false
       ??e  = Float64[]
    else
        if isnothing(??e)
            throw(ArgumentError("There are no defaults for ??e - provide a value or a vector"))
        elseif all(>=(0),??e) == false
            throw(ArgumentError("All values of ??e must be positive"))
        end

        if isa(??e, Vector)
            ls = length(stochspecies)
            l??e = length(??e)
        
            if length(??e) > length(stochspecies)
                @warn "You have provided $l??e ??e values and there are $ls stochastic species. \n Using the first $ls values of ??e"
                ??e = ??e[1:length(stochspecies)]
            end
        
            if length(??e) < length(stochspecies)
                @warn "You have provided $l??e ??e values and there are $ls stochastic species. \n Repeating ??e until there are $ls values of ??e"
                ??e = repeat(??e, outer = length(stochspecies))
                ??e = ??e[1:length(stochspecies)]
            end
        else
           ??e = repeat([??e], length(stochspecies))
        end
    end
    
    return ??e
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

Environmental stochasticity is added using an Orstein-Uhlenbeck process with a drift term; dxt = ??(?? - xt)dt + ?? dWt
- ?? controls speed of return to the mean following perturbation
- ?? is the mean value of the stochastic parameter (taken from BioRates)
- ??e is the standard deviation of the noise process for environmental stochasticity
- ??d is the standard deviation of the noise process for demographic stochasticity
"""

function AddStochasticity(FW::FoodWeb
    , BR::Union{BioRates, Nothing} = nothing
    ; addstochasticity::Bool = false
    , wherestochasticity::Union{String, Vector{String}, Int64, Vector{Int64}, Nothing} = nothing
    , nstochasticity::Union{Int64, String, Nothing} = nothing
    , ??::Union{Float64, Vector{Float64}, Nothing} = nothing
    , ??e::Union{Float64, Vector{Float64}, Nothing} = nothing
    , ??d::Union{Float64, Vector{Float64}, Nothing} = nothing
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

    ?? = thetacheck(stochspecies, addstochasticity, ??)
    ??d = sigmadcheck(stochspecies, addstochasticity, ??d)
    ??e = sigmaecheck(stochspecies, addstochasticity, ??e)


    ?? = zeros(length(stochspecies))

    if isnothing(BR)
        ?? = Float64[]
    else     
        for (i,j) in enumerate(stochspecies)
            if _idproducers(FW.A)[j]
                ??[i] = BR.r[j]
            else
                ??[i] = BR.x[j]
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
    
    return AddStochasticity(addstochasticity, ??, ??, ??e, ??d, stochspecies, stochconsumers, stochproducers)
end
