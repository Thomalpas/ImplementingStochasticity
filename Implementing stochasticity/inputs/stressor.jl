"""
A bit of playing around I have been doing to add a Stressor

Takes 
    a FoodWeb object, 
    a boolean as to add a stressor, 
    how many stressors, (is this needed?)
    the slope of the stressors' linear regression
"""

function Stressor(FW::FoodWeb
    ;addstressor::Bool = false
    ,nstressor::Int64 = 1
    ,slope::Float64 = 0.0)
    
    @assert nstressor > 0
    
    producers = Int64[]

    for i in 1:richness(FW)
        if _idproducers(FW.A)[i]
            push!(producers, i)
        end 
    end
    
    stressed_species = sample(producers,nstressor,replace = false)

    return Stressor(addstressor, stressed_species, slope)
     
end
