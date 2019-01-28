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
    "text": "@$      op dot_expr\n@$ init op dot_expr\n@$      op { dot_expr | filter_expr }\n@$ init op { dot_expr | filter_expr }\n\nExamples\n\njulia> using Mathy\n\njulia> @$ + (1:10) .^ 2\n385\n\njulia> ans == sum((1:10) .^ 2)\ntrue\n\njulia> @$ 0.0 + (1:10) .^ 2\n385.0\n\njulia> @$ 1000 + (1:10) .^ 2\n1385\n\njulia> @$ + { (1:10) .^ 2 | isodd(_) }\n165\n\njulia> ans == sum(x for x in (1:10) .^ 2 if isodd(x))\ntrue\n\njulia> @$ + { (1:10) .^ 2 | (_ + 2) % 3 == 0 }\n259\n\njulia> ans == sum(x for x in (1:10) .^ 2 if (x + 2) % 3 == 0)\ntrue\n\njulia> ∑ = +\n       ∏ = *;\n\njulia> @$ ∑ { (1:10) .^ 2 | (_ + 2) % 3 == 0 }\n259\n\njulia> @$ ∏ { (1:10) .^ 2 | (_ + 2) % 3 == 0 }\n501760000\n\n\n\n\n\n"
},

{
    "location": "#Mathy.jl-1",
    "page": "Home",
    "title": "Mathy.jl",
    "category": "section",
    "text": "Modules = [Mathy]"
},

]}
