# A math-y notation for map-filter-reduce

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tkf.github.io/Mathy.jl/dev)
[![Build Status](https://travis-ci.com/tkf/Mathy.jl.svg?branch=master)](https://travis-ci.com/tkf/Mathy.jl)
[![Codecov](https://codecov.io/gh/tkf/Mathy.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/tkf/Mathy.jl)
[![Coveralls](https://coveralls.io/repos/github/tkf/Mathy.jl/badge.svg?branch=master)](https://coveralls.io/github/tkf/Mathy.jl?branch=master)

Mathy.jl is a math-like DSL for broadcasting expressions and
[Transducers.jl](https://github.com/tkf/Transducers.jl).

```julia
julia> @$ 0 + { 2 .* ({ 1:10 | isodd(_) } .^ 2 .+ 1) .- 1 | _ % 3 == 0 }
153
```

See more in [documentation](https://tkf.github.io/Mathy.jl/dev).
