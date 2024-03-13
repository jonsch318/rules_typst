"Public API re-exports"

def _typst_pdf_impl(ctx):
    """pdf"""
    info = ctx.toolchains["@rules_typst//typst:toolchain_type"].typstinfo

    srcs = depset(
        ctx.files.main + ctx.files.srcs + info.tool_files,
    )

    ctx.actions.run(
        outputs = [ctx.outputs.out],
        mnemonic = "Typst",
        executable = info.target_tool_path,
        use_default_shell_env = True,  # we should care about fonts here
        inputs = srcs,
        arguments = [
            "compile",
            ctx.files.main[0].path,
            ctx.outputs.out.path,
        ],
    )
    pass

typst_pdf = rule(
    implementation = _typst_pdf_impl,
    attrs = {
        "main": attr.label(allow_files = [".typ"]),
        "srcs": attr.label_list(allow_files = True),
    },
    outputs = {"out": "%{name}.pdf"},
    toolchains = ["@rules_typst//typst:toolchain_type"],
)
