# Spec: Static landing page v0

Tracking issue: #91. Part of #5 (full landing page).
Copy source: `.planning/content-brief.md` § `/`.
Design source: `../evan-school-ds/` (`_tokens.css`, `hero-split.html`, `typography.html`,
`buttons.html`, `navigation.html`, `colors.html`) and the Signal/Whisper direction
(light-first, Whisper default, at most one Signal section per page).

## Feature

As Evan and the people he asks for feedback, I want the production deployment to show a
real landing page in his voice and visual identity, so that the site can be reviewed and
iterated on while the CMS, auth and mailing-list work is still in progress.

## Background

Production renders one unstyled heading, "Evan's Meditation School", which is the
template's placeholder name. The full landing page (#5) depends on four other issues.
This version depends on none of them: all copy is static and taken from the existing
site's content brief, and the only call to action is the existing Calendly booking link.

## User Scenarios

### S1 — The page is Evan's

- GIVEN a visitor opens `/` WHEN the page loads THEN the only `h1` reads "Evan Leed".
- GIVEN the page WHEN rendered THEN "Meditation School" appears nowhere, including the
  document title.
- GIVEN the document head WHEN inspected THEN the title is
  "Evan Leed | Trauma-Informed IPF Facilitator" and a meta description is present.

### S2 — Booking a consultation is the obvious next step

- GIVEN the hero WHEN rendered THEN the tagline "Helping you heal attachment wounds and
  complex trauma through the Ideal Parent Figure Protocol." and a link labelled
  "Book a free 30-minute consultation" are visible above the fold at 375 px and 1440 px.
- GIVEN that link WHEN activated THEN it navigates to `https://calendly.com/evan-leed`.
- GIVEN the header WHEN rendered THEN it shows the brand and a consultation link to the
  same URL, and no links to pages that do not exist yet.

### S3 — The visitor can judge fit and trust

- GIVEN the page WHEN rendered THEN it contains, with copy matching the content brief:
  the intro paragraphs, the core claim, the credentials list, three testimonials
  attributed to T.H., A.N. and Melissa Hower, and the scope disclaimer.
- GIVEN the page WHEN rendered THEN no price or currency amount appears.
- GIVEN the footer WHEN rendered THEN it links to Instagram `@evanleed` and
  X `@rainbowbodyhug`.

### S4 — Anyone can use it

- GIVEN the page WHEN rendered THEN it has `header`, `main` and `footer` landmarks and
  each section has a heading.
- GIVEN a keyboard user WHEN tabbing THEN every link shows a visible focus indicator.
- GIVEN every text colour used on its background WHEN checked by the contrast tests
  THEN body text meets 4.5:1 and large text meets 3:1.
- GIVEN viewports of 375, 768 and 1440 px WHEN the page renders THEN nothing overflows
  horizontally and the hero stacks to one column below 640 px.

### S5 — The deployment pipeline proves it

- GIVEN a preview deployment WHEN the E2E smoke runs THEN it asserts the new title and
  heading and passes.

## Out of scope

- MailChimp signup (#2), JSON-LD (#41), BusinessSettings values (#48), Who It's For (#44),
  course and event listings (after #3)
- Prices of any kind
- Payload, auth, removing `<ClerkProvider>` (#3)
- Dark theme (the design system defines none)
- Web fonts (the design system uses Georgia and the system sans stack)

## Success measure

Evan can open the production URL and react to real copy and design instead of a
placeholder heading.
