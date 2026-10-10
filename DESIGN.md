---
name: RoamAgent Design System
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#45464d'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e74'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#131b2e'
  on-primary-container: '#7c839b'
  inverse-primary: '#bec6e0'
  secondary: '#006398'
  on-secondary: '#ffffff'
  secondary-container: '#5bb8fe'
  on-secondary-container: '#00476e'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#370e00'
  on-tertiary-container: '#e45405'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#cce5ff'
  secondary-fixed-dim: '#93ccff'
  on-secondary-fixed: '#001d31'
  on-secondary-fixed-variant: '#004b73'
  tertiary-fixed: '#ffdbce'
  tertiary-fixed-dim: '#ffb599'
  on-tertiary-fixed: '#370e00'
  on-tertiary-fixed-variant: '#7f2b00'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
  headline-lg:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  headline-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  headline-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
  data-metric:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 26px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system establishes a focused, high-clarity travel concierge persona built specifically for the logistical reality of Indian intercity coach travel (spanning state RTC fleets, private multi-axle AC sleepers, and semi-sleeper operators). The emotional goal is immediate reassurance, operational command, and frictionless decision-making during high-stress moments like midnight boardings, highway delays, and dynamic route reassignments.

The design movement blends **Modern Utilitarian Material 3** with a crisp, functional transit-dashboard aesthetic. The interface emphasizes:
- **Uncompromised Legibility:** Glanceable information hierarchy under direct sunlight or low-light cabin environments.
- **Informational Density without Noise:** Structured data cards, side-by-side metric diffs, and sequential progression tracks replace decorative clutter.
- **Contextual Reliability:** Deliberate color coding for rapid mental processing of operational states—on-time departures, traffic choke points, and platform reallocations.

## Colors

The palette balances authoritative transit telemetry with distinct semantic feedback loops tuned for high visual clarity on mobile devices:

- **Primary (`#0F172A`, `#1E293B`):** Deep Slate Navy. Used for structural containers, top app bars, high-prominence headers, and authoritative primary button surfaces.
- **Secondary (`#0284C7`, Surface Light: `#E0F2FE`):** Sky Blue. Applied to informational telemetry, live GPS vehicle pings, route node markers, and auxiliary badges.
- **Action & Disruption Accent (`#EA580C`, Surface Light: `#FFF7ED`):** Ember Orange. Reserved for actionable interventions, delay notifications, booking urgency, and high-priority journey disruption warnings.
- **Status Success (`#16A34A`, Surface Light: `#DCFCE7`):** Emerald Green. Designates confirmed bookings, verified boarding pass QR states, on-time arrivals, and seat confirmations.
- **Neutral & Canvas (`#F8FAFC`, Surface: `#FFFFFF`, Outline: `#E2E8F0`, Muted Text: `#64748B`):** Clean, high-luminance canvas that guarantees contrast ratios above 4.5:1 for standard body text and 3:1 for large graphical elements.

## Typography

The type system is powered by **Inter**, selected for its optical correction at compact mobile viewports, tabular numeric support, and open letterforms.

- **Tabular Numerics (`tnum`):** All departure clocks (`22:45`), platform codes, seat indicators (`U-12 Sleeper`), and fare amounts (`₹1,240`) must enable tabular numbers to ensure alignment within itinerary diffs and journey steps.
- **Currency & Metric Stacking:** The Rupee sign (`₹`) retains identical weight to its corresponding numeric literal to avoid visual detachment during fast scanning.
- **Hierarchy Rules:** Primary trip markers and terminal locations use `headline-md` in `#0F172A`. Secondary contextual captions (e.g., "Via Electronic City Flyover") leverage `body-sm` in `#64748B`.

## Layout & Spacing

The layout utilizes an 8pt-derived fluid single-column structure on mobile devices, transitioning to a centered constraint column for tablet surfaces:

- **Mobile Viewports (<600dp):** Continuous 16px (`1rem`) lateral canvas padding with safe area handling for dynamic notches and bottom gesture bars.
- **Component Flow:** Vertical rhythm strictly adheres to 8px multiples. Tightly coupled metadata (e.g., operator name and sleeper category) uses `space-xs` (4px) or `space-sm` (8px). Structural separation between independent journey modules defaults to `space-md` (16px).
- **Sticky Footers:** Primary call-to-action clusters (e.g., rebooking actions, boarding pass retrieval) occupy an elevated fixed bottom container with 16px horizontal and 12px vertical padding, floating above scrolling feed content.

## Elevation & Depth

Visual hierarchy uses a hybrid of **Tonal Layering** and **Muted Ambient Shadows**, avoiding excessive skeletal borders while ensuring separation on varied display panels:

- **Level 0 (Canvas):** `#F8FAFC`. Base backdrop for page screens.
- **Level 1 (Cards & Modules):** Pure `#FFFFFF` surface combined with a soft, low-radius ambient drop shadow: `0px 2px 8px -2px rgba(15, 23, 42, 0.06)`, bounded by a 1px crisp outline in `#E2E8F0`.
- **Level 2 (Modals, Bottom Sheets, Persistent CTA Trays):** Pure `#FFFFFF` resting at `0px 8px 24px -4px rgba(15, 23, 42, 0.12)`, topped with a hairline border `#E2E8F0`.
- **Status Overlay Depth:** Warning banners and disruption alerts do not cast harsh shadows; instead, they rely on 100% opaque tinted surface containers (`#FFF7ED` or `#E0F2FE`) with hairline inner containment lines to maintain visual balance.

## Shapes

The design system enforces a disciplined geometric curve language that communicates modern precision without feeling toy-like:

- **Itinerary & Module Cards:** Standardized on 16px (`rounded-2xl` / `1rem`) corner radii, generating soft yet structured visual cards for complex trip data.
- **Pills & Status Badges:** Fully rounded (`9999px`) to maintain instant recognition as glanceable metadata tags.
- **Action Buttons & Form Controls:** 12px corner radii for clear touch boundaries and thumb ergonomics.
- **Inner Sub-Cards & Metric Diffs:** 8px corner radii to establish clean visual containment nested inside parent 16px cards.

## Components

### Buttons
- **Primary CTA:** Material 3 filled style using `#0F172A` with `#FFFFFF` text, 48px minimum touch height, `label-lg` typography, and 12px corner radius. In active disruption contexts, the primary CTA switches to `#EA580C`.
- **Secondary / Action Outlined:** 1.5px border in `#CBD5E1`, transparent background, `#0F172A` text, 48px height.
- **Pill Action (Inline / Compact):** 36px height, 8px horizontal padding, pill radius (`9999px`), utilized for "Change Pickup", "Call Operator", or "Live Track".

### Chips & Status Badges
- **Confirmed / On-Time:** Background `#DCFCE7`, border `#86EFAC`, text `#15803D`, accompanied by a 6px solid green status dot.
- **Delayed / Caution:** Background `#FFF7ED`, border `#FED7AA`, text `#C2410C`.
- **Informational / Route Tag:** Background `#E0F2FE`, border `#BAE6FD`, text `#0369A1`.
- **Persistent Demo Indicator:** Subtle pill badge at `#F1F5F9`, border `#CBD5E1`, text `#475569`, reading `Demo · Simulated travel data`, pinned at secondary headers or itinerary card roots.

### Itinerary Cards
- Pure white container with 16px rounded corners, 16px internal padding, and 1px `#E2E8F0` border.
- Header section incorporates operator brand badge, bus model (e.g., "Scania Multi-Axle AC Sleeper 2+1"), and real-time status pill.
- Central zone displays a clean horizontal departure-to-arrival schema: origin time/location left-aligned, duration and highway corridor centered, destination time/location right-aligned. Tabular numbers applied across all times and ₹ fares.

### Vertical Timeline Journey Steps
- Continuous vertical axis marked with a 2px `#E2E8F0` track line.
- Active or passed waypoints render a solid 10px `#0284C7` or `#16A34A` node circle; upcoming waypoints feature a hollow 2px bordered ring.
- Boarding points display landmark cues, exact departure windows, and integrated contact anchors.

### Side-by-Side Comparison Cards (Diff View)
- Dual column sub-layout within a warning card to evaluate original vs. revised schedules.
- Left column (Old): `#64748B` struck-through metrics with muted text.
- Right column (New): High-visibility `#0F172A` bold typography with an accompanying delay tag (e.g., `+35m`) in `#EA580C`.

### Form Inputs & Selectors
- Background `#FFFFFF`, 1px border `#CBD5E1`, 12px radius, 48px height.
- Focused state: 2px border `#0284C7` with a zero-offset subtle ring. Helper text rendered in `body-sm` (`#64748B`).