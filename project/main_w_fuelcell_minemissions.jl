# 25.03 chaging optimization objective to emissions minimization
using Clp, JuMP, DataFrames, CSV
technologies =[
    "SolarPV", "WindOnshore", "WindOffshore", "Hydro", "BiomassCHP", "CoalMine", 
    "GasExtractor", "CoalPowerPlant", "GasPowerPlant", "CoalCHPPlant",
    "GasCHPPlant", "Power2Heat", "CoalGazification", "SteamMethaneReforming", 
    "Electrolysis", "FuelCell"]

fuels = ["Coal", "Gas", "Power", "Heat", "H2"]
Demand = Dict(zip(fuels,[0, 0, 610, 1100, 0]*1e6)) # everything there is expressed as MWh in a year

# Costs
InvestmentCost = Dict(zip(technologies, [390, 1000, 2580, 2200, 2990, 0, 0, 1600, 607, 2030, 977, 0, 0, 0, 380, 2080]*1e-3)) # expressed as Mio Eur / Mwh in a year -> need to rescale by the lifetime (research annuity factor)
VariableCost  = Dict(zip(technologies, [0, 0, 0, 0, 0, 0, 0, 130, 230, 130, 230, 0, 30.03, 60.06, 1.188, 22.9]*1e-6)) # Mio Eur / Mwh

# Avg capacity Ratio
# CapacityFactor = Dict(zip(technologies, [0.15, 0.3, 0.4, 0.35, 0.6, 0.4, 0.4, 0.6, 0.6, 0.6, 0.6, 0.25, 0.5, 0.5, 0.25])) 
CapacityFactor = Dict(zip(technologies, [0.15, 0.3, 0.4, 0.35, 0.6, 0.4, 0.4, 0.6, 0.6, 0.6, 0.6, 0.25, 0.5, 0.5, 0.25, 0.6])) 
# FullLoadHours = Dict(zip(technologies, [1414, 2628, 3504, 3066, 5256, 3500, 3500, 5256, 5256, 5256, 5256, 2000, 4000, 4000, 2000])) 

# Emissions
DirectEmissionsRatio = Dict(zip(technologies, [0, 0, 0, 0, 230, 0, 0, 900, 500, 700, 180, 350, 60, 24, 0, 0]))
UpstreamtEmissionsRatio = Dict(zip(technologies, [29, 15, 17, 19, 0, 0, 0, 9.6, 1.6, 9.6, 1.6, 0, 6, 15, 0, 0]))
# DirectEmissionsRatio = Dict(zip(technologies, [0, 0, 0, 0, 230, 0, 0, 900, 500, 700, 180, 350, 60, 24, 0]))
# UpstreamtEmissionsRatio = Dict(zip(technologies, [29, 15, 17, 19, 0, 0, 0, 9.6, 1.6, 9.6, 1.6, 0, 6, 15, 0]))
# EmissionsRatio = Dict(zip(technologies, collect(values(DirectEmissionsRatio)) + collect(values(UpstreamtEmissionsRatio)))) # kgCO2e / MWh
EmissionsRatio = merge(+, DirectEmissionsRatio, UpstreamtEmissionsRatio)
println(EmissionsRatio)


OutputRatio = Dict()
for t in technologies, f in fuels
    OutputRatio[t,f] = 0
end
OutputRatio["SolarPV","Power"] = 1
OutputRatio["WindOnshore","Power"] = 1
OutputRatio["WindOffshore","Power"] = 1
OutputRatio["Hydro","Power"] = 1
OutputRatio["BiomassCHP","Power"] = 0.3
OutputRatio["BiomassCHP","Heat"] = 0.55
OutputRatio["CoalMine", "Coal"] = 1
OutputRatio["GasExtractor", "Gas"] = 1
OutputRatio["CoalPowerPlant", "Power"] = 0.45
OutputRatio["GasPowerPlant", "Power"] = 0.8
OutputRatio["CoalCHPPlant", "Power"] = 0.36
OutputRatio["CoalCHPPlant", "Heat"] = 0.44
OutputRatio["GasCHPPlant", "Power"] = 0.36
OutputRatio["GasCHPPlant", "Heat"] = 0.44
OutputRatio["Power2Heat", "Heat"] = 0.95
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
InputRatio["Power2Heat", "Power"] = 1
InputRatio["CoalGazification","Coal"] = 1
InputRatio["SteamMethaneReforming","Gas"] = 1
InputRatio["Electrolysis","Power"] = 1
InputRatio["FuelCell","H2"] = 1


ESM = Model(Clp.Optimizer)

@variable(ESM,Emissions[technologies]>=0)
@variable(ESM,CostByTechnology[technologies]>=0)
@variable(ESM,Production[technologies, fuels] >= 0)
@variable(ESM,Capacity[technologies] >=0) # 
@variable(ESM,Use[technologies, fuels] >=0)
@variable(ESM,UnservedDemand[fuels] == 0)

# CONSTRAINTS ---------------------------
@constraint(ESM, TechnologyEmissions[t in technologies], sum(Production[t,f] for f in fuels)*EmissionsRatio[t] == Emissions[t])

@constraint(ESM, ProductionFuntion[t in technologies, f in fuels], OutputRatio[t,f]*(CapacityFactor[t]*8760)*Capacity[t] >= Production[t,f])
@constraint(ESM, UseFunction[t in technologies, f in fuels], InputRatio[t,f]*sum(Production[t,ff] for ff in fuels) == Use[t,f])

@constraint(ESM, DemandAdequacy[f in fuels], sum(Production[t,f] for t in technologies) >= Demand[f] + sum(Use[t,f] for t in technologies))
# @constraint(ESM, DemandAdequacy[f in fuels], sum(Production[t,f] for t in technologies) + UnservedDemand[f] >= Demand[f] + sum(Use[t,f] for t in technologies)) # slack variable for debugging
# @constraint(ESM, DemandAdequacy[f in fuels], sum(Production[t,f] for t in technologies) + UnservedDemand[f] >= Demand[f]) # slack variable for debugging


# @constraint(ESM, ProductionCost[t in technologies], sum(Production[t,f] for f in fuels)*VariableCost[t]+Capacity[t]*InvestmentCost[t] == CostByTechnology[t])
@constraint(ESM, ProductionCost[t in technologies], sum(Production[t,f] for f in fuels)*VariableCost[t] == CostByTechnology[t])

# Max Capacities
MaxCapacity = Dict(zip(technologies, [100, 71, 20, 4.3, 7.5, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf]*1e3)) # in MW, constraint based on condition or sufficiently high value (1e9)
for t in technologies
    if MaxCapacity[t] != Inf
        @constraint(ESM, Capacity[t] <= MaxCapacity[t])
    end
end
# @constraint(ESM,CapacityConstraint[t in technologies], Capacity[t] <= MaxCapacity[t]) # if no max cap const, use very large number instead


# constraint on Coal and Gas production
# Max Production
MaxProdCoal = Dict(zip(["Power", "Heat"], [140, 60]*1e6)) # in MWh
MaxProdGas = Dict(zip(["Power", "Heat"], [70, 588]*1e6)) # in MWh
@constraint(ESM, CoalProductionConstraint[f in ["Power", "Heat"]], sum(Production[t,f] for t in ["CoalPowerPlant", "CoalCHPPlant"]) <= MaxProdCoal[f])
@constraint(ESM, GasProductionConstraint[f in ["Power", "Heat"]], sum(Production[t,f] for t in ["GasPowerPlant", "GasCHPPlant"]) <= MaxProdGas[f])

# contraints to test emissions of H2 production modes
# @constraint(ESM, ElectrolysisContraint, Production["Electrolysis","H2"] >= 1e6)
# @constraint(ESM, CoalGazificationContraint, Production["CoalGazification","H2"] == 1e6)
# @constraint(ESM, SteamMethaneReformingContraint, Production["SteamMethaneReforming","H2"] == 1e6)
# @constraint(ESM, ElectrolysisContraint, Production["Electrolysis","H2"] == 1e6)

# OPTIMIZATION ---------------------
# @objective(ESM, Min, sum(CostByTechnology[t] for t in technologies))
# @objective(ESM, Min, sum(CostByTechnology[t] for t in technologies) + 1e+3*sum(UnservedDemand[f] for f in fuels))
# @objective(ESM, Min, sum(Emissions[t] for t in technologies) + 1e+6*sum(UnservedDemand[f] for f in fuels))
@objective(ESM, Min, sum(Emissions[t] for t in technologies))


optimize!(ESM)
objective_value(ESM)

value.(CostByTechnology) # in MEur
value.(Production).data[:,3:end]*1e-6 # in TWh
value.(Capacity).data*1e-3 # in GW
value.(UnservedDemand).data[3:end]*1e-6 # in TWh
value.(Emissions).data
# value.(Use).data*1e-6 

# RESULTS ---------------------------
df = DataFrame((value.(Production).data[:,3:end])*1e-6, [:Power_TWh, :Heat_TWh, :H2_TWh]) # Prod from MWh to TWh
insertcols!(df, 1, :Technology => technologies)

# insert a blank row
blank_row = DataFrame(Technology = missing, Power_TWh = missing, Heat_TWh=missing, H2_TWh=missing)
df = vcat(df, blank_row)

# insert UnservedDemand column
new_row = (Technology = "UnservedDemand", Power_TWh = value.(UnservedDemand)["Power"]*1e-6, Heat_TWh=value.(UnservedDemand)["Heat"]*1e-6, H2_TWh=value.(UnservedDemand)["H2"]*1e-6)
push!(df, new_row)

# insert Demand column
new_row = (Technology = "Demand", Power_TWh = Demand["Power"]*1e-6, Heat_TWh=Demand["Heat"]*1e-6, H2_TWh=Demand["H2"]*1e-6)
push!(df, new_row)

# insert capacity column
padded_vector = vcat(value.(Capacity).data*1e-3 , fill(missing, 3)) # Capacities in GW
insertcols!(df, ncol(df)+1, :Capacity_GW => padded_vector)

df_max_cap = DataFrame(Technology=collect(keys(MaxCapacity)), MaxCapacity_GW=collect(values(MaxCapacity))*1e-3) # Capacities in GW
# df = outerjoin(df, df_max_cap, on = :Technology, order=:left, matchmissing=:equal)
df = outerjoin(df, df_max_cap, on = :Technology, matchmissing=:equal)

# insert cost column
padded_vector = vcat(value.(CostByTechnology).data , fill(missing, 3))
insertcols!(df, ncol(df)+1, :Cost_MiEUR => padded_vector)

# insert emissions column
padded_vector = vcat(value.(Emissions).data*1e-9 , fill(missing, 3))
insertcols!(df, ncol(df)+1, :Emissions_MtCO2e => padded_vector)

filepath = joinpath(@__DIR__, "results/results_fuelcell_minemissions.csv")
CSV.write(filepath, df)
