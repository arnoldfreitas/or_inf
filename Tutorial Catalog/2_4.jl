using Clp, JuMP

edgs = collect(1:6)
max_cap = [
    0  12 10  0  0  0
    0  0  10  9  2  0
    0  6  0   2  8  0
    0  0  0   0  0  20
    0  0  0   0  0  7
    0  0  0   0  0  0
    ]

b = [18,0,0,0,0,-18]

costs = [
    0  3  2  0  0  0
    0  0  4  2  0  0
    0  4  0  2  3  0
    0  0  0  0  0  1
    0  0  0  0  0  1
    0  0  0  0  0  0
    ]

m = Model(Clp.Optimizer)
@variable(m, flow[i=edgs, j=edgs])

@constraint(m, cap[i=edgs, j=edgs], flow[i,j] <= max_cap[i,j] )
@constraint(m, node_balance[i=edgs], sum(flow[i,j] for j in edgs) == b[i])
@constraint(m, assimetry[i=edgs, j=edgs], flow[i,j] == -flow[j,i] )
@constraint(m, cost_node[i=edgs, j=edgs], costs[i,j]*flow[i,j] >=0)

@objective(m, Min, sum(costs[i,j]*flow[i,j] for i in edgs, j in edgs))
optimize!(m)

objective_value(m)
value.(flow)
value.(cost_node)
"""
  And data, a 6×6 Matrix{Float64}:
   0.0  11.0   7.0    0.0   0.0   0.0
 -11.0   0.0   0.0    9.0   2.0   0.0
  -7.0   0.0   0.0    2.0   5.0   0.0
  -0.0  -9.0  -2.0    0.0   0.0  11.0
  -0.0  -2.0  -5.0   -0.0   0.0   7.0
  -0.0  -0.0  -0.0  -11.0  -7.0   0.0

"""