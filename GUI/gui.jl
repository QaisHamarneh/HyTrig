include("../packages.jl")

using Dates
using JSON3
using QML

include("../parsers/parser.jl")

mutable struct QTrigger
    name::String
end

mutable struct QAgent
    name::String
    triggers::JuliaItemModel
end

function QAgent(name, triggers::AbstractArray)
  return QAgent(name, JuliaItemModel([QTrigger(QML.value(t)["name"]) for t in triggers]))
end

function settriggers!(agent_model, triggers, row, col)
    agent_model[row].triggers = JuliaItemModel([QTrigger(QML.value(t)["name"]) for t in triggers])
end

mutable struct QAction
    name::String
end

mutable struct QVariable
    name::String
    value::String
end

mutable struct QLocation
    name::String
    inv::String
    initial::Bool
    flow::JuliaItemModel
end

function QLocation(name, inv, initial, flow::AbstractArray)
    return QLocation(name, inv, initial, JuliaItemModel([QFlow(QML.value(f)["var"], QML.value(f)["flow"]) for f in flow]))
end

function setflow!(location_model, flow, row, col)
    location_model[row].flow = JuliaItemModel([QFlow(QML.value(f)["var"], QML.value(f)["flow"]) for f in flow])
end

mutable struct QFlow
    var::String
    flow::String
end

mutable struct QEdge
    name::String
    source::String
    target::String
    guard::String
    agent::String
    action::String
    jump::JuliaItemModel
end

function QEdge(name, source, target, guard, agent, action, jump::AbstractArray)
    return QEdge(name, source, target, guard, agent, action,
        JuliaItemModel([QJump(QML.value(j)["var"], QML.value(j)["jump"]) for j in jump])
    )
end

function setjump!(edge_model, jump, row, col)
    edge_model[row].jump = JuliaItemModel([QJump(QML.value(j)["var"], QML.value(j)["jump"]) for j in jump])
end

mutable struct QJump
    var::String
    jump::String
end

mutable struct QQuery
    name::String
end

roles = JuliaPropertyMap()

agent_list::Vector{QAgent} = []
agent_model::JuliaItemModel = JuliaItemModel(agent_list)
setsetter!(agent_model, settriggers!, roleindex(agent_model, "triggers"))

action_list::Vector{QAction} = []

variable_list::Vector{QVariable} = []
variable_model::JuliaItemModel = JuliaItemModel(variable_list)
roles["variable_name"] = roleindex(variable_model, "name")

location_list::Vector{QLocation} = []
location_model::JuliaItemModel = JuliaItemModel(location_list)
setsetter!(location_model, setflow!, roleindex(location_model, "flow"))
roles["initial"] = roleindex(location_model, "initial")
roles["flow"] = roleindex(location_model, "flow")

temp_flow_list::Vector{QFlow} = []
temp_flow_model::JuliaItemModel = JuliaItemModel(temp_flow_list)
roles["flow_variable_name"] = roleindex(temp_flow_model, "var")

edge_list::Vector{QEdge} = []
edge_model::JuliaItemModel = JuliaItemModel(edge_list)
setsetter!(edge_model, setjump!, roleindex(edge_model, "jump"))
roles["jump"] = roleindex(edge_model, "jump")

temp_jump_list::Vector{QJump} = []
temp_jump_model::JuliaItemModel = JuliaItemModel(temp_jump_list)
roles["jump_variable_name"] = roleindex(temp_jump_model, "var")

query_list::Vector{QQuery} = []

termination_conditions = QML.QQmlPropertyMap()
termination_conditions["time-bound"] = ""
termination_conditions["max-steps"] = ""
termination_conditions["state-formula"] = ""

function has_name(name)::Bool
    name = String(name)

    agents = Set(collect(x.name for x in agent_list))
    actions = Set(collect(x.name for x in action_list))
    locations = Set(collect(x.name for x in location_list))
    variables = Set(collect(x.name for x in variable_list))
    edges = Set(collect(x.name for x in edge_list))

    if name in union(agents, actions, locations, variables, edges)
        return true
    end
    return false
end

function is_valid_formula(formula, level)
    formula = String(formula)
    level = eval(Symbol(level))
    if !(level isa ParseLevel)
        return false
    end

    agents = Set(collect(x.name for x in agent_list))
    locations = Set(collect(x.name for x in location_list))
    variables = Set(collect(x.name for x in variable_list))

    try
        parse(formula, Bindings(agents, locations, variables), level)
        return true
    catch
        return false
    end
end

function save_to_json(path)
    path = replace(String(path),  r"^(file:\/{2})" => "")
    data = Dict(
        "Game" => Dict(
            "name" => "save$(now())",
            "locations" => [_get_location_json(loc) for loc in location_list],
            "initial_valuation" => Dict(variable.name => variable.value for variable in variable_list),
            "agents" => [agent.name for agent in agent_list],
            "triggers" => Dict(
                agent.name => [trigger.name for trigger in values(agent.triggers)[]] for agent in agent_list
            ),
            "actions" => [action.name for action in action_list],
            "edges" => [_get_edge_json(edge) for edge in edge_list]
        ),
        "termination-conditions" => Dict(
            "time-bound" => termination_conditions["time-bound"],
            "max-steps" => termination_conditions["max-steps"],
            "state-formula" => termination_conditions["state-formula"]
        ),
        "queries" => [query.name for query in query_list]
    )
    open(path, "w") do f
        JSON3.pretty(f, JSON3.write(data))
    end
end

function load_from_json(path)
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

    game = data["Game"]
    for loc in game["locations"]
        push!(
            location_list,
            QLocation(loc["name"], loc["invariant"], loc["initial"],
                JuliaItemModel([QFlow(String(var), flow) for (var, flow) in loc["flow"]])
            )
        )
    end
    for (var, value) in game["initial_valuation"]
        push!(variable_list, QVariable(String(var), value))
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
            QEdge(edge["name"], edge["source"], edge["target"], edge["guard"],
                String(first(keys(edge["decision"]))), first(values(edge["decision"])),
                JuliaItemModel([QJump(String(var), jump) for (var, jump) in edge["jump"]])
            )
        )
    end
    for query_name in data["queries"]
        push!(query_list, QQuery(query_name))
    end
    term_conds = data["termination-conditions"]
    termination_conditions["time-bound"] = term_conds["time-bound"]
    termination_conditions["max-steps"] = term_conds["max-steps"]
    termination_conditions["state-formula"] = term_conds["state-formula"]
end

function _get_location_json(loc::QLocation)
    return Dict(
        "name" => loc.name,
        "invariant" => loc.inv,
        "flow" => Dict(
            loc.flow[i].var => loc.flow[i].flow for i in 1:length(loc.flow)
        ),
        "initial" => loc.initial
    )
end

function _get_edge_json(edge::QEdge)
    return Dict(
        "name" => edge.name,
        "source" => edge.source,
        "target" => edge.target,
        "guard" => edge.guard,
        "decision" => Dict(
            edge.agent => edge.action
        ),
        "jump" => Dict(
            edge.jump[i].var => edge.jump[i].jump for i in 1:length(edge.jump)
        )
    )
end

@qmlfunction has_name is_valid_formula save_to_json load_from_json

qml_file = joinpath(dirname(@__FILE__), "qml", "gui.qml")

loadqml(
    qml_file,
    roles = roles,
    agent_model = agent_model,
    action_model = JuliaItemModel(action_list),
    variable_model = variable_model,
    location_model = location_model,
    edge_model = edge_model,
    query_model = JuliaItemModel(query_list),
    termination_conditions = termination_conditions
)

exec()
