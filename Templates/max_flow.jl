using Clp, JuMP

# solved as optimization
vertices = collect(1:5) # Nodes
# max_cap on edges between vertices shape: (nodes, nodes)
max_cap = [
    0 5 4 0 0 
    0 0 0 2 0
    0 0 0 3 1
    0 0 0 0 4 
    0 0 0 0 0
]

m = Model(Clp.Optimizer)
@variable(m, flow[vertices, vertices])vertices

# Cap Constraint
@constraint(m, cap[i=vertices, j=vertices], flow[i,j] <= max_cap[i,j])
# Node balance
@constraint(m, balance[i=vertices; !(i in (1,5))], sum(flow[i,j] for j in vertices) - sum(flow[j,i] for j in vertices) == 0)
# Antisymetry
@constraint(m, antisymmetric[i=vertices, j=vertices], flow[i,j] == -flow[j,i])


@objective(m, Max, sum(flow[1,j] for j in vertices))

optimize!(m)
objective_value(m)  # 5.0
value.(flow)