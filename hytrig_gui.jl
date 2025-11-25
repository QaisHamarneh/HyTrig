"""
    HyTrig-GUI

This script runs a GUI with QML. The GUI allows to create, edit, save, load and verify hybrid games with triggers.

# Functions:
- `has_name(name)::Bool`: check if a name is already in use
- `is_valid_formula(formula, level)::Bool`: check if a formula is valid at a given parse level
- `save_to_json(path)`: save the current game to a JSON file
- `load_from_json(path)`: load a game from a JSON file
- `verify()`: verify the current game
- `up_tree()::Bool`: go up a layer in the last parsed game tree
- `down_tree(i)::Bool` go down a child in the last parsed game tree

# Authors:
- Moritz Maas
"""

include("packages.jl")

using Dates
using JSON3
using QML

include("GUI/QObjects.jl")

include("game_syntax/game.jl")
include("parsers/syntax_parsers/parser.jl")
include("model_checking/build_and_evaluate.jl")

# Declare synchronized models and roles

roles = JuliaPropertyMap()

# Declare agent model
agent_list::Vector{QAgent} = []
agent_model::JuliaItemModel = JuliaItemModel(agent_list)
setsetter!(agent_model, settriggers!, roleindex(agent_model, "triggers"))

# Declare action model
action_list::Vector{QAction} = []

# Declare variable model
variable_list::Vector{QVariable} = []
variable_model::JuliaItemModel = JuliaItemModel(variable_list)
roles["variable_name"] = roleindex(variable_model, "name")

# Declare location model
location_list::Vector{QLocation} = []
location_model::JuliaItemModel = JuliaItemModel(location_list)
setsetter!(location_model, setflow!, roleindex(location_model, "flow"))
roles["initial"] = roleindex(location_model, "initial")
roles["flow"] = roleindex(location_model, "flow")

# Temporarily create a flow model to get the role index for variable names
temp_flow_list::Vector{QFlow} = []
temp_flow_model::JuliaItemModel = JuliaItemModel(temp_flow_list)
roles["flow_variable_name"] = roleindex(temp_flow_model, "var")
roles["flow_expression"] = roleindex(temp_flow_model, "flow")

# Declare edge model
edge_list::Vector{QEdge} = []
edge_model::JuliaItemModel = JuliaItemModel(edge_list)
setsetter!(edge_model, setjump!, roleindex(edge_model, "jump"))
roles["jump"] = roleindex(edge_model, "jump")

# Temporarily create a jump model to get the role index for variable names
temp_jump_list::Vector{QJump} = []
temp_jump_model::JuliaItemModel = JuliaItemModel(temp_jump_list)
roles["jump_variable_name"] = roleindex(temp_jump_model, "var")
roles["jump_expression"] = roleindex(temp_jump_model, "jump")

# Declare query model
query_list::Vector{QQuery} = []

# Declare termination conditions
termination_conditions = JuliaPropertyMap()
termination_conditions["time-bound"] = ""
termination_conditions["max-steps"] = ""
termination_conditions["state-formula"] = ""

# Declare last parsed game tree
game_tree::Union{Node, Nothing} = Nothing()

# Declare node model
node_list::Vector{QNode} = []
node_model::JuliaItemModel = JuliaItemModel(node_list)

# Declare callable functions for QML

"""
    has_name(name)::Bool

Check if `name` is already used by an agent, action, location, variable or edge.

# Arguments
- `name`: the name to check
"""
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

"""
    is_valid_formula(formula, level)::Bool

Check if `formula` is a valid formula at level `level`.

# Arguments
- `formula`: the formula to check
- `level`: the parse level to use
"""
function is_valid_formula(formula, level)::Bool
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

"""
    verify()

Verify the current hybrid game with triggers.
"""
function verify()
    bindings = Bindings(
        Set(collect(x.name for x in agent_list)),
        Set(collect(x.name for x in location_list)),
        Set(collect(x.name for x in variable_list))
    )

    locations::Vector{Location} = []
    for loc in location_list
        push!(
            locations,
            Location(
                Symbol(loc.name),
                parse(loc.inv, bindings, constraint),
                Dict{Symbol, ExprLike}([(Variable(loc.flow[i].var) => parse(loc.flow[i].flow, bindings, expression)) for i in 1:length(loc.flow)])
            )
        )
    end
    initial_location::Location = locations[
        findfirst(loc -> loc.name == Symbol(first(filter(loc -> loc.initial, location_list)).name), locations)
    ]

    initial_valuation::Valuation = Valuation(
        Variable(var.name) => Base.parse(Float64, var.value) for var in variable_list
    )
    agents::Set{Agent} = Set(Agent(agent.name) for agent in agent_list)
    actions::Set{Action} = Set(Action(action.name) for action in action_list)
    edges::Vector{Edge} = [Edge(
        Symbol(edge.name),
        locations[findfirst(loc -> loc.name == Symbol(edge.source), locations)],
        locations[findfirst(loc -> loc.name == Symbol(edge.target), locations)],
        parse(edge.guard, bindings, constraint),
        Decision(Agent(edge.agent), Action(edge.action)),
        Dict(
            Symbol(edge.jump[i].var) => parse(edge.jump[i].jump, bindings, expression) for i in 1:length(edge.jump)
        )
    ) for edge in edge_list]
    triggers::Dict{Agent, Vector{Constraint}} = Dict{Agent, Vector{Constraint}}(
        Symbol(agent.name) => [
            parse(trigger.name, bindings, constraint) for trigger in values(agent.triggers)[]
        ] for agent in agent_list
    )

    game = Game(
        locations,
        initial_location,
        initial_valuation,
        agents,
        actions,
        edges,
        triggers,
        true
    )
    term_conds = Termination_Conditions(
        Base.parse(Float64, termination_conditions["time-bound"]),
        Base.parse(Int64, termination_conditions["max-steps"]),
        parse(termination_conditions["state-formula"], bindings, state)
    )
    queries::Vector{Strategy_Formula} = [parse(query.name, bindings, strategy) for query in query_list]

    global game_tree
    results, game_tree = evaluate_queries(game, term_conds, queries)

    empty!(node_list)

    if !isnothing(game_tree)
        push!(node_list, QNode(game_tree))
        game_tree = game_tree.parent
    end

    for (i, r) in enumerate(results)
        query_list[i].verified = true
        query_list[i].result = r
    end
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
        push!(node_list, QNode(child))
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

    empty!(node_list)

    if 0 < i <= length(game_tree.children)
        game_tree = game_tree.children[i]
        for child in game_tree.children
            push!(node_list, QNode(child))
        end
        return true
    else
        return false
    end
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

# Build and run QML GUI

@qmlfunction has_name is_valid_formula save_to_json load_from_json verify up_tree down_tree

qml_file = joinpath(dirname(@__FILE__), "GUI", "qml", "gui.qml")

loadqml(
    qml_file,
    roles = roles,
    agent_model = agent_model,
    action_model = JuliaItemModel(action_list),
    variable_model = variable_model,
    location_model = location_model,
    edge_model = edge_model,
    query_model = JuliaItemModel(query_list),
    termination_conditions = termination_conditions,
    node_model = node_model
)

exec()
