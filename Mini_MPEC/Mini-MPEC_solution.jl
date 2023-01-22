using JuMP, Ipopt, SCIP
import Printf

Base.@kwdef mutable struct Dataset
    a::Float64
    b::Float64
    c::Vector{Float64}
    C::Float64
end

Base.@kwdef mutable struct Results{T}
    q::Vector{T}
    Q::T
    P::T
    Π::T
    π::Vector{T}
end

function Base.print(results::Results)
    for n in fieldnames(Results)
        val = getfield(results,n)
        if isa(val,Vector)
            for (i,v) in enumerate(val)
                println(rpad("$n[$i]", 7), "=", Printf.@sprintf("%10.4f",v))
            end
        else
            println(rpad(n,7),"=", Printf.@sprintf("%10.4f",val))
        end
    end
end

dataset_1 = Dataset(a = 13, b = 1, c = [1,1], C = 1)
dataset_2 = Dataset(a = 13, b = 0.1, c = [1,1], C = 1)
dataset_3 = Dataset(a = 13, b = 0.1, c = [2,2], C = 2)

function solve_MPEC_disjunctive(data; BIG = 1e+3)
    followers = 1:length(data.c)
    m = Model(SCIP.Optimizer)
    set_silent(m)
    @variables m begin 
        Q >= 0
        q[followers] >= 0
        r[followers], Bin
    end
    @expression(m, P, data.a - data.b*(sum(q) + Q))
    @expression(m, π[f in followers], P*q[f] - data.c[f]*q[f])
    @objective(m, Max, P*Q - data.C * Q)
    @constraint(m, stationarity[f in followers], 0 <= -data.a + data.c[f] + 2*data.b*q[f] + data.b*sum(q[i] for i in followers if i != f) + data.b*Q )
    @constraint(m, complementarity_LHS[f in followers], -data.a + data.c[f] + 2*data.b*q[f] + data.b*sum(q[i] for i in followers if i != f) + data.b*Q <= BIG*r[f] )
    @constraint(m, complementarity_RHS[f in followers], q[f] <= BIG*(1-r[f]) )

    optimize!(m)

    result = Results{Float64}(q = value.(q), Q = value.(Q), P = value.(P), Π = objective_value(m), π = value.(π))
    print(result)
    return result
end

disjunctive_result_1 = solve_MPEC_disjunctive(dataset_1; BIG = 1e+3);
disjunctive_result_2 = solve_MPEC_disjunctive(dataset_2; BIG = 1e+5);
disjunctive_result_3 = solve_MPEC_disjunctive(dataset_3; BIG = 1e+5);

function solve_MPEC_regularized(data; regularization = [1*0.85^i for i in 1:100])
    followers = 1:length(data.c)
    m = Model(Ipopt.Optimizer)
    set_optimizer_attribute(m,"warm_start_init_point","yes")
    set_optimizer_attribute(m, "warm_start_bound_push", 1e-12)
    set_optimizer_attribute(m, "warm_start_bound_frac", 1e-12)
    set_optimizer_attribute(m, "warm_start_slack_bound_frac", 1e-12)
    set_optimizer_attribute(m, "warm_start_slack_bound_push", 1e-12)
    set_optimizer_attribute(m, "warm_start_mult_bound_push", 1e-12)
    set_silent(m)
    @variables m begin 
        Q >= 0
        q[followers] >= 0
    end
    @expression(m, P, data.a - data.b*(sum(q) + Q))
    @expression(m, π[f in followers], P*q[f] - data.c[f]*q[f])
    @objective(m, Max, P*Q - data.C * Q)
    @constraint(m, stationarity[f in followers], -data.a + data.c[f] + 2*data.b*q[f] + data.b*sum(q[i] for i in followers if i != f) + data.b*Q >= 0 )
    @constraint(m, complementarity[f in followers], (-data.a + data.c[f] + 2*data.b*q[f] + data.b*sum(q[i] for i in followers if i != f) + data.b*Q)*q[f] <= 0 )

    for t in regularization
        set_normalized_rhs.(complementarity, t)
        optimize!(m)
        v = all_variables(m)
        v_primal = value.(v)
        c = all_constraints(m, include_variable_in_set_constraints = true)
        c_dual = dual.(c)
        set_start_value.(v, v_primal)
        set_dual_start_value.(c, c_dual)
    end
    optimize!(m)
    result = Results{Float64}(q = value.(q), Q = value.(Q), P = value.(P), Π = objective_value(m), π = value.(π))
    print(result)
    return result
end


regularized_result_1 = solve_MPEC_regularized(dataset_1; regularization = [1*0.85^i for i in 1:100]);
regularized_result_2 = solve_MPEC_regularized(dataset_2; regularization = [1*0.85^i for i in 1:100]);
regularized_result_3 = solve_MPEC_regularized(dataset_3; regularization = [1*0.85^i for i in 1:100]);
