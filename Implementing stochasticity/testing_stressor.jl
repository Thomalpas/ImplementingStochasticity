
include("inclusion.jl")


FW = FoodWeb([0 0 0; 1 0 0; 0 1 0], Z = 2)
BR = BioRates(FW)
AS = AddStochasticity(FW, BR, addstochasticity = true, wherestochasticity = "producers", nstochasticity = "all", θ = 0.6, σe = [0.4, 1.3, 0.3], σd = 0.0)
S = Stressor(FW, addstressor = true, slope = -1/2000)
S2 = Stressor(FW, addstressor = false, slope = -1/2000)
FR = originalFR(FW, hill_exponent = 1.0)
MP = ModelParameters(FW, FR = FR, AS = AS, S = S2)
MP2 = ModelParameters(FW, FR = FR, AS = AS, S = S)
biomass = rand(richness(FW))
run = simulate(MP, biomass, stop = 2100, interval_tkeep = 1.0)
run2 = simulate(MP2, biomass, stop = 2100, interval_tkeep = 1.0)
plot(run2.t, run2.B[:,1], title = "Loads of stochasticity", label = "Producer")
plot(run2.t, run2.B[:,1:richness(FW)], title = "How it's going", label = ["Producer" "Herbivore" "Predator"])

run.B[:,1]
maximum(run.B[:,1])
cor(run2.B[:,1],run2.B[:,1])



change = []
for i in 1:length(run2.B[:,1])-1
    fill = run2.B[i+1,1] - run2.B[i,1]
    push!(change,fill)
end

plot([1:1:2000;], change[1:2000], xlim = [0.0, 2000.0], seriestype = :scatter, label = "Producer", title = "Producer change in biomass")

change2 = []
for i in 1:length(run2.B[:,2])-1
    fill = run2.B[i+1,2] - run2.B[i,2]
    push!(change2,fill)
end

plot([1:1:2000;], change2[1:2000], xlim = [0.0, 2000.0], label = "Herbivore", seriestype = :scatter, title = "Herbivore change in biomass")

change3 = []
for i in 1:length(run2.B[:,3])-1
    fill = run2.B[i+1,3] - run2.B[i,3]
    push!(change3,fill)
end

plot([1:1:2000;], change3[1:2000], xlim = [0.0, 2000.0], title = "Predator change in biomass", seriestype = :scatter, label = "Predator")

# Autocorrelation depending on noise

FW = FoodWeb([0 0 0; 1 0 0; 0 1 0], Z = 2)
BR = BioRates(FW)
AS = AddStochasticity(FW, BR, addstochasticity = true, wherestochasticity = "producers", nstochasticity = "all", θ = 0.6, σe = 0.3, σd = 0.0)
S = Stressor(FW, addstressor = true, slope = -1/2000)
MP = ModelParameters(FW, FR = FR, AS = AS, S = S)
run = simulate(MP, biomass, stop = 2100, interval_tkeep = 1.0)

trial1 = []
for i in 1:2000
    push!(trial1,cor(run.B[i:i+9,1],run.B[i+1:i+10,1]))
end
plot1 = plot([1:1:2000;],trial1, label = nothing, seriestype = :scatter, ylim = (-0.5,1.1), title = "Producer Autocorrelation \n σe = 0.3")
for i in 1:2000
    push!(trial1,cor(run.B[i:i+9,2],run.B[i+1:i+10,2]))
end
plot2 = plot([1:1:2000;],trial1[2001:1:4000,], label = nothing, seriestype = :scatter, ylim = (-0.5,1.1), title = "Herbivore Autocorrelation \n σe = 0.3")
for i in 1:2000
    push!(trial1,cor(run.B[i:i+9,3],run.B[i+1:i+10,3]))
end
plot3 = plot([1:1:2000;],trial1[4001:1:6000,], label = nothing, seriestype = :scatter, ylim = (-0.5,1.1), title = "Consumer Autocorrelation \n σe = 0.3")

AS = AddStochasticity(FW, BR, addstochasticity = true, wherestochasticity = "producers", nstochasticity = "all", θ = 0.6, σe = 1.3, σd = 0.0)
S = Stressor(FW, addstressor = true, slope = -1/2000)
MP = ModelParameters(FW, FR = FR, AS = AS, S = S)
run = simulate(MP, biomass, stop = 2100, interval_tkeep = 1.0)

trial2 = []
for i in 1:2000
    push!(trial2,cor(run.B[i:i+9,1],run.B[i+1:i+10,1]))
end
plot4 = plot([1:1:2000;],trial2, label = nothing, seriestype = :scatter, ylim = (-0.5,1.1), title = "Producer Autocorrelation \n σe = 1.3")
for i in 1:2000
    push!(trial2,cor(run.B[i:i+9,2],run.B[i+1:i+10,2]))
end
plot5 = plot([1:1:2000;],trial2[2001:1:4000,], label = nothing, seriestype = :scatter, ylim = (-0.5,1.1), title = "Herbivore Autocorrelation \n σe = 1.3")
for i in 1:2000
    push!(trial2,cor(run.B[i:i+9,3],run.B[i+1:i+10,3]))
end
plot6 = plot([1:1:2000;],trial2[4001:1:6000,], label = nothing, seriestype = :scatter, ylim = (-0.5,1.1), title = "Consumer Autocorrelation \n σe = 1.3")

AS = AddStochasticity(FW, BR, addstochasticity = true, wherestochasticity = "producers", nstochasticity = "all", θ = 0.6, σe = 2.3, σd = 0.0)
S = Stressor(FW, addstressor = true, slope = -1/2000)
MP = ModelParameters(FW, FR = FR, AS = AS, S = S)
run = simulate(MP, biomass, stop = 2100, interval_tkeep = 1.0)

trial3 = []
for i in 1:2000
    push!(trial3,cor(run.B[i:i+9,1],run.B[i+1:i+10,1]))
end
plot7 = plot([1:1:2000;],trial3, label = nothing, seriestype = :scatter, ylim = (-0.5,1.1), title = "Producer Autocorrelation \n σe = 2.3")
for i in 1:2000
    push!(trial3,cor(run.B[i:i+9,2],run.B[i+1:i+10,2]))
end
plot8 = plot([1:1:2000;],trial3[2001:1:4000,], label = nothing, seriestype = :scatter, ylim = (-0.5,1.1), title = "Herbivore Autocorrelation \n σe = 2.3")
for i in 1:2000
    push!(trial3,cor(run.B[i:i+9,3],run.B[i+1:i+10,3]))
end
plot9 = plot([1:1:2000;],trial3[4001:1:6000,], label = nothing, seriestype = :scatter, ylim = (-0.5,1.1), title = "Consumer Autocorrelation \n σe = 2.3")

plot(plot1, plot2, plot3, plot4, plot5, plot6, plot7, plot8, plot9, layout = (3,3))
plot!(size=(1000,1000))



S.stressed_species
E.K[first(S.stressed_species)]
MP.Environment.K
run2.B[:,1]-1
E = Environment(FW)
E.K[S.stressed_species] .= 2

if S.addstressor == true
    if stop * S.slope <= -1
        throw(ArgumentError("TOO MUCH STRESS! The stressor will take carrying capacity to 0, which crashes the system"))
    end
end

stop = 1001

stop * S.slope


E.K = convert(Vector{Float64}, E.K)

stress = Stressor(FW, addstressor = true, slope = -1/1000)

StressedEnvironment(FW, S = stress)

function testode(du,u,p,t)
    
    r = [1,1]
    K = [1,(1 - (0.001 * t))] 
    

    G1 = 1 - u[1]/K[1]
    G2 = 1 - u[2]/(K[2])

    du[1] = r[1] * G1 * u[1]
    du[2] = r[2] * G2 * u[2]

end


u0 = [0.1,0.2]
tspan = (0.0, 150.0)

1 - (tspan[2] * 0.001)

1/151

testprob = ODEProblem(testode,u0,tspan)

sol = solve(testprob, dt = 0.1, adaptive = false)

plot(sol)

plot(sol, ylim = [0.0, 2.5])

K = [1,0]


K