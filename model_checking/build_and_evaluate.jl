include("node.jl")
include("../hybrid_atl/logic.jl")
include("time_to_trigger.jl")
include("../game_semantics/transitions.jl")
include("../hybrid_atl/termination_conditions.jl")



function check_termination(node::Node, termination_conditions::Termination_Conditions):: Bool
    
    if node.config.global_clock >= termination_conditions.time_limit || 
        node.level >= termination_conditions.max_steps ||
        evaluate_state(termination_conditions.state_formula, node.config)
        return true
    else
        return false
    end
end

function build_children!(game::Game, 
                        constraints::Set{Constraint}, 
                        node::Node, 
                        termination_conditions::Termination_Conditions, 
                        built_nodes::Set{Node})
    remaining_time = termination_conditions.time_limit - node.config.global_clock
    triggers = union_safe(game.triggers[agent] for agent in game.agents)
    
    constraints_val = Dict(constr => evaluate(constr, node.config.valuation) for constr in constraints)
    sat_triggers = Dict(agent => filter(trig -> evaluate(trig, node.config.valuation), game.triggers[agent]) for agent in game.agents)

    final_valuation, final_time, path_configs = time_to_trigger(node.config, constraints ∪ triggers, Not(node.config.location.invariant), remaining_time)

    terminatal_config = nothing
    passive_configs::Vector{Configuration} = Vector{Configuration}()
    
    for config in path_configs
        if evaluate_state(termination_conditions.state_formula, config) && isnothing(terminatal_config)
            terminatal_config = config
            # break
        end
        if any(constr -> evaluate(constr, config.valuation) != constraints_val[constr], constraints)
            push!(passive_configs, config)
            for constr in constraints
                constraints_val[constr] = evaluate(constr, config.valuation)
            end
        end
        for agent in game.agents
            for trigger in game.triggers[agent]
                if ! (trigger in sat_triggers[agent]) && evaluate(trigger, config.valuation)
                    push!(sat_triggers[agent], trigger)
                    path_node::Node = node
                    for path_config in passive_configs
                        child_node = PassiveNode(path_node, agent => trigger, path_config, path_node.level, [])
                        push!(path_node.children, child_node)
                        path_node = child_node
                    end
                    for action in game.actions
                        for edge in select_edges(config, agent => action)
                            config_after_edge = discrete_transition(config, edge)
                            child_node = ActiveNode(path_node, agent => action, trigger, config_after_edge, path_node.level + 1, [])
                            push!(path_node.children, child_node)
                        end
                    end
                end
            end
        end
    end
    if length(node.children) == 0 && ! isnothing(terminatal_config)
        path_node = node
        for path_config in passive_configs
            if path_config == terminatal_config
                break
            end
            child_node = PassiveNode(path_node, nothing, path_config, path_node.level, [])
            push!(path_node.children, child_node)
            path_node = child_node
        end
        end_node = EndNode(node, terminatal_config, node.level + 1, [])
        push!(path_node.children, end_node)
    end

    push!(built_nodes, node) 
end

function evaluate_and_build!(game::Game,
                             constraints::Set{Constraint}, 
                             formula::Strategy_Formula, 
                             node::Node,
                             termination_conditions::Termination_Conditions,
                             built_nodes::Set{Node}
                             )::Bool
    @match formula begin
        Strategy_to_State(f) => evaluate_state(f, node.config)
        Strategy_Deadlock() => ! check_termination(node, termination_conditions) && length(node.children) == 0
        All_Always(agents, f) => ! evaluate_and_build!(game, constraints, Exist_Eventually(setdiff(game.agents, agents), Strategy_Not(f)), node, termination_conditions, built_nodes)
        All_Eventually(agents, f) => ! evaluate_and_build!(game, constraints, Exist_Always(setdiff(game.agents, agents), Strategy_Not(f)), node, termination_conditions, built_nodes)
        Strategy_And(left, right) => evaluate_and_build!(game, constraints, left, node, termination_conditions, built_nodes) && evaluate_and_build!(game, constraints, right, node, termination_conditions, built_nodes)
        Strategy_Or(left, right) => evaluate_and_build!(game, constraints, left, node, termination_conditions, built_nodes) || evaluate_and_build!(game, constraints, right, node, termination_conditions, built_nodes)
        Strategy_Not(f) => ! evaluate_and_build!(game, constraints, f, node, termination_conditions, built_nodes)
        Strategy_Imply(left, right) => ! evaluate_and_build!(game, constraints, left, node, termination_conditions, built_nodes) || evaluate_and_build!(game, constraints, right, node, termination_conditions, built_nodes)
        Exist_Always(agents, f) => begin
            terminal_node = check_termination(node, termination_conditions)
            if ! evaluate_and_build!(game, constraints, f, node, termination_conditions, built_nodes)
                return false
            end
            if ! (isa(node, PassiveNode) || terminal_node || (node in built_nodes))
                build_children!(game, constraints, node, termination_conditions, built_nodes)
            end
            if length(node.children) == 0 || terminal_node
                return true
            end
            children = sort_children_by_clock_agent(node, agents)
            agents_have_children = false
            for child in children
                if isa(child, EndNode) || isnothing(child.reaching_decision) || child.reaching_decision.first in agents
                    if evaluate_and_build!(game, constraints, formula, child, termination_conditions, built_nodes)
                        return true
                    end
                    agents_have_children = true
                elseif ! evaluate_and_build!(game, constraints, formula, child, termination_conditions, built_nodes)
                    return false
                end
            end
            if agents_have_children
                return false
            else
                return true
            end
        end
        Exist_Eventually(agents, f) => begin
            terminal_node = check_termination(node, termination_conditions)
            if evaluate_and_build!(game, constraints, f, node, termination_conditions, built_nodes)
                return true
            end
            if ! (isa(node, PassiveNode) || terminal_node || (node in built_nodes))
                build_children!(game, constraints, node, termination_conditions, built_nodes)
            end
            if length(node.children) == 0 || terminal_node
                return false
            end
            children = sort_children_by_clock_agent(node, agents)
            agents_have_children = false
            for child in children
                if isa(child, EndNode) || isnothing(child.reaching_decision) || child.reaching_decision.first in agents
                    if evaluate_and_build!(game, constraints, formula, child, termination_conditions, built_nodes)
                        return true
                    end
                    agents_have_children = true
                elseif ! evaluate_and_build!(game, constraints, formula, child, termination_conditions, built_nodes)
                    return false
                end
            end
            if agents_have_children
                return false
            else
                return true
            end
        end
    end
end


function evaluate_queries(game::Game, termination_conditions::Termination_Conditions, queries::Vector{Strategy_Formula}) 
    initial_config = initial_configuration(game)
    root = RootNode(initial_config, 0, [])
    constraints = get_all_constraints(queries ∪ State_Formula[termination_conditions.state_formula])

    results = Vector{Bool}()
    built_nodes = Set{Node}()
    for query in queries
        result = evaluate_and_build!(game, constraints, query, root, termination_conditions, built_nodes)
        push!(results, result)
    end
    return results, root
end
