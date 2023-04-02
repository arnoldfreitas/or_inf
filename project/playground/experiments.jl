using Pkg
Pkg.add("JuMP")
Pkg.add("DataFrames")
include(jump_container_to_dataframe)

using JuMP
using DataFrames
# using GLPK
using Clp

# Define a simple JuMP model
# model = Model(GLPK.Optimizer)
model = Model(Clp.Optimizer)
@variable(model, x[1:2, 1:2] >= 0)
@objective(model, Min, x[1, 1] + x[2, 2])
optimize!(model)

# Function to convert a JuMP container (DenseAxisArray) to a DataFrame
function jump_container_to_dataframe(container::JuMP.Containers.DenseAxisArray)
    dims = length(size(container))
    if dims != 2
        error("The function currently supports only 2-dimensional JuMP containers.")
    end

    rows, cols = size(container)
    df = DataFrame()

    for j in 1:cols
        df[!, Symbol("col_$(j)")] = [JuMP.value(container[i, j]) for i in 1:rows]
    end

    return df
end

# Convert the JuMP container x to a DataFrame
result_df = jump_container_to_dataframe(value.(x))




# Define a simple JuMP model
model = Model(Clp.Optimizer)
@variable(model, x[1:2, 1:2] >= 0)
@objective(model, Min, x[1, 1] + x[2, 2])
optimize!(model)

# Function to convert a JuMP container (DenseAxisArray) to a matrix
function jump_container_to_matrix(container::JuMP.Containers.DenseAxisArray)
    dims = length(size(container))
    if dims != 2
        error("The function currently supports only 2-dimensional JuMP containers.")
    end

    rows, cols = size(container)
    mat = Matrix{Float64}(undef, rows, cols)

    for i in 1:rows
        for j in 1:cols
            mat[i, j] = JuMP.value(container[i, j])
        end
    end

    return mat
end

# Convert the JuMP container x to a matrix
result_matrix = jump_container_to_matrix(x)




df_OutputRatio = DataFrame(OutputRatio, )


my_dict = Dict("row1" => Dict("col1" => 1, "col2" => 2),
               "row2" => Dict("col1" => 3, "col2" => 4),
               "row3" => Dict("col1" => 5, "col2" => 6))

# Convert the dictionary to an array of tuples
OutputRatioVals = [(key, value) for (key, value) in OutputRatio]

# Write the array to the CSV file
CSV.write("playground/OutputRatio.csv", OutputRatioVals, header=["key", "value"])

using Tables
