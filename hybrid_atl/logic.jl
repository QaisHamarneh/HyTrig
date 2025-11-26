include("../essential_definitions/constraint.jl")
include("../game_semantics/configuration.jl")
using Match
using DataStructures

abstract type Logic_formula end
abstract type Strategy_Formula <: Logic_formula end
abstract type State_Formula <: Logic_formula end


struct Strategy_to_State <: Strategy_Formula
    formula::State_Formula
end

# redefine comparison
Base.:(==)(x::Strategy_to_State, y::Strategy_to_State) = (
    x.formula == y.formula
)

struct Exist_Always <: Strategy_Formula
    agents::Set{Agent}
    formula::Strategy_Formula
end

# redefine comparison
Base.:(==)(x::Exist_Always, y::Exist_Always) = (
    x.agents == y.agents &&
    x.formula == y.formula
)

struct Exist_Eventually <: Strategy_Formula
    agents::Set{Agent}
    formula::Strategy_Formula
end

# redefine comparison
Base.:(==)(x::Exist_Eventually, y::Exist_Eventually) = (
    x.agents == y.agents &&
    x.formula == y.formula
)

struct All_Always <: Strategy_Formula
    agents::Set{Agent}
    formula::Strategy_Formula
end

# redefine comparison
Base.:(==)(x::All_Always, y::All_Always) = (
    x.agents == y.agents &&
    x.formula == y.formula
)

struct All_Eventually <: Strategy_Formula
    agents::Set{Agent}
    formula::Strategy_Formula
end

# redefine comparison
Base.:(==)(x::All_Eventually, y::All_Eventually) = (
    x.agents == y.agents &&
    x.formula == y.formula
)

struct Strategy_And <: Strategy_Formula
    left::Strategy_Formula
    right::Strategy_Formula
end

# redefine comparison
Base.:(==)(x::Strategy_And, y::Strategy_And) = (
    x.left == y.left &&
    x.right == y.right
)

struct Strategy_Or <: Strategy_Formula
    left::Strategy_Formula
    right::Strategy_Formula
end


struct Strategy_Not <: Strategy_Formula
    formula::Strategy_Formula
end

# redefine comparison
Base.:(==)(x::Strategy_Not, y::Strategy_Not) = (
    x.formula == y.formula
)

struct Strategy_Imply <: Strategy_Formula
    left::Strategy_Formula
    right::Strategy_Formula
end

# redefine comparison
Base.:(==)(x::Strategy_Imply, y::Strategy_Imply) = (
    x.left == y.left &&
    x.right == y.right
)

struct State_Location <: State_Formula
    proposition::Symbol
end

struct State_Constraint <: State_Formula
    constraint::Constraint
end

struct State_And <: State_Formula
    left::State_Formula
    right::State_Formula
end

struct State_Or <: State_Formula
    left::State_Formula
    right::State_Formula
end

struct State_Not <: State_Formula
    formula::State_Formula
end

struct State_Imply <: State_Formula
    left::State_Formula
    right::State_Formula
end

struct Strategy_Deadlock <: Strategy_Formula
end

function get_all_constraints(formula::State_Formula)::Set{Constraint}
    @match formula begin
        State_Location(_) => Set{Constraint}()
        State_Constraint(constraint) => Set([constraint])
        State_And(left, right) => get_all_constraints(left) ∪ get_all_constraints(right)
        State_Or(left, right) => get_all_constraints(left) ∪ get_all_constraints(right)
        State_Not(subformula) => get_all_constraints(subformula)
        State_Imply(left, right) => get_all_constraints(left) ∪ get_all_constraints(right)
    end
end

function get_all_constraints(formula::Strategy_Formula)::Set{Constraint}
    @match formula begin
        Strategy_to_State(f) => get_all_constraints(f)
        Exist_Always(_, f) => get_all_constraints(f)
        Exist_Eventually(_, f) => get_all_constraints(f)
        All_Always(_, f) => get_all_constraints(f)
        All_Eventually(_, f) => get_all_constraints(f)
        Strategy_And(left, right) => get_all_constraints(left) ∪ get_all_constraints(right)
        Strategy_Or(left, right) => get_all_constraints(left) ∪ get_all_constraints(right)
        Strategy_Not(f) => get_all_constraints(f)
        Strategy_Imply(left, right) => get_all_constraints(left) ∪ get_all_constraints(right)
        Strategy_Deadlock() => Set{Constraint}()
    end
end

function get_all_constraints(formulae::Vector{Logic_formula})::Set{Constraint}
    return union_safe([get_all_constraints(formula) for formula in formulae])
end


function evaluate_state(formula::State_Formula, config::Configuration)::Bool
    @match formula begin
        State_Location(loc) => loc == config.location
        State_Constraint(constraint) => evaluate(constraint, config.valuation)
        State_And(left, right) => evaluate_state(left, config) && evaluate_state(right, config)
        State_Or(left, right) => evaluate_state(left, config) || evaluate_state(right, config)
        State_Not(f) => ! evaluate_state(f, config)
        State_Imply(left, right) => ! evaluate_state(left, config) || evaluate_state(right, config)
    end
end