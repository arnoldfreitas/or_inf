using Clp, JuMP

products = collect(1:2) # 2 products
sources = collect(1:3) # 4 Ressources Types

# Data Table of shape (n_products, n_ressources)
data_table = [
    350 550
    4.5 3.5
    70 140
    ]

profit =Dict(zip(sources, [2000 2500]))
stock = Dict(zip(sources, [5000, 33, 770]))
init_invest = 500

m = Model(Clp.Optimizer)
@variable(m, quant[products] >=0)

@constraint(m, ressources_constraint[s in sources], 
        sum(quant[p]*data_table[s,p] for p in products) <= stock[s])
@objective(m, Max, 
        sum(quant[p]*profit[p] for p in products)-init_invest)

optimize!(m)
objective_value(m)

println([[s, value.(quant[s])] for s in products])
value.(ressources_constraint)