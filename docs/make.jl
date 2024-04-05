using ReefModEngine

using Documenter
using DocThemeIndigo

using Logging

Logging.disable_logging(Logging.Warn)

# Generate the indigo theme css
indigo = DocThemeIndigo.install(ReefModEngine)

makedocs(;
    sitename="ReefModEngine.jl",
    modules=[ReefModEngine],
    clean=true,
    doctest=true,
    authors="Iwanaga et al.",
    checkdocs=:all,
    format=Documenter.HTML(
        assets=String[indigo],
    ),
    draft=false,
    source="src",
    build="build",
    warnonly=true,
    pages=[
        "index.md",
        "getting_started.md",
        "api.md"
    ]
)

# Enable logging to console again
Logging.disable_logging(Logging.BelowMinLevel)

deploydocs(;
    repo="github.com/open-AIMS/ReefModEngine.jl.git",
    target="build",
    branch = "gh-pages",
    devbranch="main",
    push_preview = false
)
