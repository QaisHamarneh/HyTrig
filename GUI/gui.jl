# include("../packages.jl")

using Pkg
Pkg.activate(".")

using Dates
using JSON3
using QML

include("../parsers/parser.jl")

mutable struct QAgent
    name::String
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
end

mutable struct QEdge
    name::String
    source::String
    target::String
    guard::String
    agent::String
    action::String
end

agent_model::Vector{QAgent} = []
action_model::Vector{QAction} = []
variable_model::Vector{QVariable} = []
location_model::Vector{QLocation} = []
edge_model::Vector{QEdge} = []

function has_name(name)::Bool
    name = String(name)

    agents = Set(collect(x.name for x in agent_model))
    actions = Set(collect(x.name for x in action_model))
    locations = Set(collect(x.name for x in location_model))
    variables = Set(collect(x.name for x in variable_model))
    edges = Set(collect(x.name for x in edge_model))

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

    agents = Set(collect(x.name for x in agent_model))
    locations = Set(collect(x.name for x in location_model))
    variables = Set(collect(x.name for x in variable_model))

    try
        parse(formula, Bindings(agents, locations, variables), level)
        return true
    catch
        return false
    end
end

function save_to_json()
    for edge in edge_model
        println(edge.target)
    end
end

@qmlfunction has_name is_valid_formula save_to_json

qml_file = joinpath(dirname(@__FILE__), "qml", "gui.qml")

loadqml(
    qml_file,
    agent_model = JuliaItemModel(agent_model),
    action_model = JuliaItemModel(action_model),
    variable_model = JuliaItemModel(variable_model),
    location_model = JuliaItemModel(location_model),
    edge_model = JuliaItemModel(edge_model)
)

exec()
