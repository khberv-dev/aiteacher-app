class ConverseReply {
  const ConverseReply({required this.transcript, this.audioUrl});

  final String transcript;
  final String? audioUrl;

  factory ConverseReply.fromJson(Map<String, dynamic> json) {
    return ConverseReply(
      transcript: json['transcript'] as String? ?? '',
      audioUrl: json['audioUrl'] as String?,
    );
  }
}

class ConverseResult {
  const ConverseResult({
    required this.conversationId,
    required this.userTranscript,
    required this.reply,
    required this.readyForAnalyze,
  });

  final String conversationId;
  final String userTranscript;
  final ConverseReply reply;
  final bool readyForAnalyze;

  factory ConverseResult.fromJson(Map<String, dynamic> json) {
    final replyRaw = json['reply'];
    return ConverseResult(
      conversationId: json['conversationId'] as String? ?? '',
      userTranscript: json['userTranscript'] as String? ?? '',
      reply: replyRaw is Map
          ? ConverseReply.fromJson(replyRaw.cast<String, dynamic>())
          : const ConverseReply(transcript: ''),
      readyForAnalyze: json['readyForAnalyze'] as bool? ?? false,
    );
  }
}
