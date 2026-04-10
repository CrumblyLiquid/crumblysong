/// Song and song sections

#import "transpose.typ": transpose_state

#let verse_counter = counter("verse")
#let chorus_counter = counter("chorus")
#let bridge_counter = counter("bridge")

/// Creates the song scaffolding
///
/// It inserts the heading with title,
/// author + various other information
/// and sets up the the different
/// section counters and transposition state
///
///  Usage:
///  ```typst
///  #show: doc => song(
///    title: "Čarodějnice z Amesbury",
///    author: "Asonance",
///    doc,
///  )
///  ```
///
/// - title (str):
/// - author (str):
/// - capo (int):
/// - transpose (int):
/// - note (content):
/// - cols (int):
/// - col_gutter (length):
/// - font_size (length):
/// - line_spacing (length):
/// - doc (content):
/// -> content
#let song(
  title: none,
  author: none,
  capo: 0,
  transpose: 0,
  note: [],
  cols: 1,
  col_gutter: 1em,
  font_size: 1em,
  line_spacing: 0.65em,
  doc,
) = context {
  // Reset section counters
  verse_counter.update(1)
  chorus_counter.update(1)
  bridge_counter.update(1)

  // Transposition information
  let transpose_amount_text = if transpose == 0 {
    none
  } else if transpose > 0 {
    [+#transpose]
  } else {
    transpose
  }
  let transpose_text = [Transponováno:]
  let transpose_text = if transpose_amount_text == none {
    hide(transpose_text)
  } else { transpose_text }

  // Capo position information
  let capo = if capo == 0 {
    none
  } else {
    capo
  }
  let capo_text = [Capo:]
  let capo_text = if capo == none {
    hide(capo_text)
  } else { capo_text }

  // Header of the song
  // (contains song title, author, capo and transposition information and note)
  block(
    inset: (x: 1em),
    grid(
      align: (auto, center, right + bottom),
      // Split into 3 columns with the song title in the center
      columns: (1fr, auto, 1fr),
      column-gutter: 1em,
      // Left column (note)
      note,
      // Center column (title and author)
      align(center, stack(
        spacing: 0.55em,
        text(size: 1.15em, heading(depth: 2, title)),
        align(center + top, text(
          weight: "light",
          style: "italic",
          size: 0.65em,
        )[
          #author
        ]),
      )),
      // Right column (capo and transposition)
      align(horizon + right)[
        #set text(fill: gray.darken(50%))

        // Aligns the text and numbers
        // nicely into a table/grid
        #grid(
          align: right,
          rows: 2,
          row-gutter: 0.40em,
          columns: 2,
          column-gutter: 0.25em,
          capo_text, [#capo],
          transpose_text, [#transpose_amount_text],
        )
      ],
    ),
  )
  // Small space between the header and the song content
  v(0.25em)
  // The actual song content
  // TODO: Don't use columns if they're not required
  pad(
    x: 5%,
    columns(cols, gutter: col_gutter, [
      // Set transposition state
      #if transpose != none {
        transpose_state.update(transpose)
      }

      // Commonly used settings to
      // make a long song fit into
      // (usually) one page
      #set text(size: font_size)
      #set par(leading: line_spacing)
      #doc

      // Reset the transposition state (just to be safe)
      #transpose_state.update(0)
    ]),
  )
  pagebreak()
}

/// Generic song section builder
/// (it's expected to use on of the prepared ones
///  like verse, chorus, bridge, etc.)
///
/// Song section has two parts:
///   - section label
///   - section content
///
/// Section label is the part on the left that
/// identifies what section the content belongs to
/// (e.g. `Ch:` for chorus, plain numbering for verses, etc.)
///
/// Section content refers to the actual lyrics with chords.
///
/// - numbered (bool): Enable numbering
/// - counter (any): Counter to use for numbering
/// - numbering (str,function): Numbering formatting
/// - prefix (content): Content before the numbering
/// - suffix (content): Content after the numbering
/// - gutter (length): Space between section label
///                    and section content (the `doc` parameter)
/// - spacing (length): Offset of the section label to account
///                     for the chord on the first line shifting
///                     the baseline
/// - indicator_style (function): Function to be applied to the section label
/// - text_style (function): Function to be applied to the section content
/// - doc (content): Content of the song section
/// -> content
#let section(
  ref: none,
  numbered: true,
  counter: none,
  numbering: "1.",
  prefix: none,
  suffix: none,
  gutter: .75em,
  spacing: 0.3em,
  indicator_style: doc => {
    text(weight: "bold", doc)
  },
  text_style: doc => {
    doc
  },
  doc,
) = context {
  if ref == none and numbered and counter != none {
    counter.step()
  }

  // TODO: Maybe turn the lable part into a more generic
  // fuction parameter so prefix and suffix are not needed
  // (like rename and reuse the indicator_style
  //  and give it the counter parameter?)
  grid(
    columns: (auto, 1fr),
    column-gutter: gutter,
    {
      /// Offset by which the label should be shifted down
      /// to match the baseline of the section content
      /// when there's a chord on the first line
      /// that shifts the content's baseline down
      /// -> length
      let offset = {
        let chords = query(selector(<chord>).after(here()))
        if chords.len() == 0 {
          0pt
        } else {
          let here_y = here().position().y
          let chord_y = chords.first().location().position().y

          // No chords on the first line!
          if here_y != chord_y {
            0pt
          } else {
            // Chord is on the first line so we get it's height
            // to know by how much to offset the part number
            let chord_height = measure(chords.first()).height
            chord_height.to-absolute() + spacing
          }
        }
      }

      // Offset the label
      place(end, dy: offset, indicator_style({
        prefix
        if numbered and counter != none {
          if ref != none {
            std.numbering(numbering, ..counter.at(ref))
          } else {
            counter.display(numbering)
          }
        }
        suffix
      }))
    },
    text_style(doc),
  )
}

/// Verse section
#let verse = section.with(counter: verse_counter)

/// Chorus section
#let chorus = section.with(
  counter: chorus_counter,
  numbered: false,
  prefix: [R:],
)

/// Pre-chorus section
#let prechorus = section.with(numbered: false, prefix: [P:])

/// Bridge section
#let bridge = section.with(
  counter: bridge_counter,
  numbered: false,
  prefix: [B:],
)

/// Solo section
///
/// It's usually used only for chords
/// (without any lyrics)
#let solo = section.with(numbered: false, prefix: [S:], text_style: doc => {
  text(weight: "bold", doc)
})

// TODO: Deprecate Intro and use Solo instead
// as they seem to convey the same meaning?

/// Intro section
///
/// It's usually used only for chords
/// (without any lyrics)
#let intro = section.with(numbered: false, prefix: [I:], text_style: doc => {
  text(weight: "bold", doc)
})

