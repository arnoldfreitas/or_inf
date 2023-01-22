using Clp, JuMP

# solved as optimization
edges_ = collect(1:5)
# max_cap
max_cap = [
    0 5 4 0 0 
    0 0 0 2 0
    0 0 0 3 1
    0 0 0 0 4 
    0 0 0 0 0
]

m = Model(Clp.Optimizer)
@variable(m, flow[edges_, edges_])
@constraint(m, cap[i=edges_, j=edges_], flow[i,j] <= max_cap[i,j])
@constraint(m, balance[i=edges_; !(i in (1,5))], sum(flow[i,j] for j in edges_) - sum(flow[j,i] for j in edges_) == 0)
@constraint(m, antisymmetric[i=edges_, j=edges_], flow[i,j] == -flow[j,i])


@objective(m, Max, sum(flow[1,j] for j in edges_))

optimize!(m)
objective_value(m)  # 5.0
value.(flow)

"""
And data, a 5×5 Matrix{Float64}:
 0.0  1.0  4.0  0.0  0.0
 0.0  0.0  0.0  1.0  0.0
 0.0  0.0  0.0  3.0  1.0
 0.0  0.0  0.0  0.0  4.0
 0.0  0.0  0.0  0.0  0.0

 0.0   1.0   4.0   0.0  0.0
 -1.0   0.0   0.0   1.0  0.0
 -4.0  -0.0   0.0   3.0  1.0
 -0.0  -1.0  -3.0   0.0  4.0
  0.0  -0.0  -1.0  -4.0  0.0
"""

# # solve using Graphs
using Graphs, GraphsFlows, GraphPlot
g = SimpleDiGraph(u)
nl = ["s",2,3,4,"t"]
edge_labels = [U[src(e),dst(e)] for e in edges(g)]
gplot(g, nodelabel=nl, edgelabel=edge_labels)

m = Model(Clp.Optimizer)
@variable(m, f[e=edges(g)])
@constraint(m, edge_capacity[e=edges(g)], f[e] <= U[src(e), dst(e)])
@constraint(m, nodal_balance[v in vertices(g); v ∉ (1,5)],
    sum(f[Edge(i,v)] for i in inneighbors(g,v)) == sum(f[Edge(v,j)] for j in outneighbors(g,v)))
@objective(m, Max, sum(f[e] for e in edges(g) if dst(e) == 5));
print(m)
optimize!(m)
objective_value(m)
value.(f)
dual.(nodal_balance) 

# plot
fopt = round.(Int, JuMP.value.(f));
edge_labels = ["$(fopt[e]) / $(U[src(e),dst(e)])" for e in edges(g)]
gplot(g, nodelabel=nl, edgelabel=edge_labels)

# # solve using GraphsFlows package
max_flow_value, flow_var = GraphsFlows.maximum_flow(
    g, # graph
    1, # source
    5, # target
    U
)
edge_labels = ["$(flow_var[src(e),dst(e)]) / $(U[src(e),dst(e)])" for e in edges(g)]
gplot(g, nodelabel=nl, edgelabel=edge_labels)