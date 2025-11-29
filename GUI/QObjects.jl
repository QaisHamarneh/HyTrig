""""
    QObjects

This file contains all QML object definitions needed to create QML models for the GUI.

# Types:
- `QObject`: abstract type for all objects used in QML models
- `QTrigger`: a trigger used in QML models
- `QAgent`: a agent used in QML models
- `QAction`: a action used in QML models
- `QVariable`: a variable used in QML models
- `QFlow`: a flow used in QML models
- `QLocation`: a location used in QML models
- `QJump`: a jump used in QML models
- `QEdge`: a edge used in QML models
- `QQuery`: a query used in QML models

# Authors:
- Moritz Maas
"""

include("../model_checking/node.jl")

# abstract types for all objects used in QML models
abstract type QObject
end

"""
    QTrigger <: QObject

A trigger used in QML models.

    QTrigger(name::String)

Create a QTrigger with trigger `name`.
"""
mutable struct QTrigger <: QObject
    name::String
end

"""
    QAgent <: QObject

A agent used in QML models.

    QAgent(name::String, triggers::JuliaItemModel)

Create a QAgent with name `name` and triggers `triggers`.
"""
mutable struct QAgent <: QObject
    name::String
    triggers::JuliaItemModel
end

"""
    QAgent(name, triggers::AbstractArray)::QAgent

Create a QAgent with a vector of triggers.

# Arguments
- `name`: the name of the agent
- `triggers`: a QML array of triggers
"""
function QAgent(name, triggers::AbstractArray)::QAgent
  return QAgent(name, JuliaItemModel([QTrigger(QML.value(t)["name"]) for t in triggers]))
end

"""
    settriggers!(agent_model, triggers, row, col)

Set the triggers of the agent at `row` in `agent_model` to `triggers`.

# Arguments
- `agent_model`: the model of agents
- `triggers`: a QML array of triggers
- `row`: the row of the agent to set the triggers for
- `col`: the column of the agent to set the triggers for, ignored
"""
function settriggers!(agent_model, triggers, row, col)
    agent_model[row].triggers = JuliaItemModel([QTrigger(QML.value(t)["name"]) for t in triggers])
end

"""
    QAction <: QObject

A action used in QML models.

    QAction(name::String)

Create a QAction with name `name`.
"""
mutable struct QAction <: QObject
    name::String
end

"""
    QVariable <: QObject

A variable used in QML models.

    QVariable(name::String, value::String)

Create a QVariable with name `name` and value `value`.
"""
mutable struct QVariable <: QObject
    name::String
    value::String
end

"""
    QFlow <: QObject

A flow used in QML models.

    QFlow(var::String, flow::String)

Create a QFlow for variable `var` with expression `flow`.
"""
mutable struct QFlow <: QObject
    var::String
    flow::String
end

"""
    QLocation <: QObject

A location used in QML models.

    QLocation(name::String, inv::String, initial::Bool, flow::JuliaItemModel)

Create a QLocation with name `name`, invariant `inv`, initial flag `initial` and flow `flow`.
"""
mutable struct QLocation <: QObject
    name::String
    inv::String
    initial::Bool
    flow::JuliaItemModel
end

"""
    QLocation(name, inv, initial, flow::AbstractArray)::QLocation

Create a QLocation with a vector of flows.

# Arguments
- `name`: the name of the location
- `inv`: the invariant of the location
- `initial`: whether the location is initial
- `flow`: a QML array of flows
"""
function QLocation(name, inv, initial, flow::AbstractArray)::QLocation
    return QLocation(name, inv, initial, JuliaItemModel([QFlow(QML.value(f)["var"], QML.value(f)["flow"]) for f in flow]))
end

"""
    setflow!(location_model, flow, row, col)

Set the flow of the location at `row` in `location_model` to `flow`.

# Arguments
- `location_model`: the model of locations
- `flow`: a QML array of flows
- `row`: the row of the location to set the flow for
- `col`: the column of the location to set the flow for, ignored
"""
function setflow!(location_model, flow, row, col)
    location_model[row].flow = JuliaItemModel([QFlow(QML.value(f)["var"], QML.value(f)["flow"]) for f in flow])
end

"""
    QJump <: QObject

A jump used in QML models.

    QJump(var::String, jump::String)

Create a QJump for variable `var` with expression `jump`.
"""
mutable struct QJump <: QObject
    var::String
    jump::String
end

"""
    QEdge <: QObject

A edge used in QML models.

    QEdge(name::String, source::String, target::String, guard::String, agent::String, action::String, jump::JuliaItemModel)

Create a QEdge with name `name`, source location `source`, target location `target`, guard `guard`, agent `agent`, action `action` and jump `jump`.
"""
mutable struct QEdge <: QObject
    name::String
    source::String
    target::String
    guard::String
    agent::String
    action::String
    jump::JuliaItemModel
end

"""
    QEdge(name, source, target, guard, agent, action, jump::AbstractArray)::QEdge

Create a QEdge with a vector of jumps.

# Arguments
- `name`: the name of the edge
- `source`: the source location of the edge
- `target`: the target location of the edge
- `guard`: the guard of the edge
- `agent`: the agent of the edge
- `action`: the action of the edge
- `jump`: a QML array of jumps
"""
function QEdge(name, source, target, guard, agent, action, jump::AbstractArray)::QEdge
    return QEdge(name, source, target, guard, agent, action,
        JuliaItemModel([QJump(QML.value(j)["var"], QML.value(j)["jump"]) for j in jump])
    )
end

"""
    setjump!(edge_model, jump, row, col)

Set the jump of the edge at `row` in `edge_model` to `jump`.

# Arguments
- `edge_model`: the model of edges
- `jump`: a QML array of jumps
- `row`: the row of the edge to set the jump for
- `col`: the column of the edge to set the jump for, ignored
"""
function setjump!(edge_model, jump, row, col)
    edge_model[row].jump = JuliaItemModel([QJump(QML.value(j)["var"], QML.value(j)["jump"]) for j in jump])
end

"""
    QQuery <: QObject

A query used in QML models.

    QQuery(name::String, verified::Bool)

Create a QQuery with strategy formula `name`.
"""
mutable struct QQuery <: QObject
    name::String
    verified::Bool
    result::Bool
end

"""
    QActiveNode <: QObject

An active tree node used in QML models.

    TODO
"""
mutable struct QActiveNode <: QObject
    location::String
    agent::String
    action::String
    time::Float64
    passive_nodes::JuliaItemModel
end

function QActiveNode(node::Node, passive_nodes::Vector{QPassiveNode})::QActiveNode
    @match node begin
        RootNode(_, config, _, _) => QActiveNode(string(config.location), "", "", 0, JuliaItemModel([]))
        ActiveNode(_, decision, trigger, config, _, _) => 
            QActiveNode(
                string(config.location), 
                tring(decision[1]),
                string(decision[2]),
                trunc(config.global_clock, digits=5)
            )
        PassiveNode(_, _, _, _, _) => throw(ArgumentError("Passive nodes cannot be parsed to a QActiveNode."))
    end
end

"""
    QPassiveNode <: QObject

A passive tree node used in QML models.

    TODO
"""
mutable struct QPassiveNode <: QObject
    location::String
    agent::String
    action::String
    time::Float64
    passive_nodes::JuliaItemModel
end

function QActiveNode(node::Node, passive_nodes::Vector{QPassiveNode})::QActiveNode
    @match node begin
        RootNode(_, config, _, _) => QActiveNode(string(config.location), "", "", 0, JuliaItemModel([]))
        ActiveNode(_, decision, trigger, config, _, _) => 
            QActiveNode(
                string(config.location), 
                tring(decision[1]),
                string(decision[2]),
                trunc(config.global_clock, digits=5)
            )
        PassiveNode(_, _, _, _, _) => throw(ArgumentError("Passive nodes cannot be parsed to a QActiveNode."))
    end
end
