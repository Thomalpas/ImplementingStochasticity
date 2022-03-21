# Adding Stohasticity

For the model to produce early warning signals it needs to have stochasticity. 
Here we show how stochasticity can been added, and how to change the parameters involved.

Two types of stochasticity have been added. Demographic stochasticity is the intrinsic uncertainty relating to survival and reproduction.
This can either be added to all species or to none, and is applied directly to equations affecting biomass. 
Environmental stochasticity is the random effects of the environment on a population, and can be applied to some species but not others. 
In addition, environmental stochasticity has been 

## The modified BEFW equations

The classic BEFW equations (Yodzis & Innes, 1992) have been modified as follows to incorporate stochastic processes. 
The equation to add environmental stochasticity to a parameter is an Ornstein-Uhlenbeck process with a drift term: 
(https://en.wikipedia.org/wiki/Ornstein%E2%80%93Uhlenbeck_process)

![image](https://user-images.githubusercontent.com/92929876/159228743-b256f2eb-1ccb-43ed-9a55-1989fbf09e9a.png)

## Default settings - no stochasticity

Stochasticity has been implemented so that calling the `ModelParameters` function with default settings does not add any stochasticity. 
This is because both the new stochastic model and the original deterministic model use the same `simulate` function to run simulations.

~~~julia> # Define a food web  
julia> using EcologicalNetworks  
julia> FW = FoodWeb(nichemodel, 20, C = 0.2, Z = 10)
20 species - 69 links. 
 Method: nichemodel
julia> # call ModelParameters function with default settings. 
julia> MP = ModelParameters(FW)
Model parameters are compiled:
FoodWeb - 🕸
BioRates - 📈
Environment - 🌄
FunctionalResponse - 🍖
AddStochasticity - 📣
Stressor - 🤡
julia> # inspect the AddStochasticity object
julia> MP.AddStochasticity
Adding stochasticity?: false
θ (rate of return to mean): Empty
μ (mean of stochastic parameter): Empty
σe (environmental noise scaling parameter): Empty
σd (demographic noise scaling parameter): Empty
~~~

## The AddStochasticity object

### AddStochasticity input

The `AddStochasticity` object takes 8 arguments:

* A `FoodWebs` object that describes the network stochasticity is being added to
* A `BioRates` object that provides the mean values for the parameters envrionmental stochasticity is applied to
* A Boolean `addstochasticity` that determines whether stochasticity will be added or not
* `wherestochasticity`, which details to which species stochasticity will be added. This can take several forms.
If provided with "producers", "consumers", or "allspecies", stochastcity is added to producers, consumers, or all species respectively. 
`wherestochasticty` can also take an integer or vector of integers - which relate to species positions in the food web's interaction matrix - 
e.g. providing the argument `wherestochasticity = [2, 5, 7]` will add stochasticity to species 2, 5 or 7. There is no default.
* `nstochasticity` details the number of species in the group indicated by `wherestochasticity` that  will be randomly selected
and environmental stochasticity will be added to. The `nstochasticity` argument can also take several forms.
If provided with "all" or "random", then stochasticity is respectively added to all the species specified by `wherestochastcity` or a random number.
Additionally an integer can be supplied. There is no default.
* `θ` is a positive Float64 or vector of type Float64 that provides the parameter that scales the speed of the return to the mean 
in an Orstein-Uhlenbeck process (and equation 2 above) following perturbation. There is no default.
* `σe` can take a Float64 or vector of type Float64. 
The *i<sup>th</sup>* value provided controls the standard deviation of the Wiener process for environmental stochasticity
being applied to the *i<sup>th</sup>* environmentally stochastic species (see equation 2). There is no default.
* `σd` can take a Float64 or vector of type Float64 and with length equal to the number of species in the food web. 
The *i<sup>th</sup>* value provided controls the standard deviation of the Wiener process for demographic stochasticity
being applied to the *i<sup>th</sup>* species (see equation 1). The default is 0.

Note: There are certain combinations of arguments where the number of species having environmental stochasticity added to is unknown 
or may vary between networks when performing multiple runs. 
Because of this, if vectors provided for `θ` & `σe`, or the number of species specified by `nstochasticity`, are of incorrect size
then they will be trimmed or repeated until reaching the required length, with warnings provided to detail this procedure. 
This is not the case for `σd`, as this needs a length matching the total number of species, which is always known.
For an example we have a case where a 10 species network is created with 3 producers, but the AddStochasticty arguments attempt to add stochasticity to 8:

~~~
julia> # Define a food web
julia> using EcologicalNetworks
julia> FW = FoodWeb(nichemodel, 10, C = 0.2, Z = 10)
julia> # Create an AddStochasticity object 
julia> AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
    , wherestochasticity = "producers", nstochasticity = 8
    , θ = [0.8, 0.6, 0.5, 0.3], σe = [0.2,0.8])
┌ Warning: nstochasticity greater than number of species. 
│  Adding stochasticity to all species
└ @ Main /Volumes/GoogleDrive-108130493632107549870/My Drive/PhD/Julia/BEFWM2/Implementing stochasticity/inputs/stochasticity.jl:68
┌ Warning: You have provided 4 θ values and there are 3 stochastic species. 
│  Using the first 3 values of θ
└ @ Main /Volumes/GoogleDrive-108130493632107549870/My Drive/PhD/Julia/BEFWM2/Implementing stochasticity/inputs/stochasticity.jl:112
┌ Warning: You have provided 2 σe values and there are 3 stochastic species. 
│  Repeating σe until there are 3 values of σe
└ @ Main /Volumes/GoogleDrive-108130493632107549870/My Drive/PhD/Julia/BEFWM2/Implementing stochasticity/inputs/stochasticity.jl:176
Adding stochasticity?: true
θ (rate of return to mean): 0.8, ..., 0.5
μ (mean of stochastic parameter): 1.0, ..., 1.0
σe (environmental noise scaling parameter): 0.2, ..., 0.2
σd (demographic noise scaling parameter): 0.0, ..., 0.0
julia> # Check vectors
julia> AS.θ
3-element Vector{Float64}:
 0.8
 0.6
 0.5
julia> AS.σe
3-element Vector{Float64}:
 0.2
 0.8
 0.2
~~~

### AddStochasticity output

The `AddStochasticity` object that is passed to `ModelParameters` contains all the information relating to how stochasticity is being modelled,
and specifically which species are having environmental stochasticity added to them - 
although this is currently hiden from view and more for use by internal functions to correctly build the equations.
The AddStochasticity object has these fields:

* `addstochasticity` - a Boolean indicating whether or not stochasticity will be added.
* `θ` - a vector of type Float64 created from the `θ` input.
It is the same length as the number of species selected for environmental stochasticity 
and controls the speed of return to the mean following perturbation of the noise processes of these species.
* `μ` - a vector of type Float64 created from the inputted `BioRates` object.
It is the same length as the number of species selected for environmental stochasticity 
and provides a mean value for the stochastic parameter by taking the field `x` from the `BioRates` object for consumers, and `r` for producers.
* `σe` - a vector of type Float64 created from the `σe` input. 
It is the same length as the number of species selected for environmental stochasticity
and contains the standard deviations of the noise processes for all the stochastic parameters.
* `σd` - a vector of type Float64 created from the `σd` input. 
It is the same length as the number of species in the network 
and contains the standard deviations of the noise processes providing demographic stochasticity.
* `stochspecies` - a vector hidden from the output display that indicates which species in the interaction matrix have environmental stochasticity.
* `stochproducers` - a vector hidden from the output display that indicates which producers in the interaction matrix have environmental stochasticity.
* `stochconsumers` - a vector hidden from the output display that indicates which consumers in the interaction matrix have environmental stochasticity.

## Modifications to the `simulate` function

The function `simulate` is still used to simulate biomass dynamics for the given timespan
