# Running model in parallel

RME provides an option to run repititions in parallel with no additional setup via the
`thread count` option. This can be set as follows

```julia
set_option("thread_count", 2)
```

::: tip

Do remember, however, that each process requires memory as well, so the total number of
threads should not exceed `ceil([available memory] / [memory required per thread])`.

The required memory depends on a number of factors including the represented grid size.
As a general indication, RME's memory use is ~4-5GB for a single run with a 10x10 grid.

:::
