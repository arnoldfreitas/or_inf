using JuMP # enables us to tranlate math equations into Julia
using Clp # is an open-source solver that takes care of solving our problem once we created it
using Plots
using StatsPlots

# problem 1
m = Model(Clp.Optimizer)

@variable(m, 0 <= x <= 2)
@variable(m, 0 <= y <= 30)

@objective(m, Max, 5x + 3y)
@constraint(m, 1x + 5y <= 3.0)

print(m)

status = optimize!(m)

println("Objective value: ", getobjectivevalue(m))
println("x = ", getvalue(x))
println("y = ", getvalue(y))

# problem 2

demand = [5, 8]
production_cost = [2, 3, 4]
production_capacity = [2, 3, 10]

supplier = 1:3
years = 1:2


m = Model(Clp.Optimizer)

@variable(m, x[supplier, years] >= 0)

@objective(m, Min,
    sum(production_cost[s]*x[s,y] for s in supplier, y in years)
)

@constraint(m, Market[y=years],
    sum(x[s,y] for s in supplier) >= demand[y]
)

@constraint(m, ProductionLimit[s=supplier, y=years],
    x[s,y] <= production_capacity[s]
)

print(m)

status = optimize!(m)

println("Objective value: ", getobjectivevalue(m))
println("x = ", getvalue.(x))


groupedbar(years, value.(x).data', bar_position = :stack)


### problem 2 again

supplier = ["A","B","C"]
years = ["2021","2022"]

demand = Dict(zip(years, [5, 8]))
production_cost = Dict(zip(supplier, [2, 3, 4]))
production_capacity =Dict(zip(supplier, [2, 3, 10]))

m = Model(Clp.Optimizer)

@variable(m, x[supplier, years] >= 0)

@objective(m, Min,
    sum(production_cost[s]*x[s,y] for s in supplier, y in years)
)

@constraint(m, Market[y=years],
    sum(x[s,y] for s in supplier) >= demand[y]
)

@constraint(m, ProductionLimit[s=supplier, y=years],
    x[s,y] <= production_capacity[s]
)

print(m)

status = optimize!(m)

println("Objective value: ", getobjectivevalue(m))
println("x = ", getvalue.(x))


groupedbar(
    years,
    value.(x).data',
    bar_position = :stack,
    label=permutedims(supplier)
)