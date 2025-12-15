import 'package:flutter/material.dart';
import '../../../../services/chat_sessions_service.dart';
import 'chat_sessions_list.dart';

class ChatHistory extends StatelessWidget {
  const ChatHistory({
    super.key,
    required this.onSelectSession,
    required this.onCreateNew,
    required this.onDeletedSessionId,
  });

  final Future<void> Function(String id) onSelectSession;
  final Future<void> Function() onCreateNew;
  final void Function(String deletedId) onDeletedSessionId;

  @override
  Widget build(BuildContext context) {
    final service = ChatSessionsService();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: ChatSessionsList(
          service: service,
          onSelect: (s) async {
            await onSelectSession(s.id);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          onCreateNew: () async {
            await onCreateNew();
          },
          onDeletedSessionId: (deletedId) {
            onDeletedSessionId(deletedId);
          },
        ),
      ),
    );
  }
}

