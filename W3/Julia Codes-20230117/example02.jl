using JuMP
using Clp
using Plots

### Sets ###
P = 1:2
T = 1:4

### Parameters ###
demand = [110, 120, 120, 120] #MW
feedin = [100, 60, 130, 80] #MW
gmax = [50, 300] # MW
mc = [10, 25] # EUR/MW

### Model ###
m = Model(Clp.Optimizer)

@variable(m, 0 <= G[P,T])

@objective(m, Min,
    sum(mc[p] * G[p,t] for p in P, t in T)
)

@constraint(m, EnergyBalance[t=T],
    sum(G[p,t] for p in P) + feedin[t] >= demand[t]
)

@constraint(m, MaxGeneration[p=P, t=T],
    G[p,t] <= gmax[p]
)

optimize!(m)

obj_val = objective_value(m)
generation = value.(G)

generation_w_feedin = vcat(
    reshape(feedin, 1,:),
    generation.data
)'

areaplot(
    generation_w_feedin,
    label=["feedin" 1 2],
    color=["green" "brown" "orange"]
)

plot!(
    demand,
    label="Demand",
    color="black",
    width=3,
    legend=:bottomleft
)