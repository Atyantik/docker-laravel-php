# Security updates

When PHP ships a security release, every tag of `atyantik/laravel-php` has to be rebuilt on the new official base image. This file is the checklist.

## Tags
| Branch | Tags | Debian |
|---|---|---|
| `php8.2-bookworm` | `8.2-bookworm`, `8.2-bullseye`, `8.2.<patch>-bookworm` | 12 |
| `php8.3-bookworm` | `8.3-bookworm`, `8.3-bullseye`, `8.3.<patch>-bookworm` | 12 |
| `php8.4-bookworm` | `8.4-bookworm`, `8.4-bullseye`, `8.4.<patch>-bookworm` | 12 |
| `php8.5-bookworm` | `8.5-bookworm`, `8.5.<patch>-bookworm`, `latest` (no `-bullseye` tag, on purpose) | 12 |

- **`-bullseye` tags:** these have pointed at the bookworm image since Oct 2026. The official `php:*-bullseye` images stopped updating in Aug 2025.
- **`<patch>-bookworm` tags:** immutable. Pin these in client Dockerfiles, so a bump shows in git.

## Steps
1. On each `php8.x-bookworm` branch, set `ARG PHP_VERSION=<patch>`, then commit and push. Use `git worktree add` per branch.
2. `docker login`.
3. On master, run `./release.sh 8.2 8.2.<patch>`, then 8.3 and 8.4. Run 8.5 last with `--latest`. The script:
   - waits for the official base to have amd64 and arm64
   - checks the PHP version, CPU arch, `php-fpm -t`, and that the extension list is unchanged
   - pushes, then reads the tags back from Docker Hub
   - saves the previous digests in `release-log/<patch>.txt` for rollback
4. Tell clients to rebuild with `--pull` and redeploy. Nobody is patched until they do.

## Timing
- **Official images:** after php.net publishes, they take a few hours to get both arches.
- **Building on an Apple silicon Mac:** arm64 takes about 6 minutes, amd64 (emulated) about 30 to 60 minutes per version.

## Rollback
`docker buildx imagetools create -t atyantik/laravel-php:<tag> atyantik/laravel-php@<previous digest>`

## History
- **2026-10-21:** 8.2.35 / 8.3.36 / 8.4.27 / 8.5.12, for CVE-2026-109618 and CVE-2026-109619. The images moved to bookworm.
- **2026-11-19:** 8.2.36 / 8.3.37 / 8.4.28 / 8.5.13, the PHP security release that includes CVE-2026-115560.
