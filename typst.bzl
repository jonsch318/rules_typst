_typst_pdf = rule(
  attrs = {
    "main": attr.label(allow_signle_file = [".typ"])
    "srcs": attr.label(allow_files = True)
  }
)
