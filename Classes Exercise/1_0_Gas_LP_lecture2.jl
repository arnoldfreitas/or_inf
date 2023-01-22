using JuMP, Clp

country = [:NOR, :NL, :LNG1, :LNG2, :RU]

cap = Dict( zip(country, [27,28,15,12,35]) )

cost = Dict( zip(country, [54,65,88,88,36] .+ [50,5,17,18,67]) )

demand = 76

gas_model_w_ru = Model(Clp.Optimizer)

@variables gas_model_w_ru begin
    x[country] >= 0
    y[country] >= 0
end

@constraints gas_model_w_ru begin
    capacity_con[c in country], x[c] <= cap[c]
    eu_nor, x[:NL] + x[:NOR] >= 0.5*demand
    dem_ger, sum(x[c] for c in country) >= demand
end

@objective(gas_model_w_ru, Min, sum( cost[c]*x[c] for c in country) )

print(gas_model_w_ru)

optimize!(gas_model_w_ru)

value.(gas_model_w_ru[:x])

