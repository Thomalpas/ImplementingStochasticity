
This manual will describe an optional module that can be added into [`ModelParameters`](@ref) to 
introduce stochastic simulations. 
Therefore we recommend reading [How to run foodweb simulations?](@ref) first

## Background

The bioenergetic food web model equations for biomass dynamics have been updated to incorporate stochasticity by making certain parameters vary via an Ornstein-Uhlenbeck process with a drift term as follows:

For producers: 

$dB_{it} = \left[ p_{it}B_{it} - \frac{r_{it}B_{it}^2}{K_i} - \sum\limits_{j \in Consumers}\frac{x_{jt}y_jB_{jt}F_{ji}}{e_{ji}} \right] \ dt + \frac{\sigma_{di}}{\sqrt{n_{it}}} \ dW_{dit}$


$dp_{it} = \theta_i(\mu_i - p_{it}) dt + \sigma_{ei} \ dW_{eit}$

For consumers:


$dB_{it} = \left[ -x_{it}B_{it} + \sum\limits_{j \in Resources}x_{it}y_iB_{it}F_{ij} - \sum\limits_{j \in Consumers}\frac{x_jy_jB_{jt}F_{ji}}{e_{ji}} \right] \ dt + \frac{\sigma_{di}}{\sqrt{n_{it}}} \ dW_{dit}$

$dx_{it} = \theta_i(\mu_i - x_{it}) dt + \sigma_{ei} \ dW_{eit}$

For more information see our upcoming paper!

## System definition

For all examples we will consider a 4-species system with two producers, one primary consumer which consumes both producers,
and a secondary consumer that consumes the primary consumer:

```@setup befwm2
using BEFWM2
```

```@repl befwm2
foodweb = FoodWeb([0 0 0 0; 0 0 0 0; 1 1 0 0; 0 0 1 0]); # 3 eats 1 & 2, 4 eats 3
```

In this package, three types of stochasticity are available:

- [Independent environmental stochasticity](@ref)
- [Correlated environmental stochasticity](@ref)
- [Demographic stochasticity](@ref)

## How to add stochasticity

All types of stochasticity are added using the `AddStochasticity` function, and there are two arguments that need to be provided:
* A `FoodWeb` object - this is the food web that stochasticity will be added to. Note: [Multiplex networks](@ref) are not compatible
* `addstochasticity` - a Boolean which must be `true` for stochasticity to be implemented

## Environmental stochasticity - independent

Environmental stochasticity is added to the model via an Ornstein-Uhlenbeck (OU) process (https://en.wikipedia.org/wiki/Ornstein%E2%80%93Uhlenbeck_process#Definition):

$dx_t = \theta(\mu - x_t) dt + \sigma \ dW_t$

This is applied to the metabolic rate, $x_i$ , in consumers, and the density independent component of the logistic growth rate, $p_i$, for producers. 

Environmental stochasticity can be applied to species individually, and so as well as a `FoodWeb` & `addstochasticity`, 5 additional optional arguments need to be provided:
* `biorates` - a `BioRates` object - to provide the mean value, $\mu$, in the OU process
* `target` - to indicate which species should be made stochastic
* `n_species` - to indicate how many species within the target group should be stochastic
* `σe` - to provide the standard deviation of the noise, $\sigma$, in the OU process
* `θ` - to provide the decay rate, $\theta$, in the OU process

```@repl befwm2
stoch_object = AddStochasticity(foodweb, addstochasticity = true, biorates = BioRates(foodweb),
    target = "producers", n_species = "all", σe = 0.5, θ = 0.7)
```
**_NOTE:_** The `biorates` argument defaults to BioRates(foodweb) - using temperature-independent allometric relationships to determine biological rates (see [BioRates](@ref), and the `n_species` argument defaults to `"all"`. Therefore the above `stoch_object` can also be produced using:

```@repl befwm2
stoch_object = AddStochasticity(foodweb, addstochasticity = true,
    target = "producers", σe = 0.5, θ = 0.7)
```

The above examples will add environmental stochasticity to all producers, with a decay rate ( $\theta$ ) of 0.7 and a standard deviation ( $\sigma_e$ ) of 0.5 . This AddStochasticity object is then passed to a `ModelParameters` object;

```@repl befwm2
params = ModelParameters(foodweb, stochasticity = stoch_object)
```

This is then passed to `simulate`, along with a vector of starting biomass (`B0`), as [normal](@ref);

```@repl befwm2
B0 = rand(richness(foodweb))
solution = simulate(params, B0)
```

## Environmental stochasticity - correlated

To make the noise processes controlling environmental stochasticity covary, one more argument needs to be passed to `simulate`; a correlation matrix. This correlation matrix needs to be square with the number of rows and columns equal to the number of stochastic species.
In the current example there are two stochastic species, so the matrix needs to be 2 x 2. This is then passed to `simulate` as the `corrmat` argument; 

```@repl befwm2
mat = [1.0 0.5; 0.5 1.0]
correlated_solution = simulate(params, B0, corrmat = mat)
```
With stochastic simulations, the `simulate` output biomass dynamics and stochastic parameter dynamics both within the field `u`. To avoid confusion, the function `tidy_output` separates out the biomass dynamics into field `B` and the stochastic parameter dynamics into field `P`. 

**_NOTE:_**  At the time of writing the `simulate` output doesn't contain the adjacency matrix, so params is also needed to tell `tidy_output` how many species there are

```@repl befwm2
tidied_solution = tidy_output(params, solution)
tidied_correlated_solution = tidy_output(params, correlated_solution)
```

It is possible to check the correlation coefficient to see the effect of including a correlation matrix on the growth parameters

```@repl befwm2
cor(tidied_solution.P[1:end,1], tidied_solution.P[1:end,2]) # No correlation, expect ~ 0.0
cor(tidied_correlated_solution.P[1:end,1], tidied_correlated_solution.P[1:end,2]) # Correlation matrix with 0.5s supplied, expect ~ 0.5
```

## Demographic stochasticity

Demographic stochasticity is applied directly to the biomass equations and automatically scaled by population size. It is applied to all species and cannot covary.
Therefore, to simulate with demographic stochasticity only one optional argument needs to be passed to the `AddStochasticity` object:
* `σd` - to provide the standard deviation of the noise process:

```@repl befwm2
stoch_object = AddStochasticity(foodweb, addstochasticity = true, σd = 0.4)
```
As with environmental stochasticity, this is then passed to `ModelParameters` and through to `simulate` with a vector of starting biomass (`B0`):

```@repl befwm2
params = ModelParameters(foodweb, stochasticity = stoch_object)
B0 = rand(richness(foodweb))
solution = simulate(params, B0)
```
