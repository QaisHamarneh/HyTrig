using Match
using DataStructures

include("expression.jl")

abstract type Constraint end

struct Truth <: Constraint
    value::Bool
end

struct Less <: Constraint
    left::ExprLike
    right::ExprLike
end

struct LeQ <: Constraint
    left::ExprLike
    right::ExprLike
end

struct Greater <: Constraint
    left::ExprLike
    right::ExprLike
end

struct GeQ <: Constraint
    left::ExprLike
    right::ExprLike
end

struct Equal <: Constraint
    left::ExprLike
    right::ExprLike
end

struct NotEqual <: Constraint
    left::ExprLike
    right::ExprLike
end

############################
############################

struct And <: Constraint
    left::Constraint
    right::Constraint
end

struct Or <: Constraint
    left::Constraint
    right::Constraint
end

struct Not <: Constraint
    constraint::Constraint
end

struct Imply <: Constraint
    left::Constraint
    right::Constraint
end

############################
############################

function str(constraint::Constraint)::String
    @match constraint begin
        Truth(value) => string(value)
        Less(left, right) => "$(str(left)) < $(str(right))"
        LeQ(left, right) => "$(str(left)) <= $(str(right))"
        Greater(left, right) => "$(str(left)) > $(str(right))"
        GeQ(left, right) => "$(str(left)) >= $(str(right))"
        Equal(left, right) => "$(str(left)) == $(str(right))"
        NotEqual(left, right) => "$(str(left)) != $(str(right))"
        And(left, right) => "($(str(left))) ∧ ($(str(right)))"
        Or(left, right) => "($(str(left))) ∨ ($(str(right)))"
        Not(c) => "¬($(str(c)))"
        Imply(left, right) => "($(str(left))) → ($(str(right)))"
    end
end

function is_closed(constraint::Constraint)::Bool
    @match constraint begin
        Truth(_) => true
        Less(left, right) => false
        LeQ(left, right) => true
        Greater(left, right) => false
        GeQ(left, right) => true
        Equal(left, right) => true
        NotEqual(left, right) => false
        And(left, right) => is_closed(left) && is_closed(right)
        Or(left, right) => is_closed(left) && is_closed(right)
        Not(c) => ! is_closed(c)
        Imply(left, right) => is_closed(left) && is_closed(right)
    end
end

function get_atomic_constraints(constraint::Constraint)::Vector{Constraint}
    @match constraint begin
        Truth(_) => [constraint]
        Less(left, right) => [constraint]
        LeQ(left, right) => [constraint]
        Greater(left, right) => [constraint]
        GeQ(left, right) => [constraint]
        Equal(left, right) => [constraint]
        NotEqual(left, right) => [constraint]
        And(left, right) => get_atomic_constraints(left) ∪ get_atomic_constraints(right)
        Or(left, right) => get_atomic_constraints(left) ∪ get_atomic_constraints(right)
        Not(c) => get_atomic_constraints(c)
        Imply(left, right) => get_atomic_constraints(left) ∪ get_atomic_constraints(right)
    end
end

function negation_normal_form(constraint::Constraint)::Constraint
    @match constraint begin
        Not(Not(c)) => negation_normal_form(c)
        Not(And(left, right)) => Or(negation_normal_form(Not(left)), negation_normal_form(Not(right)))
        Not(Or(left, right)) => And(negation_normal_form(Not(left)), negation_normal_form(Not(right)))
        Not(Imply(left, right)) => And(negation_normal_form(left), negation_normal_form(Not(right)))
        Not(Truth(value)) => Truth(!value)
        And(left, right) => And(negation_normal_form(left), negation_normal_form(right))
        Or(left, right) => Or(negation_normal_form(left), negation_normal_form(right))
        Imply(left, right) => Or(negation_normal_form(Not(left)), negation_normal_form(right))
        Not(c) => Not(negation_normal_form(c))
        _ => constraint
    end
end

function get_zero(constraint::Constraint)::Vector{ExprLike}
    @match constraint begin
        Truth(true) => ExprLike[Const(0)]
        Truth(false) => ExprLike[Const(1)]
        LeQ(left, right) => ExprLike[Sub(right, left), Sub(left, Add(right, Const(1e-5)))]
        Less(left, right) => ExprLike[Sub(right, Add(left, Const(1e-5))), Sub(left, right)]
        GeQ(left, right) => ExprLike[Sub(left, right), Sub(right, Add(left, Const(1e-5)))]
        Greater(left, right) => ExprLike[Sub(left, Add(right, Const(1e-5))), Sub(right, left)]
        Equal(left, right) => ExprLike[Sub(left, right)] ∪ get_zero(Greater(left, right)) ∪ get_zero(Less(left, right))
        NotEqual(left, right) => ExprLike[Sub(left, right)] ∪ get_zero(Greater(left, right)) ∪ get_zero(Less(left, right))
        And(left, right) => get_zero(left) ∪ get_zero(right)
        Or(left, right) => get_zero(left) ∪ get_zero(right)
        Not(c) => get_zero(c)
        Imply(left, right) => get_zero(left) ∪ get_zero(right)
    end
end

function evaluate(constraint::Constraint, valuation::Valuation)::Bool
    @match constraint begin
        Truth(value) => value
        Less(left, right) => evaluate(left, valuation) < evaluate(right, valuation)
        LeQ(left, right) => evaluate(left, valuation) <= evaluate(right, valuation)
        Greater(left, right) => evaluate(left, valuation) > evaluate(right, valuation)
        GeQ(left, right) => evaluate(left, valuation) >= evaluate(right, valuation)
        Equal(left, right) => evaluate(left, valuation) == evaluate(right, valuation)
        NotEqual(left, right) => evaluate(left, valuation) != evaluate(right, valuation)
        And(left, right) => evaluate(left, valuation) && evaluate(right, valuation)
        Or(left, right) => evaluate(left, valuation) || evaluate(right, valuation)
        Not(c) => !evaluate(c, valuation)
        Imply(left, right) => !evaluate(left, valuation) || evaluate(right, valuation)
    end
end

function get_satisfied_constraints(constraints, valuation::Valuation)
    filter(constraint -> evaluate(constraint, valuation), constraints)
end

function get_unsatisfied_constraints(constraints, valuation::Valuation)
    filter(constraint -> ! evaluate(constraint, valuation), constraints)
end