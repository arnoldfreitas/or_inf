using Clp, JuMP

#add P2Gas and H2 for task 2
technologies =["SolarPV", "CoalMine", "GasExtractor", "CoalPowerPlant", "GasPowerPlant", "CoalCHPPlant", "GasCHPPlant", "P2Gas", "H2Car", "BEV", "PetroCar", "BECCS"]
fuels = ["Power", "Heat", "Coal", "Gas", "H2", "Mobility"]

VariableCost = Dict(zip(technologies, [0.01,0.2,0.3,1,1,1,1,1,1,1,1,1,1]))
InvestmentCost = Dict(zip(technologies, [1,0,0,1,1,1,1,1,1,2,1,1.5])) 

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
OutputRatio["P2Gas", "H2"] = 0.5 #task 2
OutputRatio["H2Car", "Mobility"] = 1 #task 3
OutputRatio["BEV", "Mobility"] = 0.9 #task 3
OutputRatio["PetroCar", "Mobility"] = 1 #task 3
OutputRatio["BECCS", "Power"] = 1

# set all to zero and then change the corresponding values
InputRatio = Dict()
for t in technologies, f in fuels
    InputRatio[t,f] = 0
end
InputRatio["CoalPowerPlant","Coal"] = 1
InputRatio["CoalCHPPlant","Coal"] = 1
InputRatio["GasPowerPlant","Gas"] = 1
InputRatio["GasCHPPlant","Gas"] = 1
InputRatio["P2Gas", "Power"] = 1 #task 2
InputRatio["H2Car", "H2"] = 1
InputRatio["BEV", "Power"] = 1
InputRatio["PetroCar", "Gas"] = 1


# add emission ratio and limit for task 3
EmissionRatio = Dict(zip(technologies, [0,0,0,2,1,2,1,0,0,0,1,-1]))
EmissionLimit = 10

Demand=Dict(zip(fuels,[15,10,0,0,10,10]))

# add maximal Capacity 
MaxCapacity = Dict()
for t in technologies
    MaxCapacity[t] = 1000
end
MaxCapacity["SolarPV"] = 30
MaxCapacity["BECCS"] = 10




ESM = Model(Clp.Optimizer)

# add variables
@variable(ESM, TotalCost[technologies]>=0)
@variable(ESM, FuelProductionByTechnology[technologies, fuels]>=0)
@variable(ESM, Capacity[technologies]>=0)
@variable(ESM, FuelUseByTechnology[technologies, fuels]>=0)
@variable(ESM, TechnologyEmissions[technologies])

@constraint(ESM, 
    ProductionCost[t in technologies], 
    TotalCost[t] == sum(FuelProductionByTechnology[t,f] for f in fuels) * VariableCost[t] + Capacity[t] * InvestmentCost[t]
)

@constraint(ESM,
    ProductionFunction[t in technologies, f in fuels],
    FuelProductionByTechnology[t,f] <= OutputRatio[t,f] * Capacity[t]
)

@constraint(ESM, 
    UseFunction[t in technologies, f in fuels],
    FuelUseByTechnology[t,f] == InputRatio[t,f] * sum(FuelProductionByTechnology[t,ff] for ff in fuels)
)

@constraint(ESM,
    EnergyBalance[f in fuels],
    sum(FuelProductionByTechnology[t,f] for t in technologies) >= Demand[f] + sum(FuelUseByTechnology[t,f] for t in technologies)
)

@constraint(ESM,
    TechnologyEmissionAccounting[t in technologies],
    TechnologyEmissions[t] == sum(FuelProductionByTechnology[t,f] for f in fuels) * EmissionRatio[t]
)

@constraint(ESM,
    TotalEmissionLimit,
    sum(TechnologyEmissions[t] for t in technologies) <= EmissionLimit
)

@constraint(ESM,
    CapacityConstraint[t in technologies],
    Capacity[t] <= MaxCapacity[t]
)

@objective(ESM, Min, sum(TotalCost[t] for t in technologies))


optimize!(ESM)
objective_value(ESM)

value.(FuelProductionByTechnology)
value.(Capacity)
value.(TechnologyEmissions)
TotalEmissions = value(TotalEmissionLimit)

# ideas how to improve the model: timesteps, storage, development over the time, regions, losses of energy