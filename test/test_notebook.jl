### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ 14f7c45f-d1e7-40dc-aacf-fccc286bd784
begin
	import Pkg
	Pkg.activate(@__DIR__)
	# We also add PlutoInclude to the load path
	push!(LOAD_PATH, dirname(@__DIR__))
	using Revise
end

# ╔═╡ b9902c25-6f7e-4760-b182-82029b4c87bd
begin
	using SimplePlutoInclude
	import PlutoUI
end

# ╔═╡ 00b24e24-fb30-4dc7-a717-14fbdab63a30
symbol_path = "imported_files/normal_file.jl" |> abspath

# ╔═╡ b57626e5-ec13-4d9a-a31c-0f9f7b547ab0
@plutoinclude symbol_path

# ╔═╡ d0677420-f4e4-4746-9dd8-a0e926635c06
normal_var

# ╔═╡ b8b6e3dd-f761-4ecf-bd0e-1f27971d51df
# This will only export the variable that is explicitly marked as `exported` in the file
@plutoinclude "imported_files/export_file.jl" all = false

# ╔═╡ a24520c0-ab0a-4010-8a60-5130ce4789a3
try
	unexported_var
catch
	"variable not defined"
end

# ╔═╡ 289fdcc9-f161-41a9-aaac-1bc91b47d1ec
exported_var

# ╔═╡ 93467a75-d63c-4d78-9703-701238f76a0c
# This will only export the variable that is explicitly marked as `exported` in the file
@plutoinclude "imported_files/imported_notebook.jl" all = false

# ╔═╡ Cell order:
# ╠═14f7c45f-d1e7-40dc-aacf-fccc286bd784
# ╠═b9902c25-6f7e-4760-b182-82029b4c87bd
# ╠═00b24e24-fb30-4dc7-a717-14fbdab63a30
# ╠═b57626e5-ec13-4d9a-a31c-0f9f7b547ab0
# ╠═d0677420-f4e4-4746-9dd8-a0e926635c06
# ╠═b8b6e3dd-f761-4ecf-bd0e-1f27971d51df
# ╠═a24520c0-ab0a-4010-8a60-5130ce4789a3
# ╠═289fdcc9-f161-41a9-aaac-1bc91b47d1ec
# ╠═93467a75-d63c-4d78-9703-701238f76a0c
