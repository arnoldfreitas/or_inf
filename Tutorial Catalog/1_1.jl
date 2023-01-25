using Clp, JuMP

products = ["Fance", "Gazebo"]
sources = ["Nail", "Finsih", "Plank", "Profit"]

nail = Dict(zip(products, [350, 550]))
finsih = Dict(zip(products, [4.5, 3.5]))
planks = Dict(zip(products, [70, 140]))
profit = Dict(zip(products, [2000, 2500]))

stock = Dict(zip(sources, [5000, 33, 770, 500]))


m = Model(Clp.Optimizer)
@variable(m, quant[products] >=0)

@constraint(m, nail_constraint, 
        sum(quant[p]*nail[p] for p in products) <= stock["Nail"])
@constraint(m, finish_constraint, 
        sum(quant[p]*finsih[p] for p in products) <= stock["Finsih"])
@constraint(m, plank_constraint, 
        sum(quant[p]*planks[p] for p in products) <= stock["Plank"])

@objective(m, Max, 
        sum(quant[p]*profit[p] for p in products)-stock["Profit"])

optimize!(m)
objective_value(m)

println([[s, value.(quant[s])] for s in products])
"""
17000.0

Vector{Any}[[\"Fance\", 5.000000000000001], [\"Gazebo\", 2.9999999999999996]]
"""
