load("@io_bazel_rules_scala//scala/private:common.bzl", "collect_jars")

def _new_generator_command(ctx, out_file, jars):
  java_path = ctx.attr._jdk[java_common.JavaRuntimeInfo].java_executable_exec_path
  gen_cmd = str(java_path)
  
  generator_class = ctx.attr.generator_class

  sep = ";" if ctx.attr.is_windows else ":"

  gen_cmd += " -cp \"{jars}\" {generator_class} --schema {schema} --out {out_file}".format(
    java = java_path,
    jars = sep.join([j.path for j in jars]),
    generator_class = generator_class,
    schema = ctx.file.schema.path,
    out_file = out_file.path
  )
  return gen_cmd

def _impl(ctx):
  jars = collect_jars(ctx.attr.deps, None, None, None)
  out_file = ctx.actions.declare_file("%s.scala" % (ctx.attr.name))
  all_jars = jars.transitive_runtime_jars.to_list()

  ctx.actions.run_shell(
    inputs = [ctx.file.schema] + all_jars,
    command = _new_generator_command(ctx, out_file, all_jars),
    outputs = [out_file],
    tools = ctx.files._jdk
  )

  srcs = out_file.path

  return DefaultInfo(files = depset([out_file]))

_spice4s_generator = rule(
  attrs = {
    "deps": attr.label_list(
      default = [
        "@spice4s//:spice4s-parser",
        "@spice4s//:spice4s-generator",
        "@spice4s//:spice4s-generator-cli",
        "@spice4s//:spice4s-client",
      ]
    ),
    "generator_class": attr.string(default = "spice4s.generator.GeneratorCli"),
    "is_windows": attr.bool(mandatory = True),
    "schema": attr.label(mandatory = True, allow_single_file = True),
    "_jdk": attr.label(default = Label("@bazel_tools//tools/jdk:current_java_runtime"), cfg = "host"),
  },
  implementation = _impl
)

def spice4s_generator(name, **kwargs):
  _spice4s_generator(
    name = name,
    is_windows = select({
        "@bazel_tools//src/conditions:windows": True,
        "//conditions:default": False,
    }),
    **kwargs
  )
