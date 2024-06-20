using Test
import Pluto: update_save_run!, update_run!, WorkspaceManager, ClientSession, ServerSession, Notebook, Cell, project_relative_path, SessionActions, load_notebook, Configuration

options = Configuration.from_flat_kwargs(; disable_writing_notebook_files=true, workspace_use_distributed_stdlib = true)

eval_in_nb(sn, expr) = WorkspaceManager.eval_fetch_in_workspace(sn, expr)

function noerror(cell; verbose=true)
    if cell.errored && verbose
        @show cell.output.body
    end
    !cell.errored
end

@testset "Pluto Session" begin
    notebook_path = joinpath(@__DIR__, "test_notebook.jl")
    ss = ServerSession(; options)
    nb = SessionActions.open(ss, notebook_path; run_async=false);

    sn = (ss, nb);

    # We test that no error occured
    for cell in nb.cells
        @test noerror(cell)
    end

    # We test that the normal and exported var are defined in the notebook
    @test eval_in_nb(sn, :(isdefined(@__MODULE__, :normal_var)))
    @test eval_in_nb(sn, :(isdefined(@__MODULE__, :exported_var)))
    # We test that the unexported variable is not defined
    @test eval_in_nb(sn, :(!isdefined(@__MODULE__, :unexported_var)))

    # We try to macroexpand including the pluto notebook to verify that the @bind macro dummy definition is not exported
    ex = eval_in_nb(sn, :(@macroexpand @plutoinclude "imported_files/imported_notebook.jl"))
    exported_names = map(ex.args[1].args[2:end]) do dotex
        dotex.args[1]
    end
    @test exported_names == [:bind_var, :nonbind_var]

    # We test the warning if no names are imported by the macro
    last_logs = nb.cells[end].logs[1]["msg"] |> first
    last_output = nb.cells[end].output.body
    @test contains(last_logs, "No names were extracted from the generated module.")
    @test contains(last_output, "No names were extracted from the generated module.")

    SessionActions.shutdown(ss, nb)
end
