include("packages.jl")
include("parsers/parse_game.jl")
# include("old_algorithm/triggers_based_game_tree.jl")
# include("old_algorithm/evaluate_logic.jl")
include("model_checking/build_and_evaluate.jl")


t1 = time();

example = 3

if example == 1
    game, termination_conditions, queries = parse_game("examples/bouncing_ball.json")
elseif example == 2
    game, termination_conditions, queries = parse_game("examples/3_players_1_ball.json")
elseif example == 3
    game, termination_conditions, queries = parse_game("examples/volleyball.json")
end

t2 = time();


# old_game_tree::OldNode = build_game_tree(game, termination_conditions, queries)

# t3 = time();

# old_results = evaluate(queries, game_tree, game.agents)

# t4 = time();

# nodes_count, passive_nodes = count_nodes(game_tree), count_passive_nodes(game_tree)
# tree_depth = depth_of_tree(game_tree)

#################################
t5 = time();

results, game_tree = evaluate_queries(game, termination_conditions, queries)

t6 = time();

nodes_count, passive_nodes = count_nodes(game_tree), count_passive_nodes(game_tree)
tree_depth = depth_of_tree(game_tree)

println("*************************")
println("*************************")
print_tree(game_tree)
println("*************************")
println("*************************")

println("*************************")
println("Time to parse = $(t2 - t1)")
# println("queries = ", queries)
println("*************************")
# println("Nodes = ", nodes_count, " Passive Nodes = ", passive_nodes, " Depth = ", tree_depth)
# println("results = ", results)
# println("Time to build = $(t3 - t2)")
# println("Time to evaluate = $(t4 - t3)")
# println("*************************")
println("***** On the fly ********")
println("Nodes = ", nodes_count, " Passive Nodes = ", passive_nodes, " Depth = ", tree_depth)
println("results = ", results)
println("Time to evaluate and build = $(t6 - t5)")
println("*************************")