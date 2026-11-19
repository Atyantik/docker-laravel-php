#!/usr/bin/env bash
# Build, check and publish one atyantik/laravel-php version for amd64 and arm64.
#
# Usage:   ./release.sh <minor> <patch> [--latest]
# Example: ./release.sh 8.2 8.2.36
#
# Before running:
#   1. On branch php<minor>-bookworm, set "ARG PHP_VERSION=<patch>" in the Dockerfile, commit, push.
#   2. docker login (Docker Hub user with push rights to atyantik/laravel-php).
#
# What it does, in order. It stops at the first failed check, before anything is pushed:
#   - waits until the official php:<patch>-fpm-bookworm has both amd64 and arm64 on Docker Hub
#     (after a PHP release this takes a few hours)
#   - checks Docker has at least 25 GB free (a full run of 4 versions filled the disk in Oct 2026)
#   - builds arm64 (native on Apple silicon, ~10 min) and amd64 (emulated, ~45-60 min),
#     retrying up to 4 times because pecl.php.net often returns 500s
#   - checks each image: PHP version, CPU arch, php-fpm -t, and that "php -m" matches the
#     image currently published under <minor>-bookworm (no extension lost or gained)
#   - pushes per-arch tags <minor>-bookworm-<arch> (and <minor>-bullseye-<arch> where that alias exists)
#   - joins them into <minor>-bookworm, <minor>-bullseye (only if it already exists: 8.2 to 8.4,
#     Debian 12 despite the name) and the immutable <patch>-bookworm. With --latest also moves "latest".
#   - reads the manifest back from Docker Hub and runs a fresh amd64 pull
#
# Rollback: the previous digests are printed and saved to release-log/<patch>.txt. Re-point a tag with
#   docker buildx imagetools create -t atyantik/laravel-php:<tag> atyantik/laravel-php@<old digest>
set -euo pipefail

MINOR=${1:?minor, e.g. 8.2}
PATCH=${2:?patch, e.g. 8.2.36}
LATEST=${3:-}
REPO=atyantik/laravel-php
BRANCH=php$MINOR-bookworm
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=$(mktemp -d)
LOG=$HERE/release-log/$PATCH.txt
mkdir -p "$HERE/release-log"
log(){ echo "[$(date -u +%H:%M:%SZ)] $*" | tee -a "$LOG"; }
trap 'git -C "$HERE" worktree remove --force "$WORK/src" 2>/dev/null || true; rm -rf "$WORK"' EXIT

hub_arches(){ # <repo> <tag> -> space separated linux arches, or nothing
  local tok
  tok=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$1:pull" | python3 -I -c 'import sys,json;print(json.load(sys.stdin)["token"])')
  curl -s -H "Authorization: Bearer $tok" -H "Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json" \
    "https://registry-1.docker.io/v2/$1/manifests/$2" | python3 -I -c 'import sys,json
try: print(" ".join(sorted({m["platform"]["architecture"] for m in json.load(sys.stdin).get("manifests",[]) if m.get("platform",{}).get("os")=="linux"})))
except Exception: pass'
}

log "release $REPO $PATCH from branch $BRANCH"

# 1. Source: the pushed branch, so the image matches what is on GitHub.
git -C "$HERE" fetch -q origin "$BRANCH"
git -C "$HERE" worktree add -q --detach "$WORK/src" "origin/$BRANCH"
grep -q "^ARG PHP_VERSION=$PATCH$" "$WORK/src/Dockerfile" || { log "Dockerfile on origin/$BRANCH does not pin $PATCH"; exit 1; }
log "source origin/$BRANCH at $(git -C "$WORK/src" rev-parse --short HEAD)"

# 2. Official base must have both arches.
until [[ "$(hub_arches library/php "$PATCH-fpm-bookworm")" == *amd64*arm64* ]]; do
  log "waiting for php:$PATCH-fpm-bookworm (has: $(hub_arches library/php "$PATCH-fpm-bookworm"))"; sleep 300
done
log "official php:$PATCH-fpm-bookworm has amd64 and arm64"

# 3. Disk.
FREE_GB=$(docker run --rm busybox df -k / | awk 'NR==2{print int($4/1048576)}')
[ "$FREE_GB" -ge 25 ] || { log "Docker has only ${FREE_GB} GB free; need 25. Run docker builder prune first."; exit 1; }
log "Docker free disk ${FREE_GB} GB"

# 4. Previous digests, for rollback.
for t in "$MINOR-bookworm" "$MINOR-bullseye" latest; do
  log "previous $t: $(docker buildx imagetools inspect "$REPO:$t" --format '{{json .Manifest.Digest}}' 2>/dev/null || echo none)"
done

# 5. Build and check each arch.
for ARCH in arm64 amd64; do
  IMG=$REPO:$MINOR-bookworm-$ARCH
  for try in 1 2 3 4; do
    log "build $ARCH, try $try"
    if docker buildx build --platform "linux/$ARCH" --pull --load -t "$IMG" "$WORK/src" > "$WORK/build-$ARCH.log" 2>&1; then break; fi
    tail -5 "$WORK/build-$ARCH.log" | tee -a "$LOG"
    [ $try = 4 ] && { log "build $ARCH failed 4 times"; exit 1; }
    sleep 60
  done
  V=$(docker run --rm --platform "linux/$ARCH" "$IMG" php -r 'echo PHP_VERSION;')
  M=$(docker run --rm --platform "linux/$ARCH" "$IMG" uname -m)
  docker run --rm --platform "linux/$ARCH" "$IMG" php-fpm -t >/dev/null 2>&1 || { log "$ARCH php-fpm -t failed"; exit 1; }
  [ "$V" = "$PATCH" ] || { log "$ARCH has PHP $V, expected $PATCH"; exit 1; }
  case "$ARCH:$M" in arm64:aarch64|amd64:x86_64) ;; *) log "$ARCH image reports uname $M"; exit 1;; esac
  docker run --rm --platform "linux/$ARCH" "$IMG" php -m 2>/dev/null | grep -v '^\[' | sort -u > "$WORK/new-$ARCH.txt"
  if docker pull -q --platform "linux/$ARCH" "$REPO:$MINOR-bookworm" >/dev/null 2>&1; then
    docker run --rm --platform "linux/$ARCH" "$REPO:$MINOR-bookworm" php -m 2>/dev/null | grep -v '^\[' | sort -u > "$WORK/old-$ARCH.txt"
    diff "$WORK/old-$ARCH.txt" "$WORK/new-$ARCH.txt" > "$WORK/mods.diff" || { log "$ARCH extension list changed:"; cat "$WORK/mods.diff" | tee -a "$LOG"; exit 1; }
  fi
  log "$ARCH ok: PHP $V on $M, php-fpm -t ok, $(wc -l < "$WORK/new-$ARCH.txt" | tr -d ' ') modules, same as published"
done

# 6. Push per-arch tags, then join.
# The -bullseye alias exists only for versions that once had a bullseye build (8.2 to 8.4).
# Never create it for a newer version.
BULLSEYE=""
[ -n "$(hub_arches "$REPO" "$MINOR-bullseye")" ] && BULLSEYE=1
for ARCH in arm64 amd64; do
  docker push -q "$REPO:$MINOR-bookworm-$ARCH" >/dev/null
  if [ -n "$BULLSEYE" ]; then
    docker tag "$REPO:$MINOR-bookworm-$ARCH" "$REPO:$MINOR-bullseye-$ARCH"
    docker push -q "$REPO:$MINOR-bullseye-$ARCH" >/dev/null
  fi
done
TAGS=(-t "$REPO:$MINOR-bookworm" -t "$REPO:$PATCH-bookworm")
[ -n "$BULLSEYE" ] && TAGS+=(-t "$REPO:$MINOR-bullseye")
[ "$LATEST" = --latest ] && TAGS+=(-t "$REPO:latest")
docker buildx imagetools create "${TAGS[@]}" "$REPO:$MINOR-bookworm-amd64" "$REPO:$MINOR-bookworm-arm64"
log "published ${TAGS[*]//-t /}"

# 7. Read back from Docker Hub.
for t in "$MINOR-bookworm" ${BULLSEYE:+"$MINOR-bullseye"} "$PATCH-bookworm" ${LATEST:+latest}; do
  A=$(hub_arches "$REPO" "$t"); log "hub $t: $A  digest $(docker buildx imagetools inspect "$REPO:$t" --format '{{json .Manifest.Digest}}')"
  [[ "$A" == *amd64*arm64* ]] || { log "hub $t is missing an arch"; exit 1; }
done
docker rmi -f "$REPO:$PATCH-bookworm" >/dev/null 2>&1 || true
log "fresh amd64 pull: $(docker run --rm --pull always --platform linux/amd64 "$REPO:$PATCH-bookworm" php -r 'echo PHP_VERSION, " ", php_uname("m");')"
log "done $PATCH"
