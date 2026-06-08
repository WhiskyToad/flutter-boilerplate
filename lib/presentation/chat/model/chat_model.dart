class ChatModel {
  String name;
  String profilePicture;
  String lastMessage;
  String? lastMessageAttachmentUrl;
  DateTime? lastMessageTime;
  int? unreadMessageCount;
  bool isOnline;
  bool? isTeam;

  /// Supabase user row id. Set when the model represents a user the
  /// current account can chat with. Empty for legacy/demo construction sites.
  String userId;

  ChatModel({
    required this.name,
    required this.profilePicture,
    required this.lastMessage,
    this.lastMessageAttachmentUrl,
    this.lastMessageTime,
    this.unreadMessageCount,
    required this.isOnline,
    this.isTeam,
    this.userId = '',
  });
}
