# Gas problem von lecture 1, linear programming
using Clp, JuMP
sources = ["NOR", "NL", "LNG1", "LNG2", "RU"]

# data from table
# capacities = Dict(zip(sources, [27,28,15,12,35])) # case with russian accessabla
capacities = Dict(zip(sources, [27,28,15,12,35]))  # case wihtout russia
production_cost = Dict(zip(sources, [54,65,88,88,36])) 
transport_cost =Dict(zip(sources, [50,5,17,18,67]))
demand = 76 # 84 - 8 produced domestically

# model
m = Model(Clp.Optimizer)
@variable(m, x[sources] >= 0)
@constraint(m,[s in sources], x[s] <= capacities[s]) # capacity constraint
@constraint(m, sum(x[s] for s in sources) >= demand) # market clearing
@constraint(m, sum(x[s] for s in sources if s in ["NOR", "NL"]) >= demand*0.5) # 50 percent of demand met by EU or Norway
@objective(m, Min, sum(x[s]*(production_cost[s]+transport_cost[s]) for s in sources))
optimize!(m)
objective_value(m)

println([[s, value.(x[s])] for s in sources])
#  ["NOR", 13.0], ["NL", 28.0], ["LNG1", 0.0], ["LNG2", 0.0], ["RU", 35.0]] # with russia
#  [["NOR", 27.0], ["NL", 28.0], ["LNG1", 15.0], ["LNG2", 6.0], ["RU", 0.0]] # without russia