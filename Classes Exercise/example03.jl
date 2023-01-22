using JuMP
using Clp

### Sets ###
P = 1:4
N = 1:3

### Parameters ###
demand = [0, 0, 120] #MW
feedin = [80, 0, 0] #MW
gmax = [50, 100, 100, 20] # MW
mc = [10, 25, 30, 15] # EUR/MW
g_location = [[1],[2],[3,4]]
ntc = [0 10 100; 10 0 20; 100 20 0]

### Model ###
m = Model(Clp.Optimizer)

@variable(m, 0 <= G[P])
@variable(m, 0 <= F[N,N])

@objective(m, Min,
    sum(mc[p] * G[p] for p in P)
)

@constraint(m, EnergyBalance[n=N],
    sum(G[pn] for pn in g_location[n])
    + feedin[n]
    + sum(F[nn,n] - F[n,nn] for nn in N)
    >=
    demand[n]
)

@constraint(m, MaxGeneration[p=P],
    G[p] <= gmax[p]
)

@constraint(m, MaxTransfer[n=N,nn=N],
    F[n,nn] <= ntc[n,nn]
)

optimize!(m)

obj_val = objective_value(m)
generation = value.(G)
flow = value.(F)
price = dual.(EnergyBalance)

println("Total cost: ", obj_val, " €")
println("Generation: ")
for (i,g) in enumerate(generation)
    println("Generator $i produced ", g, " MW")
end
for i in eachindex(flow)
    n, nn = i[1], i[2]
    println("Flow from $n to $nn is $(flow[n,nn]) (maximum $(ntc[n,nn]))")
end
