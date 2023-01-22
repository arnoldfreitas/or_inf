using JuMP
using Complementarity

# Sets:
players = ["A","B","C"]

# Parameters:
c₁ = Dict("A"=>2, "B"=>0.8, "C"=>1.5)
c₂ = Dict("A"=>0.7, "B"=>0.9, "C"=>1.1)
κ  = Dict("A"=>60, "B"=>30, "C"=>50)

# Solution to Task a)
mini_h2_mod_a = MCPModel()
@variable(mini_h2_mod_a, q[players] >= 0)
@variable(mini_h2_mod_a, λ[players] >= 0)
@mapping(mini_h2_mod_a, KKT1[i in players], 
    0.5 * q[i] - (100 - 0.5 * sum(q[j] for j in players)) 
    + (c₁[i] + 2*q[i]*c₂[i]) + λ[i])
@mapping(mini_h2_mod_a, KKT2[i in players], κ[i] - q[i])
@complementarity(mini_h2_mod_a, KKT1, q)
@complementarity(mini_h2_mod_a, KKT2, λ)
status = solveMCP(mini_h2_mod_a; convergence_tolerance=1e-8, output="yes", time_limit=3600)
@show status
@show result_value.(q)
opt_q = result_value.(q)
p = 100 - 0.5*sum(opt_q[i] for i in players)
@show p

# Solution to Task b)
κ  = Dict("A"=>60, "B"=>30, "C"=>50)
mini_h2_mod_b = MCPModel()
@variable(mini_h2_mod_b, q[players] >= 0)
@NLexpression(mini_h2_mod_b, KKT1[i in players], 0.5 * q[i] - (100 - 0.5 * sum(q[j] for j in players)) + (c₁[i] + 2*q[i]*c₂[i]) )
@complementarity(mini_h2_mod_b, KKT1, q)
status = solveMCP(mini_h2_mod_b; convergence_tolerance=1e-8, output="yes", time_limit=3600)
@show status
@show result_value.(q)
opt_q = result_value.(q)
p = 100 - 0.5*sum(opt_q[i] for i in players)
@show p

# Solution to Task c)
c₁["B"] = c₁["B"]*2
c₂["B"] = c₂["B"]*2
mini_h2_mod_c = MCPModel()
@variable(mini_h2_mod_c, q[players] >= 0)
@variable(mini_h2_mod_c, λ[players] >= 0)
@NLexpression(mini_h2_mod_c, KKT1[i in players], 0.5 * q[i] - (100 - 0.5 * sum(q[j] for j in players)) + (c₁[i] + 2*q[i]*c₂[i]) + λ[i])
@NLexpression(mini_h2_mod_c, KKT2[i in players], κ[i] - q[i])
@complementarity(mini_h2_mod_c, KKT1, q)
@complementarity(mini_h2_mod_c, KKT2, λ)
status = solveMCP(mini_h2_mod_c; convergence_tolerance=1e-8, output="yes", time_limit=3600)
@show status
@show result_value.(q)
opt_q = result_value.(q)
p = 100 - 0.5*sum(opt_q[i] for i in players)
@show p
