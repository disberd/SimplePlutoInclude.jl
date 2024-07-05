include(joinpath(@__DIR__, "helpers.jl"))

import Pluto: update_save_run!, update_run!, WorkspaceManager, ClientSession, ServerSession, Notebook, Cell, project_relative_path, SessionActions, load_notebook, Configuration

options = Configuration.from_flat_kwargs(; disable_writing_notebook_files=true, workspace_use_distributed_stdlib = true)

eval_in_nb(sn, expr) = WorkspaceManager.eval_fetch_in_workspace(sn, expr)

function noerror(cell; verbose=true)
    if cell.errored && verbose
        @show cell.output.body
    end
    !cell.errored
end

function has_log_msg(cell, needle; level = nothing)
    any(cell.logs) do dict
        msg = dict["msg"] |> first
        msg_matches = contains(msg, needle)
        isnothing(level) && return msg_matches
        level_matches = dict["level"] == level
        return level_matches && msg_matches
    end
end
function has_body_msg(cell, needle)
    body = cell.output.body
    if body isa Dict{Symbol, Any}
        body = body[:msg]
    end
    valid = contains(body, needle)
    valid || @info "Body mismatch" body
    return valid
end
function has_log_and_body_msg(cell, needle; level = nothing)
    return has_body_msg(cell, needle) && has_log_msg(cell, needle; level)
end