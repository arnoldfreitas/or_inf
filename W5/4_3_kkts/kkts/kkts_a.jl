using Complementarity

x_ind = 1:2
λ_ind = 1:2

m = MCPModel()

@variable(m, x[i in x_ind] >= 0)
@variable(m, λ[j in λ_ind] >= 0)

@mapping(m, f1, -1 + 2*λ[1] - λ[2])
@mapping(m, f2, -3 + 3*λ[1] + 2*λ[2])
@mapping(m, f3, 6 - 2*x[1] - 3*x[2])
@mapping(m, f4, x[1] - 2*x[2] + 2)

@complementarity(m, f1, x[1])
@complementarity(m, f2, x[2])
@complementarity(m, f3, λ[1])
@complementarity(m, f4, λ[2])

status = solveMCP(m; convergence_tolerance=1e-8, output="yes", time_limit=3600)
result_value.(x)
result_value.(λ)

5/7
3/7