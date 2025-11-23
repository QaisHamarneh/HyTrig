include("../game_syntax/game.jl")
include("../game_semantics/configuration.jl")

struct TriggerPath
    trigger::Constraint
    end_valuation::Valuation
    ttt::Float64
    path_to_trigger::Vector{Configuration}
end

struct Node
    parent::Union{Node, Nothing}
    reaching_decision::Union{Pair{Agent, Action}, Pair{Agent, <:Constraint}, Nothing}
    reaching_trigger::Union{TriggerPath, Nothing}
    level::Int32
    trigger_number::Int32
    passive_number::Int32
    passive_node::Bool
    config::Configuration
    children::Vector{Node}
end

function count_nodes(root::Node, level=0)::Int
    println("Level: ", root.level,  " - Trigger: ", root.trigger_number, " - Passive: ", root.passive_number, " - ", root.config.location.name, " - ",  root.config.valuation)
    @match root begin
        Node(_, _, _, _, _, _, _, _, []) => 1
        Node(_, _, _, _, _, _, _, _, children) => 1 + sum(count_nodes(child, level+1) for child in children)
    end
end

function count_passive_nodes(root::Node)::Int
    # println("Level: ", level, " - Location ", root.config.location.name, " - Valuation: ",  root.config.valuation)
    @match root begin
        Node(_, _, _, _, _, _, passive, _, []) => Int(passive)
        Node(_, _, _, _, _, _, passive, _, children) => Int(passive) + sum(count_passive_nodes(child) for child in children)
    end
end

function depth_of_tree(root::Node, level::Int = 1)::Int
    @match root begin
        Node(_, _, _, _, _, _, _, _, []) => level
        Node(_, _, _, _, _, _, passive, _, children) => maximum(depth_of_tree(child, level + Int(!passive)) for child in children)
    end
end

function child_time(child::Node)::Float64
    if child.passive_node
        return child_time(child.children[1])
    else
        return child.config.global_clock
    end
end

function sort_children_by_clock!(root::Node)
    # sorts children by global clock, and if two children have the same clock, the one with the agent's decision comes last
    sort!(root.children, by = child -> child_time(child))
end

function sort_children_by_clock_agent(root::Node, agents::Set{Agent})
    # sorts children by global clock, and if two children have the same clock, the one with the agent's decision comes last
    sort(root.children, by = child -> (child_time(child), child.reaching_decision.first in agents))
end