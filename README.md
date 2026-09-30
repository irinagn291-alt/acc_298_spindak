# Anathyrosis

Tap drums in order to rebuild a painting's maker or title.

Anathyrosis is for people who remember a painting and want to seat its inscription from loose stones. Home is the ruined column. Explore, Saved, and Settings stay sheets around that shaft. There is no shop, no grade field, and no Game tab.

## Who it is for

Someone who saved a Victoria and Albert Museum painting and wants to rebuild the maker name or the picture title from a jumble of drums. Not a name-chip pick. Not a one-hole patch. Every word is already on the spoil heap. Only the order is wrong.

## Architecture

The shaft is an Anastylosis fold over Pieces: Spoil, Laid, Rebuilt. A fourth case is a defect.

- Scatter samples one saved Piece that is not Rebuilt, splits maker XOR title on whitespace, shuffles those drums onto the spoil heap, and folds Spoil to Laid.
- Scatter with no loose Piece writes Waste. A second Scatter while Laid is refused.
- Stack writes a ClampMark when the tapped Drum is the next word and seats that stone. A miss writes a SpallMark, keeps the Shaft, and leaves that Drum on the heap.
- Stack on Spoil is refused. The last true Stack folds Laid to Rebuilt so the painting leaves Scatter and sits on Saved.
- Undo peels the newest ClampMark or SpallMark.

One observable ShaftStore pattern-matches the fold. Views call `scatterPiece`, `stackDrum`, `missDrum`, and `peelNewestMark`. They never keep a second shaft enum.

This fold fits the product because the job is seating stones in reading order. A list of saved works without a fold is a crate. A quiz that hides the words is a different family.

Persistence is UserDefaults plus Codable. Day edges use `Calendar.current.startOfDay` and fold to Int YYYYMMDD.

## Why pick this app

Scatter-then-stack is the reason. Home already shows the heap. Scatter pulls one loose Piece and jumbles maker or title into drums. The restorer seats them in reading order. Stacking the next true drum writes a ClampMark and grows the shaft. A drum out of order writes a SpallMark and stays on the heap. Simulator seed already shows a jumbled inscription so the first tap can seat a drum.

That fold is persisted, unit-tested, and visible on Quiz. It is not a Settings flourish.

## How this differs from others in the batch

Home is stack-the-drum. Every word of the maker name or the picture title is already visible. Extras stay out. Minium hides a rubric and inks letters from a case that includes decoys. Tratteggio punches one hole and offers replacement chips. Athetesis asks the user to find an interpolated word. This product seats drums from the bottom of a column until the inscription reads, then files the painting as rebuilt.

Chrome is shaft-locked: Quiz never leaves. Explore, Saved, and Settings arrive as sheets. Four destinations. No TabView. `-ReviewScreen today|log|goals` are launch keys, not tabs. After onboarding, `ProcessInfo` reads those keys once: today stays on Quiz, log presents Saved, goals presents Settings. Extra key explore presents Explore.

## Design

Soft card daylight. Warm, hospitable, photography-first. Tokens live in Assets.xcassets and are reached through ShaftInk, ShaftType, ShaftSpace, ShaftRadius, and ShaftLift. Cards and sheets use 20pt. Chips use 12pt. Soft shadow sits only on the Quiz hero. Every other surface is flat fill.

Custom drawing is confined to the Quiz hero (`SeatedShaftDraw`). Explore, Saved, and Settings are stock List and Form sheets.

## AI art

Style: 3D glass render, glassmorphism. Assets are generated later by `assets.generate`. Image sets are named here with the `ahy_` prefix. Recorded prompts match SPEC section 13.

Base prompt, reused and extended:

```
3D glass render, glassmorphism, studio-lit ruined column, seated stone drums, spoil heap of loose drums, refraction and soft bloom, isolated subjects, quiet uncluttered ground, hospitable daylight not a museum grid, no text, no letters, no logo, no photoreal stock, no specified colours, one shaft and a heap not a chip easel and not a canvas wall
```

**ahy_AppIcon** (1024x1024, no alpha)

```
A single 3D glass ruined column drum, glassmorphism, subject centred filling the canvas edge to edge, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas
```

**ahy_Splash** (1290x2796, fill)

```
A tall vertical 3D glass ruined column, seated drums receding, quiet uncluttered centre band for a wordmark, glassmorphism, no readable text
```

**ahy_Onboarding1** (1024x1536, cutout)

```
Solid stone column drum on a spoil heap, the product in one glance, isolated cutout, opaque subject in the center, transparent corners, no glass box, no text
```

**ahy_Onboarding2** (1024x1536, cutout)

```
A hand seating one solid stone drum onto a short shaft, scatter then stack, isolated cutout, opaque subject in the center, no hollow frame, no text
```

**ahy_Onboarding3** (1024x1536, cutout)

```
A rebuilt stone shaft of seated drums, isolated cutout, opaque masonry in the center, transparent corners, no plate, no text
```

**ahy_EmptyHome** (1024x1024, cutout)

```
A solid closed stone drum waiting to be seated, opaque masonry, isolated cutout, transparent corners, not glass, no text
```

**ahy_EmptyList** (1024x1024, cutout)

```
A solid empty wooden crate, isolated cutout, opaque wood filling the center, transparent corners, no plate, no text
```

**ahy_CardBackdrop** (1200x800, fill)

```
An abstract soft daylight field behind a ruined column, low contrast so text stays readable, fill the canvas, glassmorphism bloom, no readable text, no specified colours
```

**ahy_ControlFace** (512x512, cutout)

```
The face of a single solid stone drum, isolated cutout, opaque stone, transparent corners, no plate, no text
```

**ahy_TwistHero** (1024x1024, cutout)

```
A ruined column beside a spoil heap of loose drums, isolated cutout, opaque stone filling the center, transparent corners, no hollow frame, no text
```

**ahy_SuccessMark** (512x512, cutout)

```
A solid iron clamp ring, isolated cutout, opaque metal, transparent corners, no plate, no text
```

**ahy_HeaderDecor** (1200x600, cutout)

```
A wide solid stone entablature band, isolated cutout, opaque masonry, transparent corners, no text
```

**ahy_ColumnDrum** (1024x1024, cutout)

```
Isolated solid marble column drum, cutout, transparent corners, opaque stone filling the center, no plate, no hollow frame, no text
```

**ahy_SpoilHeap** (1024x1024, cutout)

```
Isolated solid pile of stone drums, cutout, opaque masonry, transparent corners, no plate, no text
```

**ahy_IronClamp** (1024x1024, cutout)

```
Isolated solid iron clamp, cutout, opaque metal, transparent corners, no plate, no text
```

## Build

Requires Xcode 16 or later, iOS 17.0, Swift 6.2. No packages.

```bash
cd Anathyrosis
xcodegen generate
xcodebuild build-for-testing -scheme Anathyrosis -destination 'generic/platform=iOS Simulator'
xcodebuild -scheme Anathyrosis -destination 'generic/platform=iOS' build
```

Simulator seed uses the versioned key `ahy.demo.v1` and marks onboarding complete. Device never writes that seed.

Launch keys after onboarding:

- `-ReviewScreen today` stays on Quiz
- `-ReviewScreen log` presents Saved
- `-ReviewScreen goals` presents Settings
- `-ReviewScreen explore` presents Explore

Contact: https://anathyrosis-shaft.pro/contact-us
