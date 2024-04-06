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
    warnonly=true
)

# Enable logging to console again
Logging.disable_logging(Logging.BelowMinLevel)

deploydocs(;
    repo="github.com/open-AIMS/ReefModEngine.jl.git",
    target="build", # this is where Vitepress stores its output
    branch = "gh-pages",
    devbranch="main",
    push_preview=true
)
