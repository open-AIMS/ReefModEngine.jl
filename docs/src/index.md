# ReefModEngine.jl

A Julia interface to the ReefMod Engine (RME) C++ API.

Targets RME v1.0, and provides some convenience functions to interact with the RME.
All other functions are accessible via the `@RME` macro.

The RME library, accompanying dataset, and RME documentation has to be requested from RME developers.

## Preface

ReefMod is a coral ecology model developed at the University of Queensland (UQ) with more
than 20 years of development history. The original ReefMod model was written in MATLAB.
ReefMod has been ported to C++ to address issues and concerns around computational
efficiency. This port is referred to as the ReefMod Engine (RME).

This package, ReefModEngine.jl, provides a Julia interface to the RME, leveraging Julia's
first-class language interoperability support. The package does the following

- **Exposes the RME engine c++ API**
- **Provides a simpler API for setup result collection** (optional)

To avoid confusion, the following naming conventions are used when referring to each.

- The original MATLAB implementation is _always_ referred to as ReefMod.
- The C++ port, ReefMod Engine (RME), is referred to either as RME or its full name.
- This package, ReefModEngine.jl, is _always_ referred to by its full name.

::: info

This package does not implement ReefMod or ReefMod Engine. It is simply an interface to
allow its use in Julia.

A copy of the ReefMod Engine is available on request from its current developers at UQ.

:::
