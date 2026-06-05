"""Tests for bpf-linker repository selection."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(":bpf_linker_repository.bzl", "BPF_LINKER_SUPPORTED_EXEC_TRIPLES", "bpf_linker_repository_name")

def _bpf_linker_repository_name_test_impl(ctx):
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        "rs_bpf_linker_aarch64_unknown_linux_musl",
        bpf_linker_repository_name("aarch64-unknown-linux-gnu"),
    )
    asserts.equals(
        env,
        "rs_bpf_linker_x86_64_apple_darwin",
        bpf_linker_repository_name("x86_64-apple-darwin"),
    )
    asserts.equals(env, None, bpf_linker_repository_name("x86_64-pc-windows-msvc"))
    asserts.equals(env, None, bpf_linker_repository_name("riscv64gc-unknown-linux-gnu"))
    asserts.equals(
        env,
        [
            "aarch64-apple-darwin",
            "aarch64-unknown-linux-gnu",
            "x86_64-apple-darwin",
            "x86_64-unknown-linux-gnu",
        ],
        BPF_LINKER_SUPPORTED_EXEC_TRIPLES,
    )

    return unittest.end(env)

_bpf_linker_repository_name_test = unittest.make(_bpf_linker_repository_name_test_impl)

def bpf_linker_repository_tests():
    _bpf_linker_repository_name_test(
        name = "bpf_linker_repository_name_test",
    )

    native.test_suite(
        name = "bpf_linker_repository_tests",
        tests = [":bpf_linker_repository_name_test"],
    )
