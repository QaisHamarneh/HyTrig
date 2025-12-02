"""
    JSON Utilities

This script contains utility functions for handling games and their .json representation.

# Functions:
- `save_to_json(path)`: save the current game to a JSON file
- `load_from_json(path)`: load a game from a JSON file

# Authors:
- Moritz Maas
"""

include("QObjects.jl")

"""
    save_to_json(path)

Save the current game to a JSON file at `path`.

# Arguments
- `path`: the path to save the JSON file to
"""
function save_to_json(path)
    path = replace(String(path),  r"^(file:\/{2})" => "")
    if !endswith(path, r"\.json")
        path = path * ".json"
    end
    data = Dict(
        "Game" => Dict(
            "name" => "save$(now())",
            "locations" => [_get_location_json(loc) for loc in location_list],
            "initial_valuation" => [Dict(variable.name => Base.parse(Float64, variable.value)) for variable in variable_list],
            "agents" => [agent.name for agent in agent_list],
            "triggers" => Dict(
                agent.name => [trigger.name for trigger in values(agent.triggers)[]] for agent in agent_list
            ),
            "actions" => [action.name for action in action_list],
            "edges" => [_get_edge_json(edge) for edge in edge_list]
        ),
        "termination-conditions" => Dict(
            "time-bound" => Base.parse(Float64, termination_conditions["time-bound"]),
            "max-steps" => Base.parse(Int64, termination_conditions["max-steps"]),
            "state-formula" => termination_conditions["state-formula"]
        ),
        "queries" => [query.name for query in query_list]
    )
    open(path, "w") do f
        JSON3.pretty(f, JSON3.write(data))
    end
end

"""
    load_from_json(path)

Load a game from a JSON file at `path`.

# Arguments
- `path`: the path to load the JSON file from
"""
function load_from_json(path)::Bool
    path = replace(String(path),  r"^(file:\/{2})" => "")
    data = open(path, "r") do f
        JSON3.read(f)
    end

    empty!(agent_list)
    empty!(action_list)
    empty!(variable_list)
    empty!(location_list)
    empty!(edge_list)
    empty!(query_list)

    try
        game = data["Game"]
        for loc in game["locations"]
            push!(
                location_list,
                QLocation(loc["name"], loc["invariant"], loc["initial"],
                    JuliaItemModel([QFlow(String(first(keys(flow))), first(values(flow))) for flow in loc["flow"]])
                )
            )
        end
        for var in game["initial_valuation"]
            push!(variable_list, QVariable(String(first(keys(var))), string(first(values(var)))))
        end
        for agent_name in game["agents"]
            triggers = JuliaItemModel([QTrigger(t) for t in game["triggers"][agent_name]])
            push!(agent_list, QAgent(agent_name, triggers))
        end
        for action_name in game["actions"]
            push!(action_list, QAction(action_name))
        end
        for edge in game["edges"]
            push!(
                edge_list,
                QEdge(edge["name"], edge["start_location"], edge["target_location"], edge["guard"],
                    String(first(keys(edge["decision"]))), first(values(edge["decision"])),
                    JuliaItemModel([QJump(String(first(keys(jump))), first(values(jump))) for jump in edge["jump"]])
                )
            )
        end
        for query_name in data["queries"]
            push!(query_list, QQuery(query_name, false, false))
        end
        term_conds = data["termination-conditions"]
        termination_conditions["time-bound"] = string(term_conds["time-bound"])
        termination_conditions["max-steps"] = string(term_conds["max-steps"])
        termination_conditions["state-formula"] = term_conds["state-formula"]
    catch
        return false
    end
    return true
end

function _get_location_json(loc::QLocation)
    return Dict(
        "name" => loc.name,
        "invariant" => loc.inv,
        "flow" => [Dict(loc.flow[i].var => loc.flow[i].flow) for i in 1:length(loc.flow)],
        "initial" => loc.initial
    )
end

function _get_edge_json(edge::QEdge)
    return Dict(
        "name" => edge.name,
        "start_location" => edge.source,
        "target_location" => edge.target,
        "guard" => edge.guard,
        "decision" => Dict(
            edge.agent => edge.action
        ),
        "jump" => [Dict(edge.jump[i].var => edge.jump[i].jump) for i in 1:length(edge.jump)]
    )
end