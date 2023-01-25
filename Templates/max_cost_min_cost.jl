using Clp, JuMP

vertices = collect(1:6) # Nodes
# max_cap on edges between vertices shape: (nodes, nodes)
# Can solva max flow problem first and set max_cap(node,node) = flow(node,node)
max_cap = [
    0  12 10  0  0  0
    0  0  10  9  2  0
    0  6  0   2  8  0
    0  0  0   0  0  20
    0  0  0   0  0  7
    0  0  0   0  0  0
    ]

# b(i) > 0: supply node; b(i) = 0: transport node; b(i) < 0: demand node
b = [18,0,0,0,0,-18]

# costs on edges between vertices shape: (nodes, nodes)
costs = [
    0  3  2  0  0  0
    0  0  4  2  0  0
    0  4  0  2  3  0
    0  0  0  0  0  1
    0  0  0  0  0  1
    0  0  0  0  0  0
    ]

m = Model(Clp.Optimizer)
@variable(m, flow[i=vertices, j=vertices])

# Cap Constraint
@constraint(m, cap[i=vertices, j=vertices], flow[i,j] <= max_cap[i,j] )
# Node balance
@constraint(m, node_balance[i=vertices], sum(flow[i,j] for j in vertices) == b[i])
# Antisymetry
@constraint(m, assimetry[i=vertices, j=vertices], flow[i,j] == -flow[j,i] )
# Non Negative Costs - If comment out must be sure max cap is set for max flow network
@constraint(m, cost_node[i=vertices, j=vertices], costs[i,j]*flow[i,j] >=0)

@objective(m, Min, sum(costs[i,j]*flow[i,j] for i in vertices, j in vertices))
optimize!(m)

objective_value(m)
value.(flow)
value.(cost_node)