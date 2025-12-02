include("../game_syntax/game.jl")

struct Configuration
    location::Location
    valuation::Valuation
    global_clock::Float64
end

function initial_configuration(game::Game)::Configuration
    Configuration(game.initial_location, 
                  game.initial_valuation,
                  0.0)
end

# redefine comparison
Base.:(==)(x::Configuration, y::Configuration) = (
    x.location.name == y.location.name &&
    x.valuation == y.valuation &&
    x.global_clock == y.global_clock
)
