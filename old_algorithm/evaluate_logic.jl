include("../hybrid_atl/logic.jl")
include("old_tree.jl")

function evaluate(formula::State_Formula, node::OldNode)::Bool
    @match formula begin
        State_Location(loc) => loc == node.config.location
        State_Constraint(constraint) => evaluate(constraint, node.config.valuation)
        State_And(left, right) => evaluate(left, node.config) && evaluate(right, node.config)
        State_Or(left, right) => evaluate(left, node.config) || evaluate(right, node.config)
        State_Not(f) => ! evaluate(f, node.config)
        State_Imply(left, right) => ! evaluate(left, node.config) || evaluate(right, node.config)
        State_Deadlock() => ! node.terminal_node && length(node.children) == 0
    end
end

function evaluate(formula::Strategy_Formula, node::OldNode, all_agents::Set{Agent})::Bool
    @match formula begin
        Strategy_to_State(f) => evaluate(f, node)
        All_Always(agents, f) => ! evaluate(Exist_Eventually(setdiff(all_agents, agents), Strategy_Not(f)), node, all_agents)
        All_Eventually(agents, f) => ! evaluate(Exist_Always(setdiff(all_agents, agents), Strategy_Not(f)), node, all_agents)
        Strategy_And(left, right) => evaluate(left, node, all_agents) && evaluate(right, node, all_agents)
        Strategy_Or(left, right) => evaluate(left, node, all_agents) || evaluate(right, node, all_agents)
        Strategy_Not(f) => ! evaluate(f, node, all_agents)
        Strategy_Imply(left, right) => ! evaluate(left, node, all_agents) || evaluate(right, node, all_agents)
        Exist_Always(agents, f) => begin
            if ! evaluate(f, node, all_agents)
                return false
            end
            if length(node.children) == 0 || node.terminal_node
                return true
            end
            if node.passive_node
                return evaluate(formula, node.children[1], all_agents)
            end
            children = sort_children_by_clock_agent(node, agents)
            agents_children = Vector{OldNode}()
            other_agents_children = Vector{OldNode}()
            for child in children
                if child.reaching_decision.first in agents
                    if evaluate(formula, child, all_agents)
                        return true
                    end
                    push!(agents_children, child)
                else 
                    if ! evaluate(formula, child, all_agents)
                        return false
                    end
                    push!(other_agents_children, child)
                end
            end
            # if length(agents_children) > 0 && (length(other_agents_children) == 0 || last(agents_children).global_clock < last(other_agents_children).global_clock)
            #     return false
            # else
            #     return true
            # end
            return true
        end
        Exist_Eventually(agents, f) => begin
            if evaluate(f, node, all_agents)
                return true
            end
            if length(node.children) == 0 || node.terminal_node
                return false
            end
            if node.passive_node
                return evaluate(formula, node.children[1], all_agents)
            end
            children = sort_children_by_clock_agent(node, agents)
            agents_children = Vector{OldNode}()
            other_agents_children = Vector{OldNode}()
            for child in children
                if child.reaching_decision.first in agents
                    if evaluate(formula, child, all_agents)
                        return true
                    end
                    push!(agents_children, child)
                else 
                    if ! evaluate(formula, child, all_agents)
                        return false
                    end
                    push!(other_agents_children, child)
                end
            end
            return true
            # if length(agents_children) > 0 && (length(other_agents_children) == 0 || last(agents_children).global_clock < last(other_agents_children).global_clock)
            #     return false
            # else
            #     return true
            # end
        end
    end
end


function evaluate(formulae::Vector{Strategy_Formula}, node::OldNode, all_agents::Set{Agent})::Vector{Bool}
    results = Vector{Bool}()
    for formula in formulae
        push!(results, evaluate(formula, node, all_agents))
    end
    return results
end