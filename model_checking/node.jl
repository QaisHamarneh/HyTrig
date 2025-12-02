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
    config::Configuration
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
    reaching_decision::Union{Pair{Agent, Constraint}, Nothing}
    config::Configuration
    level::Int32
    children::Vector{Node}
end

struct EndNode <: Node
    parent::Node
    config::Configuration
    level::Int32
    children::Vector{Node}
end

function print_tree(root::Node)
    res = ""
    @match root begin
        RootNode(_, _, children) =>
            begin
                res *= "\nRoot  $(root.config.location.name)\nValuation: $(root.config.valuation)\nChildren: $(length(children))"
                res *= "\n--------------\n"
                for child in children
                    res *= print_tree(child)
                end
            end
        ActiveNode(_, decision, trigger, _, level, children) =>
            begin
                res *= "\n$level- Active - Agent: $(decision.first) - Action: $(decision.second) / $(str(trigger)) - Location: $(root.config.location.name)\nValuation: $(round5(root.config.valuation)), - Time: $(round5(root.config.global_clock))\nChildren: $(length(children))"
                res *= "\n--------------\n"
                for child in children
                    res *= print_tree(child)
                end
            end
        PassiveNode(_, decision, _, level, children) =>
            begin
                if isnothing(decision)
                    res *= "\n$level- Passive - Location: $(root.config.location.name)\nValuation: $(root.config.valuation), - Time: $(root.config.global_clock)"
                res *= "\n--------------\n"
                else
                    res *= "\n$level- Passive - Agent: $(decision.first) - Trigger: $(str(decision.second)) - Location: $(root.config.location.name)\nValuation: $(round5(root.config.valuation)), - Time: $(round5(root.config.global_clock))\nChildren: $(length(children))"
                res *= "\n--------------\n"
                end
                for child in children
                    res *=print_tree(child)
                end
            end
        EndNode(_, _, level, children) =>
            begin
                res *= "\n$level- End - Location: $(root.config.location.name)\nValuation: $(root.config.valuation), - Time: $(root.config.global_clock)"
                res *= "\n--------------\n"
                for child in children
                    res *=print_tree(child)
                end
            end
    end
    return res
end

function count_nodes(root::Node)::Int
    # println("Level = ", root.level, " - ", root.config.location.name, " - ",  root.config.valuation)
    @match root begin
        RootNode(_, _, []) => 1
        RootNode(_, _, children) => 1 + sum(count_nodes(child) for child in children)
        ActiveNode(_, _, _, _, _, []) => 1
        ActiveNode(_, _, _, _, _, children) => 1 + sum(count_nodes(child) for child in children)
        PassiveNode(_, _, _, _, []) => 1
        PassiveNode(_, _, _, _, children) => 1 + sum(count_nodes(child) for child in children)
        EndNode(_, _, _, []) => 1
        EndNode(_, _, _, children) => 1 + sum(count_nodes(child) for child in children)
    end
end

function count_passive_nodes(root::Node)::Int
    @match root begin
        RootNode(_, _, []) => 0
        RootNode(_, _, children) => sum(count_passive_nodes(child) for child in children)
        ActiveNode(_, _, _, _, _, []) => 0
        ActiveNode(_, _, _, _, _, children) => sum(count_passive_nodes(child) for child in children)
        PassiveNode(_, _, _, _, []) => 1
        PassiveNode(_, _, _, _, children) => 1 + sum(count_passive_nodes(child) for child in children)
        EndNode(_, _, _, []) => 1
        EndNode(_, _, _, children) => 1 + sum(count_nodes(child) for child in children)
    end
end

function depth_of_tree(root::Node)::Int
    @match root begin
        RootNode(_, _, []) => 1
        RootNode(_, _, children) => maximum(depth_of_tree(child) for child in children)
        ActiveNode(_, _, _, _, _, []) => root.level
        ActiveNode(_, _, _, _, _, children) => maximum(depth_of_tree(child) for child in children)
        PassiveNode(_, _, _, _, []) => root.level
        PassiveNode(_, _, _, _, children) => maximum(depth_of_tree(child) for child in children)
        EndNode(_, _, _, []) => root.level
        EndNode(_, _, _, children) => maximum(depth_of_tree(child) for child in children)
    end
end


function max_time(root::Node)::Float64
    @match root begin
        RootNode(_, _, []) => round5(root.config.global_clock)
        RootNode(_, _, children) => maximum(max_time(child) for child in children)
        ActiveNode(_, _, _, _, _, []) => round5(root.config.global_clock)
        ActiveNode(_, _, _, _, _, children) => maximum(max_time(child) for child in children)
        PassiveNode(_, _, _, _, []) => round5(root.config.global_clock)
        PassiveNode(_, _, _, _, children) => maximum(max_time(child) for child in children)
        EndNode(_, _, _, []) => round5(root.config.global_clock)
        EndNode(_, _, _, children) => maximum(max_time(child) for child in children)
    end
end

function child_time(child::Node)::Float64
    @match child begin
        RootNode(_, _, _) => 0
        ActiveNode(_, _, _, _, _, _) => child.config.global_clock
        PassiveNode(_, _, _, _, []) => child.config.global_clock
        PassiveNode(_, _, _, _, children) => child_time(children[1])
        EndNode(_, _, _, children) => child.config.global_clock
    end
end

function sort_children_by_clock!(root::Node)
    # sorts children by global clock, and if two children have the same clock, the one with the agent's decision comes last
    sort!(root.children, by = child -> child_time(child))
end

function sort_children_by_clock_agent(root::Node, agents::Vector{Agent})
    # sorts children by global clock, and if two children have the same clock, the one with the agent's decision comes last
    sort(root.children, by = child -> (child_time(child), child.reaching_decision.first in agents))
end