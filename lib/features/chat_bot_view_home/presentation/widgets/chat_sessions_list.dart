import 'package:flutter/material.dart';
import '../../../../services/chat_sessions_service.dart';
import '../../../../common/app_confirm_dialog.dart';
import '../../../../common/snackbar_helper.dart';
import '../../../../l10n/app_localizations.dart';

class ChatSessionsList extends StatelessWidget {
  const ChatSessionsList({
    super.key,
    required this.service,
    this.onSelect,
    this.onCreateNew,
    this.onDeletedSessionId,
  });

  final ChatSessionsService service;
  final void Function(ChatSessionFS session)? onSelect;
  final VoidCallback? onCreateNew;
  final void Function(String sessionId)? onDeletedSessionId;

  String _two(int n) => n < 10 ? '0$n' : '$n';
  String _formatTime(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final d = DateTime(dt.year, dt.month, dt.day);
    final today = DateTime(now.year, now.month, now.day);
    if (d == today) {
      return '${_two(dt.hour)}:${_two(dt.minute)}'; // 13:45
    }
    if (today.difference(d).inDays == 1) {
      return '${l10n.chatBotYesterday} ${_two(dt.hour)}:${_two(dt.minute)}';
    }
    return '${_two(dt.day)}/${_two(dt.month)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  Future<void> _confirmDelete(BuildContext context, ChatSessionFS s) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showAppConfirmDialog(
      context,
      title: l10n.chatBotConfirmDeleteTitle,
      message: l10n.chatBotConfirmDeleteMessage(s.title),
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      destructive: true,
    );
    if (ok == true) {
      await service.deleteSession(s.id);
      // Thông báo về phiên đã xóa cho chủ sở hữu widget (để dọn UI nếu cần)
      onDeletedSessionId?.call(s.id);
      // ignore: use_build_context_synchronously
      SnackBarHelper.showSuccess(context, l10n.chatBotSessionDeleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Expanded(
          child: StreamBuilder<List<ChatSessionFS>>(
            stream: service.streamSessionsForCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data ?? const <ChatSessionFS>[];
              if (items.isEmpty) {
                final l10n = AppLocalizations.of(context)!;
                return Center(child: Text(l10n.chatBotHistoryEmpty));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = items[index];
                  return ListTile(
                    onTap: onSelect == null ? null : () => onSelect!(s),
                    leading: const Icon(Icons.forum_outlined),
                    title: Text(
                      s.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      s.lastMessagePreview.isEmpty
                          ? AppLocalizations.of(context)!.chatBotStartConversation
                          : s.lastMessagePreview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: SizedBox(
                      width: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(context, s.lastMessageAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              tooltip: AppLocalizations.of(context)!.delete,
                              icon: const Icon(Icons.delete_outline),
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              onPressed: () => _confirmDelete(context, s),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
