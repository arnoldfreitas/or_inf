using Clp, JuMP
n_prod = collect(1:2)
n_dealer = collect(1:2)
# cost[prods; dealers]
costs = [
    1 4
    7 1
]

# per dealer
max_cases = [20, 9]
# max_cases = [20, 17]

# per product
demand= [12, 17]
# demand= [20, 17]

m = Model(Clp.Optimizer)
@variable(m, cases[n_dealer, n_prod] >=0)

@constraint(m, buy_p[j=n_prod], sum(cases[i, j] for i in n_dealer) == demand[j])
@constraint(m, buy_d[i=n_prod], sum(cases[i, j] for j in n_prod) <= max_cases[i])

@objective(m, Min, sum(cases[i,j]*costs[i,j] for i in n_dealer, j in n_prod))

optimize!(m)
objective_value(m) # 53 ; 37
value.(cases)
"""
And data, a 2×2 Matrix{Float64}:
 12.0  8.0
  0.0  9.0

  
And data, a 2×2 Matrix{Float64}:
 20.0   0.0
  0.0  17.0
  """