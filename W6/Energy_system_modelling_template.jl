using Clp, JuMP
technologies =["SolarPV", "CoalMine", "GasExtractor", "CoalPowerPlant", "GasPowerPlant", "CoalCHPPlant", "GasCHPPlant"]
fuels = ["Power", "Heat", "Coal", "Gas"]

VariableCost = Dict(zip(technologies, [0.01,0.2,0.3,1,1,1,1,1]))
InvestmentCost = Dict(zip(technologies, [1,0,0,1,1,1,1])) 

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


InputRatio = Dict()
for t in technologies, f in fuels
    InputRatio[t,f] = 0
end
InputRatio["CoalPowerPlant","Coal"] = 1
InputRatio["CoalCHPPlant","Coal"] = 1
InputRatio["GasPowerPlant","Gas"] = 1
InputRatio["GasCHPPlant","Gas"] = 1


Demand=Dict(zip(fuels,[10,10,0,0]))

ESM = Model(Clp.Optimizer)

#
# Add your code here

optimize!(ESM)
objective_value(ESM)

value.(Production)
value.(Capacity)

