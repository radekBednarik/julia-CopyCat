module CopyCat

using ArgParse

ParsedArgs = Dict{String, Any}

function parse_cli_args()::ParsedArgs
    settings::ArgParseSettings = ArgParseSettings()
    @add_arg_table! settings begin
        "--source", "-s"
        help = "Dirpath to source folder."
        arg_type = String
        required = true

        "--target", "-t"
        help = "Dirpath to target folder."
        arg_type = String
        required = true
    end

    return ArgParse.parse_args(ARGS, settings)
end

function main()::Nothing
    args::ParsedArgs = parse_cli_args()
end

main()

end # module
