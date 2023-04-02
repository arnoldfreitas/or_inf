# After 25.03's changes
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
MaxCapacity = Dict(zip(technologies, [100, 71, 20, 4.3, 1e6, 1e6, 1e6, 37, 1e6, 1e6, 1e6, 1e6, 1e6, 1e6]*1e3)) # in MW, constraint based on condition or sufficiently high value (1e9)

MaxProdCoal = Dict(zip(["Power", "Heat"], [60, 60]*1e6)) # in MWh
MaxProdGas = Dict(zip(["Power", "Heat"], [70, 588]*1e6)) # in MWh

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

Demand = Dict(zip(fuels,[0, 0, 610, 1100, 90]*1e6)) # everything there is expressed as MWh in a year

ESM = Model(Clp.Optimizer)

@variable(ESM,TotalCost[technologies]>=0)
@variable(ESM,Production[technologies, fuels] >= 0)
@variable(ESM,Capacity[technologies] >=0) # 
@variable(ESM,Use[technologies, fuels] >=0)
@variable(ESM, UnservedDemand[fuels] >= 0)

# CONSTRAINTS ---------------------------
# @constraint(ESM, ProductionCost[t in technologies], sum(Production[t,f] for f in fuels)*VariableCost[t]+Capacity[t]*InvestmentCost[t] == TotalCost[t])
@constraint(ESM, ProductionCost[t in technologies], sum(Production[t,f] for f in fuels)*VariableCost[t] == TotalCost[t])
@constraint(ESM, ProductionFuntion[t in technologies, f in fuels], OutputRatio[t,f]*FullLoadHours[t]*Capacity[t] >= Production[t,f])
@constraint(ESM, UseFunction[t in technologies, f in fuels], InputRatio[t,f]*sum(Production[t,ff] for ff in fuels) == Use[t,f])
# @constraint(ESM, DemandAdequacy[f in fuels], sum(Production[t,f] for t in technologies) >= Demand[f] + sum(Use[t,f] for t in technologies))
@constraint(ESM, DemandAdequacy[f in fuels], sum(Production[t,f] for t in technologies) + UnservedDemand[f] >= Demand[f] + sum(Use[t,f] for t in technologies)) # slack variable for debugging

@constraint(ESM,CapacityConstraint[t in technologies], Capacity[t] <= MaxCapacity[t]) # if no max cap const, use very large number instead

# constraint on Coal and Gas production
@constraint(ESM, CoalProductionConstraint[f in ["Power", "Heat"]], sum(Production[t,f] for t in ["CoalPowerPlant", "CoalCHPPlant"]) <= MaxProdCoal[f])
@constraint(ESM, GasProductionConstraint[f in ["Power", "Heat"]], sum(Production[t,f] for t in ["GasPowerPlant", "GasCHPPlant"]) <= MaxProdGas[f])

# OPTIMIZATION ---------------------
# @objective(ESM, Min, sum(TotalCost[t] for t in technologies))
@objective(ESM, Min, sum(TotalCost[t] for t in technologies) + 1e+3*sum(UnservedDemand[f] for f in fuels))

optimize!(ESM)
objective_value(ESM)

value.(Production)
value.(Capacity)
value.(UnservedDemand)

# RESULTS ---------------------------
df = DataFrame((value.(Production).data)/1e6, [:Coal_TWh, :Gas_TWh, :Power_TWh, :Heat_TWh, :H2_TWh]) # Prod from MWh to TWh
insertcols!(df, 1, :Technology => technologies)
insertcols!(df, 7, :Capacity_GW => value.(Capacity).data/1e3) # Capacities in GW
insertcols!(df, 8, :TotalCost_MiEUR => value.(TotalCost).data)
CSV.write("results/results_main_new.csv", df)


