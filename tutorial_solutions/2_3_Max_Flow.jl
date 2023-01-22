using JuMP, Clp

# # solve as optimization 
v_list = collect(1:5)
U = [
    0 5 4 0 0
    0 0 0 2 0
    0 0 0 3 1
    0 0 0 0 4
    0 0 0 0 0
]

m = Model(Clp.Optimizer)
n = Model(Clp.Optimizer)
@variable(m,f[v_list, v_list])
@constraint(m, capacity[i=v_list, j=v_list], f[i,j] <= u[i,j])
@constraint(m, node_balance[i=v_list; i ∉ (1,5)], sum(f[i,j] for j in v_list) - sum(f[j,i] for j in v_list) == 0)
@constraint(m, antisymmetric[i=v_list, j=v_list], f[i,j] == -f[j,i])
@objective(m, Max, sum(f[1,j] for j in v_list))
optimize!(m)
objective_value(m)
value.(f)


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
dual.(flow_conservation) 

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