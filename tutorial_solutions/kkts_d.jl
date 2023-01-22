using Complementarity

pv = 1:1
dv = 1:2

m = MCPModel()

@variable(m, x[i in pv] >= 0)
@variable(m, l[j in dv] >= 0)

@mapping(m, f1, 2 * x[1] - l[1] + l[2])
@mapping(m, f2, x[1] + 1)
@mapping(m, f3, -x[1] + 1)

@complementarity(m, f1, x[1])
@complementarity(m, f2, l[1])
@complementarity(m, f3, l[2])

status = solveMCP(m; convergence_tolerance=1e-8, output="yes", time_limit=3600)
@show result_value.(x)
@show result_value.(l)
