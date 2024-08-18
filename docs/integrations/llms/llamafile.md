---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/llamafile.ipynb
description: Llamafile은 LLM을 단일 파일로 배포하고 실행할 수 있게 해주는 도구로, 복잡성을 줄여 로컬에서 쉽게 사용할 수 있습니다.
---

# Llamafile

[Llamafile](https://github.com/Mozilla-Ocho/llamafile)는 단일 파일로 LLM을 배포하고 실행할 수 있게 해줍니다.

Llamafile은 [llama.cpp](https://github.com/ggerganov/llama.cpp)와 [Cosmopolitan Libc](https://github.com/jart/cosmopolitan)를 결합하여 모든 LLM의 복잡성을 단일 실행 파일(“llamafile”이라고 함)로 축소하여 대부분의 컴퓨터에서 로컬로 실행할 수 있도록 합니다. 설치가 필요 없습니다.

## 설정

1. 사용하고 싶은 모델의 llamafile을 다운로드합니다. [HuggingFace](https://huggingface.co/models?other=llamafile)에서 llamafile 형식의 많은 모델을 찾을 수 있습니다. 이 가이드에서는 작은 모델인 `TinyLlama-1.1B-Chat-v1.0.Q5_K_M`을 다운로드합니다. 참고: `wget`이 없다면 이 [링크](https://huggingface.co/jartine/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile?download=true)를 통해 모델을 다운로드할 수 있습니다.

```bash
wget https://huggingface.co/jartine/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile
```


2. llamafile을 실행 가능하게 만듭니다. 먼저, 아직 하지 않았다면 터미널을 엽니다. **MacOS, Linux 또는 BSD를 사용하는 경우,** `chmod`를 사용하여 이 새 파일을 실행할 수 있는 권한을 부여해야 합니다(아래 참조). **Windows를 사용하는 경우,** 파일 이름 끝에 ".exe"를 추가하여 파일 이름을 변경합니다(모델 파일 이름은 `TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile.exe`여야 합니다).

```bash
chmod +x TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile  # run if you're on MacOS, Linux, or BSD
```


3. "서버 모드"에서 llamafile을 실행합니다:

```bash
./TinyLlama-1.1B-Chat-v1.0.Q5_K_M.llamafile --server --nobrowser
```


이제 llamafile의 REST API에 호출할 수 있습니다. 기본적으로 llamafile 서버는 http://localhost:8080에서 수신 대기합니다. 전체 서버 문서는 [여기](https://github.com/Mozilla-Ocho/llamafile/blob/main/llama.cpp/server/README.md#api-endpoints)에서 확인할 수 있습니다. REST API를 통해 llamafile과 직접 상호작용할 수 있지만, 여기서는 LangChain을 사용하여 상호작용하는 방법을 보여줍니다.

## 사용법

```python
<!--IMPORTS:[{"imported": "Llamafile", "source": "langchain_community.llms.llamafile", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.llamafile.Llamafile.html", "title": "Llamafile"}]-->
from langchain_community.llms.llamafile import Llamafile

llm = Llamafile()

llm.invoke("Tell me a joke")
```


```output
'? \nI\'ve got a thing for pink, but you know that.\n"Can we not talk about work anymore?" - What did she say?\nI don\'t want to be a burden on you.\nIt\'s hard to keep a good thing going.\nYou can\'t tell me what I want, I have a life too!'
```


토큰을 스트리밍하려면 `.stream(...)` 메서드를 사용합니다:

```python
query = "Tell me a joke"

for chunks in llm.stream(query):
    print(chunks, end="")

print()
```

```output
.
- She said, "I’m tired of my life. What should I do?"
- The man replied, "I hear you. But don’t worry. Life is just like a joke. It has its funny parts too."
- The woman looked at him, amazed and happy to hear his wise words. - "Thank you for your wisdom," she said, smiling. - He replied, "Any time. But it doesn't come easy. You have to laugh and keep moving forward in life."
- She nodded, thanking him again. - The man smiled wryly. "Life can be tough. Sometimes it seems like you’re never going to get out of your situation."
- He said, "I know that. But the key is not giving up. Life has many ups and downs, but in the end, it will turn out okay."
- The woman's eyes softened. "Thank you for your advice. It's so important to keep moving forward in life," she said. - He nodded once again. "You’re welcome. I hope your journey is filled with laughter and joy."
- They both smiled and left the bar, ready to embark on their respective adventures.
```

LangChain 표현 언어 및 LLM에서 사용할 수 있는 메서드에 대해 더 알아보려면 [LCEL 인터페이스](/docs/concepts#interface)를 참조하세요.

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)