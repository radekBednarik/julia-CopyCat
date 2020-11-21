module CopyCat

using Base
using Core
using ArgParse

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

        "--overwrite", "-o"
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

function copy_file(
    source_path::String,
    target_path::String,
    file::String,
    overwrite::Bool = false,
)::Any
    !isdir(target_path) && mkpath(target_path)
    if overwrite
        return cp(joinpath(source_path, file), joinpath(target_path, file), force = true)
    end
    return cp(joinpath(source_path, file), joinpath(target_path, file))
end

function move_file(
    source_path::String,
    target_path::String,
    file::String,
    overwrite::Bool = false,
)::Any
    !isdir(target_path) && mkpath(target_path)
    if overwrite
        return mv(joinpath(source_path, file), joinpath(target_path, file), force = true)
    end
    return mv(joinpath(source_path, file), joinpath(target_path, file))
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
)::Bool
    try
        for (root, dirs, files) in walkdir(source_path)
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

                # logging to console
                println("ROOT_SOURCE: ", root)
                println("EXPANSION_FOR_TARGET: ", get_subfolders(root, source_path))
                println("EXPANDED_TARGET: ", expanded_target_path)
                println("FILES: ", files)
                println("======================")

                # copy or move the files, depending on if flag '-m' is provided 
                !move ? copy_file.(root, expanded_target_path, files, overwrite) :
                move_file.(root, expanded_target_path, files, overwrite)
            end
        end
        # delete empty dirs recursively, if flag '-m' is provided, after all files were moved
        move && rm(source_path, recursive = true)
    catch err
        throw(err)
    end
    return true
end

function main()
    a::ParsedArgs = parse_cli_args()

    process_files(
        abspath(a["source"]),
        convert_path_to_abs(a["target"]),
        a["move"],
        a["overwrite"],
    )
end

main()

end # module
