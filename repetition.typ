/// Repetition
///
/// Inserts repetition start and end signs
///
/// - repeat (int): How many times to repeat
/// - doc (content): What to repeat
/// -> content
#let rep(
  repeat: 2,
  doc,
) = {
  let repeat_sign = text.with(fill: gray.darken(80%), size: 1.2em)
  repeat_sign[𝄆]
  [ ]
  doc
  [ ]
  repeat_sign[𝄇]
  if repeat != 2 {
    [#repeat\x]
  }
}
