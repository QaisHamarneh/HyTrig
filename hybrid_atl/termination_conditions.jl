include("logic.jl")

struct Termination_Conditions
    time_limit::Float64
    max_steps::Int64
    state_formula::State_Formula
end