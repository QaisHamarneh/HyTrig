using DifferentialEquations
include("../essential_definitions/evolution.jl")
include("../game_semantics/configuration.jl")

function time_to_trigger(config::Configuration, constraints::Vector{Constraint}, invariant::Constraint, max_time::Float64)

    constraints_val = Dict(constr => evaluate(constr, config.valuation) for constr in constraints)

    zero_constraints::Vector{ExprLike} = get_zero(constraints)
    zero_invariant::Vector{ExprLike} = get_zero(invariant)

    path_to_trigger::Vector{Configuration} = Vector()
    function flowODE!(du, u, p, t)
        current_valuation = valuation_from_flow_vector(config.location.flow, config.valuation, u)
        for (i, (_, var_flow)) in enumerate(config.location.flow)
            # Evaluate the flow for the variable
            du[i] = evaluate(var_flow, current_valuation)
        end
    end

    function condition(out, u, t, integrator) # Event when condition(out,u,t,integrator) == 0
        current_valuation = valuation_from_flow_vector(config.location.flow, config.valuation, u)
        for (i, zero_constr) in enumerate(zero_constraints ∪ zero_invariant)
            out[i] = round5(evaluate(zero_constr, current_valuation))
        end
    end

    function affect!(integrator, idx)
        if round5(integrator.t) == 0.0
            return # No need to affect the valuation if the trigger was already met at time 0
        end
        current_valuation = round5(valuation_from_flow_vector(config.location.flow, config.valuation, integrator.u))
        if evaluate(invariant, current_valuation)
            terminate!(integrator) # Stop the integration when the condition is met
            return
        end
        if any(zero_constr -> evaluate(zero_constr, current_valuation) == 0.0, zero_constraints) && 
           any(constr -> evaluate(constr, current_valuation) != constraints_val[constr], constraints)
            push!(path_to_trigger, Configuration(config.location, current_valuation, config.global_clock + integrator.t))
            for constr in constraints
                constraints_val[constr] = evaluate(constr, current_valuation)
            end
        end
    end

    cbv = VectorContinuousCallback(condition, affect!, length(zero_constraints ∪ zero_invariant))

    u0 = Float64[round5(config.valuation[var]) for (var, _) in config.location.flow] 
    tspan = (0.0, max_time + 1e-5)  # Add a small buffer to ensure we capture the trigger time
    prob = ODEProblem(flowODE!, u0, tspan)
    sol = solve(prob, Tsit5(), callback = cbv, abstol=1e-6, reltol=1e-6)
    
    final_valuation = round5(valuation_from_flow_vector(config.location.flow, config.valuation, sol[end]))
    return final_valuation, round5(sol.t[end]), path_to_trigger
end
