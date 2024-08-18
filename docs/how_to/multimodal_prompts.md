---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/multimodal_prompts.ipynb
description: 모델에 대한 멀티모달 입력 형식을 지정하는 방법을 보여주며, 이미지 설명 요청 예제를 포함합니다.
---

# 멀티모달 프롬프트 사용 방법

여기에서는 프롬프트 템플릿을 사용하여 모델에 대한 멀티모달 입력을 형식화하는 방법을 보여줍니다.

이 예제에서는 모델에게 이미지를 설명하도록 요청할 것입니다.

```python
import base64

import httpx

image_url = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
image_data = base64.b64encode(httpx.get(image_url).content).decode("utf-8")
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to use multimodal prompts"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to use multimodal prompts"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-4o")
```


```python
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "Describe the image provided"),
        (
            "user",
            [
                {
                    "type": "image_url",
                    "image_url": {"url": "data:image/jpeg;base64,{image_data}"},
                }
            ],
        ),
    ]
)
```


```python
chain = prompt | model
```


```python
response = chain.invoke({"image_data": image_data})
print(response.content)
```

```output
The image depicts a sunny day with a beautiful blue sky filled with scattered white clouds. The sky has varying shades of blue, ranging from a deeper hue near the horizon to a lighter, almost pale blue higher up. The white clouds are fluffy and scattered across the expanse of the sky, creating a peaceful and serene atmosphere. The lighting and cloud patterns suggest pleasant weather conditions, likely during the daytime hours on a mild, sunny day in an outdoor natural setting.
```

우리는 여러 이미지를 전달할 수도 있습니다.

```python
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "compare the two pictures provided"),
        (
            "user",
            [
                {
                    "type": "image_url",
                    "image_url": {"url": "data:image/jpeg;base64,{image_data1}"},
                },
                {
                    "type": "image_url",
                    "image_url": {"url": "data:image/jpeg;base64,{image_data2}"},
                },
            ],
        ),
    ]
)
```


```python
chain = prompt | model
```


```python
response = chain.invoke({"image_data1": image_data, "image_data2": image_data})
print(response.content)
```

```output
The two images provided are identical. Both images feature a wooden boardwalk path extending through a lush green field under a bright blue sky with some clouds. The perspective, colors, and elements in both images are exactly the same.
```