# Flow Integration - Nutrition Calculator

## 🔄 Flow Navigation Mới

```
goal_selection.dart
    ↓
goal_reason_screen.dart
    ↓
gender_selector.dart
    ↓
age_selector.dart
    ↓
height_selector.dart
    ↓
weight_selector.dart
    ↓
goal_weight_selector.dart
    ↓
daily_activities_selector.dart  ← Chọn mức độ vận động
    ↓
target_days_selector.dart       ← [MỚI] Chọn số ngày (7-365)
    ↓
nutrition_summary.dart          ← [MỚI] Xem tổng kết & cảnh báo
    ↓
interface_confirmation.dart
```

## 📦 Các file đã tạo/cập nhật

### 1. Model
- ✅ `lib/model/nutrition_calculation_model.dart` (MỚI)
  - `NutritionCalculation`: Lưu kết quả tính toán
  - `UserNutritionInfo`: Lưu thông tin người dùng

### 2. Service
- ✅ `lib/services/nutrition_calculator_service.dart` (MỚI)
  - Tính BMR, TDEE, calories
  - Validation và cảnh báo
  - Tính số ngày khuyến nghị

### 3. Views
- ✅ `lib/view/on_boarding/user_information/daily_activities_selector.dart` (CẬP NHẬT)
  - Thay đổi navigation: `InterfaceConfirmation` → `TargetDaysSelector`
  
- ✅ `lib/view/on_boarding/user_information/target_days_selector.dart` (MỚI)
  - Màn hình chọn số ngày
  - Slider + quick options
  - Hiển thị tính toán real-time
  - Cảnh báo nếu không an toàn
  - Progress: 7/8
  
- ✅ `lib/view/on_boarding/user_information/nutrition_summary.dart` (MỚI)
  - Màn hình tổng kết
  - Hiển thị BMR, TDEE, calories
  - Cảnh báo chi tiết
  - Khuyến nghị số ngày
  - Navigation đến `InterfaceConfirmation`

### 4. Utils
- ✅ `lib/utils/nutrition_utils.dart` (MỚI)
  - Format dữ liệu
  - Tính BMI
  - Gợi ý chế độ ăn/tập luyện

## 📊 Dữ liệu Flow

### Input (từ các màn hình trước):
- `age` (int)
- `gender` (String: 'Nam' hoặc 'Nữ')
- `heightCm` (double)
- `weightKg` (double)
- `goalWeightKg` (double)
- `activityLevel` (String: 'Ít vận động', 'Vận động nhẹ', etc.)

### Output (lưu vào LocalStorage):
- `targetDays` (int): Số ngày mục tiêu
- `nutritionCalculation` (Map): Kết quả tính toán đầy đủ

## 🎯 Công thức tính toán

### BMR (Basal Metabolic Rate)
- **Nam**: `(10 × cân nặng) + (6.25 × chiều cao) - (5 × tuổi) + 5`
- **Nữ**: `(10 × cân nặng) + (6.25 × chiều cao) - (5 × tuổi) - 161`

### TDEE (Total Daily Energy Expenditure)
- `TDEE = BMR × R` (R là hệ số mức độ vận động)

### Hệ số vận động (R):
- Ít vận động: 1.2
- Vận động nhẹ: 1.375
- Vận động vừa: 1.55
- Vận động nặng: 1.725
- Vận động rất nặng: 1.9

### Calories
- **Calories tối đa**: `BMR + 1000`
- **Calories tối thiểu**: 1500 (nam) / 1200 (nữ)
- **Calories mục tiêu**: `TDEE ± (W_chênh lệch × 7700 / số ngày)`

## ⚠️ Validation & Cảnh báo

Hệ thống tự động kiểm tra:
1. ✅ Calories mục tiêu trong khoảng an toàn (min-max)
2. ✅ Mức điều chỉnh ≤ 1000 cal/ngày
3. ✅ Tốc độ thay đổi cân nặng hợp lý

Nếu không đạt → Hiển thị:
- ❌ Cảnh báo màu đỏ
- 💡 Khuyến nghị số ngày phù hợp
- ⚠️ Thông báo chi tiết

## 🎨 UI/UX

### target_days_selector.dart
- Slider: 7-365 ngày
- Quick options: 7, 14, 30, 60, 90, 180, 365
- Card hiển thị: BMR, TDEE, Calories mục tiêu
- Warning card (nếu không an toàn)
- Progress bar: 7/8

### nutrition_summary.dart
- Header với icon
- Goal card: Cân nặng hiện tại → mục tiêu
- Nutrition card: BMR, TDEE, Calories
- Warning card (màu đỏ) nếu không an toàn
- Recommendation card (màu xanh)
- Button: "Xác nhận" (xanh) hoặc "Tôi hiểu rủi ro" (đỏ)

## 🔧 Cách test

1. Chạy app và đi qua flow onboarding
2. Tại `daily_activities_selector.dart`, chọn mức độ vận động
3. Tại `target_days_selector.dart`:
   - Thử slider
   - Thử quick options
   - Kiểm tra tính toán real-time
   - Thử số ngày quá ngắn/dài
4. Tại `nutrition_summary.dart`:
   - Kiểm tra hiển thị đầy đủ
   - Xem cảnh báo (nếu có)
   - Nhấn "Xác nhận"

## 📝 Lưu ý quan trọng

1. **Progress Bar**: Đã cập nhật từ 7/7 → 7/8 trong `target_days_selector.dart`
2. **Navigation**: 
   - `daily_activities_selector.dart` → `target_days_selector.dart`
   - `target_days_selector.dart` → `nutrition_summary.dart`
   - `nutrition_summary.dart` → `interface_confirmation.dart`
3. **Data Persistence**: Tất cả dữ liệu được lưu vào LocalStorage
4. **Validation**: Luôn kiểm tra `isHealthy` trước khi tiếp tục

## 🚀 Tính năng nổi bật

1. ✅ **Tính toán chính xác** theo công thức khoa học
2. ✅ **Real-time calculation** khi thay đổi số ngày
3. ✅ **Cảnh báo thông minh** với màu sắc rõ ràng
4. ✅ **Khuyến nghị tự động** số ngày phù hợp
5. ✅ **UI đẹp và dễ sử dụng**
6. ✅ **Code sạch, dễ maintain*[object Object]Kết quả

Người dùng sẽ:
- Hiểu rõ BMR, TDEE, calories của mình
- Biết được chế độ ăn có an toàn không
- Nhận được khuyến nghị số ngày phù hợp
- Có thông tin đầy đủ để đưa ra quyết định

---

**Hoàn thành**: Tất cả các file đã được tạo và tích hợp thành công! 🎉

