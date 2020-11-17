module CopyCat

using Base: values, error
using Core: throw
using ArgParse
using Base.Filesystem: abspath, isdir

ParsedArgs = Dict{String, Any}

function parse_cli_args()::ParsedArgs
    settings = ArgParseSettings()
    @add_arg_table! settings begin
        "source"
        help = "Dirpath to source folder."
        action = :store_arg
        arg_type = String
        required = true
        nargs = 'A'

        "target"
        help = "Dirpath to target folder."
        action = :store_arg
        arg_type = String
        required = true
        nargs = 'A'
    end

    return parse_args(settings)
end

function convert_path_to_abs(path::String)::String
    abs_path::String = abspath(path)

    if isdir(abs_path)
        return abs_path
    end
    throw(error("$path converted to $abs_path does not point to existing directory."))
end

function main()
    a = parse_cli_args()
    abs_paths::Array{String} = convert_path_to_abs.(values(a))

    println(a)
    print(abs_paths)
end

main()

end # module
