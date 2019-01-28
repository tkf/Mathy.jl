var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#Mathy.@$-Tuple",
    "page": "Home",
    "title": "Mathy.@$",
    "category": "macro",
    "text": "@$      op dot_expr\n@$ init op dot_expr\n@$      op { dot_expr | filter_expr }\n@$ init op { dot_expr | filter_expr }\n\nReduce dot call expression dot_expr [dot_syntax] with binary operator op without allocating any intermediate arrays.  The result of the dot_expr may be filtered by filter_expr using set-builder like notation { dot_expr | filter_expr }.  Expression dot_expr itself may contain the set-builder like notation.  Optionally, the initial value init for operator op can be specified.\n\nFor example, the expression @$ + { f.(a) | p(_) } is equivalent to the mathematical notation\n\nsum  y in f(a)  p(y) \n=\nsum_x in a  p(f(x)) f(x)\n\nwhere predicate p is a function that takes the output of f and returns a Boolean.  In general filter_expr is evaluated by \"substituting\" each output element of dot_expr to _ in filter_expr.  Likewise, @$ * { f.(a) | p(_) } is equivalent to prod  y in f(a)  p(y) .\n\nnote: Note\nAlthough set-builder like notation is used, the order of application of op is guaranteed to be left-to-right (foldl). Thus, unlike the mathematical notation, operator op does not have to be commutative or associative.\n\nUnder the hood, @$ init op { dot_expr | filter_expr } is converted to an expression that is conceptually equivalent to\n\nmapfoldl(Filter(_ -> filter_expr), op, dot_expr, init=init, simd=true)\n\nwhere mapfoldl and Filter are implemented in Transducers.jl.  However, the output of dot_expr is never \"materialized\"; each output element is computed on-the-fly.\n\n[dot_syntax]: Dot Syntax for Vectorizing Functions: https://docs.julialang.org/en/latest/manual/functions/#man-vectorized-1\n\nExamples\n\njulia> using Mathy\n\njulia> @$ + (1:10) .^ 2\n385\n\njulia> ans == sum((1:10) .^ 2)\ntrue\n\njulia> @$ 0.0 + (1:10) .^ 2\n385.0\n\njulia> @$ 1000 + (1:10) .^ 2\n1385\n\njulia> @$ + { (1:10) .^ 2 | isodd(_) }\n165\n\njulia> ans == sum(x for x in (1:10) .^ 2 if isodd(x))\ntrue\n\njulia> @$ + { (1:10) .^ 2 | (_ + 2) % 3 == 0 }\n259\n\njulia> ans == sum(x for x in (1:10) .^ 2 if (x + 2) % 3 == 0)\ntrue\n\njulia> ∑ = +\n       ∏ = *;\n\njulia> @$ ∑ { (1:10) .^ 2 | (_ + 2) % 3 == 0 }\n259\n\njulia> @$ ∏ { (1:10) .^ 2 | (_ + 2) % 3 == 0 }\n501760000\n\nCurly braces can be nested (although it is not optimized yet as of Transducers 0.2.1):\n\njulia> @$ + { 1:10 | isodd(_) } .^ 2\n165\n\njulia> @$ 0 + { 2 .* ({ 1:10 | isodd(_) } .^ 2 .+ 1) .- 1 | _ % 3 == 0 }\n153\n\njulia> ans == sum(filter(x -> x % 3 == 0, 2 .* (filter(isodd, 1:10) .^ 2 .+ 1) .- 1))\ntrue\n\n\n\n\n\n"
},

{
    "location": "#Mathy.@eduction-Tuple{Any}",
    "page": "Home",
    "title": "Mathy.@eduction",
    "category": "macro",
    "text": "@eduction dot_expr\n@eduction { dot_expr | filter_expr }\n\nLike @$ but without op.\n\nExamples\n\njulia> using Mathy\n\njulia> collect(@eduction { (1:10) .^ 2 | isodd(_) })\n5-element Array{Int64,1}:\n  1\n  9\n 25\n 49\n 81\n\n\n\n\n\n"
},

{
    "location": "#Mathy.jl:-A-math-y-notation-for-fused-map-filter-reduce-1",
    "page": "Home",
    "title": "Mathy.jl: A math-y notation for fused map-filter-reduce",
    "category": "section",
    "text": "Mathy.jl is a proof of concept embedded domain specific language for broadcasting expression (dot call syntax) and Transducers.jl.warning: Warning\nMathy.jl is a proof of concept.  Some operations may not be as efficient as it can be.Pages = [\"index.md\"]Modules = [Mathy]\nPrivate = false"
},

{
    "location": "internals/#",
    "page": "Internals",
    "title": "Internals",
    "category": "page",
    "text": ""
},

{
    "location": "internals/#Mathy.isdotbracecall-Tuple{Any}",
    "page": "Internals",
    "title": "Mathy.isdotbracecall",
    "category": "method",
    "text": "isdotbracecall(x)\n\nExamples\n\njulia> using Mathy: isdotbracecall\n\njulia> isdotbracecall(:(f.{x}))\ntrue\n\njulia> isdotbracecall(:(f.(x)))\nfalse\n\njulia> isdotbracecall(:(f{x}))\nfalse\n\n\n\n\n\n"
},

{
    "location": "internals/#Mathy.isdotcall-Tuple{Any}",
    "page": "Internals",
    "title": "Mathy.isdotcall",
    "category": "method",
    "text": "isdotcall(x)\n\nExamples\n\njulia> using Mathy: isdotcall\n\njulia> isdotcall(:(f.(x)))\ntrue\n\njulia> isdotcall(:(f(x)))\nfalse\n\njulia> isdotcall(:(x .+ y))  # handled separately\nfalse\n\n\n\n\n\n"
},

{
    "location": "internals/#Internals-1",
    "page": "Internals",
    "title": "Internals",
    "category": "section",
    "text": "Modules = [Mathy]\nPublic = false"
},

]}
