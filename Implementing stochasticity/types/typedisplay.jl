"""
Food Webs 
"""

function Base.show(io::IO, DFW::FoodWeb)
    N = UnipartiteNetwork(DFW.A, DFW.species)
    mthd = DFW.method
    print(io, "$(richness(N; dims=1)) species - $(links(N)) links. \n Method: $mthd")
end

"""
Functional Response
"""

function Base.show(io::IO, f::FunctionalResponse)
    
    str1 = "functional response: $(String(Symbol(f.functional_response)))"
    if f.hill_exponent == 1.0
        str2 = "type II"
    elseif f.hill_exponent == 2.0 
        str2 = "type III"
    else
        str2 = "h = $(f.hill_exponent)"
    end
    print(io, str1 * "\n" * str2)

end

""" 
Biological Rates
"""

function Base.show(io::IO, b::BioRates)
    
    str1 = "r (growth rate): $(b.r[1]), ..., $(b.r[end])"
    str2 = "x (metabolic rate): $(b.x[1]), ..., $(b.x[end])"
    str3 = "y (max. consumption rate): $(b.y[1]), ..., $(b.y[end])"
    print(io, str1 * "\n" * str2 * "\n" * str3)

end

"""
Environmental context
"""

function Base.show(io::IO, E::Environment)
    str1 = "K (carrying capacity): $(E.K[1]), ..., $(E.K[end])"
    str2 = "T (temperature in Kelvins - 0C = 273.15K): $(E.T) K"
    print(io, str1 * "\n" * str2)
end

"""
Adding Stochasticity
"""

function Base.show(io::IO, a::AddStochasticity)
    if a.addstochasticity == true
        str1 = "Adding stochasticity?: $(a.addstochasticity)"
        str2 = "θ (rate of return to mean): $(a.θ[1]), ..., $(a.θ[end])"
        str3 = "μ (mean of stochastic parameter): $(a.μ[1]), ..., $(a.μ[end])"
        str4 = "σe (environmental noise scaling parameter): $(a.σe[1]), ..., $(a.σe[end])"
        str5 = "σd (demographic noise scaling parameter): $(a.σd[1]), ..., $(a.σd[end])"
    else
        str1 = "Adding stochasticity?: $(a.addstochasticity)"
        str2 = "θ (rate of return to mean): Empty"
        str3 = "μ (mean of stochastic parameter): Empty"
        str4 = "σe (environmental noise scaling parameter): Empty"
        str5 = "σd (demographic noise scaling parameter): Empty"
    end

    print(io, str1 * "\n" * str2 * "\n" * str3 * "\n" * str4 * "\n" * str5)
end

"""
Stressor 
"""

function Base.show(io::IO, a::Stressor)
    str1 = "Adding a stressor?: $(a.addstressor)"
    str2 = "Which species is stressed?: $(a.stressed_species[1])"
    str3 = "Slope of stressor linear regression: $(a.slope[1])"

    print(io, str1 * "\n" * str2 * "\n" * str3)
end

"""
Model Parameters
"""

function Base.show(io::IO, MP::ModelParameters)
    str0 = "Model parameters are compiled:"
    str1 = "FoodWeb - 🕸"
    str2 = "BioRates - 📈"
    str3 = "Environment - 🌄"
    str4 = "FunctionalResponse - 🍖"
    str5 = "AddStochasticity - 📣"
    str6 = "Stressor - 🤡"
    print(io, str0 * "\n" * str1 * "\n" * str2 * "\n" * str3 * "\n" * str4 * "\n" * str5 * "\n" * str6)
end
