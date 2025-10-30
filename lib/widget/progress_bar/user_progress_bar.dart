import 'package:flutter/material.dart';

/// Widget hiển thị thanh progress bar cho quá trình onboarding
/// Sử dụng cho các màn hình user information
class ProgressBarWidget extends StatelessWidget {
  /// Giá trị tiến độ hiện tại (0.0 - 1.0)
  final double progress;
  
  /// Chiều cao của progress bar
  final double height;
  
  /// Màu nền của progress bar
  final Color backgroundColor;
  
  /// Màu của phần đã hoàn thành
  final Color progressColor;
  
  /// Border radius của progress bar
  final double borderRadius;
  
  /// Có hiển thị animation khi thay đổi progress không
  final bool animated;
  
  /// Thời gian animation (milliseconds)
  final int animationDuration;

  const ProgressBarWidget({
    Key? key,
    required this.progress,
    this.height = 8.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = const Color(0xFFFFA726), // Màu cam/vàng như trong hình
    this.borderRadius = 4.0,
    this.animated = true,
    this.animationDuration = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Đảm bảo progress trong khoảng 0.0 - 1.0
    final clampedProgress = progress.clamp(0.0, 1.0);
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AnimatedContainer(
          duration: animated 
              ? Duration(milliseconds: animationDuration)
              : Duration.zero,
          curve: Curves.easeInOut,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: clampedProgress,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget hiển thị progress bar với thông tin bước hiện tại
/// Ví dụ: "Bước 2/5"
class ProgressBarWithSteps extends StatelessWidget {
  /// Bước hiện tại (bắt đầu từ 1)
  final int currentStep;
  
  /// Tổng số bước
  final int totalSteps;
  
  /// Chiều cao của progress bar
  final double height;
  
  /// Màu nền của progress bar
  final Color backgroundColor;
  
  /// Màu của phần đã hoàn thành
  final Color progressColor;
  
  /// Border radius của progress bar
  final double borderRadius;
  
  /// Có hiển thị text thông tin bước không
  final bool showStepText;
  
  /// Style cho text thông tin bước
  final TextStyle? stepTextStyle;
  
  /// Khoảng cách giữa progress bar và text
  final double spacing;

  const ProgressBarWithSteps({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 8.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = const Color(0xFFFFA726),
    this.borderRadius = 4.0,
    this.showStepText = true,
    this.stepTextStyle,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps > 0 ? currentStep / totalSteps : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgressBarWidget(
          progress: progress,
          height: height,
          backgroundColor: backgroundColor,
          progressColor: progressColor,
          borderRadius: borderRadius,
        ),
        if (showStepText) ...[
          SizedBox(height: spacing),
          Text(
            'Bước $currentStep/$totalSteps',
            style: stepTextStyle ?? 
                TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Widget hiển thị progress bar với nhiều segment (phân đoạn)
/// Mỗi segment đại diện cho một bước
class SegmentedProgressBar extends StatelessWidget {
  /// Số lượng segment
  final int segmentCount;
  
  /// Segment hiện tại đang hoàn thành (bắt đầu từ 0)
  final int currentSegment;
  
  /// Chiều cao của progress bar
  final double height;
  
  /// Khoảng cách giữa các segment
  final double segmentSpacing;
  
  /// Màu của segment chưa hoàn thành
  final Color inactiveColor;
  
  /// Màu của segment đã hoàn thành
  final Color activeColor;
  
  /// Border radius của mỗi segment
  final double borderRadius;

  const SegmentedProgressBar({
    Key? key,
    required this.segmentCount,
    required this.currentSegment,
    this.height = 8.0,
    this.segmentSpacing = 4.0,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.activeColor = const Color(0xFFFFA726),
    this.borderRadius = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        segmentCount,
        (index) {
          final isActive = index <= currentSegment;
          return Expanded(
            child: Container(
              height: height,
              margin: EdgeInsets.only(
                right: index < segmentCount - 1 ? segmentSpacing : 0,
              ),
              decoration: BoxDecoration(
                color: isActive ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget hiển thị progress bar với gradient color
class GradientProgressBar extends StatelessWidget {
  /// Giá trị tiến độ hiện tại (0.0 - 1.0)
  final double progress;
  
  /// Chiều cao của progress bar
  final double height;
  
  /// Màu nền của progress bar
  final Color backgroundColor;
  
  /// Gradient colors cho phần đã hoàn thành
  final List<Color> gradientColors;
  
  /// Border radius của progress bar
  final double borderRadius;
  
  /// Có hiển thị animation khi thay đổi progress không
  final bool animated;

  const GradientProgressBar({
    Key? key,
    required this.progress,
    this.height = 8.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.gradientColors = const [
      Color(0xFFFFB74D), // Vàng cam nhạt
      Color(0xFFFFA726), // Cam
      Color(0xFFFF9800), // Cam đậm
    ],
    this.borderRadius = 4.0,
    this.animated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AnimatedContainer(
          duration: animated 
              ? const Duration(milliseconds: 300)
              : Duration.zero,
          curve: Curves.easeInOut,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: clampedProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

