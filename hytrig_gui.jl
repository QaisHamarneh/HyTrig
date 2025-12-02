"""
    HyTrig-GUI

This script runs a GUI with QML. The GUI allows to create, edit, save, load and verify hybrid games with triggers.

# Functions:
- `has_name(name)::Bool`: check if a name is already in use
- `is_valid_formula(formula, level)::Bool`: check if a formula is valid at a given parse level
- `verify()`: verify the current game

# Authors:
- Moritz Maas
"""

include("packages.jl")

using Dates
using JSON3
using QML

include("GUI/gui_tree.jl")
include("GUI/json_utils.jl")
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

# Declare edge model
edge_list::Vector{QEdge} = []
edge_model::JuliaItemModel = JuliaItemModel(edge_list)
setsetter!(edge_model, setjump!, roleindex(edge_model, "jump"))
roles["jump"] = roleindex(edge_model, "jump")

# Declare query model
query_list::Vector{QQuery} = []

# Declare termination conditions
termination_conditions = JuliaPropertyMap()
termination_conditions["time-bound"] = ""
termination_conditions["max-steps"] = ""
termination_conditions["state-formula"] = ""

# Declare last parsed game tree
game_tree = nothing

# Declare node model
node_list::Vector{QActiveNode} = []
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
    is_savable()::Bool

Check if the current game state is savable.
"""
function is_savable()::Bool
    for loc in location_list
        for flow in values(loc.flow).val
            if flow.flow == ""
                return false
            end
        end
    end
    for edge in edge_list
        for jump in values(edge.jump).val
            if jump.jump == ""
                return false
            end
        end
    end
    return true
end

"""
    append_flow(i, var)

Append the flow of location `i` with the variable `var`.

# Arguments
- `i`: location index
- `var`: the flow variable to append
"""
function append_flow(i, var)
    push!(location_list[i].flow, QFlow(String(var), ""))
end

"""
    remove_flow(i, j)

Removes the flow variable of location `i` at index `j`.

# Arguments
- `i`: location index
- `j`: the index of the flow variable to remove
"""
function remove_flow(i, j)
    delete!(location_list[i].flow, j)
end

"""
    append_jump(i, var)

Append the jump of edge `i` with the variable `var`.

# Arguments
- `i`: edge index
- `var`: the jump variable to append
"""
function append_jump(i, var)
    push!(edge_list[i].jump, QJump(String(var), ""))
end

"""
    remove_jump(i, j)

Removes the jump variable of edge `i` at index `j`.

# Arguments
- `i`: edge index
- `j`: the index of the jump variable to remove
"""
function remove_jump(i, j)
    delete!(edge_list[i].jump, j)
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

    agents = collect(x.name for x in agent_list)
    locations = collect(x.name for x in location_list)
    variables = collect(x.name for x in variable_list)

    try
        parse(formula, Bindings(agents, locations, variables), level)
        return true
    catch
        return false
    end
end

"""
    verify()::String

Verify the current hybrid game with triggers.
"""
function verify()::String
    bindings = Bindings(
        collect(x.name for x in agent_list),
        collect(x.name for x in location_list),
        collect(x.name for x in variable_list)
    )

    locations::Vector{Location} = []
    for loc in location_list
        push!(
            locations,
            Location(
                Symbol(loc.name),
                parse(loc.inv, bindings, constraint),
                OrderedDict{Symbol, ExprLike}([(Variable(loc.flow[i].var) => parse(loc.flow[i].flow, bindings, expression)) for i in 1:length(loc.flow)])
            )
        )
    end
    initial_location::Location = locations[
        findfirst(loc -> loc.name == Symbol(first(filter(loc -> loc.initial, location_list)).name), locations)
    ]

    initial_valuation::Valuation = Valuation(
        Variable(var.name) => Base.parse(Float64, var.value) for var in variable_list
    )

    if !check_invariant(Configuration(initial_location, initial_valuation, 0))
        return "Invariant of initial location is not satisfied."
    end

    agents::Vector{Agent} = [Agent(agent.name) for agent in agent_list]
    actions::Vector{Action} = [Action(action.name) for action in action_list]
    edges::Vector{Edge} = [Edge(
        Symbol(edge.name),
        locations[findfirst(loc -> loc.name == Symbol(edge.source), locations)],
        locations[findfirst(loc -> loc.name == Symbol(edge.target), locations)],
        parse(edge.guard, bindings, constraint),
        Decision(Agent(edge.agent), Action(edge.action)),
        Dict{Symbol, ExprLike}(
            [(Symbol(edge.jump[i].var) => parse(edge.jump[i].jump, bindings, expression)) for i in 1:length(edge.jump)]
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
        parse(String(termination_conditions["state-formula"]), bindings, state)
    )
    queries::Vector{Strategy_Formula} = [parse(query.name, bindings, strategy) for query in query_list]

    global game_tree
    results, game_tree = evaluate_queries(game, term_conds, queries)

    empty!(node_list)

    if !isnothing(game_tree)
        game_tree = build_gui_tree(game_tree)
        push!(node_list, QActiveNode(game_tree.children[1]))
    end

    for (i, r) in enumerate(results)
        query_list[i].verified = true
        query_list[i].result = r
    end

    return ""
end

# Build and run QML GUI

@qmlfunction has_name is_savable append_flow remove_flow append_jump remove_jump is_valid_formula save_to_json load_from_json verify up_tree down_tree

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
