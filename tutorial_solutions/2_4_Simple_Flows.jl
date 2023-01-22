using Clp, JuMP
# # 2.2
v_list = collect(1:6)
U = [ # adjacency capacity matrix
    0 12 10 0 0 0 
    0 0 10 9 0 0
    0 6 0 2 8 0 
    0 0 0 0 0 20 
    0 0 0 0 0 7 
    0 0 0 0 0 0
]

m = Model(Clp.Optimizer)
@variable(m, f[v_list, v_list])
@constraint(m, edge_capacity[i=v_list, j=v_list], f[i,j] <= U[i,j])
@constraint(m, nodal_balance[i=v_list; i ∉ (1,6)], sum(f[i,j] for j in v_list) == 0)
@constraint(m, antisymmetric[i=v_list, j=v_list], f[i,j] == -f[j,i])
@objective(m, Max, sum(f[1,j] for j in v_list))
optimize!(m)
println(m)
objective_value(m)

# # 2.3
U = [ # adjacency capacity matrix
    0 12 10 0 0 1000 
    0 0 10 9 0 0
    0 6 0 2 8 0 
    0 0 0 0 0 20 
    0 0 0 0 0 7 
    0 0 0 0 0 0
]

C = zeros(Int, 6, 6)
C[1,6] = 1
b = [100,0,0,0,0,-100]

m = Model(Clp.Optimizer)
@variable(m, f[v_list, v_list])
@constraint(m, edge_capacity[i=v_list, j=v_list], f[i,j] <= U[i,j])
@constraint(m, nodal_balance[i=v_list], sum(f[i,j] for j in v_list) == b[i])
@constraint(m, antisymmetric[i=v_list, j=v_list], f[i,j] == -f[j,i])
@objective(m, Min, sum(f[i,j]*C[i,j] for i in v_list, j in v_list))
optimize!(m)
objective_value(m)
println(m)
value.(f)

# # 2.4
U = [ # adjacency capacity matrix
    0 12 10 0 0 0
    0 0 10 9 2 0
    0 6 0 2 8 0 
    0 0 0 0 0 20 
    0 0 0 0 0 7 
    0 0 0 0 0 0
]

C = [ # adjacency cost matrix
    0 3 2 0 0 0 
    0 0 4 2 0 0 
    0 4 0 2 3 0 
    0 0 0 0 0 1 
    0 0 0 0 0 1 
    0 0 0 0 0 0
]
b = [18,0,0,0,0,-18]

m = Model(Clp.Optimizer)
@variable(m, f[v_list, v_list])
@constraint(m, edge_capacity[i=v_list, j=v_list], f[i,j] <= U[i,j])
@constraint(m, nodal_balance[i=v_list], sum(f[i,j] for j in v_list) == b[i])
@constraint(m, antisymmetric[i=v_list, j=v_list], f[i,j] == -f[j,i])
# @constraint(m, cost_node[i=edgs, j=edgs], C[i,j]*f[i,j] >=0)


@objective(m, Min, sum(f[i,j]*C[i,j] for i in v_list, j in v_list))
optimize!(m)

objective_value(m)
value.(f)
f = [
    0.0   8.0  10.0    0.0   0.0   0.0
    -8.0   0.0  -3.0    9.0   2.0   0.0
   -10.0   3.0   0.0    2.0   5.0   0.0
    -0.0  -9.0  -2.0    0.0   0.0  11.0
    -0.0  -2.0  -5.0   -0.0   0.0   7.0
    -0.0  -0.0  -0.0  -11.0  -7.0   0.0
]
cost = [C[i,j]*value.(f)[i,j] for i in v_list, j in v_list]




sC = zeros(Int,6,6)
for i in v
    for j in v
        if (i,j) in e_list
            temp_e = e_dict[(i,j)]
            C[i,j] = c[temp_e]
            C[j,i] = c[temp_e]
        end
    end
end


[i for i in 1:10 if i%2 == 1]
[i*j for i in 1:5, j in 5:10]


e_dict = Dict(zip(e_list, e))
u_dict = Dict(zip(e,u))
c_dict = Dict(zip(e,c))


m[:f]

e_list = [(1,2),(1,3),(2,3),(3,2),(2,5),(2,4),(3,4),(3,5),(4,6),(5,6)]
e = collect(1:length(e_list))
u = [12,10,10,6,2,9,2,8,20,7]
c = [2,2,4,4,0,2,2,3,1,1]