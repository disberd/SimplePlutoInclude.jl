@testitem "With Pluto Session" begin
    include(joinpath(@__DIR__, "with_pluto_helpers.jl"))
    notebook_path = joinpath(@__DIR__, "test_notebook.jl")
    ss = ServerSession(; options)
    nb = SessionActions.open(ss, notebook_path; run_async=false)

    sn = (ss, nb);

    try
        # We test that no error occured
        for cell in nb.cells
            @test noerror(cell)
        end

        # We test that the normal and exported var are defined in the notebook
        @test eval_in_nb(sn, :(isdefined(@__MODULE__, :normal_var)))
        @test eval_in_nb(sn, :(isdefined(@__MODULE__, :exported_var)))
        # We test that the unexported variable is not defined
        @test eval_in_nb(sn, :(!isdefined(@__MODULE__, :unexported_var)))

        # We test that the module file correctly imported the inner module
        @test eval_in_nb(sn, :(isdefined(@__MODULE__, :TestModule)))
        @test eval_in_nb(sn, :(isdefined(@__MODULE__, :exported_from_module)))
        @test eval_in_nb(sn, :(!isdefined(@__MODULE__, :hidden_in_module)))
        @test eval_in_nb(sn, :(isdefined(TestModule, :hidden_in_module)))

        # We test the warning if no names are imported by the macro
        @test has_log_and_body_msg(nb.cells[end], "The macro did not import any name"; level="Error")

        # We check the warning when a file is updated a warning is sent. For some reason doing this only once does not make the test pass
        for _ in 1:2
            normal_file_path = eval_in_nb(sn, :symbol_path)
            touch(normal_file_path);
            update_run!(ss, nb, nb.cells[5]); # This is the cell which puts the path in a variable
        end
        @test has_log_and_body_msg(nb.cells[6], "The file was updated"; level="Warn");
        original_code = nb.cells[5].code

        # We test that changing file to a valid one gives a corresponding warning
        nb.cells[5].code = original_code;
        update_run!(ss, nb, nb.cells[5]); 
        update_run!(ss, nb, nb.cells[6]); 
        nb.cells[5].code = "symbol_path = \"imported_files/export_file.jl\" |> abspath"
        update_run!(ss, nb, nb.cells[5]); 
        @test has_log_and_body_msg(nb.cells[6], "The target points to a different file"; level="Warn");

        # We test that changing file to an invalid one gives a corresponding warning
        nb.cells[5].code = original_code;
        update_run!(ss, nb, nb.cells[5]); 
        update_run!(ss, nb, nb.cells[6]); 
        nb.cells[5].code = "symbol_path = \"imported_files/nonexistent.jl\" |> abspath"
        update_run!(ss, nb, nb.cells[5]); 
        @test has_log_and_body_msg(nb.cells[6], "does not seem to point to an existing file"; level="Error");
    finally
        SessionActions.shutdown(ss, nb)
    end
end
