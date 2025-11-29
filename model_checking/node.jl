include("../game_syntax/game.jl")
include("../game_semantics/configuration.jl")

struct TriggerPath
    trigger::Constraint
    end_valuation::Valuation
    ttt::Float64
    path_to_trigger::Vector{Configuration}
end

abstract type Node
end

struct RootNode <: Node
    parent::Union{Node, Nothing}
    config::Union{Configuration, Nothing}
    level::Int32
    children::Vector{Node}
end

struct ActiveNode <: Node
    parent::Node
    reaching_decision::Pair{Agent, Action}
    reaching_trigger::Constraint
    config::Configuration
    level::Int32
    children::Vector{Node}
end

struct PassiveNode <: Node
    parent::Node
    reaching_decision::Pair{Agent, Constraint}
    config::Configuration
    level::Int32
    children::Vector{Node}
end

function count_nodes(root::Node)::Int
    # println(root.config.location.name, " - ",  root.config.valuation)
    @match root begin
        RootNode(_, _, _, []) => 1
        RootNode(_, _, _, children) => 1 + sum(count_nodes(child) for child in children)
        ActiveNode(_, _, _, _, _, []) => 1
        ActiveNode(_, _, _, _, _, children) => 1 + sum(count_nodes(child) for child in children)
        PassiveNode(_, _, _, _, []) => 1
        PassiveNode(_, _, _, _, children) => 1 + sum(count_nodes(child) for child in children)
    end
end

function count_passive_nodes(root::Node)::Int
    @match root begin
        RootNode(_, _, _, []) => 0
        RootNode(_, _, _, children) => sum(count_passive_nodes(child) for child in children)
        ActiveNode(_, _, _, _, _, []) => 0
        ActiveNode(_, _, _, _, _, children) => sum(count_passive_nodes(child) for child in children)
        PassiveNode(_, _, _, _, []) => 1
        PassiveNode(_, _, _, _, children) => 1 + sum(count_passive_nodes(child) for child in children)
    end
end

function depth_of_tree(root::Node, level::Int = 1)::Int
    @match root begin
        RootNode(_, _, _, []) => level
        RootNode(_, _, _, children) => maximum(depth_of_tree(child, level + 1) for child in children)
        ActiveNode(_, _, _, _, _, []) => level
        ActiveNode(_, _, _, _, _, children) => maximum(depth_of_tree(child, level + 1) for child in children)
        PassiveNode(_, _, _, _, []) => level
        PassiveNode(_, _, _, _, children) => maximum(depth_of_tree(child, level) for child in children)
    end
end

function child_time(child::Node)::Float64
    @match child begin
        RootNode(_, _, _, _) => 0
        ActiveNode(_, _, _, _, _, _) => child.config.global_clock
        PassiveNode(_, _, _, _, []) => child.config.global_clock
        PassiveNode(_, _, _, _, children) => child_time(children[1])
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