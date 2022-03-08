"""
    environment()

TODO
"""

function Environment(FW::FoodWeb; K::Union{Int64, Vector{Int64}} = 1, T::Float64 = 293.15)
    if isa(K, Vector)
        isequal(length(K),richness(FW)) || throw(ArgumentError("K should be either a single value or a vector of length richness(FoodWeb)"))
    else
        K = repeat([K], richness(FW)) # everything gets a K
        K[.!_idproducers(FW.A)] .= 0 # if you aren't a producer K set to 0
    end
    return Environment(K,T)
end
