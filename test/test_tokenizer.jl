using Test

include("../parsers/syntax_parsers/tokenizer.jl")

@test tokenize("", Bindings([], [], [])) == Vector{Token}(undef, 0)

function _test_a_plus_b(input::String)
    test_tokens::Vector{Token} = tokenize(input, Bindings([], [], ["a", "b"]))

    @test length(test_tokens) == 3
    @test test_tokens[1] isa VariableToken
    @test test_tokens[1].type == "a"
    @test test_tokens[2] isa ExpressionBinaryOperatorToken
    @test test_tokens[2].type == "+"
    @test test_tokens[3] isa VariableToken
    @test test_tokens[3].type == "b"
end

# test different spacing
_test_a_plus_b("a+b")
_test_a_plus_b("a + b")
_test_a_plus_b("    a+ b")
_test_a_plus_b("a +b    ")
_test_a_plus_b("a\n+\nb")

# test keyword tokenization
test_tokens::Vector{Token} = tokenize("true && deadlock", Bindings([], [], []))
@test length(test_tokens) == 3
@test test_tokens[1] isa BooleanToken
@test test_tokens[1].type == "true"
@test test_tokens[2] isa ConstraintBinaryOperatorToken
@test test_tokens[2].type == "&&"
@test test_tokens[3] isa StrategyConstantToken
@test test_tokens[3].type == "deadlock"

# test comparison tokenization
test_tokens = tokenize("10 <= c < 20", Bindings([], [], ["c"]))
@test length(test_tokens) == 5
@test test_tokens[1] isa NumericToken
@test test_tokens[1].type == "10"
@test test_tokens[2] isa ConstraintCompareToken
@test test_tokens[2].type == "<="
@test test_tokens[3] isa VariableToken
@test test_tokens[3].type == "c"
@test test_tokens[4] isa ConstraintCompareToken
@test test_tokens[4].type == "<"
@test test_tokens[5] isa NumericToken
@test test_tokens[5].type == "20"

# test separator tokenization
test_tokens = tokenize("<<a,b>>", Bindings(["a", "b"], [], []))
@test length(test_tokens) == 5
@test test_tokens[1] isa SeparatorToken
@test test_tokens[1].type == "<<"
@test test_tokens[2] isa AgentToken
@test test_tokens[2].type == "a"
@test test_tokens[3] isa SeparatorToken
@test test_tokens[3].type == ","
@test test_tokens[4] isa AgentToken
@test test_tokens[4].type == "b"
@test test_tokens[5] isa SeparatorToken
@test test_tokens[5].type == ">>"

test_tokens = tokenize("))", Bindings([], [], []))
@test length(test_tokens) == 2
@test test_tokens[1] isa SeparatorToken
@test test_tokens[1].type == ")"
@test test_tokens[2] isa SeparatorToken
@test test_tokens[2].type == ")"

# test function tokenization
test_tokens = tokenize("min(3,5)", Bindings([], [], []))
@test length(test_tokens) == 6
@test test_tokens == [
    ExpressionBinaryFunctionToken("min"),
    SeparatorToken("("),
    NumericToken("3"),
    SeparatorToken(","),
    NumericToken("5"),
    SeparatorToken(")")
]

# test numeric tokenization
@test tokenize("10", Bindings([], [], [])) == [NumericToken("10")]
@test tokenize("10.0", Bindings([], [], [])) == [NumericToken("10.0")]
@test tokenize("10.01", Bindings([], [], [])) == [NumericToken("10.01")]

# test error handling
@test_throws TokenizeError("'10.' is an invalid number.") tokenize("10.", Bindings([], [], []))
@test_throws TokenizeError("'+-' is an invalid sequence of symbols.") tokenize("a+-b", Bindings([], [], ["a", "b"]))
@test_throws TokenizeError("''' is an invalid starting symbol.") tokenize("a'b", Bindings([], [], ["a", "b"]))
@test_throws TokenizeError("'_' is an invalid starting symbol.") tokenize("a && _b", Bindings([], [], ["a", "b"]))
@test_throws TokenizeError("'a' is not defined in bindings.") tokenize("a", Bindings([], [], []))
