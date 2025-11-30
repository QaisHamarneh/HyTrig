""""
    GUI tree

This file contains all definitions for creating the traversable game tree for the GUI.

TODO

# Authors:
- Moritz Maas
"""

include("../essential_definitions/iliases.jl")
include("../game_syntax/game.jl")
include("../game_semantics/configuration.jl")
include("../model_checking/node.jl")

struct GUINode
    parent::Union{GUINode, Nothing}
    reaching_decision::Union{Pair{Agent, Action}, Nothing}
    reaching_trigger::Union{Constraint, Nothing}
    config::Configuration
    children::Vector{GUINode}
    passive_nodes::Vector{PassiveNode}
end

function GUINode(node::ActiveNode, parent::Union{GUINode, Nothing})::GUINode
    return GUINode(
        parent,
        node.reaching_decision,
        node.reaching_trigger,
        node.config,
        [],
        []
    )
end

function GUINode(node::RootNode, parent::Union{GUINode, Nothing})::GUINode
    return GUINode(
        parent,
        nothing,
        nothing,
        node.config,
        [],
        []
    )
end

function build_gui_tree(root::Union{ActiveNode, RootNode})::GUINode
    gui_root = GUINode(root, nothing)
    push!(gui_root.children, GUINode(root, gui_root))
    append!(gui_root.children[1].children, _get_next_layer(root, gui_root.children[1]))
    return gui_root
end

function _get_next_layer(node::Union{ActiveNode, RootNode}, parent::GUINode)::Vector{GUINode}
    nodes::Vector{GUINode} = []
    for child in node.children
        passives::Vector{PassiveNode} = []
        current_node::Node = child
        while !(current_node isa ActiveNode || current_node isa EndNode)
            push!(passives, current_node)
            current_node = current_node.children[1]
        end
        current_node = current_node.parent
        for active in current_node.children
            gui_node = GUINode(active, parent)
            append!(gui_node.passive_nodes, passives)
            append!(gui_node.children, _get_next_layer(active, gui_node))
            push!(nodes, gui_node)
        end
    end
    return nodes
end
