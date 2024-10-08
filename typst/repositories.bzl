"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//typst/private:toolchains_repo.bzl", "PLATFORMS", "toolchains_repo")
load("//typst/private:versions.bzl", "TOOL_VERSIONS")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
# This is all fixed by bzlmod, so we just tolerate it for now.
def rules_typst_dependencies():
    # The minimal version of bazel_skylib we require
    http_archive(
        name = "bazel_skylib",
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
    )

########
# Remaining content of the file is only used to support toolchains.
########
_DOC = "Fetch external tools needed for typst toolchain"
_ATTRS = {
    "typst_version": attr.string(mandatory = True, values = TOOL_VERSIONS.keys()),
    "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
    "_build_template": attr.label(
            default = Label("@rules_typst//typst/private:BUILD.tpl"),
        ),
}

def _typst_repo_impl(repository_ctx):
    extension = "tar.xz"
    if repository_ctx.attr.platform == "x86_64-pc-windows-msvc":
        extension = "zip"

    url = "https://github.com/typst/typst/releases/download/v{0}/typst-{1}.{2}".format(
        repository_ctx.attr.typst_version,
        repository_ctx.attr.platform,
        extension,
    )

    status = repository_ctx.download_and_extract(
        url = url,
        integrity = TOOL_VERSIONS[repository_ctx.attr.typst_version][repository_ctx.attr.platform],
    )
    repository_ctx.report_progress("Creating Typst toolchain files")

    if not status.success:
        fail("Could not download typst compiler")

    repository_ctx.template("BUILD.bazel", repository_ctx.attr._build_template, substitutions = {
                            "{platform}": repository_ctx.attr.platform
  })

    # test = repository_ctx.read("typst-{}/typst".format(repository_ctx.attr.platform))
    # print("TEST:", test)
    # Base BUILD file for this repository
    # repository_ctx.file("BUILD.bazel", build_content)

typst_repositories = repository_rule(
    _typst_repo_impl,
    doc = _DOC,
    attrs = _ATTRS,
)

# Wrapper macro around everything above, this is the primary API
def typst_register_toolchains(name, register = True, **kwargs):
    """Convenience macro for users which does typical setup.

    - create a repository for each built-in platform like "typst_linux_amd64" -
      this repository is lazily fetched when node is needed for that platform.
    - TODO: create a convenience repository for the host platform like "typst_host"
    - create a repository exposing toolchains for each platform like "typst_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.
    Args:
        name: base name for all created repos, like "typst0_11_0_rc1"
        register: whether to call through to native.register_toolchains.
            Should be True for WORKSPACE users, but false when used under bzlmod extension
        **kwargs: passed to each node_repositories call
    """
    for platform in PLATFORMS.keys():
        typst_repositories(
            name = name + "_" + platform,
            platform = platform,
            **kwargs
        )
        if register:
            native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )
