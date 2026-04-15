/// Chord typesetting stuff

#import "transpose.typ": transpose_automatic

/// Create colored boxes around
/// chords and some lyrics
/// for debugging
/// -> bool
#let debug_boxes = false

/// Apply special styling to a chord
///
/// Namely replace the `#` and `b`
/// with the correct symbols
///
/// (Note: this sometimes messes with the
///  measured width of the chord and
///  I'm not sure there's a way to avoid that)
///
/// - chord (content): Chord to be shown
/// -> content
#let styled_chord(chord) = [
  #text(weight: "bold")[
    #show "#": text(size: 1em, "♯")
    #show "b": text(size: 1em, "♭")
    #chord
  ]<chord>
]

/// Note: Requires context
#let chord_height(chord, text, spacing) = {
  if text == none {
    text = [~]
  }
  measure(chord).height + measure(text).height + spacing
}

/// Insert a chord above some specific lyrics
///
/// - chord (content): Chord content
/// - text (content): Lyrics content
/// - spacing (length): Additional spacing between `chord` and `text`
/// -> content
#let stacked_chord(
  chord,
  text,
  spacing,
) = context {
  box(
    stroke: if debug_boxes { gray.transparentize(40%) } else { none },
    stack(
      dir: ttb,
      spacing: spacing + 0.013em,
      box(
        stroke: if debug_boxes { green.transparentize(40%) } else { none },
        styled_chord(chord),
      ),
      text,
    ),
  )
}

/// Insert a simple chord that will float above the text
/// (without association to a specific part of the lyrics)
///
/// - chord (content): Chord content
/// - spacing (length): Additional spacing between `chord` and the text below it
/// -> content
#let simple_chord(
  chord,
  spacing,
) = context {
  box(
    stroke: if debug_boxes { red.transparentize(40%) } else { none },
    place(
      start,
      box(
        stroke: if debug_boxes { blue.transparentize(40%) } else { none },
        styled_chord(chord),
      ),
    ),
    height: chord_height(chord, [~], spacing),
  )
}

/// Create a space between text to prevent
/// neighboring chords from overlapping
///
/// - height (length): Height of the chord
/// - spacer (content): Conter to put into the inserted space
/// -> content
#let adjust_chord_spacing(height, spacer) = context {
  let previous_chords = query(selector(<chord>).before(here()))

  // No chords -> no spacing needed
  if previous_chords.len() == 0 {
    return
  }

  let last_chord = previous_chords.last()
  // last_chord

  // Don't insert spacing if the chords
  // are on different lines or pages
  let here_pos = here().position()
  let last_pos = last_chord.location().position()
  // - height.to-absolute() is an adjustment for
  // as here_pos is at the bottom of the line
  // but the last_pos has the y coordinate of the chord
  // (so last_pos.y is a smaller value)
  if (
    (here_pos.page, here_pos.y - height.to-absolute())
      != (last_pos.page, last_pos.y)
  ) {
    return
  }

  // repr(here_pos.y - height.to-absolute())
  // repr(last_pos.y)

  let additional_padding = measure([~]).width

  let chord_end_x = last_pos.x + measure(last_chord).width
  let missing_space = chord_end_x - here_pos.x

  if missing_space + additional_padding <= 0pt {
    return
  }

  let actual_spacer = if (
    spacer != none and measure(spacer).width < missing_space
  ) {
    spacer
  } else {
    [~]
  }

  // I'm not really sure why this would be needed...
  box(
    stroke: if debug_boxes { fuchsia.transparentize(40%) } else { none },
    width: missing_space + additional_padding,
    align(center + horizon, actual_spacer),
  )
}

/// Create a chord
///
/// - hidden (bool): Hide the chord
/// - inline (bool): Place chords inline with the text
/// - auto_spacing (bool): Leave space for previous chords
/// - spacing (length):
/// - spacer (content): The content between words if spacing is needed
/// - content (content):
/// -> content
#let chord(
  hidden: false,
  inline: false,
  auto_spacing: true,
  spacing: 0.3em,
  spacer: none,
  ..content,
) = context {
  let chord = content.pos().first()
  let text = content.pos().at(1, default: none)

  if hidden {
    return text
  }

  let transposed_chord = transpose_automatic(chord)

  if inline {
    transposed_chord
    text
  } else {
    if auto_spacing == true {
      let chord_height = chord_height(transposed_chord, text, spacing)
      adjust_chord_spacing(chord_height, spacer)
    }

    if text == none {
      simple_chord(transposed_chord, spacing)
    } else {
      stacked_chord(transposed_chord, text, spacing)
    }
  }
}

// TODO: Examples

/// Regular chord
#let c = chord
/// Chord which doesn't do
/// automatic spacing to distance itself
/// from previous chords
#let d = chord.with(auto_spacing: false)
/// Chord which inserts a dash as a spacer
/// into the automatic spacing it creates
#let w = chord.with(spacer: [-])
/// Chord that is placed inline
/// with the text
/// (useful for solo chords, etc.)
#let i = chord.with(inline: true)
