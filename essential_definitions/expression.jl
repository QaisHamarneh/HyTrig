using Match
using DataStructures
include("iliases.jl")

abstract type ExprLike end

struct Const <: ExprLike
    value::Float64
end

struct Var <: ExprLike
    name::Variable
end

struct Neg <: ExprLike
    expr::ExprLike
end

struct Add <: ExprLike
    left::ExprLike
    right::ExprLike
end

struct Mul <: ExprLike
    left::ExprLike
    right::ExprLike
end

struct Sub <: ExprLike
    left::ExprLike
    right::ExprLike
end

struct Div <: ExprLike
    left::ExprLike
    right::ExprLike
end

struct Expon <: ExprLike
    base::ExprLike
    power::ExprLike
end

struct Modulo <: ExprLike
    left::ExprLike
    right::ExprLike
end

struct Min <: ExprLike
    left::ExprLike
    right::ExprLike
end

struct Max <: ExprLike
    left::ExprLike
    right::ExprLike
end

struct Sin <: ExprLike
    base::ExprLike
end

struct CoSin <: ExprLike
    base::ExprLike
end

struct Tan <: ExprLike
    base::ExprLike
end

struct CoTan <: ExprLike
    base::ExprLike
end

struct Min <: ExprLike
    left::ExprLike
    right::ExprLike
end

struct Max <: ExprLike
    left::ExprLike
    right::ExprLike
end


if !isdefined(Main, :ReAssignment)
    const ReAssignment = Dict{Variable, <:ExprLike}
end

function evaluate(expr::ExprLike, valuation::Valuation)::Float64
    @match expr begin
        Const(value) => round5(value)
        Var(name) => round5(valuation[name])
        Neg(expr1) => round5(-1 * evaluate(expr1, valuation))
        Add(left, right) => round5(evaluate(left, valuation) + evaluate(right, valuation))
        Mul(left, right) => round5(evaluate(left, valuation) * evaluate(right, valuation))
        Sub(left, right) => round5(evaluate(left, valuation) - evaluate(right, valuation))
        Div(left, right) => round5(evaluate(left, valuation) / evaluate(right, valuation))
        Expon(base, power) => round5(evaluate(base, valuation) ^ evaluate(power, valuation))
        Modulo(left, right) => round5(evaluate(left, valuation) % evaluate(right, valuation))
        Min(left, right) => round5(min(evaluate(left, valuation)), evaluate(right, valuation))
        Max(left, right) => round5(max(evaluate(left, valuation)), evaluate(right, valuation))
        Sin(base) => round5(sin(evaluate(base, valuation)))
        CoSin(base) => round5(cos(evaluate(base, valuation)))
        Tan(base) => round5(tan(evaluate(base, valuation)))
        CoTan(base) => round5(cot(evaluate(base, valuation)))
        Min(left, right) => round5(min(evaluate(left, valuation), evaluate(right, valuation)))
        Max(left, right) => round5(max(evaluate(left, valuation), evaluate(right, valuation)))
    end
end

function str(expr::ExprLike)::String
    @match expr begin
        Const(value) => "$value"
        Var(name) => String(name)
        Neg(expr1) => "- $(str(expr1))"
        Add(left, right) => "($(str(left)) + $(str(right)))"
        Mul(left, right) => "($(str(left)) * $(str(right)))"
        Sub(left, right) => "($(str(left)) - $(str(right)))"
        Div(left, right) => "($(str(left)) / $(str(right)))"
        Expon(base, power) => "$(str(base))^$(str(power))"
        Modulo(left, right) => "($(str(left)) % $(str(right)))"
        Min(left, right) => "min($(str(left)), $(str(right)))"
        Max(left, right) => "max($(str(left)), $(str(right)))"
        Sin(base) => "sin($(str(base)))"
        CoSin(base) => "cos($(str(base)))"
        Tan(base) => "tan($(str(base)))"
        CoTan(base) => "cot($(str(base)))"
        Min(left, right) => "min($(str(left)), $(str(right)))"
        Max(left, right) => "max($(str(left)), $(str(right)))"
    end
end

function is_constant(expr::ExprLike)::Bool
    @match expr begin
        Const(_) => true
        Var(_) => false
        Neg(expr1) => is_constant(expr1)
        Add(left, right) => is_constant(left) && is_constant(right)
        Mul(left, right) => is_constant(left) && is_constant(right)
        Sub(left, right) => is_constant(left) && is_constant(right)
        Div(left, right) => is_constant(left) && is_constant(right)
        Expon(base, power) => is_constant(base) && is_constant(power)
        Modulo(left, right) => is_constant(left) && is_constant(right)
        Min(left, right) => is_constant(left) && is_constant(right)
        Max(left, right) => is_constant(left) && is_constant(right)
        Sin(base) => is_constant(base)
        CoSin(base) => is_constant(base)
        Tan(base) => is_constant(base)
        CoTan(base) => is_constant(base)
        Min(left, right) => is_constant(left) && is_constant(right)
        Max(left, right) => is_constant(left) && is_constant(right)
    end
end

function is_linear(expr::ExprLike)::Bool
    @match expr begin
        Const(_) => true
        Var(_) => true
        Neg(expr1) => is_linear(expr1)
        Add(left, right) => is_linear(left) && is_linear(right)
        Sub(left, right) => is_linear(left) && is_linear(right)
        Mul(left, right) => (is_constant(left) || is_constant(right)) && (is_linear(left) || is_linear(right))
        Div(left, right) => is_linear(left) && is_constant(right) && (is_linear(left) || is_linear(right))
        Expon(base, power) => is_linear(base) && is_constant(power)
        Modulo(left, right) => is_linear(left) && is_constant(right) && (is_linear(left) || is_linear(right))
        # TODO Min, Max
        Sin(base) => is_constant(base)
        CoSin(base) => is_constant(base)
        Tan(base) => is_constant(base)
        CoTan(base) => is_constant(base)
        Min(left, right) => is_linear(left) && is_linear(right)
        Max(left, right) => is_linear(left) && is_linear(right)
    end
end
