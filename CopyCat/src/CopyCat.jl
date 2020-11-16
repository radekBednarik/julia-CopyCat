module CopyCat

using ArgParse
using Base.Filesystem: abspath

ParsedArgs = Dict{String, Any}

function parse_cli_args()::ParsedArgs
    settings = ArgParseSettings()
    @add_arg_table! settings begin
        "-s"
        help = "Dirpath to source folder."
        required = true

        "-t"
        help = "Dirpath to target folder."
        required = true
    end

    return parse_args(settings)
end

function convert_path_to_abs(path::String)::Union{String, Nothing}
    try
        return abspath(path)
    catch e
        println("Path $path could not be converted to absolute path.\n$(String(e))")
        return nothing
    end
end

function main()::Nothing
    a = parse_cli_args()
end

main()

end # module
