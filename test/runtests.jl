## runtests.jl  

using DataFrames
using Margins
using Stella
using Test
using CSV
using GLM
using CategoricalArrays
using Statistics

# auto.csv
cars = CSV.read(download("https://raw.githubusercontent.com/sassoftware/sas-viya-programming/refs/heads/master/data/cars.csv"), DataFrame)

# linear regression
cars.Origin = categorical(cars.Origin);
descr(cars)
lm1 = fit(LinearModel, @formula(Invoice ~ Origin + EngineSize + Cylinders + Horsepower + Weight + Length), cars)

# find differences in Invoice price by origin
Margins.margins(lm1,:Origin)

