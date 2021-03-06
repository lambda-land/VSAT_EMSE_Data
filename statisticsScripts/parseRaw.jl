################################################################################
# small script to parse the output of the gauge benchmarking library the script
# simply parses the "Name" or "name" column of the csv to new columns feel free
# to use awk or whatever you want to if this script doesn't work for you you can
# retrieve our exact version of julia used for the script using nix please see
# the nix directory

# Intended to be run in the "statisticsScripts" sub-directory.
# Intended use: please manually alter the "fileName" variable to whatever you need.
# If you are parsing any file with the suffix "raw" then you'll need to convert
# :Name -> :name because gauge changes the column name for some reason
################################################################################

using CSV        # read in a csv
using DataFrames # for rename!
using Query      # Tidyverse
using Plots      # for plotting

### get the data in a data frame
inputDirectory  = "../raw_data"
outputDirectory = "../munged_data"
fileName        = "fin_variate_timings.csv"
sep             = "/"
dataFile = inputDirectory * sep * fileName
df = CSV.File(dataFile) |> DataFrame

### helper functions
id = x -> x

function mungeName(nameString) arr = split(nameString, "/") end

function genCol(df, colName, index, f)
    df[!,colName] = map(name -> mungeName(name) |> x -> getindex(x,index) |> f, df[!,:Name])
    df
end

function addData(df) genCol(df, :DataSet, 1, x->x) end

function addAlg(df) genCol(df, :Algorithm, 2, x->x) end

function addConf(df) genCol(df, :Config, 3, id) end

function addChc(df) genCol(df, :Chc, 4, id) end

function addNumChc(df) genCol(df, :ChcCount, 5, x->parse(Int,x)) end

function addVariantSize(df) genCol(df, :Variant, 6, id) end

function addNumPlain(df) genCol(df, :PlainCount, 7, x->parse(Float64, x)) end

function addComp(df) genCol(df, :CompressionRatio, 9, x->parse(Float64,x)) end

function addVCoreSize(df) genCol(df, :VCoreSize, 11, x->parse(Int,x)) end

function addVCorePlainCnt(df) genCol(df, :VCorePlain, 13, x->parse(Int,x)) end

function addVCoreVarCnt(df) genCol(df, :VCoreVar, 15, x->parse(Int,x)) end

function addVariantCount(df) genCol(df, :Variants, 17, x->parse(Int,x)) end


# mutate the data by splitting on the name column
# function mungeDF!(df::DataFrame)
#     df |>
#         addNumPlain |>
#         addAlg |>
#         # addNumPlain |>
#         addConf |>
#         addNumChc |>
#         addChc |>
#         addVariantSize |>
#         addNumVariant |>
#         addComp |> addType
# end
function mungeDF!(df::DataFrame)
    df |> addData |> addAlg |> addConf |> addNumChc |> addNumPlain |> addComp |> addVCoreSize |> addVCorePlainCnt |> addVCoreVarCnt |> addVariantCount
end

## perform the mutation
data = mungeDF!(df)

## write the file
outPath = outputDirectory * sep * fileName
# mkpath(outPath)
data |> CSV.write(outPath)
