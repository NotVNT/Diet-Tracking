tạo môi trường .venv
  cd chat_box; python -m venv .venv
kích hoạt môi trường
  .\.venv\Scripts\Activate.ps1
Tải thư viện yêu cầu
  pip install -r requirements.txt

uvicorn vid_to_recipe:app --host 192.168.1.140 --port 8002 --reload
  
  uvicorn main:app --host 192.168.1.140 --port 8001 --reload
uvicorn nutrient_regressor:app --host 192.168.1.140 --port 8000 --reload

uvicorn nutrient_regressor:app --host https://ivank04-barcode-server.hf.space --port 8000 --reload

uvicorn barcode:app --host 0.0.0.0 --port 8000 --reload
tải thư viện uvicorn về, sau đó mở terminal ngay ở mục chat_box, terminal phải có đường mục giống thế này-"(.venv) C:\Users\LENOVO\myfilebro\diet-tracking\chat_box>",
sau đó nhập lệnh uvicorn main:app --reload là server sẽ chạy
trường hợp server không chạy, coi thử api của gemini đã load vào mô hình chưa, qua bên chat_bot_view.dart coi thử đường chạy local của mô hình đã đúng chưa
##-----##
Future<String> fetchGeminiReply(String prompt) async {
    final url = Uri.parse('http://127.0.0.1:8000/chat');<------------------------(nếu server ko chạy thì coi thử link local của mình có đúng với máy mình không)
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "age": 18,
        "height": 171,
        "weight": 65,
        "disease": "thừa cân",
        "allergy": "sữa",
        "goal": "giảm cân",
        "prompt": prompt,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] ?? 'Không có phản hồi từ AI';
    } else {
      return 'Lỗi kết nối API';
    }
  }
  ##-----##
