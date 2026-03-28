/// = crumblysong
/// `crumblysong` is a songbook package
/// that allows (relatively) easy
/// typesetting of song sections
/// and chords over lyrics.
///
/// == Basic usage
/// ```
/// #import "@local/crumblysong:0.1.0": *;
///
/// #show: doc => song(
///   title: [Red Dwarf Theme],
///   author: [Howard Goodall],
///   doc,
/// )
///
/// #verse[
///   Its #d[C]cold out#c[Emi]side,\
///   There's #d[F]no kind of atmosphere,\
///   I'm #d[C]all #c[Gmi]alone,\
///   #d[Dmi]More or #c[A]less.
/// ]
///
/// #prechorus[
///   #d[F]Let me fly,
///   #d[D7/F\#]Far away from here,
/// ]
///
/// #chorus[
///   #d[C]Fun, #c[C7]fun, #c[Asus4]fun, ...#c[A]\
///   In the #d[Dmi]sun, #c[Fmi]sun, #c[G]sun.
/// ]
/// ```
///
/// == Available primitives
///
/// === `song`
///
/// The basic building block is the
/// `song` function that creates the song header
/// and initializes the section counters
///
/// Usage:
/// ```
/// #show: doc => song(
///   title: [Red Dwarf Theme],
///   author: [Howard Goodall],
///   doc,
/// )
/// ```
///
/// === Sections
///
/// There are multiple different section types provided:
/// - verse
/// - chorus
/// - prechorus
/// - bridge
/// - intro
/// - solo
///
/// Usage:
/// ```
/// #verse[
///   Lyrics go here...
/// ]
/// ```
///
/// === Chords
///
/// There are three types of chord functions provided:
/// - regular chord (`c`)
/// - chord with a spacer (`w`)
/// - chord without spacing (`d`)
///
/// ==== Regular chord
///
/// This is probably the most used type of chord.
/// It has automatic spacing from preceding chords
/// which means that chords won't overlap if they're
/// too close together.
///
/// ==== Chord with a spacer
///
/// This is the same as regular chord but with
/// the caveat that it inserts a dash into the
/// space between it and the preceding chord.
///
/// It's useful when there're two chords in
/// a single word near each other to signify
/// that the word doesn't end where
/// the automatic chord spacing is inserted
/// but continues.
///
/// ==== Chord without any spacing
///
/// This chord type doesn't insert any spacing.
///
/// There's a bug that sometimes causes chords
/// that stick beyond the end of the line to shift
/// the chords on the next line and this is a way to fix that.
///

#import "./song.typ": bridge, chorus, intro, prechorus, solo, song, verse
#import "./chord.typ": c, d, w
#import "./transpose.typ": transpose_state
