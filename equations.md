
$F_{ij} = \omega_{ij} \alpha_i B_j + \sigma_e + \theta$

```math
F_{ij} = \omega_{ij} \alpha_i B_j
```


```@setup befwm2
using BEFWM2
```

Note: This manual will describe an optional module that can be added into ModelParameters to 
introduce stochastic simulations. 
Therefore we recommend reading [How to run foodweb simulations?](@ref) first

The bioenergetic food web model equations for biomass dynamics have been updated to incorporate stochasticity by making certain parameters vary via an Ornstein-Uhlenbeck process with a drift term (;

For producers: 

$dB_{it} = \left[ p_{it}B_{it} - \frac{r_{it}B_{it}^2}{K_i} - \sum\limits_{j \in Consumers}\frac{x_{jt}y_jB_{jt}F_{ji}}{e_{ji}} \right] \ dt + \frac{\sigma_{di}}{\sqrt{n_{it}}} \ dW_{dit}$


$dp_{it} = \theta_i(\mu_i - p_{it}) dt + \sigma_{ei} \ dW_{eit}$

For consumers:


$dB_{it} = \left[ -x_{it}B_{it} + \sum\limits_{j \in Resources}x_{it}y_iB_{it}F_{ij} - \sum\limits_{j \in Consumers}\frac{x_jy_jB_{jt}F_{ji}}{e_{ji}} \right] \ dt + \frac{\sigma_{di}}{\sqrt{n_{it}}} \ dW_{dit}$

$dx_{it} = \theta_i(\mu_i - x_{it}) dt + \sigma_{ei} \ dW_{eit}$

This allows to add demographic stochasticity directly to all species biomasses (which is automatically scaled by population size, $n_{it}$), and environmental stochasticity via the density independent component of the logistic growth rate, $p_i$, for producers, and the metabolic rate, $x_i$, for consumers.

## System definition

For all examples we will consider a 4-species system with two producers, one primary consumer which consumes both,
and a secondary consumer that consumes the primary consumer

```@repl befwm2
foodweb = FoodWeb([0 0 0 0; 0 0 0 0; 1 1 0 0; 0 0 1 0]); # 3 eats 1 & 2, 4 eats 3
```

In this package, three types of stochasticity are available:

- [Independent environmental stochasticity](@ref)
- [Correlated environmental stochasticity](@ref)
- [Demographic stochasticity](@ref)


## Independent environmental stochasticity
Stochasticity is added to the model using the AddStochasticity function;

```@repl befwm2
stochasticity = AddStochasticity(foodweb, BioRates(foodweb), addstochasticity = true, 
    wherestochasticity = "producers", nstochasticity = "all", σe = 0.5, θ = 0.7);
```

The above example will add environmental stochasticity to all producers, with a decay rate ( $\theta$ ) of 0.7 and a standard deviation ( $\sigma_e$ ) of 0.5 . This AddStochasticity object is then passed to a ModelParameters object, 
