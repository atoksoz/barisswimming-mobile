/// Ders yoklaması roster satırında «yakma» arayüz durumu
/// (sunucu [burned] + [_pendingBurns] / [_pendingUnburns]).
enum TrainerRosterBurnUiPhase {
  normal,
  burned,
  pendingBurn,
  pendingUnburn,
}
