ENV["PATH_LICENSE_STRING"] = "2830898829&Courtesy&&&USR&45321&5_1_2021&1000&PATH&GEN&31_12_2025&0_0_0&6000&0_0"
using Complementarity

function solvemidterm()
   ### Sets:
   nodes = ["GER", "FRA", "AUT", "ITA", "ESP", "NOR"]
   demandnodes = ["GER", "FRA", "AUT"]
   firms = ["ITA_H2", "ESP_H2", "NOR_H2"]

   ### Parameters:
   sigma = -1
   c_P = Dict((f,n) => 0.0 for f in firms, n in nodes)
   c_P["ITA_H2","ITA"] = 3.5
   c_P["ESP_H2","ESP"] = 3
   c_P["NOR_H2","NOR"] = 2.5

   cap_P = Dict( (f,n) => 0.0 for f in firms, n in nodes)
   cap_P["ITA_H2","ITA"] = 10_000
   cap_P["ESP_H2","ESP"] = 50_000
   cap_P["NOR_H2","NOR"] = 80_000

   cap_T = Dict( (f,n,m) => 0.0 for f in firms, n in nodes, m in nodes)
   cap_T["ITA_H2","ITA","GER"] = 70_000
   cap_T["ITA_H2","GER","FRA"] = 14_000
   cap_T["ITA_H2","GER","AUT"] = 6_000
   cap_T["ESP_H2","FRA","GER"] = 2_000
   cap_T["ESP_H2","FRA","AUT"] = 2_000
   cap_T["ESP_H2","ESP","FRA"] = 100_000
   cap_T["NOR_H2","NOR","GER"] = 50_000
   cap_T["NOR_H2","NOR","FRA"] = 25_000
   cap_T["NOR_H2","AUT","FRA"] = 1_500
   cap_T["NOR_H2","GER","AUT"] = 25_000

   c_T = Dict( (n,m) => 0.0 for n in nodes, m in nodes)
   c_T["FRA","GER"] = 0.7
   c_T["AUT","GER"] = 0.5
   c_T["ITA","GER"] = 0.2
   c_T["NOR","GER"] = 0.2
   c_T["GER","FRA"] = 1
   c_T["AUT","FRA"] = 0.5
   c_T["ESP","FRA"] = 0.5
   c_T["NOR","FRA"] = 0.3
   c_T["GER","AUT"] = 0.5
   c_T["FRA","AUT"] = 0.8

   cons_ref = Dict("GER"=> 80_000,"FRA"=> 20_000, "AUT"=> 20_000)
   p_ref    = Dict("GER"=> 6, "FRA"=> 5, "AUT"=> 4.5)

   a = Dict(n => 0.0 for n in nodes)
   for (nod,val) in p_ref
      a[nod] = p_ref[nod]*(1-1/sigma)
   end

   b = Dict(n => 0.0 for n in nodes)
   for (nod,val) in p_ref
      b[nod] = (p_ref[nod]/cons_ref[nod])*(1/sigma)
   end

   midterm = MCPModel()
   @variable(midterm, p[nodes])
   @variable(midterm, phi[firms,nodes])
   @variable(midterm, x[firms,nodes,nodes]>=0)
   @variable(midterm, z[firms,nodes,nodes]>=0)
   @variable(midterm, lambda[firms,nodes]>=0)
   @variable(midterm, gamma[firms,nodes,nodes]>=0)

   @mapping(midterm, Production[f in firms,n in nodes, m in nodes], -p[m]-b[m]*x[f,n,m]+c_P[f,n]+lambda[f,n]+phi[f,n]-phi[f,m]  )
   @mapping(midterm, Transport[f in firms,n in nodes, m in nodes], c_T[n,m]+gamma[f,n,m]-phi[f,n]+phi[f,m])
   @mapping(midterm, Prod_cap[f in firms,n in nodes], cap_P[f,n]-sum(x[f,n,m] for m in nodes))
   @mapping(midterm, Trans_cap[f in firms,n in nodes, m in nodes],  cap_T[f,n,m]-z[f,n,m])
   @mapping(midterm, Flow[f in firms,n in nodes], sum(x[f,n,m] for m in nodes)- sum(x[f,m,n] for m in nodes) - (sum(z[f,n,m] for m in nodes)-sum(z[f,m,n] for m in nodes)))
   @mapping(midterm, MCC[m in nodes],  p[m] - a[m] - b[m]*sum(x[f,n,m] for f in firms, n in nodes))


   @complementarity(midterm, Production, x)
   @complementarity(midterm, Transport, z)
   @complementarity(midterm, Prod_cap, lambda)
   @complementarity(midterm, Trans_cap, gamma)
   @complementarity(midterm, Flow, phi)
   @complementarity(midterm, MCC, p)

   status = solveMCP(midterm; convergence_tolerance=1e-8, output="yes", time_limit=3600)

   return result_value.(p), result_value.(x), result_value.(z), result_value.(gamma), result_value.(lambda), result_value.(phi)
end
prices, quantities, flows, dual_trans_cap, dual_prod_cap, dual_node_balance =  solvemidterm()

prices
quantities
flows
dual_trans_cap
dual_prod_cap
dual_node_balance