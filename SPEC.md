# Anathyrosis — Build Specification

> Portfolio app 100, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Tap drums in order to rebuild a painting's maker or title.

| Field | Value |
| --- | --- |
| Product name | Anathyrosis |
| Bundle identifier | `com.anathyrosis.shaft` |
| Domain | https://anathyrosis-shaft.pro |
| Contact URL | https://anathyrosis-shaft.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `ahy_` |
| User-Agent | `Anathyrosis/1.0 (iOS; +https://anathyrosis-shaft.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Anathyrosis -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A restorer taps inscription drums in reading order so that saved painting files as rebuilt.

### 2.1 User flow

1. Tap the first true drum on the spoil heap
2. Keep stacking drums until the shaft reads the maker or the title
3. Open Explore and save another painting into the crate
4. Open Saved to review rebuilt paintings and spalls
5. Open Settings to read the Victoria and Albert Museum credit

### 2.2 Essential behaviour

- Explore search and save into a local crate
- Quiz rebuilds a maker name or a picture title from shuffled drums
- A wrong drum records a reviewable spall and the shaft does not grow
- No shop and no grade field
- One collection voice: Victoria and Albert Museum
- Seed already jumbles one inscription so the first tap can stack

---

## 3. Uniqueness assignment for Anathyrosis

| Axis | Assigned value |
| --- | --- |
| Architecture | **Anastylosis ADT fold (Spoil | Laid | Rebuilt); the shaft is a fold over Pieces; Scatter writes Drums as maker XOR title in shuffled order and folds Spoil to Laid; Stack writes a ClampMark when the tapped Drum is the next word and seats it on the Shaft; a miss writes a SpallMark and keeps the Shaft; the last true Stack folds Laid to Rebuilt; Stack on Spoil is refused; a second Scatter while Laid is refused; Scatter samples a Piece that is not Rebuilt; empty shaft writes Waste** |
| UI approach | **SwiftUI pure · take artquiz7** |
| Naming convention | **Anastylosis / column-drum lexicon** |
| File organization | **By shaft role (Shaft, Piece, Drum, ClampMark, SpallMark, Spoil)** |
| Dependency strategy | **None** |
| Design direction | **Soft card daylight · take artquiz3** |
| Typography | **SF Pro** |
| Navigation pattern | **Shaft-locked chrome (the ruined column never leaves; Explore, Saved and Settings arrive as sheets; scatter and stack fuse on Quiz)** |
| AI art style | **3D glass render glassmorphism · take artquiz7** |
| Functional twist | **Scatter-then-stack (Scatter samples a Piece that is not Rebuilt; Drums are maker XOR title in shuffled order; Stack writes a ClampMark when the tapped Drum is the next word and seats it; a miss writes a SpallMark and keeps the Shaft; Stack on Spoil is refused; empty shaft writes Waste)** |
| Persistence | **UserDefaults+Codable** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — art_quiz

**Core** — A restorer taps inscription drums in reading order so that saved painting files as rebuilt.

**Audience** — People who remember a painting and want to rebuild its maker name or title from loose stones, not pick a name chip or fill a hole.

**User flow**

1. Tap the first true drum on the spoil heap
2. Keep stacking drums until the shaft reads the maker or the title
3. Open Explore and save another painting into the crate
4. Open Saved to review rebuilt paintings and spalls
5. Open Settings to read the Victoria and Albert Museum credit

**Essential features**

- Explore search and save into a local crate
- Quiz rebuilds a maker name or a picture title from shuffled drums
- A wrong drum records a reviewable spall and the shaft does not grow
- No shop and no grade field
- One collection voice: Victoria and Albert Museum
- Seed already jumbles one inscription so the first tap can stack

**Twist** — Scatter-then-stack. Home is the ruined column. Scatter pulls one painting that is still loose and splits either the maker name or the picture title into drums, then jumbles those drums on the spoil heap. Stacking the next true drum records a ClampMark and seats that stone on the shaft. A drum out of order records a SpallMark and stays on the heap. Stacking does nothing before Scatter. Explore saves a painting as loose; the same object id only brings that row forward. Rebuilt paintings move to Saved and leave Scatter. Undo peels the newest clamp or spall. Scatter on an empty crate prints Waste. First launch already shows a jumbled inscription, so the opening tap can seat a drum. The job on home is stack-the-drum. Saved lists ClampMarks and SpallMarks. Settings credits the Victoria and Albert Museum. Grades and a shop stay out.

**Why this is not a repeat** — Home is stack-the-drum: every word of the maker name or the picture title is already visible, only the order is wrong, and extras are not in the heap. Minium hides a rubric and inks letters from a case that includes decoys. Tratteggio punches one hole and offers replacement chips. Athetesis asks the user to find an interpolated word. This product seats drums from the bottom of a column until the inscription reads, then files the painting as rebuilt. Explore, Saved, and Settings stay sheets around that column. Soft card daylight, SwiftUI pure, and glassmorphism are leftover closed-axis takes, not new catalog bases.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Explore → saved → quiz artist or title.
- Invariant: Quiz draws from saved works. Misses are reviewable. Collecting without a test is the crate clone.
- Never: One collection voice. No shop.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

Anastylosis is a closed algebraic fold with cases Spoil, Laid, and Rebuilt; a fourth case is a defect. The shaft is a fold over Pieces: Scatter samples one saved Piece that is not Rebuilt, writes Drums as maker XOR title split on whitespace and shuffled, and folds Spoil to Laid; Scatter with no loose Piece writes Waste; a second Scatter while Laid is refused; Rebuilt pieces leave that pool for Saved. Stack writes a ClampMark when the tapped Drum is the next word in reading order and seats that stone on the Shaft; a miss writes a SpallMark, keeps the Shaft, and leaves that Drum on the spoil heap; Stack on Spoil is refused; the last true Stack folds Laid to Rebuilt. Undo peels the newest ClampMark or SpallMark so a ClampMark unseats that drum back onto the heap, and Explore writes a Piece as loose Spoil with daykey Int YYYYMMDD from Calendar.current.startOfDay while a repeated object id focuses the existing row and does not reset Anastylosis. One observable ShaftStore pattern-matches the fold; views call scatterPiece, stackDrum, missDrum, and peelNewestMark and never keep a second shaft enum; unit tests prove not-Rebuilt sampling, maker-XOR-title drums with no decoys, Stack-on-Spoil refuse, second-Scatter-while-Laid refuse, miss keep, last-Stack fold, Undo fold-back, Rebuilt leaving the pool, duplicate focus, and Waste.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

100 percent SwiftUI, Light. No UIViewRepresentable, no WKWebView, no Safari sheet, no camera preview, no TabView. The ui axis restates SwiftUI pure with take-token artquiz7: leftover closed-axis take, so compose an original ruined column, not a chip easel, not a canvas wall, not a lectern case, not a loupe hole, and not three equal cards. Do not copy holder file trees, type names, or layouts. Do not ship a title screen named Anathyrosis. Home is the mechanic: Quiz is the shaft filling remaining height and the iPad width, a photography-first hero tile of the Piece with the caption under the tile not on it, a spoil-heap rail of Drum stones, and one secondary ClampMark SpallMark stat. Scatter and Stack fuse on that column; Scatter does not auto-advance after Rebuilt. Confine custom drawing to that one Quiz hero (Shape, Path, one Material on the seated shaft); Explore, Saved, and Settings are stock sheets (List, Form). Taste is already Soft card daylight take artquiz3: kit radius 20 and radius_small 12, shadow elevation, soft-card controls, hero-rail 2+1, snap motion. Do not add a second glass UI kit or a second radius language. Soft shadow only on the hero tile; every other surface is flat fill. Primary Stack uses a ButtonStyle with default, pressed, disabled, and loading. resetAllData uses the destructive variant. Drums, dock, and sheet rows are native Buttons with contentShape, min 44pt, one target on the whole chrome. Empty Quiz (Waste), empty Explore, and empty Saved are full pages (frame maxHeight infinity) with generated cutout art, one headline, one line, and a bottom full-width CTA. Snap motion: press scale 0.97 in 140 to 180ms ease-out, sheets scale 0.96 to 1 plus fade; Reduce Motion is opacity only. Colour is never the only miss signal; a miss also leaves the Drum on the heap and does not grow the Shaft. One haptic on a successful ClampMark, none on SpallMark, none on presenting a sheet. VoiceOver labels on every icon-only sheet control. Warm voice, short display, no em dash, no emoji. The ui axis string is never a section title.

### 3.3 Naming contract

Convention: Anastylosis / column-drum lexicon.

Examples to follow: `Anastylosis`, `ClampMark`, `scatterPiece()`, `stackDrum()`

### 3.4 Dependency contract

None. project.yml has no packages key. No SPM, no CocoaPods, no bundled font. SF Pro is the system face. Foundation, SwiftUI, and URLSession only. The leftover AVCaptureMetadataOutput scanner stays unused: do not import AVFoundation or Vision for capture, do not request camera access, and do not ship NSCameraUsageDescription beyond the identity string that the app does not use the camera. Honor the cgi search pl assignment as paginated JSON search: query, json, page, page_size mapped onto GET https://api.vam.ac.uk/v2/objects/search with q, page, page_size, and images_exist=1. Never call world.openfoodfacts.org or /cgi/search.pl. Never call collectionapi.metmuseum.org or api.artic.edu. Never Open Food Facts, calories, meal slots, or a food catalog. Dedicated JSONDecoder with useDefaultKeys. DTO CodingKeys map V&A fields (systemNumber, accessionNumber, _primaryTitle, _primaryMaker, _primaryImageId) without convertFromSnakeCase, then map to domain Piece. Prefer a non-empty _primaryImageId with both a maker name and a title. IIIF thumbs use https://framemark.vam.ac.uk/collections/{_primaryImageId}/full/!400,/0/default.jpg. Object pages use https://collections.vam.ac.uk/item/{systemNumber}. Set User-Agent Anathyrosis/1.0 (iOS; +https://anathyrosis-shaft.pro) on every request. Debounce search about 500 ms, cancel the previous Task, empty query does not hit the network. Cache resolved pieces locally so empty or failed search still hangs from the bundled crate shelf. Settings credits the Victoria and Albert Museum as tappable source links (https://www.vam.ac.uk and https://www.vam.ac.uk/info/open-data).

### 3.5 Navigation contract

Shaft-locked chrome: Quiz is the root ruined column and never leaves. There is no TabView and no pushed museum detail. Scatter, Stack on a Drum, and Undo fuse on Quiz. Explore, Saved, and Settings arrive as sheets over the shaft. Four destinations, never exactly three tabs. App Intents open Quiz, Explore, Saved, or Settings, or fire stackDrum in place. Custom URL scheme anathyrosis routes anathyrosis://quiz, anathyrosis://explore, anathyrosis://saved, anathyrosis://settings, and the matching https://anathyrosis-shaft.pro paths into those same jobs. One haptic on a successful ClampMark, none on presenting a sheet. Contact URL https://anathyrosis-shaft.pro/contact-us lives on Settings. Undo is also reachable from Settings. After onboarding, read ProcessInfo.processInfo.arguments once: -ReviewScreen today stays on Quiz, log presents Saved, goals presents Settings. Extra key explore presents Explore. Skip onboarding on Simulator after the ahy.demo.v1 seed so the hook can fire.

### 3.6 Screen composition contract

Shaft-root fused quiz (Quiz holds the column and the spoil heap; Explore, Saved and Settings are sheets). Physical screens: Quiz, Explore, Saved, Settings. Quiz is the locked ruined column (ReviewScreen today): Scatter samples a Piece that is not Rebuilt and jumbles maker XOR title drums on the spoil heap; Stack seats the next true Drum; Undo peels the newest ClampMark or SpallMark; status shows Spoil, Laid, Rebuilt, Waste. Explore is a sheet that searches the Victoria and Albert Museum and writes a loose Piece, with a local crate shelf when search is empty or fails (deep link explore). Saved is a sheet of Rebuilt paintings plus ClampMarks and SpallMarks (ReviewScreen log). Settings is a Form for Victoria and Albert Museum credit, Undo, contact URL at https://anathyrosis-shaft.pro/contact-us, re-run onboarding, and resetAllData (ReviewScreen goals). Onboarding is a one-shot cover of three pages with Continue or Next at the bottom full width. Empty Quiz with no loose Piece is Waste as a full page: generated cutout art, headline Crate empty., one line Save a painting, then stack., full-width bottom Explore. Empty Explore and empty Saved are full pages of their own. Seeded Quiz already shows a jumbled inscription so the first Drum tap can stack; Waste is a test fixture, not the first frame. No Today, Scan, Search, or Goals screens. ReviewScreen today, log, and goals must open three different screens.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By shaft role (Shaft, Piece, Drum, ClampMark, SpallMark, Spoil)**

```
Anathyrosis/
  Shaft/
  Shaft.swift
  Anastylosis.swift
  ShaftStore.swift
  QuizView.swift
  ShaftLinks.swift
  SettingsView.swift
Piece/
  Piece.swift
  ExploreView.swift
  SavedView.swift
  CatalogClient.swift
  CrateShelf.swift
Drum/
  Drum.swift
ClampMark/
  ClampMark.swift
SpallMark/
  SpallMark.swift
Spoil/
  Spoil.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Explore
A first-class screen for **Explore**. Must render empty, populated and error states.

### 5.3 Saved
A first-class screen for **Saved**. Must render empty, populated and error states.

### 5.4 Quiz
A first-class screen for **Quiz**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Work** — named per this app's convention.
- **QuizCard** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **Soft card daylight · take artquiz3**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#FAF7F5` | Screen background |
| `surface` | `#FEFEFD` | Cards, rows, sheets |
| `ink` | `#392818` | Primary text and icons |
| `accent` | `#CC6D19` | Primary action, key figure, progress fill |
| `muted` | `#816C5A` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **SF Pro**

SF Pro via Font.system as the hospitable short-display type move from Soft card daylight: display is at most four words (Stack, Scatter, Waste), tight leading, one or two lines, about 2x body, never above 34pt. Body is about 17pt under the photo tile for Drum words and the seated shaft line. Caption sits under the painting tile, not on it, and names Spoil, Laid, Rebuilt, Waste. At most six named steps behind one accessor: display, title, headline, body, caption, micro. Weights and step carry hierarchy. No Font.custom, no fixedSize, never below 12pt, no serif, no second family. ClampMark counts, SpallMark counts, and day keys go through NumberFormatter with tabular figures. Dynamic Type; at AX5 Stack may drop a step so it never clips; names truncate, numbers win. Day edges use Calendar.current.startOfDay then fold to Int YYYYMMDD.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **20pt** for cards, sheets and primary surfaces; **12pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **soft card** — primary actions live inside a rounded card using the radius below, not a flat row with no fill.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI pure · take artquiz7**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI pure · take artquiz7** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

### 7.6 Taste DNA

Aesthetic: **warm** (Warm soft: friendly radii, comfortable pad, one playful moment.)

Reference system: **airbnb** — steal rhythm and restraint, not their colours or logos.

Mood: **hospitable**.

Home rhythm (`hero-rail`, comfortable): One large photo-tile mechanic, a recent rail, one secondary stat. Uneven 2+1.

Photography-first home. Caption sits under the tile, not on it. Pill CTA. Soft shadow only on the hero; every other surface is flat fill.

Type move: Short display (max four words), tight leading, small body under it.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable**

One Codable ShaftDocument (schemaVersion from 1, Pieces with Anastylosis Spoil Laid or Rebuilt, Drums, ClampMarks, SpallMarks, cached catalog rows, daykeys as Int YYYYMMDD) encoded to JSON Data in UserDefaults under ahy.shaft.v1. Anastylosis case is stored; rebuilt-ness is not a parallel bool. In-memory ShaftStore is the source of truth; UserDefaults is the projection. Views never touch UserDefaults. Debounce writes. Flush when scenePhase becomes inactive or background, and after Scatter, Stack, SpallMark, Undo, Explore save, or reset. Decoding failure falls back to ahy.shaft.v1.backup, then an empty shaft, never a crash. resetAllData() is reachable from Settings. Tests use a private UserDefaults suite. Simulator seed only once behind ahy.demo.v1 writes several Pieces from the local crate shelf, a mix of Spoil Laid and Rebuilt, several SpallMarks so Saved is a used product, lays one multi-word inscription already jumbled so Stack is live, marks onboarding complete, and never seeds Waste as the first frame. Never seed on a device. Cached pieces catch empty or failed V&A search.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Anathyrosis/1.0 (iOS; +https://anathyrosis-shaft.pro)` on every request. Never reuse another app's string.
Use the **cgi search pl** search endpoint for this app.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.education`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.education
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Scatter-then-stack (Scatter samples a Piece that is not Rebuilt; Drums are maker XOR title in shuffled order; Stack writes a ClampMark when the tapped Drum is the next word and seats it; a miss writes a SpallMark and keeps the Shaft; Stack on Spoil is refused; empty shaft writes Waste)

Home is stack-the-drum: Scatter pulls one loose Piece and splits either the maker name or the picture title into drums, jumbles those drums on the spoil heap, and the restorer seats them in reading order, not a name-chip pick and not a one-hole patch. Stacking the next true drum writes a ClampMark and seats that stone on the shaft; a drum out of order writes a SpallMark and stays on the heap; Stack on Spoil is refused; a second Scatter while Laid is refused. The last true Stack folds Laid to Rebuilt so that painting leaves Scatter and sits on Saved; misses stay reviewable as SpallMarks. Explore only stocks loose Pieces from the Victoria and Albert Museum or the local crate shelf; a repeated object id focuses that row; Undo peels the newest ClampMark or SpallMark; Scatter on an empty crate writes Waste; Simulator seed already shows a jumbled inscription so the opening tap can seat a drum. Saved lists ClampMarks and SpallMarks; Settings credits the Victoria and Albert Museum; grades, a shop, and a WebView museum stay out.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **3D glass render glassmorphism · take artquiz7**


This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

Base prompt, reused and extended for every asset:

```
3D glass render, glassmorphism, studio-lit ruined column, seated stone drums, spoil heap of loose drums, refraction and soft bloom, isolated subjects, quiet uncluttered ground, hospitable daylight not a museum grid, no text, no letters, no logo, no photoreal stock, no specified colours, one shaft and a heap not a chip easel and not a canvas wall
```

All 15 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `ahy_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `ahy_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `ahy_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `ahy_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `ahy_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `ahy_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `ahy_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `ahy_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `ahy_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `ahy_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `ahy_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Scatter-then-stack (Scatter samples a Piece that is not Rebuilt; Drums are maker XOR title in shuffled order; Stack writes a ClampMark when the tapped Drum is the next word and seats it; a miss writes a SpallMark and keeps the Shaft; Stack on Spoil is refused; empty shaft writes Waste)' feature screen. |
| 11 | `ahy_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `ahy_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |
| 13 | `ahy_ColumnDrum` | 1024x1024 | **required cutout** | Isolated solid marble column drum, cutout, transparent corners, opaque stone filling the center, no plate, no hollow frame, no text |
| 14 | `ahy_SpoilHeap` | 1024x1024 | **required cutout** | Isolated solid pile of stone drums, cutout, opaque masonry, transparent corners, no plate, no text |
| 15 | `ahy_IronClamp` | 1024x1024 | **required cutout** | Isolated solid iron clamp, cutout, opaque metal, transparent corners, no plate, no text |

### Prompt per asset

**`ahy_AppIcon`** — 1024x1024

```
A single 3D glass ruined column drum, glassmorphism, subject centred filling the canvas edge to edge, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas
```

**`ahy_Splash`** — 1290x2796

```
A tall vertical 3D glass ruined column, seated drums receding, quiet uncluttered centre band for a wordmark, glassmorphism, no readable text
```

**`ahy_Onboarding1`** — 1024x1536

```
Solid stone column drum on a spoil heap, the product in one glance, isolated cutout, opaque subject in the center, transparent corners, no glass box, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_Onboarding2`** — 1024x1536

```
A hand seating one solid stone drum onto a short shaft, scatter then stack, isolated cutout, opaque subject in the center, no hollow frame, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_Onboarding3`** — 1024x1536

```
A rebuilt stone shaft of seated drums, isolated cutout, opaque masonry in the center, transparent corners, no plate, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_EmptyHome`** — 1024x1024

```
A solid closed stone drum waiting to be seated, opaque masonry, isolated cutout, transparent corners, not glass, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_EmptyList`** — 1024x1024

```
A solid empty wooden crate, isolated cutout, opaque wood filling the center, transparent corners, no plate, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_CardBackdrop`** — 1200x800

```
An abstract soft daylight field behind a ruined column, low contrast so text stays readable, fill the canvas, glassmorphism bloom, no readable text, no specified colours
```

**`ahy_ControlFace`** — 512x512

```
The face of a single solid stone column drum, isolated cutout, opaque stone, transparent corners, no plate, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_TwistHero`** — 1024x1024

```
A ruined column beside a spoil heap of loose drums, isolated cutout, opaque stone filling the center, transparent corners, no hollow frame, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_SuccessMark`** — 512x512

```
A solid iron clamp ring, isolated cutout, opaque metal, transparent corners, no plate, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_HeaderDecor`** — 1200x600

```
A wide solid stone entablature band, isolated cutout, opaque masonry, transparent corners, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_ColumnDrum`** — 1024x1024

```
Isolated solid marble column drum, cutout, transparent corners, opaque stone filling the center, no plate, no hollow frame, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_SpoilHeap`** — 1024x1024

```
Isolated solid pile of stone drums, cutout, opaque masonry, transparent corners, no plate, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ahy_IronClamp`** — 1024x1024

```
Isolated solid iron clamp, cutout, opaque metal, transparent corners, no plate, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`ahy.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `AnathyrosisTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Anathyrosis -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Anastylosis ADT fold (Spoil | Laid | Rebuilt); the shaft is a fold over Pieces; Scatter writes Drums as maker XOR title in shuffled order and folds Spoil to Laid; Stack writes a ClampMark when the tapped Drum is the next word and seats it on the Shaft; a miss writes a SpallMark and keeps the Shaft; the last true Stack folds Laid to Rebuilt; Stack on Spoil is refused; a second Scatter while Laid is refused; Scatter samples a Piece that is not Rebuilt; empty shaft writes Waste** with no leakage across layers.
- [ ] UI approach matches **SwiftUI pure · take artquiz7**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Shaft-locked chrome (the ruined column never leaves; Explore, Saved and Settings arrive as sheets; scatter and stack fuse on Quiz)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **SF Pro** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Anathyrosis
xcodegen generate
xcodebuild -scheme Anathyrosis -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcrun simctl list devices available
xcodebuild -scheme Anathyrosis -destination 'platform=iOS Simulator,id=<UDID>' test
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY or DEVELOPMENT_TEAM in project.yml — CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
