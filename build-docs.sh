# This assumes the remote is named 'origin' and the remote url ends with '{repo_name}.git'
repo_name=$(basename -s .git `git remote get-url origin`)

# Swift-DocC currently only supports generating documentation for a single target, but we
# can "cheat" that by specifying the `--additional-symbol-graph-dir` below. The specified
# directory should contain symbol graphs for all the targets we want to document. This is
# achieved by building each target with `-emit-symbol-graph` and `-emit-symbol-graph-dir`
# flags. See the `Package.swift` file for more details.
#
# Swift-DocC still expects a target name to be specified, so we'll use the most important
# module in the package as the target. It's unclear exactly how the target's name will be
# used in the generated documentation. However, this is just a temporary workaround until
# Swift-DocC supports generating documentation for multiple targets.
#
# Many thanks to Stefan Kieleithner (@steviki) for documenting this workaround in this post:
# https://pspdfkit.com/blog/2024/generating-api-documentation-for-multiple-targets-with-docc/
# While he used Xcode, I've adapted his approach for use with just Swift Package Manager.
#
# TODO: Would it be overkill to write some sort of parser to determine the most important
# module in the package? For now, we'll just hardcode this target name.
root_target=MachMsg

# Use the `-p` flag to preview the documentation locally instead of generating it.
getopts "p" _;
if [ $? -eq 0 ]; then
    options=" \
    --disable-sandbox \
    preview-documentation \
    "
else
    # Note the base path is the repo name (as this will be hosted on GitHub Pages)
    options=" \
    --allow-writing-to-directory ./docs \
    generate-documentation \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path $repo_name \
    --output-path ./docs \
    "
fi
swift package \
    $options \
    --target $root_target \
    --additional-symbol-graph-dir ./.build/symbol-graphs/ \
    --diagnostic-level hint \
    --verbose \
    Documentation.docc