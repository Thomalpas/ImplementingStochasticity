# Stressors

This is a quite possibly temporary module to implement a stressor into the BEFW. 
We recommend familiarising yourself with the AddStochasticity implementation first because this module is embedded within those changes.
It works by incrementally reducing the intrinsic growth rate, *r<sub>i</sub>*, of a random producer, such that *r<sub>i</sub>* = 1 + (slope x t).

Although adding a stressor only works when also adding stochasticity (i.e `addstochasticity = true` within the `AddStochasticity` object),
the producer being stressed does not have to be stochastic. 

## The Stressor function

Creating a `Stressor` object uses the `Stressor` function, which takes 3 arguments:

* the `FoodWeb` object defining the network stress is being added into
* `addstressor` - a Boolean that indicates whether a stressor is to be added. Defaults to `false`
* `slope` - a Float64 that provides a linear rate of change for the intrinsic growth rate being stressed. Defaults to 0.0

## The Stressor object

The `Stressor` object has 3 outputs:

* `addstressor` - The Boolean that was inputted into the `Stressor` function using the `addstressor` argument
and will determine if a stressor will be added
* `stressed_species` - an integer that indicates which producer has been randomly selected to be stressed. 
The value of the integer relates to position in the interaction matrix
* `slope` - The Float64 that was inputted into the `Stressor` function using the `slope` argument
and will determine the gradient of the stressor's linear regression

## Example: adding stress to a 3-species chain

In this example the intrinsic growth rate of the producer is being reduced by 0.0025 every timestep.

~~~
julia> # Define a 3 species chain by supplying a matrix to FoodWeb
julia> using EcologicalNetworks, Plots
julia> FW = FoodWeb([0 0 0; 1 0 0; 0 1 0], Z = 10)
3 species - 2 links. 
 Method: unspecified
julia> # Call the ModelParameters function with an AddStochasticity object defined
julia> AS = AddStochasticity(FW, BioRates(FW), addstochasticity = true
           , wherestochasticity = "producers", nstochasticity = 1
           , θ = 0.8, σe = 0.2)
Adding stochasticity?: true
θ (rate of return to mean): 0.8, ..., 0.8
μ (mean of stochastic parameter): 1.0, ..., 1.0
σe (environmental noise scaling parameter): 0.2, ..., 0.2
σd (demographic noise scaling parameter): 0.0, ..., 0.0
julia> MP = ModelParameters(FW, AS = AS)
Model parameters are compiled:
FoodWeb - 🕸
BioRates - 📈
Environment - 🌄
FunctionalResponse - 🍖
AddStochasticity - 📣
Stressor - 🤡
julia> # Create a random vector of biomasses and simulate BEFW dynamics 
julia> biomass = rand(richness(FW))
3-element Vector{Float64}:
 0.46097029156190183
 0.03652970578698744
 0.08388785600530646
julia> run = simulate(MP, biomass)
(ModelParameters = Model parameters are compiled:
FoodWeb - 🕸
BioRates - 📈
Environment - 🌄
FunctionalResponse - 🍖
AddStochasticity - 📣
Stressor - 🤡, t = [0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25  …  497.75, 498.0, 498.25, 498.5, 498.75, 499.0, 499.25, 499.5, 499.75, 500.0], B = [0.5993433332203497 0.00040919781129011845 0.3071279334020619 1.0; 0.6582750662343908 0.0004855435934540636 0.2995940306146958 1.1249213502681072; … ; 0.4362837341629651 0.19878978382017218 0.6197734088020748 1.1410349497919938; 0.436125355256014 0.2005636525901539 0.6213160286636724 1.047968566761634])
julia> # Plot the simulation with no stressor
julia> pl1 = plot(run.t, run.B[:,1:richness(FW)], label = ["Producer" "Herbivore" "Carnivore"], title = "No stressor", xlab = "Time", ylab = "Biomass")
julia> # Create a Stressor object
julia> S = Stressor(FW, addstressor = true, slope = -0.0025)
Adding a stressor?: true
Which species is stressed?: 1
Slope of stressor linear regression: -0.0025
julia> # Call the ModelParameters function with both the AddStochasticity Stressor objects
julia> MP2 = ModelParameters(FW, AS = AS, S = S)
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
Stressor - 🤡, t = [0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25  …  499.98999999969027, 499.98999999969027, 499.99999999969026, 499.99999999969026, 499.99999999969026, 499.99999999969026, 500.0, 500.0, 500.0, 500.0], B = [0.5993433332203497 0.00040919781129011845 0.3071279334020619 1.0; 0.6568537770084761 0.00048549737263191577 0.2995940306119626 0.9612930147829437; … ; 7.3793681962880686e-6 0.0 0.0 -0.2800217803304669; 7.3793681962880686e-6 0.0 0.0 -0.2800217803304669])
julia> # Plot just the biomass dynamics
julia> pl2 = plot(run2.t, run2.B[:,1:richness(FW)], label = ["Producer" "Herbivore" "Carnivore"], title = "Added stressor", xlab = "Time", ylab = "Biomass")
julia> # Plot the two side by side
julia> plot(pl1, pl2, size = (1200, 400))
~~~
![image](https://user-images.githubusercontent.com/92929876/159525032-c495d8e2-297c-4956-93ea-75b3efe771f5.png)

