---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/google_imagen.ipynb
description: 구글 이미지는 Vertex AI에서 텍스트 프롬프트로 고품질 이미지를 생성하고 편집할 수 있는 최첨단 AI 기능을 제공합니다.
---

# 구글 이미지

> [Vertex AI의 Imagen](https://cloud.google.com/vertex-ai/generative-ai/docs/image/overview)은 구글의 최첨단 이미지 생성 AI 기능을 애플리케이션 개발자에게 제공합니다. Vertex AI의 Imagen을 사용하면 애플리케이션 개발자는 AI 생성을 통해 사용자의 상상을 고품질 시각 자산으로 변환하는 차세대 AI 제품을 몇 초 만에 구축할 수 있습니다.

Langchain의 Imagen을 사용하면 다음 작업을 수행할 수 있습니다.

- [VertexAIImageGeneratorChat](#image-generation) : 텍스트 프롬프트만 사용하여 새로운 이미지를 생성합니다 (텍스트-투-이미지 AI 생성).
- [VertexAIImageEditorChat](#image-editing) : 텍스트 프롬프트로 전체 업로드된 이미지 또는 생성된 이미지를 편집합니다.
- [VertexAIImageCaptioning](#image-captioning) : 시각적 캡션을 사용하여 이미지에 대한 텍스트 설명을 얻습니다.
- [VertexAIVisualQnAChat](#visual-question-answering-vqa) : 시각적 질문 응답(VQA)을 통해 이미지에 대한 질문에 대한 답변을 얻습니다.
  * 참고 : 현재 우리는 시각적 QnA(VQA)에 대해 단일 턴 채팅만 지원합니다.

## 이미지 생성
텍스트 프롬프트만 사용하여 새로운 이미지를 생성합니다 (텍스트-투-이미지 AI 생성).

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Google Imagen"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Google Imagen"}]-->
from langchain_core.messages import AIMessage, HumanMessage
from langchain_google_vertexai.vision_models import VertexAIImageGeneratorChat
```


```python
# Create Image Gentation model Object
generator = VertexAIImageGeneratorChat()
```


```python
messages = [HumanMessage(content=["a cat at the beach"])]
response = generator.invoke(messages)
```


```python
# To view the generated Image
generated_image = response.content[0]
```


```python
import base64
import io

from PIL import Image

# Parse response object to get base64 string for image
img_base64 = generated_image["image_url"]["url"].split(",")[-1]

# Convert base64 string to Image
img = Image.open(io.BytesIO(base64.decodebytes(bytes(img_base64, "utf-8"))))

# view Image
img
```


![](/img/e76fbff9938a3435103e20a32884e775.png)

## 이미지 편집
텍스트 프롬프트로 전체 업로드된 이미지 또는 생성된 이미지를 편집합니다.

### 생성된 이미지 편집

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Google Imagen"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Google Imagen"}]-->
from langchain_core.messages import AIMessage, HumanMessage
from langchain_google_vertexai.vision_models import (
    VertexAIImageEditorChat,
    VertexAIImageGeneratorChat,
)
```


```python
# Create Image Gentation model Object
generator = VertexAIImageGeneratorChat()

# Provide a text input for image
messages = [HumanMessage(content=["a cat at the beach"])]

# call the model to generate an image
response = generator.invoke(messages)

# read the image object from the response
generated_image = response.content[0]
```


```python
# Create Image Editor model Object
editor = VertexAIImageEditorChat()
```


```python
# Write prompt for editing and pass the "generated_image"
messages = [HumanMessage(content=[generated_image, "a dog at the beach "])]

# Call the model for editing Image
editor_response = editor.invoke(messages)
```


```python
import base64
import io

from PIL import Image

# Parse response object to get base64 string for image
edited_img_base64 = editor_response.content[0]["image_url"]["url"].split(",")[-1]

# Convert base64 string to Image
edited_img = Image.open(
    io.BytesIO(base64.decodebytes(bytes(edited_img_base64, "utf-8")))
)

# view Image
edited_img
```


![](/img/d0f2fe028cdc86a81c8941731cc1e63f.png)

## 이미지 캡셔닝

```python
from langchain_google_vertexai import VertexAIImageCaptioning

# Initialize the Image Captioning Object
model = VertexAIImageCaptioning()
```


참고 : [이미지 생성 섹션](#image-generation)에서 생성된 이미지를 사용하고 있습니다.

```python
# use image egenarted in Image Generation Section
img_base64 = generated_image["image_url"]["url"]
response = model.invoke(img_base64)
print(f"Generated Cpation : {response}")

# Convert base64 string to Image
img = Image.open(
    io.BytesIO(base64.decodebytes(bytes(img_base64.split(",")[-1], "utf-8")))
)

# display Image
img
```

```output
Generated Cpation : a cat sitting on the beach looking at the camera
```


![](/img/41e1ec2a77baa5b8e990268a2cf510f5.png)

## 시각적 질문 응답 (VQA)

```python
from langchain_google_vertexai import VertexAIVisualQnAChat

model = VertexAIVisualQnAChat()
```


참고 : [이미지 생성 섹션](#image-generation)에서 생성된 이미지를 사용하고 있습니다.

```python
question = "What animal is shown in the image?"
response = model.invoke(
    input=[
        HumanMessage(
            content=[
                {"type": "image_url", "image_url": {"url": img_base64}},
                question,
            ]
        )
    ]
)

print(f"question : {question}\nanswer : {response.content}")

# Convert base64 string to Image
img = Image.open(
    io.BytesIO(base64.decodebytes(bytes(img_base64.split(",")[-1], "utf-8")))
)

# display Image
img
```

```output
question : What animal is shown in the image?
answer : cat
```


![](/img/41e1ec2a77baa5b8e990268a2cf510f5.png)

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)