# # 1.2) Max and the fuel crops
using JuMP, Clp

# data input
crops = [:corn,:sunflower]
cost = Dict(crops .=> [6,9])
profit = Dict(crops .=> [1,2])

# model
m = Model(Clp.Optimizer)
@variable(m, x[crops] >= 0) # non-negativity
@constraint(m, max_acres, sum(x[c] for c in crops) <= 100) # max acres
@constraint(m, max_invest, sum(x[c]*cost[c] for c in crops) <= 720) # maximum investment
@constraint(m, sunflowers, x[:sunflower] <= 40) # sunflower constraint
@objective(m, Max, sum(x[c]*profit[c] for c in crops))
optimize!(m)
objective_value(m)
value.(x)