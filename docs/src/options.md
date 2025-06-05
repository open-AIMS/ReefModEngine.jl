# Setting RME options

RME allows access to a range of options that change the way runs are execited. All of these
are have defaults so are not required to changed for model runs but many are useful.
ReefModEngine.jl provides access via the `set_option` function. For example, parallelisation
can be set via the number of threads to use

```julia
set_option("thread_count", 2)
```

The name of all options and expected inputs is provided in the **RME system options**
section of the documentation provided with the binaries. The documentation lists the option
name, default value and the effect/meaning of the option.

Some other options are as follows.

```julia
set_option("restoration_dhw_tolerance_outplants", 3)
set_option("use_fixed_seed", 1)  # turn on use of a fixed seed value
set_option("fixed_seed", 123)  # set the fixed seed value
```
