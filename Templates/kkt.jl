using Complementarity

n_x = 1:2     # Size of vector x in objective function
n_ineq = 1:2  # Number of Inequalities
n_eq = 1:2    # Number of Equalities, if any

# Define Model
m = MCPModel()
# Lagrangian Variables
@variable(m, x[i in n_x] >= 0)
@variable(m, lamb[j in n_ineq] >= 0)
# @variable(m, kappa[j in n_eq])

# Define derivate of Lagrangian Functions (KKT Conditions)
@mapping(m, f1, x[2] + lamb[1] - lamb[2])
@mapping(m, f2, x[1] - lamb[1])
@mapping(m, f3, -x[1] + x[2] - 1)
@mapping(m, f4, x[1] - 1)

# Define Complementarity Conditions (prep operator) 
@complementarity(m, f1, x[1])
@complementarity(m, f2, x[2])
@complementarity(m, f3, lamb[1])
@complementarity(m, f4, lamb[2])

status = solveMCP(m; convergence_tolerance=1e-8, output="yes", time_limit=3600)
@show result_value.(x)
@show result_value.(lamb)
# @show result_value.(kappa)