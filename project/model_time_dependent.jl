# # Base Solution -----

using Clp, JuMP, DataFrames, CSV
technologies =[
    "SolarPV", "WindOnshore", "WindOffshore", "Hydro", "CoalMine", 
    "GasExtractor", "CoalPowerPlant", "GasPowerPlant", "CoalCHPPlant",
    "GasCHPPlant", "CoalGazification", "SteamMethaneReforming", "Electrolysis", 
    "FuelCell"]

fuels = ["Coal", "Gas", "Power", "Heat", "H2"]

InvestmentCost = Dict(zip(technologies, [0.39, 1, 2.58, 2.2, 0, 0, 1.6, 0.607, 2.03, 0.977, 0, 0, 0.38, 2.08])) # expressed as Mio Eur / Mwh in a year -> need to rescale by the lifetime (research annuity factor)
VariableCost  = Dict(zip(technologies, [0, 0, 0, 0, 0, 0, 130, 230, 130, 230, 30.03, 60.06, 1.188, 22.9]*1e-6)) # Mio Eur / Mwh
FullLoadHours = Dict(zip(technologies, [1414, 2628, 3504, 3066, 3500, 3500, 5256, 5256, 5256, 5256, 4000, 4000, 2000, 6386]))
# MaxCapacity = Dict(zip(technologies, [67280, 58290, 8170, 4940, 0, 0, 19000, 32090, 0, 0, 0, 0, 0, 0])) # constraint based on condition or sufficiently high value

OutputRatio = Dict()
for t in technologies, f in fuels
    OutputRatio[t,f] = 0
end
OutputRatio["SolarPV","Power"] = 1
OutputRatio["WindOnshore","Power"] = 1
OutputRatio["WindOffshore","Power"] = 1
OutputRatio["Hydro","Power"] = 1
OutputRatio["CoalMine", "Coal"] = 1
OutputRatio["GasExtractor", "Gas"] = 1
OutputRatio["CoalPowerPlant", "Power"] = 0.45
OutputRatio["GasPowerPlant", "Power"] = 0.8
OutputRatio["CoalCHPPlant", "Power"] = 0.36
OutputRatio["CoalCHPPlant", "Heat"] = 0.44
OutputRatio["GasCHPPlant", "Power"] = 0.36
OutputRatio["GasCHPPlant", "Heat"] = 0.44
OutputRatio["CoalGazification", "H2"] = 0.7
OutputRatio["SteamMethaneReforming", "H2"] = 0.7
OutputRatio["Electrolysis", "H2"] = 0.7
OutputRatio["FuelCell", "Power"] = 0.6

InputRatio = Dict()
for t in technologies, f in fuels
    InputRatio[t,f] = 0
end
InputRatio["CoalPowerPlant","Coal"] = 1
InputRatio["CoalCHPPlant","Coal"] = 1
InputRatio["GasPowerPlant","Gas"] = 1
InputRatio["GasCHPPlant","Gas"] = 1
InputRatio["CoalGazification","Coal"] = 1
InputRatio["SteamMethaneReforming","Gas"] = 1
InputRatio["Electrolysis","Power"] = 1
InputRatio["FuelCell","H2"] = 1

Demand = Dict(zip(fuels,[0, 0, 610, 1100, 90]*1e3)) # everything there is expressed as MWh in a year

ESM = Model(Clp.Optimizer)

@variable(ESM,TotalCost[technologies, period]>=0)
@variable(ESM,Production[technologies, fuels] >= 0)
@variable(ESM,Capacity[technologies] >=0) # 
@variable(ESM,Use[technologies, fuels] >=0)
# @variable(ESM, UnservedDemand[fuels] >= 0)

@constraint(ESM, ProductionCost[t in technologies, p in periods], sum(Production[t,f] for f in fuels)*VariableCost[t]+Capacity[t,p]*InvestmentCost[t] == TotalCost[t,p])
@constraint(ESM, ProductionFuntion[t in technologies, f in fuels], OutputRatio[t,f]*FullLoadHours[t]*Capacity[t,p] >= Production[t,f,p])
@constraint(ESM, UseFunction[t in technologies, f in fuels], InputRatio[t,f]*sum(Production[t,ff] for ff in fuels) == Use[t,f])
@constraint(ESM, DemandAdequacy[f in fuels], sum(Production[t,f] for t in technologies) >= Demand[f] + sum(Use[t,f] for t in technologies))
# @constraint(ESM, DemandAdequacy[f in fuels], sum(Production[t,f] for t in technologies) + UnservedDemand[f] >= Demand[f] + sum(Use[t,f] for t in technologies)) # slack variable for debugging
@constraint(ESM,CapacityConstraint[t in technologies], Capacity[t] <= MaxCapacity[t])

@objective(ESM, Min, sum(TotalCost[t,p] for t in technologies, p in periods))
# @objective(ESM, Min, sum(TotalCost[t] for t in technologies) + 1e+3*sum(UnservedDemand[f] for f in fuels))

optimize!(ESM)
objective_value(ESM)

value.(Production)
value.(Capacity)

# Production_df = DataFrame(value.(Production))

# value.(Production)["CoalMine",:]
# value.(UnservedDemand)
# ESM[:ProductionFuntion]
# ESM[:ProductionFuntion]["CoalMine","Coal"]

# table = Containers.rowtable(value.(Production); header = [:Technology, :Fuel, :value])
# df = DataFrame(table)

df = DataFrame((value.(Production).data)/1000, [:Coal_TWh, :Gas_TWh, :Power_TWh, :Heat_TWh, :H2_TWh])
insertcols!(df, 1, :Technology => technologies)
insertcols!(df, 7, :Capacity_MW => value.(Capacity).data)
insertcols!(df, 8, :TotalCost_MiEUR => value.(TotalCost).data)
CSV.write("results/results_FullLoadHours_MaxCap.csv", df)


