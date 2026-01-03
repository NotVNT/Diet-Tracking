import cv2
import os
import base64
from PIL import Image
from io import BytesIO
import base64
from openai import OpenAI
from dotenv import load_dotenv
import tempfile
from fastapi import FastAPI, UploadFile, File 
import tempfile 
import shutil

app = FastAPI()

load_dotenv()

HF_TOKEN = os.getenv("HF_TOKEN")

client = OpenAI(
    base_url="https://router.huggingface.co/v1",
    api_key=HF_TOKEN,
)

def encode_image(path):
    img = Image.open(path).convert("RGB")
    buf = BytesIO()
    img.save(buf, format="JPEG")
    return base64.b64encode(buf.getvalue()).decode()

def describe_frame(image_path):
    image_b64 = encode_image(image_path)

    completion = client.chat.completions.create(
        model="Qwen/Qwen2.5-VL-7B-Instruct:hyperbolic",
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Describe the cooking action and the INGREDIENTS that are used into ONE short sentence using a verb and object. No explanations."
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{image_b64}"
                        }
                    }
                ]
            }
        ],
        max_tokens=40,
        temperature=0.2,
    )

    return completion.choices[0].message.content

def process_frames(frame_dir):
    results = []

    frame_files = sorted(os.listdir(frame_dir))

    for fname in frame_files:
        path = os.path.join(frame_dir, fname)

        # lấy timestamp từ tên file: frame_000005.jpg → 5
        timestamp = int(fname.split("_")[1].split(".")[0])

        desc = describe_frame(path)

        results.append({
            "time": timestamp,
            "desc": desc
        })

    return results


def extract_frames(video_path, interval_sec=3):
    # tạo thư mục tạm
    with tempfile.TemporaryDirectory() as out_dir:
        cap = cv2.VideoCapture(video_path)
        fps = cap.get(cv2.CAP_PROP_FPS)
        frame_interval = int(fps * interval_sec)

        frame_idx = 0
        saved = 0

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            if frame_idx % frame_interval == 0:
                timestamp = int(frame_idx / fps)
                filename = os.path.join(out_dir, f"frame_{timestamp:06d}.jpg")
                cv2.imwrite(filename, frame)
                saved += 1

            frame_idx += 1

        cap.release()
        print("Saved frames:", saved)

        # gọi process_frames với thư mục tạm
        descriptions = process_frames(out_dir)

        # khi thoát khỏi with, folder out_dir sẽ tự động bị xoá
        return descriptions
    
def group_actions(actions, gap=3):
    steps = []
    group_start_time = actions[0]["time"]
    current_step = {"start": group_start_time, "descs": [actions[0]["desc"]]}

    for curr in actions[1:]:
        # Nếu hành động hiện tại vẫn nằm trong khoảng gap kể từ hành động đầu tiên của nhóm
        if curr["time"] - group_start_time <= gap:
            current_step["descs"].append(curr["desc"])
        else:
            steps.append(current_step)
            # bắt đầu nhóm mới
            group_start_time = curr["time"]
            current_step = {"start": curr["time"], "descs": [curr["desc"]]}

    steps.append(current_step)
    return steps

def summarize_step(descs):
    # Nối tất cả các hành động trong list thành một string
    return " ".join(descs)   # hoặc " → ".join(descs) nếu muốn có dấu mũi tên

def generate_recipe(steps):
    """
    steps: list các string mô tả hành động đã summarize
    Trả về: recipe step-by-step từ LLM
    """
    # Tạo prompt từ danh sách bước
    prompt = "Hãy biến các mô tả sau thành hướng dẫn nấu ăn step-by-step bằng tiếng Việt:\n" + "\n\nHướng dẫn:" + steps

    # Gọi LLM
    completion = client.chat.completions.create(
        model="Qwen/Qwen2.5-7B-Instruct",
        messages=[
            {"role": "user", "content": prompt}
        ],
    )

    return completion.choices[0].message.content

@app.post("/upload-video/")
async def upload_video(file: UploadFile = File(...)):
    # tạo file tạm để lưu video
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
        shutil.copyfileobj(file.file, tmp)
        tmp_path = tmp.name  # đường dẫn file tạm

    try:
        descriptions = extract_frames(tmp_path, interval_sec=3)

        steps = group_actions(descriptions, gap=3)

        # summarize
        all_steps_text = "\n".join(
            [
                f"Bước {i}: {summarize_step(step['descs'])}"
                for i, step in enumerate(steps, 1)
            ]
        )

        recipe = generate_recipe(all_steps_text)

        return {
            "recipe": recipe
        }
    finally:
        try:
            os.remove(tmp_path)
        except Exception:
            # ignore cleanup failures
            pass

