using JuMP, JuMP.Containers, Clp, CSV, DataFrames

df_m = CSV.read("markets.csv", DataFrame)
df_p = CSV.read("plants.csv", DataFrame)
