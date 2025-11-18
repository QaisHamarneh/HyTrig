# using Ranges   # Remove this line
include("packages.jl")
include("parsers/parse_game.jl")
include("model_checking/build_and_evaluate.jl")

example = ARGS[1]


t0 = time();

if example == "1"
    game, termination_conditions, queries = parse_game("examples/bouncing_ball.json")
elseif example == "2"
    game, termination_conditions, queries = parse_game("examples/3_players_1_ball.json")
elseif example == "3"
    game, termination_conditions, queries = parse_game("examples/player_in_middle.json")
else 
    error("Example not recognized")
end


##################################
t1 = time();

results, game_tree = evaluate_queries(game, termination_conditions, queries)

t2 = time();

nodes_count, passive_nodes = count_nodes(game_tree), count_passive_nodes(game_tree)
tree_depth = depth_of_tree(game_tree)

println("*************************")
println("Time to parse = $(t2 - t1)")
println("queries = ", queries)
println("*************************")
println("***** On the fly ********")
println("Nodes = ", nodes_count, " Passive Nodes = ", passive_nodes, " Depth = ", tree_depth)
println("results = ", results)
println("Time to evaluate and build = $(t2 - t1)")
println("*************************")
println("*** For a full view of the game tree, please use hytrig-gui.jl. ***")
println("*************************")