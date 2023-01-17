# we can load packages that offer useful functions and objects
using Statistics

# outside of the base packages like `Statistics` we have to install them first
# with ] we can enter the package MethodError
# alternatively, we can the Pkg functions when we load the Pkg module

using Pkg

# first we want to create an environment to make sure that everybody works in the same world
# ]activate .
# or
Pkg.activate(".")

# add a package with 
# ]add JuMP in the REPL
# or
Pkg.add("JuMP")
Pkg.add("Clp")
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Plots")
Pkg.add("StatsPlots")
Pkg.add("Graphs")
Pkg.add("GraphPlot")

# once u created an environment in your current working directory you can set this env as default env in vscode

using Plots

x = -10:10
y = x-> x^2 + 1

plot(x, y, label="x² + 1")