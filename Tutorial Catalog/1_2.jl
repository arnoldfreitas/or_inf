using Clp, JuMP

land_area = 100 # acres
invest = 720 # k.euro
max_sunflower_area = 40 # acres

product = ["Corn", "Sunflower"]

cost_p = Dict(zip(product, [6,9])) # k.euro
profit_p = Dict(zip(product, [1,2]))# k.euro

m = Model(Clp.Optimizer)
@variable(m, area_p[product] >= 0)
@constraint(m, area_p["Sunflower"] <=40)
@constraint(m, sum(area_p[p] for p in product) <= 100)
@constraint(m, sum(area_p[p]*cost_p[p] for p in product) <= 720)

@objective(m, Max,  sum(area_p[p]*profit_p[p] for p in product))

optimize!(m)
objective_value(m)

println([[s, value.(area_p[s])] for s in product])
# Vector{Any}[["Corn", 60.0], ["Sunflower", 40.0]]