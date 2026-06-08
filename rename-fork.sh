#!/usr/bin/env sh
# rename-fork.sh - re-apply the module rename after pulling a new upstream tag.
#
# This fork keeps upstream gophertunnel's code verbatim but renames its module
# path from github.com/sandertv/gophertunnel to github.com/iteplenky/gophertunnel
# so downstreams can `require` it directly. That lets the deferred-packet
# handshake-deadlock patch ship without a `replace` directive in the consumer's
# go.mod - which is what makes `go install <consumer>@latest` work (Go refuses to
# install a module whose go.mod carries replace directives).
#
# Maintenance loop after an upstream rebase/merge:
#   1. merge the new upstream tag onto this branch
#   2. ./rename-fork.sh
#   3. go build ./... && go vet ./...
#   4. git commit && git tag vX.Y.Z-patched.N && git push --follow-tags
#
# go-raknet (github.com/sandertv/go-raknet) is intentionally NOT renamed.
set -e
grep -rl 'github.com/sandertv/gophertunnel' --include='*.go' . \
  | xargs perl -i -pe 's{github\.com/sandertv/gophertunnel}{github.com/iteplenky/gophertunnel}g'
perl -i -pe 's{github\.com/sandertv/gophertunnel}{github.com/iteplenky/gophertunnel}g' go.mod
echo "rename applied; residual sandertv/gophertunnel .go refs: $(grep -rl 'sandertv/gophertunnel' --include='*.go' . | wc -l | tr -d ' ') (expect 0)"
