# YOLO 常用标注工具整理

## 1. YOLO 格式说明
YOLO（You Only Look Once）系列模型使用的标注格式通常为 `.txt` 文件，每行数据格式如下：

```
[class_id x_center y_center width height]
```

其中：
- `class_id`：类别索引，从 0 开始。
- `x_center, y_center`：目标框中心点坐标（归一化到 0-1）。
- `width, height`：目标框宽高（归一化到 0-1）。

以下工具均支持 **YOLO 格式**，可用于 YOLOv5、YOLOv7、YOLOv8、YOLOv10。

---

## 2. 常用标注工具

### **1. LabelImg**（推荐）
- **特点**：轻量级 GUI 工具，支持 YOLO 格式导出。
- **优点**：易于使用，适合小数据集手动标注。
- **安装**：
  ```bash
  pip install labelImg
  ```
- **运行**：
  ```bash
  labelImg
  ```

---

### **2. LabelMe**
- **特点**：支持多边形标注，适用于实例分割任务。
- **优点**：适用于复杂形状目标的标注。
- **安装**：
  ```bash
  pip install labelme
  ```
- **运行**：
  ```bash
  labelme
  ```

---

### **3. Roboflow Annotate**（推荐）
- **特点**：在线标注工具，支持自动标注，YOLO 格式导出。
- **优点**：
  - AI 辅助标注，提高效率。
  - 在线使用，无需安装。
- **网址**：[https://roboflow.com/](https://roboflow.com/)

---

### **4. CVAT（Computer Vision Annotation Tool）**
- **特点**：开源 Web 标注工具，支持团队协作。
- **优点**：
  - 适用于大规模数据集。
  - 多种标注任务（目标检测、实例分割等）。
- **安装**（Docker 部署）：
  ```bash
  docker-compose up -d
  ```
- **网址**：[https://github.com/openvinotoolkit/cvat](https://github.com/openvinotoolkit/cvat)

---

### **5. makesense.ai**
- **特点**：在线标注工具，支持矩形框和多边形标注。
- **优点**：
  - 界面简洁，易于上手。
  - 无需安装，直接在线使用。
- **网址**：[https://www.makesense.ai/](https://www.makesense.ai/)

---

### **6. VoTT（Visual Object Tagging Tool）**
- **特点**：微软开发，适用于视频目标检测任务。
- **优点**：
  - 适用于视频数据标注。
  - 支持 YOLO 格式导出。
- **下载**：[https://github.com/microsoft/VoTT](https://github.com/microsoft/VoTT)

---

### **7. Label Studio**
- **特点**：支持多模态数据（图像、文本、音频）标注。
- **优点**：
  - 适用于复杂任务。
  - 可扩展功能，适合多种数据类型。
- **安装**：
  ```bash
  pip install label-studio
  ```
- **运行**：
  ```bash
  label-studio
  ```

---

### **8. X-AnyLabeling（YOLOv10 推荐）**
- **特点**：基于 AI 的自动标注工具，支持 YOLOv10。
- **优点**：
  - AI 自动标注，提高标注效率。
  - 适用于大规模数据集。
- **安装（源码运行）**：
  ```bash
  git clone https://github.com/CVHub520/X-AnyLabeling.git
  cd X-AnyLabeling
  conda create --name x-anylabeling python=3.8
  conda activate x-anylabeling
  pip install -r requirements-gpu-dev.txt
  python anylabeling/app.py
  ```
- **参考**：[X-AnyLabeling 官方文档](https://github.com/CVHub520/X-AnyLabeling)

---

## 3. 工具对比

| 工具名            | 适用场景               | 是否支持 YOLO | 是否支持团队协作 |
|----------------|----------------|------------|------------|
| **LabelImg**      | 小型数据集，手动标注 | ✅ | ❌ |
| **LabelMe**       | 需要实例分割         | ✅（转换后） | ❌ |
| **Roboflow**      | 大数据集，自动标注   | ✅ | ✅ |
| **CVAT**          | 多任务标注，团队协作 | ✅ | ✅ |
| **makesense.ai**  | 轻量级在线标注       | ✅ | ❌ |
| **VoTT**          | 视频数据标注         | ✅ | ❌ |
| **Label Studio**  | 多模态数据标注       | ✅ | ✅ |
| **X-AnyLabeling** | AI 自动标注，YOLOv10 | ✅ | ✅ |

---

## 4. 如何选择合适的标注工具？

- **小规模数据集，手动标注** → **LabelImg**
- **需要实例分割** → **LabelMe**
- **大数据集，AI 自动标注** → **Roboflow**
- **多人协作，复杂任务** → **CVAT**
- **在线快速标注** → **makesense.ai**
- **标注视频数据** → **VoTT**
- **多模态任务（文本、音频、图像）** → **Label Studio**
- **YOLOv10 自动标注** → **X-AnyLabeling**

根据具体需求，选择最适合的标注工具，提高数据标注的效率和质量。
