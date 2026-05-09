/// Song and song sections

#import "transpose.typ": transpose_state
#import "chord.typ": chord, i

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
/// - url (str): Link to an audio or video of the song
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
  url: none,
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

  let left_column = note

  let title_heading = heading(depth: 2, title)

  let linked_title = if url != none {
    link(url, title_heading)
  } else {
    title_heading
  }

  let styled_title = text(size: 1.15em, linked_title)
  let styled_author = align(center + top, text(
    weight: "light",
    style: "italic",
    size: 0.65em,
    author,
  ))

  // Title and author info
  let center_column = align(center, stack(
    spacing: 0.55em,
    styled_title,
    styled_author,
  ))

  // Capo and transposition info
  let right_column = align(horizon + right)[
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
  ]

  // Header of the song
  // (contains song title, author, capo and transposition information and note)
  block(
    inset: (x: 1em),
    grid(
      align: (auto, center, right + bottom),
      // Split into 3 columns with the song title in the center
      columns: (1fr, auto, 1fr),
      column-gutter: 1em,
      left_column, center_column, right_column,
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
/// - ref (label): Reference another section using its label
/// - numbered (bool): Enable numbering
/// - counter (any): Counter to use for numbering
/// - numbering (str,function): Numbering formatting
/// - prefix (content): Content before the numbering
/// - suffix (content): Content after the numbering
/// - ribbon (stroke): Stroke of the ribbon
/// - ribbon_gutter (length): Space between the ribbon and the label
/// - ribbon_outset (length): How much to stretch the ribbon past the
///                           text's upper and lower limits
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
  numbering: none,
  prefix: none,
  suffix: none,
  ribbon: none,
  ribbon_gutter: 0.5em,
  ribbon_outset: 0.35em,
  gutter: 0.5em,
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

  // Either use dictionary with
  // additional properties or
  // just the color
  let ribbon_dict = if ribbon == none {
    (paint: black.transparentize(100%))
  } else if type(ribbon) == color {
    (paint: ribbon)
  } else {
    ribbon
  }

  /// Whether the first line has any chords
  /// and thereby the ribbon and the indicator
  /// should be shortened/offset
  /// -> bool
  let first_line_chord = false

  // TODO: Maybe turn the lable part into a more generic
  // fuction parameter so prefix and suffix are not needed
  // (like rename and reuse the indicator_style
  //  and give it the counter parameter?)
  grid(
    columns: (auto, 1fr),
    column-gutter: gutter + ribbon_gutter,
    {
      first_line_chord = {
        let chords = query(selector(<chord>).after(here()))
        if chords.len() == 0 {
          false
        } else {
          let here_y = here().position().y
          let chord_y = chords.first().location().position().y

          here_y == chord_y
        }
      }

      let indicator = indicator_style({
        prefix
        if numbered and counter != none {
          if ref != none {
            std.numbering(numbering, ..counter.at(ref))
          } else {
            counter.display(numbering)
          }
        }
        suffix
      })

      let offset_indicator = if first_line_chord {
        chord([~], indicator)
      } else {
        indicator
      }

      block(
        outset: (y: ribbon_outset),
        place(end, offset_indicator),
      )
    },
    {
      let chord_height = measure([~]).height
      block(
        stroke: (
          left: (
            ..ribbon_dict,
            thickness: 2pt,
          ),
        ),
        outset: if first_line_chord {
          // TODO: The `top` outset should be something
          // like 0.3em - chord_height - chord_spaceing
          (left: gutter, top: -chord_height, bottom: ribbon_outset)
        } else {
          (left: gutter, y: 0.3em)
        },
        text_style(doc),
      )
    },
  )
}

/// Verse section
#let verse = section.with(
  counter: verse_counter,
  numbered: true,
  numbering: "1",
  prefix: none,
  suffix: [.#h(0.01em)],
  ribbon: (paint: gray),
)

/// Chorus section
#let chorus = section.with(
  counter: chorus_counter,
  numbered: false,
  prefix: [R],
  suffix: [:],
  ribbon: (paint: navy),
)

/// Pre-chorus section
#let prechorus = section.with(
  numbered: false,
  prefix: [P],
  suffix: [:],
  ribbon: (paint: navy.lighten(50%)),
)

/// Bridge section
#let bridge = section.with(
  counter: bridge_counter,
  numbered: false,
  prefix: [B],
  suffix: [:],
  ribbon: (paint: navy, dash: "dotted"),
)

/// Solo section
///
/// It's usually used only for chords
/// (without any lyrics)
///
/// Note: It automatically transposes
///       anything that looks like a chord!
#let solo = section.with(
  numbered: false,
  prefix: [S],
  suffix: [:],
  ribbon: (paint: gray.lighten(30%), dash: "dotted"),
  text_style: doc => {
    text(weight: "bold", i(doc))
  },
)
