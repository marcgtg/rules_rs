"""Repository rule for downloading bpf-linker."""

_BPF_LINKER_VERSION = "0.10.3"

_BPF_LINKER_ARCHIVES = {
    "aarch64-apple-darwin": "983f86e20f5353c9645e6ee314dcd897133c613315b57b00c7e75ddb507ee6a3",
    "aarch64-unknown-linux-musl": "02f71967eddf61229fd0ae39736bfcaa00b27872df5af868b025f578371204d1",
    "x86_64-apple-darwin": "8dbea75f14d96e84a5fe7ce6120627e3c3511a49c406e76c14d187dc191ca528",
    "x86_64-unknown-linux-musl": "0fa4645d2dfbb5cafe6231b0aa9fad4f1430bd0871e3bd7319e82d827bf6262c",
}

_BPF_LINKER_ARCHIVE_TRIPLES = {
    "aarch64-apple-darwin": "aarch64-apple-darwin",
    "aarch64-unknown-linux-gnu": "aarch64-unknown-linux-musl",
    "x86_64-apple-darwin": "x86_64-apple-darwin",
    "x86_64-unknown-linux-gnu": "x86_64-unknown-linux-musl",
}

BPF_LINKER_SUPPORTED_EXEC_TRIPLES = sorted(_BPF_LINKER_ARCHIVE_TRIPLES.keys())

def _bpf_linker_archive_triple(exec_triple):
    return _BPF_LINKER_ARCHIVE_TRIPLES.get(exec_triple)

def bpf_linker_repository_name(exec_triple):
    archive_triple = _bpf_linker_archive_triple(exec_triple)
    if not archive_triple:
        return None
    return "rs_bpf_linker_" + archive_triple.replace("-", "_")

def _bpf_linker_repository_impl(rctx):
    archive_triple = rctx.attr.archive_triple
    rctx.download_and_extract(
        url = "https://github.com/aya-rs/bpf-linker/releases/download/v{version}/bpf-linker-{triple}.tar.gz".format(
            version = _BPF_LINKER_VERSION,
            triple = archive_triple,
        ),
        sha256 = _BPF_LINKER_ARCHIVES[archive_triple],
    )
    rctx.file(
        "BUILD.bazel",
        """\
exports_files(
    ["bpf-linker"],
    visibility = ["//visibility:public"],
)
""",
    )

    return rctx.repo_metadata(reproducible = True)

_bpf_linker_repository = repository_rule(
    implementation = _bpf_linker_repository_impl,
    attrs = {
        "archive_triple": attr.string(
            mandatory = True,
            values = _BPF_LINKER_ARCHIVES.keys(),
        ),
    },
)

def declare_bpf_linker_repository(exec_triple):
    """Declares the pinned bpf-linker repository for a supported execution triple."""
    archive_triple = _bpf_linker_archive_triple(exec_triple)
    if not archive_triple:
        fail("bpf-linker is not available for execution triple {}".format(exec_triple))

    _bpf_linker_repository(
        name = bpf_linker_repository_name(exec_triple),
        archive_triple = archive_triple,
    )
