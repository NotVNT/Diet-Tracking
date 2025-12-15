import '../../../record_view_home/domain/entities/food_record_entity.dart';

/// Use case to build the prompt for analyzing a scanned food item
class BuildFoodScanAnalysisPromptUseCase {
  String execute(FoodRecordEntity r) {
    final buf = StringBuffer();
    buf.writeln('Bạn là chuyên gia dinh dưỡng cá nhân.');
    buf.writeln('Nhiệm vụ: đánh giá mức độ phù hợp của sản phẩm thực phẩm dưới đây với hồ sơ sức khỏe và mục tiêu của người dùng.');
    buf.writeln('Hãy trả lời NGẮN GỌN và rõ ràng theo cấu trúc:');
    buf.writeln('- Kết luận: Safe to eat | Use with caution | Not recommended');
    buf.writeln('- Lý do chính (gạch đầu dòng)');
    buf.writeln('- Lưu ý dị ứng/kiêng kỵ nếu có');
    buf.writeln('- Mẹo thay thế lành mạnh (nếu cần)');
    buf.writeln('');
    buf.writeln('Thông tin sản phẩm đã quét:');
    buf.writeln('• Tên: ${r.foodName}');
    buf.writeln('• Calories: ${r.calories.toStringAsFixed(0)} kcal');
    if (r.protein != null) buf.writeln('• Protein: ${r.protein!.toStringAsFixed(0)} g');
    if (r.carbs != null) buf.writeln('• Carbs: ${r.carbs!.toStringAsFixed(0)} g');
    if (r.fat != null) buf.writeln('• Fat: ${r.fat!.toStringAsFixed(0)} g');
    if (r.barcode != null && r.barcode!.trim().isNotEmpty) buf.writeln('• Barcode: ${r.barcode}');
    if (r.nutritionDetails != null && r.nutritionDetails!.trim().isNotEmpty) {
      buf.writeln('• Thông tin thành phần/dinh dưỡng thêm:');
      buf.writeln(r.nutritionDetails);
    }
    buf.writeln('');
    buf.writeln('Dựa trên hồ sơ người dùng và kế hoạch dinh dưỡng (được cung cấp trong ngữ cảnh hệ thống), hãy đưa ra đánh giá cá nhân hóa.');
    buf.writeln('Nếu có nguy cơ dị ứng (ví dụ chứa các thành phần thường gây dị ứng như đậu phộng, sữa, gluten, hải sản, trứng, đậu nành, hạt tree nuts, v.v.) hãy nêu rõ.');
    buf.writeln('Nếu người dùng có bệnh nền (tiểu đường, tăng huyết áp, rối loạn mỡ máu, thận, dạ dày...) hãy cân nhắc đường, natri, chất béo bão hòa, chất xơ...');
    buf.writeln('Hãy thật súc tích (tối đa ~120-160 từ).');
    return buf.toString();
  }
}

