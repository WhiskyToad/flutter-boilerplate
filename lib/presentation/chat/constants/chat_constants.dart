/// Top-level Firestore collection holding one document per registered user.
const String kChatUsersCollection = 'users';

/// Top-level Firestore collection holding one document per one-to-one chat.
const String kChatsCollection = 'chats';

/// Subcollection under each chat document containing its messages.
const String kChatMessagesSubcollection = 'messages';

/// Builds a deterministic chat document id for a one-to-one chat between
/// [uidA] and [uidB] by sorting the two ids alphabetically and joining them
/// with an underscore. Both participants always derive the same id so they
/// converge on a single chat document.
String buildChatId(String uidA, String uidB) {
  final sorted = [uidA, uidB]..sort();
  return '${sorted[0]}_${sorted[1]}';
}
