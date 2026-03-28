/// Chord transposition logic

/// Current transposition state (how much to transpose by)
#let transpose_state = state("transpose_amount", 0)

#let notes_sharp = (
  "C",
  "C#",
  "D",
  "D#",
  "E",
  "F",
  "F#",
  "G",
  "G#",
  "A",
  "A#",
  "H",
)

#let notes_flat = (
  "C",
  "Db",
  "D",
  "Eb",
  "E",
  "F",
  "Gb",
  "G",
  "Ab",
  "A",
  "B",
  "H",
)

/// Converts Typst content
/// (e.g. [Ami]) into a raw string ("Ami")
///
/// - c (content): Chord in content form
/// -> str
#let content_to_str(c) = {
  if type(c) == str { return c }
  if type(c) == content {
    if c.has("text") { return c.text }
    if c.has("children") { return c.children.map(content_to_str).join() }
  }
  return ""
}

/// Transpose part of the chord
/// (doesn't handle slashes)
///
/// - amount (int): How much to transpose by
/// - part (str): Part of the chord
/// -> str
#let transpose_part(amount: int, part) = {
  // Separate the root note (C, F#, Bb)
  // from the suffix (mi, 7, maj7)
  let match = part.match(regex("^([A-G][#b]?)(.*)"))
  if match != none {
    let note = match.captures.at(0)
    let suffix = match.captures.at(1)

    // Find note index
    let index = notes_sharp.position(n => n == note)
    if index == none {
      index = notes_flat.position(n => n == note)
    }

    // Transpose
    if index != none {
      // +120 ensures safe positive modulo even if `amount` is a large negative number
      let transposed_index = calc.rem(index + amount + 120, 12)
      return notes_sharp.at(transposed_index) + suffix
    }
  }

  // Failed to match so just return the input
  return part
}

/// Parses a chord string, finds the root note, and transposes it
///
/// - chord (content):
/// - amount (int):
/// -> content
#let transpose_chord(chord, amount: int) = {
  if amount == 0 { return chord }

  let chord_str = content_to_str(chord)
  // Conversion failed
  if chord_str == "" { return chord }

  let transpose_part_amount = transpose_part.with(amount: amount)
  // Process each part of the chord separately
  return chord_str.split("/").map(transpose_part_amount).join("/")
}

/// Automatically transpose the chord
/// based on the current `transpose_state`
///
/// - chord (content): Chord content to transpose
/// -> content
#let transpose_automatic(chord) = context {
  let amount = int(transpose_state.get())
  return transpose_chord(amount: amount, chord)
}
