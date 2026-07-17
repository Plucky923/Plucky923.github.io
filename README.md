# plucky.wang

Source for [plucky.wang](https://plucky.wang), a personal site built with [Hugo](https://gohugo.io/) and the [Blowfish](https://blowfish.page/) theme (managed as a Hugo module).

## Development

Requires Hugo 0.161.1 (local binary at `$(HOME)/.local/bin/hugo`).

```bash
make server   # local preview with drafts
make build    # production build
make clean    # remove public/ and resources/_gen/
make new TITLE="Hello"  # create a new post
```

## Deployment

Production builds and deploys to GitHub Pages are handled by `.github/workflows/publish.yml`. No manual push needed.

## Project Layout

- `content/` — site content (posts, about)
- `layouts/` — Hugo template overrides
- `assets/css/` — custom styles
- `_vendor/` — vendored Blowfish theme
- `.trellis/` — task research and Trellis workflow files
