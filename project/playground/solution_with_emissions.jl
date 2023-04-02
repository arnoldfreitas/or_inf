using Clp, JuMP
technologies =["SolarPV", "CoalMine", "GasExtractor", "CoalPowerPlant", "GasPowerPlant", "CoalCHPPlant", "GasCHPPlant", "Power2Gas"]
fuels = ["Power", "Heat", "Coal", "Gas", "H2"]

VariableCost = Dict(zip(technologies, [0.01,0.2,0.3,1,1,1,1,1,1]))
InvestmentCost = Dict(zip(technologies, [1,0,0,1,1,1,1,1])) 

OutputRatio = Dict()
for t in technologies, f in fuels
    OutputRatio[t,f] = 0
end
OutputRatio["SolarPV","Power"] = 0.5
OutputRatio["CoalPowerPlant", "Power"] = 1
OutputRatio["CoalMine","Coal"] = 1
OutputRatio["CoalCHPPlant","Power"] = 0.4
OutputRatio["CoalCHPPlant","Heat"] = 0.6
OutputRatio["GasPowerPlant","Power"] = 1
OutputRatio["GasExtractor","Gas"] = 1
OutputRatio["GasCHPPlant","Power"] = 0.4
OutputRatio["GasCHPPlant","Heat"] = 0.6
OutputRatio["Power2Gas","H2"] = 0.5

InputRatio = Dict()
for t in technologies, f in fuels
    InputRatio[t,f] = 0
end
InputRatio["CoalPowerPlant","Coal"] = 1
InputRatio["CoalCHPPlant","Coal"] = 1
InputRatio["GasPowerPlant","Gas"] = 1
InputRatio["GasCHPPlant","Gas"] = 1
InputRatio["Power2Gas","Power"] = 1

Demand=Dict(zip(fuels,[10,10,0,0,10]))

EmissionRatio=Dict(zip(technologies,[0,0,0,2,1,2,1,0]))

EmissionLimit = 20

ESM = Model(Clp.Optimizer)

@variable(ESM,TotalCost[technologies]>=0)
@variable(ESM,Production[technologies, fuels] >= 0)
@variable(ESM,Capacity[technologies] >=0)
@variable(ESM,Use[technologies, fuels] >=0)
@variable(ESM,Emissions[technologies] >=0)

@constraint(ESM, DemandAdequacy[f in fuels], sum(Production[t,f] for t in technologies) >= Demand[f] + sum(Use[t,f] for t in technologies))
@constraint(ESM, ProductionCost[t in technologies], sum(Production[t,f] for f in fuels)*VariableCost[t]+Capacity[t]*InvestmentCost[t] == TotalCost[t])
@constraint(ESM, ProductionFuntion[t in technologies, f in fuels], OutputRatio[t,f]*Capacity[t] >= Production[t,f])
@constraint(ESM, UseFunction[t in technologies, f in fuels], InputRatio[t,f]*sum(Production[t,ff] for ff in fuels) == Use[t,f])
@constraint(ESM, TechnologyEmissions[t in technologies], sum(Production[t,f] for f in fuels)*EmissionRatio[t] == Emissions[t])
@constraint(ESM, TotalEmissionsFunction, sum(Emissions[t] for t in technologies) <= EmissionLimit)

@objective(ESM, Min, sum(TotalCost[t] for t in technologies))

optimize!(ESM)
objective_value(ESM)

value.(Production)
value.(Capacity)
value.(Emissions)
TotalEmissions = sum(value.(Emissions))