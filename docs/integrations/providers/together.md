---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/together.ipynb
description: Together AI는 간단한 코드로 50개 이상의 오픈 소스 모델에 접근할 수 있는 API를 제공합니다. LangChain과의
  상호작용 방법을 소개합니다.
---

# Together AI

[Together AI](https://www.together.ai/)는 몇 줄의 코드로 [50개 이상의 주요 오픈 소스 모델](https://docs.together.ai/docs/inference-models)을 쿼리할 수 있는 API를 제공합니다.

이 예제에서는 LangChain을 사용하여 Together AI 모델과 상호 작용하는 방법을 설명합니다.

## Installation

```python
%pip install --upgrade langchain-together
```


## Environment

Together AI를 사용하려면 API 키가 필요하며, 이는 여기에서 찾을 수 있습니다:  
https://api.together.ai/settings/api-keys. 이 키는 초기화 매개변수 `together_api_key`로 전달하거나 환경 변수 `TOGETHER_API_KEY`로 설정할 수 있습니다.

## Example

```python
<!--IMPORTS:[{"imported": "ChatTogether", "source": "langchain_together", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_together.chat_models.ChatTogether.html", "title": "Together AI"}]-->
# Querying chat models with Together AI

from langchain_together import ChatTogether

# choose from our 50+ models here: https://docs.together.ai/docs/inference-models
chat = ChatTogether(
    # together_api_key="YOUR_API_KEY",
    model="meta-llama/Llama-3-70b-chat-hf",
)

# stream the response back from the model
for m in chat.stream("Tell me fun things to do in NYC"):
    print(m.content, end="", flush=True)

# if you don't want to do streaming, you can use the invoke method
# chat.invoke("Tell me fun things to do in NYC")
```


```python
<!--IMPORTS:[{"imported": "Together", "source": "langchain_together", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_together.llms.Together.html", "title": "Together AI"}]-->
# Querying code and language models with Together AI

from langchain_together import Together

llm = Together(
    model="codellama/CodeLlama-70b-Python-hf",
    # together_api_key="..."
)

print(llm.invoke("def bubble_sort(): "))
```