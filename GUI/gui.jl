include("../packages.jl")

using Dates
using JSON3
using QML

include("../parsers/parser.jl")

function is_valid_formula(formula, vars, locs, agns, level)
    formula = String(formula)
    level = eval(Symbol(level))
    if !(level isa ParseLevel)
        return false
    end
    variables = Vector{String}()
    for i in eachindex(vars)
        push!(variables, vars[i])
    end
    locations = Vector{String}()
    for i in eachindex(locs)
        push!(locations, locs[i])
    end
    agents = Vector{String}()
    for i in eachindex(agns)
        push!(agents, agns[i])
    end 
    try
        parse(formula, Bindings(Set(agents), Set(locations), Set(variables)), level)
        return true
    catch
        return false
    end
end

function save_to_json(data)
    open("save_$(now()).json", "w") do f
        JSON3.write(f, data)
    end
end

@qmlfunction is_valid_formula save_to_json

qml_file = joinpath(dirname(@__FILE__), "qml", "gui.qml")

loadqml(qml_file, guiproperties = JuliaPropertyMap())

exec()
