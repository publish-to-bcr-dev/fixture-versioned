#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}

# Substitute version into MODULE.bazel
VERSION=${TAG#v}
sed -i -e "s/0\\.0\\.0/${VERSION}/g" MODULE.bazel

# The prefix is chosen to match what GitHub generates for source archives
# This guarantees that users can easily switch from a released artifact to a source archive
# with minimal differences in their code (e.g. strip_prefix remains the same)
PREFIX="fixture-versioned-${TAG:1}"
ARCHIVE="ixture-versioned-$TAG.tar.gz"
ARCHIVE_TMP=$(mktemp)

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix=${PREFIX}/ ${TAG} --add-file MODULE.bazel >$ARCHIVE_TMP

gzip <$ARCHIVE_TMP >$ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat <<EOF

## Release notes

Foobar

\`\`\`

EOF