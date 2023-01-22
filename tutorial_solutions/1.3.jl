using JuMP, JuMP.Containers, Clp, CSV, DataFrames

df_m = CSV.read("./markets.csv", DataFrame)
df_p = CSV.read("plants.csv", DataFrame)

markets = df_m.markets
plants = df_p.plants

supply = Dict(zip(plants, df_p.supply))
demand = Dict(zip(markets, df_m.demand))
df_shippingcost = df_p[:,["New York","Chicago","Topeka"]]
df_shippingcost_arr = Array(df_shippingcost)

shippingcost = DenseAxisArray(df_shippingcost_arr, plants, markets)

n = Model(Clp.Optimizer)
@variable(n, 0 <= x[plants, markets])
@objective(n, Min, 
    sum(shippingcost[p,m]*x[p,m] for m in markets, p in plants)
)
@constraint(n, Sup[p=plants],
    sum(x[p,m] for m in markets) <= supply[p]
)
@constraint(n, Dem[m=markets],
    sum(x[p,m] for p in plants) >= demand[m]
)
print(n)
optimize!(n)
println("Objective value: ", objective_value(n))
for i in plants
    for j in markets
        println("x[$i,$j] = ",value(x[i,j]))
    end
end