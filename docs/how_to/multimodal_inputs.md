---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/multimodal_inputs.ipynb
description: 모델에 멀티모달 데이터를 직접 전달하는 방법을 설명하며, 이미지 설명 요청 예제를 포함합니다. 다양한 모델 통합 방식을 다룹니다.
---

# 모델에 다중 모달 데이터를 직접 전달하는 방법

여기에서는 다중 모달 입력을 모델에 직접 전달하는 방법을 보여줍니다. 현재 모든 입력이 [OpenAI에서 기대하는 형식](https://platform.openai.com/docs/guides/vision)으로 전달될 것으로 예상합니다. 다중 모달 입력을 지원하는 다른 모델 제공업체에 대해서는 예상 형식으로 변환하는 로직을 클래스 내부에 추가했습니다.

이 예제에서는 모델에게 이미지를 설명하도록 요청할 것입니다.

```python
image_url = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
```


```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to pass multimodal data directly to models"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to pass multimodal data directly to models"}]-->
from langchain_core.messages import HumanMessage
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-4o")
```


이미지를 전달하는 가장 일반적으로 지원되는 방법은 바이트 문자열로 전달하는 것입니다. 이는 대부분의 모델 통합에서 작동해야 합니다.

```python
import base64

import httpx

image_data = base64.b64encode(httpx.get(image_url).content).decode("utf-8")
```


```python
message = HumanMessage(
    content=[
        {"type": "text", "text": "describe the weather in this image"},
        {
            "type": "image_url",
            "image_url": {"url": f"data:image/jpeg;base64,{image_data}"},
        },
    ],
)
response = model.invoke([message])
print(response.content)
```

```output
The weather in the image appears to be clear and pleasant. The sky is mostly blue with scattered, light clouds, suggesting a sunny day with minimal cloud cover. There is no indication of rain or strong winds, and the overall scene looks bright and calm. The lush green grass and clear visibility further indicate good weather conditions.
```

이미지 URL을 "image_url" 유형의 콘텐츠 블록에 직접 전달할 수 있습니다. 이는 일부 모델 제공업체만 지원한다는 점에 유의하세요.

```python
message = HumanMessage(
    content=[
        {"type": "text", "text": "describe the weather in this image"},
        {"type": "image_url", "image_url": {"url": image_url}},
    ],
)
response = model.invoke([message])
print(response.content)
```

```output
The weather in the image appears to be clear and sunny. The sky is mostly blue with a few scattered clouds, suggesting good visibility and a likely pleasant temperature. The bright sunlight is casting distinct shadows on the grass and vegetation, indicating it is likely daytime, possibly late morning or early afternoon. The overall ambiance suggests a warm and inviting day, suitable for outdoor activities.
```

여러 이미지를 전달할 수도 있습니다.

```python
message = HumanMessage(
    content=[
        {"type": "text", "text": "are these two images the same?"},
        {"type": "image_url", "image_url": {"url": image_url}},
        {"type": "image_url", "image_url": {"url": image_url}},
    ],
)
response = model.invoke([message])
print(response.content)
```

```output
Yes, the two images are the same. They both depict a wooden boardwalk extending through a grassy field under a blue sky with light clouds. The scenery, lighting, and composition are identical.
```

## 도구 호출

일부 다중 모달 모델은 [도구 호출](/docs/concepts/#functiontool-calling) 기능도 지원합니다. 이러한 모델을 사용하여 도구를 호출하려면, [일반적인 방법](/docs/how_to/tool_calling)으로 도구를 바인딩하고 원하는 유형의 콘텐츠 블록(예: 이미지 데이터가 포함된 블록)을 사용하여 모델을 호출하면 됩니다.

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to pass multimodal data directly to models"}]-->
from typing import Literal

from langchain_core.tools import tool


@tool
def weather_tool(weather: Literal["sunny", "cloudy", "rainy"]) -> None:
    """Describe the weather"""
    pass


model_with_tools = model.bind_tools([weather_tool])

message = HumanMessage(
    content=[
        {"type": "text", "text": "describe the weather in this image"},
        {"type": "image_url", "image_url": {"url": image_url}},
    ],
)
response = model_with_tools.invoke([message])
print(response.tool_calls)
```

```output
[{'name': 'weather_tool', 'args': {'weather': 'sunny'}, 'id': 'call_BSX4oq4SKnLlp2WlzDhToHBr'}]
```