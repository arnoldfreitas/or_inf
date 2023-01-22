using Clp, JuMP

nodes = collect(1:7)
cap_vert = [
    0  0  0  10  0  0   0
    0  0  0  10  0  0   0
    0  0  0  0   5  6   0
    0  0  0  0   0  10  0
    0  0  0  0   10 0   5
    0  0  0  0   0  0   0
    0  0  0  0   0  0   0
]

cost_vert = [
    0  0  0  2  0  0  0
    0  0  0  3  0  0  0
    0  0  0  0  2  4  0
    0  0  0  0  0  1  0
    0  0  0  0  1  0  2
    0  0  0  0  0  0  0
    0  0  0  0  0  0  0
]

cap_node_supply = [10, 10, 15, 0, 0, 0, 0]
cap_node_demand = [0, 0, 0, -15, -5, -7, -5]
# cost_node = [1, 1, 1, 3, 5, 6, 5]
cap_node = [10, 10, 11, -15, 5, -6, -5] # Adapting for max flow
cost_node = [1, 1, 1, -3, -5, -6, -5]

m = Model(Clp.Optimizer)
@variable(m, flow[nodes,nodes])
# @variable(m, quant_node[i=nodes,i=nodes])

@constraint(m, capacity_vert[i=nodes, j=nodes], flow[i,j] <= cap_vert[i,j])
# @constraint(m, balance_node_s[i=nodes], sum(flow[i,j] for j in nodes) <= cap_node_supply[i])
# @constraint(m, balance_node_d[i=nodes], sum(flow[i,j] for j in nodes) >= cap_node_demand[i])

@constraint(m, balance_node_s[i=nodes], sum(flow[i,j] for j in nodes) == cap_node[i])
# @constraint(m, costs_node[i=nodes], sum((cost_vert[i,j]+cost_node[i])*flow[i,j] for j in nodes) >=0)
@constraint(m, antisymmetric[i=nodes, j=nodes], flow[i,j] == -flow[j,i])

@objective(m, Min, sum((cost_vert[i,j]+cost_node[i])*flow[i,j] for i in nodes, j in nodes))

optimize!(m)
objective_value(m)
value.(flow)
# value.(costs_node)
value.(balance_node_s)
value.(balance_node_d)
value.(capacity_vert)