using JuMP
using Clp

### Sets ###
P = 1:3

### Parameters ###
demand = 120 #MW
feedin = 60 #MW
gmax = [50, 300, 10] # MW
mc = [25, 30, 26] # EUR/MW

### Model ###
m = Model(Clp.Optimizer)

@variable(m, 0 <= G[P])

@objective(m, Min,
    sum(mc[p] * G[p] for p in P)
)

@constraint(m, EnergyBalance,
    sum(G[p] for p in P) + feedin >= demand
)

@constraint(m, MaxGeneration[p=P],
    G[p] <= gmax[p]
)

optimize!(m)

obj_val = objective_value(m)
generation = value.(G)
price = dual(EnergyBalance)

println("Total cost: ", obj_val, " €")
println("Generation: ")
for (i,g) in enumerate(generation)
    println("Generator $i produced ", g, " MW")
end
println("Feedin is $feedin")