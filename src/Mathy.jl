module Mathy

export @$, @eduction

using Transducers
using Transducers: air

const _atmath_syntax = raw"""
    @$      op dot_expr
    @$ init op dot_expr
    @$      op { dot_expr | filter_expr }
    @$ init op { dot_expr | filter_expr }
"""

"""
$_atmath_syntax

Reduce dot call expression `dot_expr` [^dot_syntax] with binary
operator `op` without allocating any intermediate arrays.  The result
of the `dot_expr` may be filtered by `filter_expr` using set-builder
like notation `{ dot_expr | filter_expr }`.  Expression `dot_expr`
itself may contain the set-builder like notation.  Optionally, the
initial value `init` for operator `op` can be specified.

For example, the expression `@\$ + { f.(a) | p(_) }` is equivalent to
the mathematical notation

```math
\\sum \\{ y \\in f.(a) \\,|\\, p(y) \\}
=
\\sum_{x \\in a \\,|\\, p(f(x))} f(x)
```

where predicate `p` is a function that takes the output of `f` and
returns a Boolean.  In general `filter_expr` is evaluated by
"substituting" each output element of `dot_expr` to `_` in
`filter_expr`.  Likewise, `@\$ * { f.(a) | p(_) }` is equivalent to
``\\prod \\{ y \\in f.(a) \\,|\\, p(y) \\}``.

!!! note

    Although set-builder like notation is used, the order of
    application of `op` is guaranteed to be left-to-right (`foldl`).
    Thus, unlike the mathematical notation, operator `op` does not
    have to be commutative or associative.

Under the hood, `@\$ init op { dot_expr | filter_expr }` is converted
to an expression that is conceptually equivalent to

```
mapfoldl(Filter(_ -> filter_expr), op, dot_expr, init=init, simd=true)
```

where `mapfoldl` and `Filter` are implemented in
[Transducers.jl](https://github.com/tkf/Transducers.jl).  However, the
output of `dot_expr` is never "materialized"; each output element is
computed on-the-fly.

[^dot_syntax]:
    Dot Syntax for Vectorizing Functions:
    <https://docs.julialang.org/en/latest/manual/functions/#man-vectorized-1>

# Examples
```jldoctest
julia> using Mathy

julia> @\$ + (1:10) .^ 2
385

julia> ans == sum((1:10) .^ 2)
true

julia> @\$ 0.0 + (1:10) .^ 2
385.0

julia> @\$ 1000 + (1:10) .^ 2
1385

julia> @\$ + { (1:10) .^ 2 | isodd(_) }
165

julia> ans == sum(x for x in (1:10) .^ 2 if isodd(x))
true

julia> @\$ + { (1:10) .^ 2 | (_ + 2) % 3 == 0 }
259

julia> ans == sum(x for x in (1:10) .^ 2 if (x + 2) % 3 == 0)
true

julia> ∑ = +
       ∏ = *;

julia> @\$ ∑ { (1:10) .^ 2 | (_ + 2) % 3 == 0 }
259

julia> @\$ ∏ { (1:10) .^ 2 | (_ + 2) % 3 == 0 }
501760000
```

Curly braces can be nested (although it is not optimized yet as of
Transducers 0.2.1):

```jldoctest; setup = :(using Mathy)
julia> @\$ + { 1:10 | isodd(_) } .^ 2
165

julia> @\$ 0 + { 2 .* ({ 1:10 | isodd(_) } .^ 2 .+ 1) .- 1 | _ % 3 == 0 }
153

julia> ans == sum(filter(x -> x % 3 == 0, 2 .* (filter(isodd, 1:10) .^ 2 .+ 1) .- 1))
true
```
"""
macro ($)(args...)
    esc(atmath_impl(args...))
end

function atmath_impl(expr::Expr)
    @assert expr.head == :call
    if length(expr.args) == 3
        op, init, body = expr.args
        return atmath_impl(init, op, body)
    elseif length(expr.args) == 2
        op, body = expr.args
        return atmath_impl(op, body)
    else
        error("Unsupported expression ", expr, "\n",
              "Supported syntax:\n",
              _atmath_syntax)
    end
end

atmath_impl(op, body) =
    atmath_impl(Transducers.MissingInit(), op, body)

function compile_body(body)
    if body.head === :braces
        @assert length(body.args) == 1
        parsed = parse_dot_expr(body.args[1])
        if parsed isa Some
            dot_expr, filter_expr = something(parsed)
            xf_expr = compile_filter(filter_expr)
        else
            dot_expr = body.args[1]
            xf_expr = Map(identity)
        end
    else
        dot_expr = body
        xf_expr = Map(identity)
    end
    return brace_to_eduction(dot_expr), xf_expr
end

function atmath_impl(init, op, body)
    dot_expr, xf_expr = compile_body(body)
    return quote
        $mapfoldl($xf_expr, $op, $air.($dot_expr); init=$init, simd=true)
    end
end

parse_dot_expr(x) = x
function parse_dot_expr(expr::Expr)
    if expr.head === :call
        if expr.args[1] == :|
            @assert length(expr.args) == 3
            _, l, r = expr.args
            return Some((l, r))
        elseif length(expr.args) === 3  # binary operator
            op, x, y = expr.args
            a = parse_dot_expr(x)
            if a isa Some
                l, r = something(a)
                return Some((l, Expr(:call, op, r, y)))
            end
            b = parse_dot_expr(y)
            if b isa Some
                l, r = something(b)
                return Some((Expr(:call, op, x, l), r))
            end
            return expr
        else
            return expr
        end
    elseif expr.head === :if
        a1 = parse_dot_expr(expr.args[1])
        if a1 isa Some
            l, r = something(a1)
            return Some((l, Expr(expr.head, r, expr.args[2:end]...)))
        else
            return expr
        end
    else
        return expr
    end
end

function compile_filter(filter_expr)
    var = gensym("x")
    subs(x) = x
    subs(x::Expr) = Expr(x.head, subs.(x.args)...)
    subs(x::Symbol) = x == :_ ? var : x
    return :($Filter($var -> $(subs(filter_expr))))
end

"""
    isdotcall(x)

# Examples
```jldoctest
julia> using Mathy: isdotcall

julia> isdotcall(:(f.(x)))
true

julia> isdotcall(:(f(x)))
false

julia> isdotcall(:(x .+ y))  # handled separately
false
```
"""
isdotcall(::Any) = false
isdotcall(ex::Expr) =
    ex.head === :. && length(ex.args) == 2 && ex.args[2] isa Expr &&
    ex.args[2].head === :tuple

"""
    isdotbracecall(x)

# Examples
```jldoctest
julia> using Mathy: isdotbracecall

julia> isdotbracecall(:(f.{x}))
true

julia> isdotbracecall(:(f.(x)))
false

julia> isdotbracecall(:(f{x}))
false
```
"""
isdotbracecall(::Any) = false
isdotbracecall(ex::Expr) =
    ex.head === :. && length(ex.args) == 2 && ex.args[2] isa Expr &&
    ex.args[2].head === :quote && length(ex.args[2].args) == 1 &&
    ex.args[2].args[1] isa Expr &&
    ex.args[2].args[1].head == :braces && length(ex.args[2].args[1].args) == 1

brace_to_eduction(x) = x
function brace_to_eduction(ex::Expr)
    if isdotcall(ex)
        args = brace_to_eduction.(ex.args[2].args)
        return Expr(:., ex.args[1], Expr(:tuple, args...))
    #=
    elseif isdotbracecall(ex)
        return Expr(:., ex.args[1],
                    Expr(:tuple, brace_to_eduction(ex.args[2].args[1])))
    =#
    elseif ex.head === :braces
        @assert length(ex.args) == 1
        return :($(@__MODULE__).@eduction $ex)
    elseif ex.head === :call
        return Expr(:call, brace_to_eduction.(ex.args)...)
    else
        return ex
    end
end

"""
    @eduction dot_expr
    @eduction { dot_expr | filter_expr }

Like [`@\$`](@ref) but without `op`.

# Examples
```jldoctest
julia> using Mathy

julia> collect(@eduction { (1:10) .^ 2 | isodd(_) })
5-element Array{Int64,1}:
  1
  9
 25
 49
 81
```
"""
macro eduction(ex)
    esc(ateduction_impl(ex))
end

function ateduction_impl(ex)
    dot_expr, xf_expr = compile_body(ex)
    return :($eduction($xf_expr, $air.($dot_expr)))
end

end # module
