""""
    GUI tree

This file contains all definitions for creating the traversable game tree for the GUI.

# Types:
- `GUINode`: a node in a traversable GUI tree

# Functions:
- `build_gui_tree(root::Union{ActiveNode, RootNode})::GUINode`: build a GUI tree from a game tree
- `up_tree()::Bool`: ascend a layer in the GUI tree
- `down_tree(i)::Bool`: descend a layer in the GUI tree

# Authors:
- Moritz Maas
"""

include("../essential_definitions/iliases.jl")
include("../game_syntax/game.jl")
include("../game_semantics/configuration.jl")
include("../model_checking/node.jl")

"""
    GUINode

A node used in the traversable GUI tree.
"""
struct GUINode
    parent::Union{GUINode, Nothing}
    reaching_decision::Union{Pair{Agent, Action}, Nothing}
    reaching_trigger::Union{Constraint, Nothing}
    config::Configuration
    children::Vector{GUINode}
    passive_nodes::Vector{PassiveNode}
end

"""
    GUINode(node::ActiveNode, parent::Union{GUINode, Nothing})::GUINode

Create a GUINode from the given active node `node` with the parent `parent`.
# Arguments
- `node::ActiveNode`: the active node
- `parent::Union{GUINode, Nothing}`: the nodes next active parent
"""
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

"""
    GUINode(node::RootNode, parent::Union{GUINode, Nothing})::GUINode

Create a GUINode from the given root node `node` with the parent `parent`.
# Arguments
- `node::RootNode`: the root node
- `parent::Union{GUINode, Nothing}`: the nodes next active parent
"""
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

"""
    GUINode(node::EndNode, parent::Union{GUINode, Nothing})::GUINode

Create a GUINode from the given end node `node` with the parent `parent`.
# Arguments
- `node::EndNode`: the end node
- `parent::Union{GUINode, Nothing}`: the nodes next active parent
"""
function GUINode(node::EndNode, parent::Union{GUINode, Nothing})::GUINode
    return GUINode(
        parent,
        nothing,
        nothing,
        node.config,
        [],
        []
    )
end

global game_tree::Union{GUINode, Node, Nothing}

"""
    build_gui_tree(root::Union{ActiveNode, RootNode})::GUINode

Recursively build the GUI tree from a game tree rooted in `root`.

# Arguments
- `root::Union{ActiveNode, RootNode}`: the game trees root
"""
function build_gui_tree(root::Union{ActiveNode, RootNode})::GUINode
    gui_root = GUINode(root, nothing)
    push!(gui_root.children, GUINode(root, gui_root))
    append!(gui_root.children[1].children, _get_next_layer(root, gui_root.children[1]))
    return gui_root
end


"""
    up_tree()::Bool

Set the node model to the current nodes parent layer.
"""
function up_tree()::Bool
    global game_tree
    if isnothing(game_tree) || isnothing(game_tree.parent)
        return false
    end

    empty!(node_list)

    game_tree = game_tree.parent

    for child in game_tree.children
        push!(node_list, QActiveNode(child))
    end
    return true
end

"""
    down_tree(i)::Bool

Set the node model to the current nodes child layer of child `i`.
"""
function down_tree(i)::Bool
    global game_tree
    if isempty(node_list) || isnothing(game_tree)
        return false
    end

    i = Int(i)

    if 0 < i <= length(game_tree.children)
        if isempty(game_tree.children[i].children)
            return false
        end
        empty!(node_list)
        game_tree = game_tree.children[i]
        for child in game_tree.children
            push!(node_list, QActiveNode(child))
        end
        return true
    else
        return false
    end
end

function _get_next_layer(node::Union{ActiveNode, RootNode}, parent::GUINode)::Vector{GUINode}
    nodes::Vector{GUINode} = []
    for child in node.children
        passives::Vector{PassiveNode} = []
        current_node::Node = child
        while !(current_node isa ActiveNode || current_node isa EndNode)
            push!(passives, current_node)
            if length(current_node.children) != 1 && current_node.children[1] isa PassiveNode
                print("Alarm!")
            end
            current_node = current_node.children[1]
        end
        current_node = current_node.parent
        for active in current_node.children
            gui_node = GUINode(active, parent)
            append!(gui_node.passive_nodes, passives)
            if !(active isa EndNode)
                append!(gui_node.children, _get_next_layer(active, gui_node))
            end
            push!(nodes, gui_node)
        end
    end
    return nodes
end
