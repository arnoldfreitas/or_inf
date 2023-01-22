# # 1.1 Max the Builder
using JuMP, Clp

# # the GAMS way
PRODUCTS = collect(1:2) # 1: fences, 2: gazebos
INPUTS = collect(1:3) # 1: nails, 2: finish, 3: planks
# input parameter from table
b_ij = [
    350 550
    4.5 3.5
    70 140
]
π_i = [2000, 2500] # profit
b_max = [5000, 33, 770] # available stock

m = Model(Clp.Optimizer)
@variable(m, x[PRODUCTS] >= 0);
@constraint(m, production_constraint[i=INPUTS], sum(b_ij[i,p]*x[p] for p in PRODUCTS) <= b_max[i]);
@objective(m, Max, sum(x[p]*π_i[p] for p in PRODUCTS)-500);
optimize!(m)
objective_value(m)
value.(x) # production variables
dual.(production_constraint) # dual on production constraint

# # the human readable version
using DataFrames

# create dataframe from input table
df = DataFrame(Inputs = ["Nails", "Finish", "Planks"],
                Fence = [350, 4.5, 70],
                Gazebo = [550, 3.5, 140],
                Max_Production = [5000, 33, 770])

inputs = df.Inputs # production inputs
products = names(df)[2:3] # products

# create dicts
fence = Dict(df.Inputs .=> df.Fence)
gazebo = Dict(df.Inputs .=> df.Gazebo)
max_prod = Dict(df.Inputs .=> df.Max_Production)
profit = Dict(products .=> [2000, 2500])

# model
m_v1 = Model(Clp.Optimizer)
@variable(m_v1, x[products] >= 0) # production variable for each product
@constraint(m_v1, production_constraint[i=inputs], fence[i]*x["Fence"] + gazebo[i]*x["Gazebo"] <= max_prod[i]) # max production
@objective(m_v1, Max, sum(x[p]*profit[p] for p in products)-500)
optimize!(m_v1)
objective_value(m_v1)

# # written out constraints
m_v2 = Model(Clp.Optimizer)
@variables m_v2 begin
    x1 >= 0 # fences
    x2 >= 0 # gazebos
end
@constraint(m_v2, nails, 350*x1 + 550*x2 <= 5000);
@constraint(m_v2, buckets, 4.5*x1 + 3.5*x2 <= 33);
@constraint(m_v2, planks, 70*x1 + 140*x2 <= 770);
@objective(m_v2, Max, 2000*x1 + 2500*x2 - 500)
optimize!(m_v2)
objective_value(m_v2)
value(x1)
value(x2)