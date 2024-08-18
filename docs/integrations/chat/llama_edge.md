---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/llama_edge.ipynb
description: LlamaEdge는 GGUF 형식의 LLM과 채팅할 수 있는 서비스로, API 및 로컬 환경에서 사용 가능합니다. WebAssembly
  기반으로 경량화되었습니다.
---

# LlamaEdge

[LlamaEdge](https://github.com/second-state/LlamaEdge)는 [GGUF](https://github.com/ggerganov/llama.cpp/blob/master/gguf-py/README.md) 형식의 LLM과 로컬 및 채팅 서비스를 통해 대화할 수 있게 해줍니다.

- `LlamaEdgeChatService`는 개발자에게 HTTP 요청을 통해 LLM과 대화할 수 있는 OpenAI API 호환 서비스를 제공합니다.
- `LlamaEdgeChatLocal`은 개발자가 로컬에서 LLM과 대화할 수 있게 해줍니다(곧 출시 예정).

`LlamaEdgeChatService`와 `LlamaEdgeChatLocal`은 LLM 추론 작업을 위한 경량화되고 이식 가능한 WebAssembly 컨테이너 환경을 제공하는 [WasmEdge Runtime](https://wasmedge.org/) 기반 인프라에서 실행됩니다.

## API 서비스로 채팅하기

`LlamaEdgeChatService`는 `llama-api-server`에서 작동합니다. [llama-api-server 빠른 시작](https://github.com/second-state/llama-utils/tree/main/api-server#readme)의 단계를 따르면, 인터넷이 가능한 한 어떤 장치에서든 원하는 모델과 대화할 수 있는 API 서비스를 호스팅할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "LlamaEdgeChatService", "source": "langchain_community.chat_models.llama_edge", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.llama_edge.LlamaEdgeChatService.html", "title": "LlamaEdge"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "LlamaEdge"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "LlamaEdge"}]-->
from langchain_community.chat_models.llama_edge import LlamaEdgeChatService
from langchain_core.messages import HumanMessage, SystemMessage
```


### 비스트리밍 모드에서 LLM과 대화하기

```python
# service url
service_url = "https://b008-54-186-154-209.ngrok-free.app"

# create wasm-chat service instance
chat = LlamaEdgeChatService(service_url=service_url)

# create message sequence
system_message = SystemMessage(content="You are an AI assistant")
user_message = HumanMessage(content="What is the capital of France?")
messages = [system_message, user_message]

# chat with wasm-chat service
response = chat.invoke(messages)

print(f"[Bot] {response.content}")
```

```output
[Bot] Hello! The capital of France is Paris.
```

### 스트리밍 모드에서 LLM과 대화하기

```python
# service url
service_url = "https://b008-54-186-154-209.ngrok-free.app"

# create wasm-chat service instance
chat = LlamaEdgeChatService(service_url=service_url, streaming=True)

# create message sequence
system_message = SystemMessage(content="You are an AI assistant")
user_message = HumanMessage(content="What is the capital of Norway?")
messages = [
    system_message,
    user_message,
]

output = ""
for chunk in chat.stream(messages):
    # print(chunk.content, end="", flush=True)
    output += chunk.content

print(f"[Bot] {output}")
```

```output
[Bot]   Hello! I'm happy to help you with your question. The capital of Norway is Oslo.
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)