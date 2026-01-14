# DaisyUI CDN Styling Approach

## Context
We want a light UI refresh using DaisyUI, but must avoid introducing a Node build
pipeline or `node_modules`. The app currently uses Propshaft with a plain CSS
manifest and no Tailwind build step.

## Decision
Use DaisyUI via a CDN-hosted compiled stylesheet and apply DaisyUI classes in
views. This provides quick styling improvements without adding Node or Tailwind
build tooling.

## Alternatives Considered
- **Tailwind build pipeline (tailwindcss-rails or cssbundling-rails)**: rejected
  for now because it introduces Node/tooling and `node_modules`.
- **Hand-rolled CSS only**: rejected; DaisyUI provides a faster path to usable
  components and consistent styling.

## Consequences
### Positive
- Zero Node/tooling overhead.
- Faster iteration on UI polish.
- Easy to remove or replace later.

### Negative
- The CDN stylesheet is larger than a minimal, purged build.
- Limited customization compared to a full Tailwind + DaisyUI pipeline.

## Open Questions / Follow-ups
- If the UI grows, do we want to revisit a build pipeline for smaller CSS and
  theme customization?
