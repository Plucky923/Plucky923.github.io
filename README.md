# plucky.wang

Source for [plucky.wang](https://plucky.wang), a personal site built with [Hugo](https://gohugo.io/) and the [Blowfish](https://blowfish.page/) theme (managed as a Hugo module).

## Development

Requires Hugo 0.161.1 (local binary at `$(HOME)/.local/bin/hugo`).

```bash
make server   # local preview with drafts
make build    # production build
make clean    # remove public/ and resources/_gen/
make new TITLE="Hello"  # create a new post
make new-project TITLE="My Project"  # create a draft project directory
```

## Deployment

Production builds and deploys to GitHub Pages are handled by `.github/workflows/publish.yaml`. No manual push needed.

## Project Layout

- `content/` — site content (posts, about, and project bundles)
- `content/projects/<slug>/` — one project; place `index.md` and its files together here
- `archetypes/project.md` — front matter template used by `make new-project`
- `layouts/` — Hugo template overrides
- `assets/css/` — custom styles
- `_vendor/` — vendored Blowfish theme
- `.trellis/` — task research and Trellis workflow files

## Projects

Projects are Hugo leaf bundles. Run `make new-project TITLE="My Project"`, then write the overview in the created `index.md`. Put PDFs, images, archives, or other project files in that same directory; the `/projects/` page and the individual project page will discover and list them automatically when the project is no longer a draft.
