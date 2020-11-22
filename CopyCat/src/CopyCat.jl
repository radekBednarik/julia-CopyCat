module CopyCat

using Base
using Core
using ArgParse
using ProgressBars

export main

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

        "--move", "-m"
        help = "Flag: if used, files and folders are MOVED not copied."
        action = :store_true
        nargs = 0

        "--force", "-f"
        help = "Flag: if used, existing files in the destination folders will be overwritten."
        action = :store_true
        nargs = 0
    end

    return parse_args(settings)
end

function convert_path_to_abs(path::String)::String
    abs_path::String = abspath(path)
    !isdir(abs_path) && mkpath(abs_path)
    return abs_path
end

function handle_file(
    source_path::String,
    target_path::String,
    file::String,
    overwrite::Bool = false,
    move::Bool = false,
)::String
    !isdir(target_path) && mkpath(target_path)
    fsp::String = joinpath(source_path, file)
    ftp::String = joinpath(target_path, file)

    if overwrite && move
        return mv(fsp, ftp, force = true)
    end
    if overwrite && !move
        return cp(fsp, ftp, force = true)
    end
    if !overwrite && move
        return mv(fsp, ftp)
    end
    if !overwrite && !move
        return cp(fsp, ftp)
    end
end

function get_subfolders(base_path::String, to_replace_path::String)::String
    !startswith(base_path, to_replace_path) &&
        throw(error("Not possible to get correct subdirectories sub-path string."))

    return replace(base_path, to_replace_path => String(""))
end

function process_files(
    source_path::String,
    target_path::String,
    move::Bool = false,
    overwrite::Bool = false,
)::Integer
    try
        for (root, dirs, files) in tqdm(walkdir(source_path))
            # here we will handle all moving, or copying files
            if length(files) > 0
                expanded_target_path::String = target_path

                if root !== source_path
                    # for some reason, no Filesystem join method works here :o
                    # they drop all the absolute part until the subfolders
                    # possible because of this: https://docs.julialang.org/en/v1/base/file/#Base.Filesystem.joinpath
                    # so I had to just string concat the path
                    expanded_target_path = target_path * get_subfolders(root, source_path)
                end

                handle_file.(root, expanded_target_path, files, overwrite, move)
            end
        end
        # delete empty dirs recursively, if flag '-m' is provided, after all files were moved
        move && rm(source_path, recursive = true)
    catch err
        println("Error in function 'process_files': ", err)
        return 1
    end
    return 0
end

function main()
    a::ParsedArgs = parse_cli_args()
    println("Input arguments parsed.")
    println("File operation started...")

    status::Integer = process_files(
        abspath(a["source"]),
        convert_path_to_abs(a["target"]),
        a["move"],
        a["force"],
    )
    status === 0 && println("File operation finished sucessfully.")
    status === 1 && println("File operation finished unsuccessfully.")
end

main()

end # module
