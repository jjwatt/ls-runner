load("@pip//:requirements.bzl", "requirement")
load("@rules_python//python:defs.bzl", "py_binary", "py_test")

package(default_visibility = ["//visibility:public"])

py_binary(
    name = "slsread",
    srcs = ["slsread.py"],
    data = [ "env.yml", "serverless.yml" ],
    deps = [
        requirement("pyyaml"),
    ],
)
