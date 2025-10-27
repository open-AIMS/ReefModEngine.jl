using Documenter, DocumenterVitepress
using DocumenterTools
using ReefModEngine
using Logging

Logging.disable_logging(Logging.Warn)

makedocs(;
    sitename="ReefModEngine.jl",
    modules=[ReefModEngine],
    clean=true,
    doctest=true,
    authors="Iwanaga et al.",
    checkdocs=:all,
    format=DocumenterVitepress.MarkdownVitepress(
        repo="github.com/open-AIMS/ReefModEngine.jl", # this must be the full URL!
        devbranch="main",
        devurl="dev";
    ),
    draft=false,
    source="src",
    build="build",
    pages=[
         "index.md",
         "Getting Started"=>"getting_started.md",
         "Options"=>"options.md",
         "Parallelisation"=>"parallelisation.md",
         "Results"=>"results_store.md",
    ]
)

# Enable logging to console again
Logging.disable_logging(Logging.BelowMinLevel)

# VitePress not compatible with Documenter anymore
DocumenterVitepress.deploydocs(;
    repo = "github.com/open-AIMS/ReefModEngine.jl",
    target = joinpath(@__DIR__, "build"),
    branch = "gh-pages",
    devbranch = "main",
    push_preview = true,
)
