module Mathy

export @$

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

function atmath_impl(init, op, body)
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

end # module
