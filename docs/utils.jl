using Documenter, Mathy

mathy_makedocs(; kwargs...) = makedocs(;
    modules=[Mathy],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        hide("internals.md"),
    ],
    repo="https://github.com/tkf/Mathy.jl/blob/{commit}{path}#L{line}",
    sitename="Mathy.jl",
    authors="Takafumi Arakaki",
    assets=[],
    root=@__DIR__,
    strict=true,
    kwargs...
)
