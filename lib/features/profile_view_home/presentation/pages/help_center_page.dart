import 'package:flutter/material.dart';
import '../../../../common/custom_app_bar.dart';

/// Trang Trung tâm hỗ trợ đơn giản
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: const CustomAppBar(
        title: 'Trung tâm hỗ trợ',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeaderCard(context),
            
            const SizedBox(height: 24),
            
            // FAQ Section
            _buildSectionTitle(context, 'Câu hỏi thường gặp'),
            const SizedBox(height: 12),
            _buildFAQCard(context),
            
            const SizedBox(height: 24),
            
            // Contact Section
            _buildSectionTitle(context, 'Liên hệ với chúng tôi'),
            const SizedBox(height: 12),
            _buildContactCard(context),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chúng tôi sẵn sàng hỗ trợ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tìm câu trả lời hoặc liên hệ với team',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildFAQCard(BuildContext context) {
    final faqItems = [
      {
        'question': 'Làm thế nào để theo dõi dinh dưỡng?',
        'answer': 'Bạn có thể thêm thực phẩm vào nhật ký bữa ăn hàng ngày. Ứng dụng sẽ tự động tính toán dinh dưỡng cho bạn.',
      },
      {
        'question': 'Tôi có thể đặt mục tiêu calo không?',
        'answer': 'Có, bạn có thể đặt mục tiêu calo và các chỉ số dinh dưỡng khác trong phần Cài đặt Mục tiêu.',
      },
      {
        'question': 'Làm sao để tạo thực đơn?',
        'answer': 'Vào phần Thực đơn, chọn "Tạo mới" và thêm các món ăn bạn muốn. Ứng dụng sẽ tính toán dinh dưỡng tự động.',
      },
      {
        'question': 'Dữ liệu của tôi có được đồng bộ không?',
        'answer': 'Có, dữ liệu được tự động đồng bộ với cloud nếu bạn đã đăng nhập tài khoản.',
      },
      {
        'question': 'Làm sao để xuất báo cáo?',
        'answer': 'Vào phần Báo cáo, chọn khoảng thời gian và nhấn nút "Xuất PDF" để tải báo cáo về máy.',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: faqItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == faqItems.length - 1;
          
          return _buildFAQItem(
            context,
            question: item['question']!,
            answer: item['answer']!,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
    required bool isLast,
  }) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        question,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildContactItem(
            context,
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@diettracking.vn',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang mở ứng dụng email...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            indent: 68,
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
          _buildContactItem(
            context,
            icon: Icons.phone_outlined,
            title: 'Hotline',
            subtitle: '1900 xxxx (8:00 - 22:00)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang gọi hotline...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            indent: 68,
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
          _buildContactItem(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            subtitle: 'Trò chuyện trực tiếp với chúng tôi',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng đang được phát triển...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
