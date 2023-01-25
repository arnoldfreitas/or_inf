using Complementarity
# TODO: Still not working
players = collect(1:2) # n_players 
n_ineq = 1:2  # Number of Inequalities
n_eq = 1:2    # Number of Equalities, if any

max_cap = Dict(zip(players, [2000 2500])) # n_players 
marginal_cost = 0.5 # cost_function(quant = 1)

# Define Model
m = MCPModel()
# Lagrangian Variables
@variable(m, quant[p in players] >= 0) # Quant produced by each players
@variable(m, lamb[i in n_ineq] >= 0)
# @variable(m, kappa[j in n_eq])

@mapping(m, f1, quant[2] + lamb[1] - lamb[2])
@mapping(m, f2, x[1] - lamb[1])
# Cost Function 
@mapping(m, f3, -x[1] + x[2] - 1)
@constraint(m, cost_function[p in players], 0.5*quant[p]^2 >= 0)
# Sum of all productions 
@mapping(m, f4, x[1] - 1)
@constraint(m, production, sum(quant[p] for p in players) >= 0 )


#  --- OPTIONALS --- 
# Max Cap Productions - if necessary
# @constraint(m, prod_cap[p in players], quant[p] <= max_cap[p]) # Quant produced by each players


@objective(m, Max, (210 - sum(quant[p] for p in players)) * quant[p] - cost_function[p] for p in players)
