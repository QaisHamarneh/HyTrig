include("packages.jl")
include("parsers/parse_game.jl")
include("model_checking/build_and_evaluate.jl")

example = 5
all_info = true

t1 = time();
if example == 1
    game, termination_conditions, queries = parse_game("examples/bouncing_ball.json")
elseif example == 2
    game, termination_conditions, queries = parse_game("examples/3_players_1_ball.json")
elseif example == 3
    game, termination_conditions, queries = parse_game("examples/4_player_square.json")
elseif example == 4
    game, termination_conditions, queries = parse_game("examples/volleyball.json")
elseif example == 5
    game, termination_conditions, queries = parse_game("examples/volleyball_3p.json")
end


t2 = time();

if all_info
    println("Locations = ", length(game.locations))
    println("Edges = ", length(game.edges))
    println("Agents = ", length(game.agents))
    println("Actions = ", length(game.actions))
    println("Triggers per agent = ", Dict(agent => length(game.triggers[agent]) for agent in game.agents))
    println("Initial Configurations = ", initial_configuration(game).valuation)
    println("*************************")
    println("Time to parse = $(round5(t2 - t1))")
    println("*************************")
end

t3 = time();
results, game_tree = evaluate_queries(game, termination_conditions, queries)

t4 = time();
nodes_count, passive_nodes = count_nodes(game_tree), count_passive_nodes(game_tree)
tree_depth = depth_of_tree(game_tree)
tree_max_time = max_time(game_tree)

tree_text = print_tree(game_tree)
io = open("logs/tree.md", "w");                                                                                                                                                                                                                                                                                                                               
write(io, tree_text);                                                                                                                                                                                                                                                                                                                                                           
close(io); 


println("*************************")
println("***** On the fly ********")
println("Nodes = ", nodes_count, " Passive Nodes = ", passive_nodes, " Depth = ", tree_depth, " Max Time = ", tree_max_time)
println("results = ", results)
println("***************************")
println("Time to evaluate and build = $(round5(t4 - t3))")
