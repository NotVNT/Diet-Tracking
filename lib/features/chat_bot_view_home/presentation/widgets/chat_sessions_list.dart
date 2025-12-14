import 'package:flutter/material.dart';
import '../../../../services/chat_sessions_service.dart';
import '../../../../common/app_confirm_dialog.dart';
import '../../../../common/snackbar_helper.dart';

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
  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final d = DateTime(dt.year, dt.month, dt.day);
    final today = DateTime(now.year, now.month, now.day);
    if (d == today) {
      return '${_two(dt.hour)}:${_two(dt.minute)}'; // 13:45
    }
    if (today.difference(d).inDays == 1) {
      return 'Hôm qua ${_two(dt.hour)}:${_two(dt.minute)}';
    }
    return '${_two(dt.day)}/${_two(dt.month)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  Future<void> _confirmDelete(BuildContext context, ChatSessionFS s) async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Xóa cuộc trò chuyện',
      message:
          'Bạn có chắc muốn xóa cuộc trò chuyện "${s.title}"? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
      destructive: true,
    );
    if (ok == true) {
      await service.deleteSession(s.id);
      // Thông báo về phiên đã xóa cho chủ sở hữu widget (để dọn UI nếu cần)
      onDeletedSessionId?.call(s.id);
      // ignore: use_build_context_synchronously
      SnackBarHelper.showSuccess(context, 'Đã xóa cuộc trò chuyện');
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
                return const Center(child: Text('Chưa có lịch sử trò chuyện'));
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
                          ? 'Bắt đầu cuộc trò chuyện'
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
                            _formatTime(s.lastMessageAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              tooltip: 'Xóa',
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
