using Documenter, Mathy

makedocs(;
    modules=[Mathy],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/Mathy.jl/blob/{commit}{path}#L{line}",
    sitename="Mathy.jl",
    authors="Takafumi Arakaki",
    assets=[],
)

deploydocs(;
    repo="github.com/tkf/Mathy.jl",
)
