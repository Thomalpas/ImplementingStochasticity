# Adding Stohasticity

For the model to produce early warning signals it needs to have stochasticity. 
Here we show how stochasticity can been added, and how to change the parameters involved.

Two types of stochasticity have been added. Demographic stochasticity is the intrinsic uncertainty relating to survival and reproduction.
This can either be added to all species or to none, and is applied directly to equations affecting biomass. 
Environmental stochasticity is the random effects of the environment on a population, and can be applied to some species but not others. 
In addition, it is possible for the noise processes causing environmental stochasticity to covary with each other - though demographic noise processes always remain independent. 

## The modified BEFW equations

The classic BEFW equations (Yodzis & Innes, 1992) have been modified as follows to incorporate stochastic processes. 
The equation to add environmental stochasticity to a parameter is an Ornstein-Uhlenbeck process with a drift term: 
(https://en.wikipedia.org/wiki/Ornstein%E2%80%93Uhlenbeck_process)

![image](https://user-images.githubusercontent.com/92929876/159228743-b256f2eb-1ccb-43ed-9a55-1989fbf09e9a.png)

## Default settings - no stochasticity

Stochasticity has been implemented so that calling the `ModelParameters` function with default settings does not add any stochasticity. 
This is because both the new stochastic model and the original deterministic model use the same `simulate` function to run simulations.

Therefore, unless an `AddStochasticity` object is called and passed to `ModelParameters`, this entire module can be ignored and will not be used by `simulate`, and so will have no effect on the simulation of biomass dynamics. For example:

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

If the intention is to add stochasticity to the BEFW, an `AddStochasticity` object needs to be created and passed to `ModelParameters`. The `AddStochasticity` function creates the object, and takes 8 arguments:

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
being applied to the *i<sup>th</sup>* species (see equation 1). The default is 0.0 (no demographic stochasticity).

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

## Modifications to the simulate function

The function `simulate` is used to simulate biomass dynamics for the given timespan, whether stochasticity is being added or not. 
This is controlled by the condition of the `addstochasticity` Boolean within the `AddStochasticity` object; if `addstochasticity = false`,
then the `simulate` function will construct and solve an ODE problem in the usual way.
However, if `addstochasticity = true`, then `simulate` will instead create and solve an SDE problem, adding stochasticity to the BEFW dynamics. 

The noise process that is passed to the SDE problem is a correlated wiener process, as this gives environmental stochasticity the potential to covary.
It was considered more intuitive for the user to provide a correlation matrix for the environmental stochasticity, which is converted to a covariance matrix.

As such, addition arguments can be supplied that will only do something if stochasticity is being added. 

* `extinction_threshold` - although this argument was already in the `simulate` function it was unused. Provide a Float64 (default is 1e-6) and any biomass value that goes below this threshold will at the next timestep be set to 0.0 
* `corrmat` - a correlation matrix for adding covarying environmental noise processes. This matrix has to be square, positive definite, and have dimensions at least as big as the number of environmental noise processes. Because, for instance, adding environmental stochasticity to all producers may vary the size of matrix required, a provided correlation matrix that is too big will be trimmed to size - although there is no process for extrapolating a too-small matrix. The default is an identity matrix, providing no covariance. 

## Adding stochasticity - an example

In this example we will produce a network using the niche model and simulate it with no stochasticity and with adding stochasticity to 2 producers. We will plot the results side-by-side for a direct comparison.

~~~
julia> # Define a food web
julia> using EcologicalNetworks, Plots
julia> FW = FoodWeb(nichemodel, 10, C = 0.2, Z = 10)
10 species - 27 links. 
 Method: nichemodel
julia> # Call the ModelParameters function with default settings
julia> MP = ModelParameters(FW)
Model parameters are compiled:
FoodWeb - 🕸
BioRates - 📈
Environment - 🌄
FunctionalResponse - 🍖
AddStochasticity - 📣
Stressor - 🤡
julia> # Create a random vector of biomasses and simulate BEFW dynamics 
julia> biomass = rand(richness(FW))
10-element Vector{Float64}:
 0.5051702184341095
 0.573834363702471
 0.016871039022351986
 0.16338946608077587
 0.6153973996860426
 0.8765245999871492
 0.8763490269113854
 0.7066798642909136
 0.29262838821207426
 0.19325524384390635
julia> run = simulate(MP, biomass)
(ModelParameters = Model parameters are compiled:
FoodWeb - 🕸
BioRates - 📈
Environment - 🌄
FunctionalResponse - 🍖
AddStochasticity - 📣
Stressor - 🤡, t = [0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25  …  497.75, 498.0, 498.25, 498.5, 498.75, 499.0, 499.25, 499.5, 499.75, 500.0], B = [0.5051702184341095 0.573834363702471 … 0.29262838821207426 0.19325524384390635; 0.39413565298553255 0.5616828116223318 … 0.31436439894201024 0.20531711370446654; … ; 0.3140572069543845 0.1713219269672154 … 0.03333658147233786 0.26446754337095774; 0.3140877551644615 0.17132209074562957 … 0.03334085783888716 0.2644273461768384])
julia> pl1 = plot(run.t, run.B, label = nothing, title = "No stochasticity")
julia> # Create an AddStochasticity object
julia> AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
    , wherestochasticity = "producers", nstochasticity = 2
    , θ = [0.8, 0.6], σe = [0.2,0.8])
Adding stochasticity?: true
θ (rate of return to mean): 0.8, ..., 0.6
μ (mean of stochastic parameter): 1.0, ..., 1.0
σe (environmental noise scaling parameter): 0.2, ..., 0.8
σd (demographic noise scaling parameter): 0.0, ..., 0.0
julia> # Call the ModelParameters function with this AddStochasticity object
julia> MP2 = ModelParameters(FW, AS = AS)
Model parameters are compiled:
FoodWeb - 🕸
BioRates - 📈
Environment - 🌄
FunctionalResponse - 🍖
AddStochasticity - 📣
Stressor - 🤡
julia> # Simulate biomass dynamics using the original biomass vector and our new ModelParameters object
julia> run2 = simulate(MP2, biomass)
(ModelParameters = Model parameters are compiled:
FoodWeb - 🕸
BioRates - 📈
Environment - 🌄
FunctionalResponse - 🍖
AddStochasticity - 📣
Stressor - 🤡, t = [0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25  …  497.75, 498.0, 498.25, 498.5, 498.75, 499.0, 499.25, 499.5, 499.75, 500.0], B = [0.5051702184341095 0.573834363702471 … 1.0 1.0; 0.39388285104132414 0.5620444638933464 … 1.0916078163748413 1.1807362796318157; … ; 0.26246551379589067 0.16549059411113845 … 0.7782207837820889 0.08174114690148288; 0.2581128295741214 0.16094092835833065 … 0.7222850155815512 0.23204708286808665])
julia> # Plot just the biomass dynamics
julia> pl2 = plot(run2.t, run2.B[:,1:richness(FW)], label = nothing, title = "Added stochasticity")
julia> # Plot the two side by side
julia> plot(pl1, pl2, size = (1200, 400))
~~~
![image](https://user-images.githubusercontent.com/92929876/159461307-00180814-fbc2-4dcc-bdd3-083d232ffec2.png)
