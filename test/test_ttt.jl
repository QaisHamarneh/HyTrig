using Test

include("../game_tree/time_to_trigger.jl")
include("../parsers/syntax_parsers/parser.jl")
include("../parsers/ast_to_logic.jl")


flow_l_a::ReAssignment = Dict(:x => parse("spd_A * dir_x", Bindings(Set([]), Set([]), Set(["x", "y", "spd_A", "dir_x"])), expression), 
                              :y => parse("spd_A * dir_y", Bindings(Set([]), Set([]), Set(["x", "y", "spd_A", "dir_y"])), expression))
l_a = Location(:A_Throwing, parse("y-11 <= x && x <= 11 && -1 <= y && y <= 11", Bindings(Set([]), Set([]), Set(["x", "y", "spd_A", "dir_x", "dir_y"])), constraint), flow_l_a)
v0::Valuation = OrderedDict(:x => -5.0, :y => 5.0, :spd_A => 0.2, :dir_x => -5, :dir_y => -5)
config0 = Configuration(l_a, v0, 0.0)
trigger = parse("-10.5 <= x  && x<= -9.5 && -0.5 <= y  && y <= 0.5", Bindings(Set([]), Set([]), Set(["x", "y"])), constraint)

queries = Logic_formula[
    parse("<<A, C>> F x > 8 || y >= 4", Bindings(Set(["A", "C"]), Set([]), Set(["x", "y"])), strategy), 
    parse("<<A, C>> F x <= -7 || y > 9", Bindings(Set(["A", "C"]), Set([]), Set(["x", "y"])), strategy)
]

constraints = get_all_constraints(queries)

new_valuation, ttt, path_to_trigger = time_to_trigger(config0, trigger, constraints, 20.0)
println("New Valuation: ", new_valuation)
println("Time to Trigger: ", ttt)
for (i, config) in enumerate(path_to_trigger)
    println("Valuation: ", config.valuation, ", Global Clock: ", config.global_clock)
end