<!-- gf-brief source=17e30ec59235461a5b934c5b5553ee954b472283ca88cc059bb82c3300d655a0 written=2026-09-30T08:28:16+03:00 -->
# Spindak
## What it is
Spindak is a word-stacking exercise for people who want to rebuild a painting’s title or the painter’s name from loose stones. You save works from the Victoria and Albert Museum onto this device, scatter those words onto a heap, and tap them in reading order on the shaft. Home is that ruined column, not a museum walk.

## Launch and onboarding
On a cold launch there is a pause with no words. It can last several seconds. Light appearance only.

During that pause a system tracking prompt can appear. Its usage string is “We use this identifier to personalize your experience and measure app performance.”

After the pause a full-screen splash picture shows. It has no words.

The first time, three onboarding pages cover the screen. Page dots are announced as “Page 1 of 3”, “Page 2 of 3”, or “Page 3 of 3”.

1. Headline “Save a painting.” Line “Keep Victoria and Albert Museum files on this device. Home is the ruined column, not a museum walk.” Top right “Skip” (VoiceOver: “Skip onboarding”). Bottom “Next”.
2. Headline “Scatter the drums.” Line “Scatter splits maker or title into stones. Only the order is wrong. Extras stay out.” Top right “Skip”. Bottom “Next”.
3. Headline “Stack in order.” Line “The next true drum seats. A miss stays on the heap. Undo peels the newest mark.” No Skip. Bottom “Continue”.

“Skip” and “Continue” both end onboarding and open the shaft. “Next” only advances the page.

Later cold launches skip these pages and open the shaft after the pause and splash. “Replay the first pages” on Progress plays them again. “Erase saved paintings” also returns to these pages. If saved progress could not be read, the first pages can play again and the shaft then shows the recover line.

## Screens
There is no tab bar. The shaft stays put. Explore, Saved, Settings, and Scatter then stack open over it (a sheet on iPhone; full screen on a wide iPad).

Siri and Shortcuts phrases (the name is “Spindak”): “Open Quiz in Spindak”, “Stack the drum in Spindak”, “Open Explore in Spindak”, “Open Saved in Spindak”, “Open Settings in Spindak”, “Stack a drum in Spindak”, “Scatter then stack in Spindak”. Shortcut titles: “Open Quiz”, “Open Explore”, “Open Saved”, “Open Settings”, “Stack a drum”, “Open scatter then stack”. Short titles: “Quiz”, “Explore”, “Saved”, “Settings”, “Stack”, “Scatter”. “Open Quiz” shows the shaft. “Stack a drum” / “Stack the drum” seats the next true word if a job is already open.

### The shaft
No navigation title. The headline and line change with the job.

Icon buttons across the top (VoiceOver labels; no visible text):
- “Explore” — opens Save a painting.
- “Saved” — opens Saved paintings.
- “Open another painting” — opens Scatter then stack.
- “Settings” — opens Progress.

These four icons stay on the empty crate page as well.

**Crate empty (no job on the shaft).** Headline “Crate empty.” Line “Save a painting, then stack.” Bottom “Explore” opens Save a painting. If saved progress failed to load instead: headline “Progress did not load.” Line “Saved progress did not load. Start from Explore.” Same “Explore” button.

**A painting is saved but not yet opened.** Headline “Open a painting.” Line “Open a painting to start.” Picture tile (placeholder title “Painting” if the title is missing; VoiceOver on the picture is the title while you work, or “title, maker” after you finish). Caption may show the title. Heap plate “Open a painting. The words wait here.” Counts “0 named” and “0 missed” (the numbers follow the device’s grouping; VoiceOver: “0 named, 0 missed”). Bottom “Open a painting” (dimmed when there is no loose painting left) and “Undo” (dimmed until there is a mark to peel). Hint on “Open a painting”: “Open a loose painting into words”. Hint on “Undo”: “Undo the newest named or missed word”.

**Words are on the heap.** Headline “Name this painting” when the stones are the title, or “Name the painter” when they are the painter’s name. Line “Tap the next word of the title.”, “Tap the next word of the painter.”, or “Tap the next word.” Picture of the work. While you are naming the title, the title is hidden under the picture. The painter’s name stays hidden until the work is finished, except for a short reveal after a correct tap. Section “Words” shows every stone; each stone is the word itself (VoiceOver: “Drum” plus that word; hint “Stack this stone if it is next”). A correct tap seats that word and it leaves the heap. A wrong tap leaves it there and shows “That drum stays on the heap.” After the first named or missed word, “Undo” appears. “Open a painting” is hidden while this job is open. Counts “N named” and “N missed” (VoiceOver: “N named, N missed”). A correct tap also gives a light haptic.

**You finished the words.** Headline “You named it”. Line “Open another painting when you want.” Title and painter show under the picture. Heap plate “You named this work. Open another painting when you want.” Bottom “Open another” and “Undo”. A “Named paintings” rail of up to six finished works appears; tapping a thumbnail opens Saved paintings (VoiceOver on a thumbnail is the painting’s title).

A fault line can appear on the shaft: “Write failed. Scatter or Stack again.”, “That drum stays on the heap.”, “Scatter a painting first.”, “Finish this shaft first.”, “Need two words to scatter.”, “That drum is not on this heap.”, “That drum is next. Stack it.”, “That drum is already seated.”, “Nothing to undo.”, “This painting has no object id.”, “That painting is not in the crate.”, or “Saved progress did not load. Start from Explore.”

On a wide iPad in regular width (and not at accessibility type sizes) the picture sits in a left column and the words, counts, and buttons sit on the right. Otherwise the shaft scrolls as one column.

### Save a painting
Title “Save a painting”. Close control (VoiceOver: “Close”) returns to the shaft. Line “Search the Victoria and Albert Museum, then save a loose painting.” Field “Search a painting”. Keyboard “Done” dismisses the keyboard. A spinner shows while search is running.

Each hit shows the painting’s title, the maker, and either “Save” or “In the crate”. Tap saves that work as a loose painting, or brings an already-saved one forward. After a tap: “Saved as loose spoil.” or “That painting is already in the crate.” The page does not close by itself. Rows do not accept another tap until the current save finishes. VoiceOver on a row is “title, maker”.

When the field is empty, a fixed shelf of museum paintings is listed (see Starter content). A live search that finds nothing, or that cannot reach the museum, usually still shows that shelf, often with no extra miss line. These lines can also appear under the field or on the empty page: “The museum had no match. The crate shelf is here.”, “Search could not reach the museum. The crate shelf is here.”, “The museum refused the search. The crate shelf is here.”, “Search could not be read. The crate shelf is here.”, “Search stopped.”

If the list is empty and there is a fault: headline “Search paused.”, the fault line or “Search could not reach the museum. The crate shelf is here.”, button “Try again”. If the list is empty with no fault: headline “The crate is quiet.” Line “Search the museum, then save a painting.” Button “Show the shelf” clears the field and shows the shelf.

### Saved paintings
Title “Saved paintings”. Close (VoiceOver: “Close”) returns to the shaft.

Empty: headline “Nothing rebuilt yet.” Line “Stack the drums, then look here.” Button “Back to the shaft”. This empty page still shows after you have only saved works and have not yet named or missed a word.

When there is something to show, three sections can appear.

**Rebuilt.** Each row is the painting’s title, the maker, and a date like “2026.09.30” (the day the work was saved into the crate). VoiceOver: “{title}, {maker}, rebuilt {date}”. Tap opens a page titled “Rebuilt” with the picture, the title (or “Painting”), the maker, and that date.

**Named.** A row such as “You named a word on {title}.” or “You named N words on {title}.” (or “You named a word on a painting.” / “You named N words on a painting.” if the title is missing). Line “One correct word on this painting.” or “N correct words on this painting.” plus the date of the newest named word on that work. Tap opens a page titled “Clamp”: headline “You named a word on {title}.”, line “You named the word {word} in the maker.” or “You named the word {word} in the title.”, stamp “Clamp” plus the date.

**Missed.** A row such as “You missed a word on {title}.” or “You missed N words on {title}.” (or “You missed a word on a painting.” / “You missed N words on a painting.”). Line “One missed word on this painting.” or “N missed words on this painting.” plus the date. Tap opens a page titled “Spall”: headline “You missed a word on {title}.”, line “You missed the word {word} in the maker.” or “You missed the word {word} in the title.”, stamp “Spall” plus the date.

On a wide iPad, Rebuilt and Named sit in one list and Missed in the other.

### Scatter then stack
Title “Scatter then stack”. Close (VoiceOver: “Close”) returns to the shaft. Headline “Scatter then stack”. Line “Scatter pulls one loose painting and jumbles maker or title into drums. Stack the next true drum. A miss stays on the heap.”

A status plate shows “Waste”, “Spoil”, “Laid”, or “Rebuilt”, plus the same next-tap line as the shaft. If the shaft is already Laid, the same “Words” stones appear here.

Bottom button: “Scatter” when no job is open (dimmed when there is no loose painting). It opens one loose painting into words, then closes this page. “Back to the shaft” when a job is already open; it only dismisses.

### Progress
Title “Progress”. Close (VoiceOver: “Close”) returns to the shaft.

If you have not saved a painting yet, an extra line: “Museum credit and Undo live here once you save a painting.” The rest of the form still shows.

If progress failed to load: “Saved progress did not load. Start from Explore.” A fault from the shaft can repeat here. A write-failed notice can also appear.

**Source.** Header “Source”. “Victoria and Albert Museum”. “Paintings stay on this device. Search uses the museum collection.” “Museum site” opens the museum in the system browser. “Open data” opens the museum’s open-data page in the system browser.

**Score.** Header “Score”. “Named” with a count. “Missed” with a count. “Undo” peels the newest named or missed word; it is dimmed when there is nothing to peel.

**Contact.** Header “Contact”. “Write to us” opens the support page.

**Reset.** Header “Reset”. “Replay the first pages” closes Progress and shows onboarding again; saved paintings stay. “Erase saved paintings” opens a confirmation titled “Erase saved paintings” with message “Named paintings and word marks leave this device.” Buttons “Erase saved paintings” (destructive) and “Keep paintings”. Confirming wipes the crate and marks, then returns to onboarding.

## Features
- Save a painting from the Victoria and Albert Museum into the crate
- Search a painting in that museum collection
- A crate shelf of museum works when search is empty or cannot reach the museum
- Scatter the drums: one loose painting, maker or title split into stones, only the order is wrong, extras stay out
- Stack in order: tap the next true drum; a miss stays on the heap
- Name this painting or Name the painter
- Named and missed word marks
- Undo peels the newest mark
- Rebuilt paintings on Saved paintings
- Named paintings rail on the shaft after works are finished
- Progress counts for Named and Missed
- Replay the first pages
- Erase saved paintings
- Write to us
- Museum site and Open data
- Shortcuts phrases: “Open Quiz in Spindak”, “Stack the drum in Spindak”, “Open Explore in Spindak”, “Open Saved in Spindak”, “Open Settings in Spindak”, “Stack a drum in Spindak”, “Scatter then stack in Spindak”

## Behaviours that can look like bugs
- **Blank launch.** A pause with no words can last several seconds before the splash. Wait. A tracking prompt can sit on top of that pause.
- **“Crate empty.” / “Save a painting, then stack.”** Nothing to stack until you save a work. Tap “Explore”, search or use the shelf, tap “Save”, then Close. If every loose painting has fewer than two words in both the title and the painter’s name, “Open a painting” still accepts a tap and home can become “Crate empty.” even though those works stay in the crate (“In the crate” on Save a painting). Save a work with at least two words in the title or the painter’s name.
- **“Open a painting” dimmed** when there is no loose painting left (every saved work is already named). Save another painting.
- **“Open a painting” hidden** once a job is Laid. You cannot skip to another work until every stone is seated. Finish the words, or use “Undo”, or “Erase saved paintings”.
- **“Finish this shaft first.”** A second scatter is refused while words are still on the heap. Finish or undo.
- **“That drum stays on the heap.”** A wrong word does not disappear and can be tapped again (another miss). Tap the next word of the title or the painter.
- **Title or painter missing under the picture** while you are naming that field. That is the exercise. They return when the headline is “You named it”, and briefly after a correct tap. VoiceOver may still speak the title while it is hidden on screen.
- **“Nothing rebuilt yet.”** on Saved paintings even after you saved works. Saved stays empty until you name or miss a word. Stack the drums, then look here.
- **“Museum credit and Undo live here once you save a painting.”** on Progress until the first save. Source, Score, Contact, and Reset are still there.
- **“Undo” dimmed** until you have named or missed a word. “Nothing to undo.” if you tap it with an empty peel list.
- **“In the crate”** still accepts a tap and then shows “That painting is already in the crate.” The work is not saved twice.
- **Search with no museum match** can fall back to the crate shelf without a miss line. Live search also waits a moment after each keystroke. “Show the shelf” clears the field and lists the shelf on purpose.
- **“Search paused.” / “Try again”** when the list is empty and search failed. Tap “Try again”, or “Show the shelf”.
- **Word stones dim** while one tap is finishing. Wait.
- **Save rows dim** while one painting is being written. Wait for “Saved as loose spoil.” The page stays open until you Close.
- **Finished work does not open the next painting by itself.** Tap “Open another” when you want. After the last loose painting is named, “Open another” stays dimmed until you save another work. Home stays on “You named it”; it does not jump back to “Crate empty.”
- **Undo after “You named it”** puts the last seated word back on the heap and the headline returns to “Name this painting” or “Name the painter”.
- **“Replay the first pages”** loops back to onboarding on purpose. Skip or Continue returns to the shaft with paintings still there.
- **“Erase saved paintings”** then onboarding is a full reset, not a crash.
- **“Saved progress did not load. Start from Explore.”** Use Explore and save again. Named and missed counts may be gone. The first pages may play again.
- **“Write failed. Scatter or Stack again.”** Repeat Scatter, a word tap, or Undo.
- **“Scatter a painting first.”** can appear if “Stack a drum” runs before any words are on the heap.
- **Picture tiles can stay a flat colour** until the museum image loads. The crate shelf and already-saved works do not need a live search, but their pictures still need a network.
- **Dates on Rebuilt rows** are the day the painting was saved, not the day you finished naming it.
- **Words keep punctuation** attached after a space split. There are no extra decoy stones; “extras stay out” means only the real words of that title or painter name are on the heap.
- Live search needs a network. The crate shelf and already-saved works do not.

## Starter content and resume
When “Search a painting” is empty, or search cannot reach the museum, these shelf works appear (title, then maker):

- “Salisbury Cathedral from the Close”, “John Constable”
- “Venice from the Giudecca”, “Joseph Mallord William Turner”
- “The Day Dream”, “Dante Gabriel Rossetti”
- “Pizarro Seizing the Inca of Peru”, “John Everett Millais”
- “Branch Hill Pond Hampstead”, “John Constable”
- “East Cowes Castle”, “Joseph Mallord William Turner”
- “Gillingham Mill Dorset”, “John Constable”
- “Line Fishing Off Hastings”, “Joseph Mallord William Turner”
- “Golding Constable House East Bergholt”, “John Constable”
- “Elizabeth Siddal”, “Dante Gabriel Rossetti”

They are not in the crate until you tap “Save”. On a device there are no pre-saved paintings and no pre-stacked words.

Unfinished work resumes. A Laid heap, seated words, the crate, named and missed marks, and the onboarding flag stay on this device after you leave the app. Open it again and the same shaft is there.

## Permissions
Tracking. Asked on cold launch (and again when the app becomes active, if the system has not already recorded an answer). Usage string: “We use this identifier to personalize your experience and measure app performance.”

The app never asks for camera, photos, microphone, or location.

## Absent
Genuinely absent: login or accounts, in-app purchase, ads, user-generated content (no posting or profiles; you only save museum works and local word marks), account deletion flow.

Not absent: App Tracking Transparency prompt; the app also measures performance and personalizes the experience, as that prompt says.

## Data and support
Paintings, named and missed marks, and shaft progress stay on this device. Search uses the museum collection.

On-screen support is “Write to us” under “Contact” on Progress. It opens the support page.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show health, medical, or product-health information.

## Platform
English copy only; no other language files. No in-app region or country switch. Counts use the device locale. Dates on saved rows look like “2026.09.30”. Search is the Victoria and Albert Museum collection and needs a network for live results.

Portrait only, light appearance, full screen. iPhone and iPad. Not for Mac. Not for Apple Vision. Minimum iOS 17.0.

## Category
Education
