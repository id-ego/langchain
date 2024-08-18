---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/llm_chain.ipynb
description: 이 튜토리얼에서는 LangChain을 사용하여 영어를 다른 언어로 번역하는 간단한 LLM 애플리케이션을 구축하는 방법을 소개합니다.
sidebar_position: 0
---

# LCEL로 간단한 LLM 애플리케이션 구축하기

이 퀵스타트에서는 LangChain을 사용하여 간단한 LLM 애플리케이션을 구축하는 방법을 보여줍니다. 이 애플리케이션은 영어 텍스트를 다른 언어로 번역합니다. 이는 상대적으로 간단한 LLM 애플리케이션으로, 단일 LLM 호출과 몇 가지 프롬프트로 구성됩니다. 그럼에도 불구하고, 이는 LangChain을 시작하는 훌륭한 방법입니다. 몇 가지 프롬프트와 LLM 호출만으로 많은 기능을 구축할 수 있습니다!

이 튜토리얼을 읽은 후에는 다음에 대한 높은 수준의 개요를 갖게 됩니다:

- [언어 모델 사용하기](/docs/concepts/#chat-models)
- [PromptTemplates](/docs/concepts/#prompt-templates) 및 [OutputParsers](/docs/concepts/#output-parsers) 사용하기
- 구성 요소를 연결하기 위한 [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language-lcel) 사용하기
- [LangSmith](/docs/concepts/#langsmith)를 사용하여 애플리케이션 디버깅 및 추적하기
- [LangServe](/docs/concepts/#langserve)를 사용하여 애플리케이션 배포하기

자, 시작해봅시다!

## 설정

### 주피터 노트북

이 가이드(및 문서의 대부분의 다른 가이드)는 [주피터 노트북](https://jupyter.org/)을 사용하며, 독자가 주피터 노트북을 사용한다고 가정합니다. 주피터 노트북은 LLM 시스템을 사용하는 방법을 배우기에 완벽합니다. 왜냐하면 종종 예상치 못한 출력, API 다운 등 문제가 발생할 수 있기 때문입니다. 대화형 환경에서 가이드를 진행하는 것은 이를 더 잘 이해하는 좋은 방법입니다.

이 튜토리얼과 다른 튜토리얼은 주피터 노트북에서 가장 편리하게 실행될 수 있습니다. 설치 방법은 [여기](https://jupyter.org/install)를 참조하세요.

### 설치

LangChain을 설치하려면 다음을 실행하세요:

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import CodeBlock from "@theme/CodeBlock";

<Tabs>
  <TabItem value="pip" label="Pip" default>
    <CodeBlock language="bash">pip install langchain</CodeBlock>
  </TabItem>
  <TabItem value="conda" label="Conda">
    <CodeBlock language="bash">conda install langchain -c conda-forge</CodeBlock>
  </TabItem>
</Tabs>

자세한 내용은 [설치 가이드](/docs/how_to/installation)를 참조하세요.

### LangSmith

LangChain으로 구축하는 많은 애플리케이션은 여러 단계와 여러 LLM 호출을 포함합니다. 이러한 애플리케이션이 점점 더 복잡해짐에 따라 체인이나 에이전트 내부에서 정확히 무슨 일이 일어나고 있는지 검사할 수 있는 것이 중요해집니다. 이를 가장 잘 수행하는 방법은 [LangSmith](https://smith.langchain.com)입니다.

위 링크에서 가입한 후, 환경 변수를 설정하여 추적 로그를 시작하세요:

```shell
export LANGCHAIN_TRACING_V2="true"
export LANGCHAIN_API_KEY="..."
```


또는 노트북에서 다음과 같이 설정할 수 있습니다:

```python
import getpass
import os

os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 언어 모델 사용하기

먼저, 언어 모델을 단독으로 사용하는 방법을 배워봅시다. LangChain은 서로 교환 가능하게 사용할 수 있는 다양한 언어 모델을 지원합니다 - 아래에서 사용하고 싶은 모델을 선택하세요!

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs openaiParams={`model="gpt-4"`} />

먼저 모델을 직접 사용해 보겠습니다. `ChatModel`은 LangChain "Runnables"의 인스턴스로, 이를 상호작용하기 위한 표준 인터페이스를 제공합니다. 모델을 간단히 호출하려면, 메시지 목록을 `.invoke` 메서드에 전달하면 됩니다.

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Build a Simple LLM Application with LCEL"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "Build a Simple LLM Application with LCEL"}]-->
from langchain_core.messages import HumanMessage, SystemMessage

messages = [
    SystemMessage(content="Translate the following from English into Italian"),
    HumanMessage(content="hi!"),
]

model.invoke(messages)
```


```output
AIMessage(content='ciao!', response_metadata={'token_usage': {'completion_tokens': 3, 'prompt_tokens': 20, 'total_tokens': 23}, 'model_name': 'gpt-4', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-fc5d7c88-9615-48ab-a3c7-425232b562c5-0')
```


LangSmith를 활성화했다면, 이 실행이 LangSmith에 기록된 것을 볼 수 있으며, [LangSmith 추적](https://smith.langchain.com/public/88baa0b2-7c1a-4d09-ba30-a47985dde2ea/r)을 확인할 수 있습니다.

## OutputParsers

모델의 응답이 `AIMessage`라는 점에 주목하세요. 이는 문자열 응답과 응답에 대한 기타 메타데이터를 포함합니다. 종종 우리는 문자열 응답만 작업하고 싶을 수 있습니다. 간단한 출력 파서를 사용하여 이 응답만 파싱할 수 있습니다.

먼저 간단한 출력 파서를 가져옵니다.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Build a Simple LLM Application with LCEL"}]-->
from langchain_core.output_parsers import StrOutputParser

parser = StrOutputParser()
```


사용하는 한 가지 방법은 단독으로 사용하는 것입니다. 예를 들어, 언어 모델 호출의 결과를 저장한 다음 이를 파서에 전달할 수 있습니다.

```python
result = model.invoke(messages)
```


```python
parser.invoke(result)
```


```output
'Ciao!'
```


더 일반적으로, 우리는 이 출력 파서와 모델을 "체인"할 수 있습니다. 이는 이 체인에서 매번 이 출력 파서가 호출된다는 것을 의미합니다. 이 체인은 언어 모델의 입력 유형(문자열 또는 메시지 목록)을 가져오고 출력 파서의 출력 유형(문자열)을 반환합니다.

`|` 연산자를 사용하여 쉽게 체인을 생성할 수 있습니다. `|` 연산자는 LangChain에서 두 요소를 결합하는 데 사용됩니다.

```python
chain = model | parser
```


```python
chain.invoke(messages)
```


```output
'Ciao!'
```


이제 LangSmith를 살펴보면, 체인에 두 단계가 있음을 볼 수 있습니다: 먼저 언어 모델이 호출되고, 그 결과가 출력 파서에 전달됩니다. 우리는 [LangSmith 추적](https://smith.langchain.com/public/f1bdf656-2739-42f7-ac7f-0f1dd712322f/r)을 확인할 수 있습니다.

## 프롬프트 템플릿

현재 우리는 메시지 목록을 언어 모델에 직접 전달하고 있습니다. 이 메시지 목록은 어디에서 오는 것일까요? 일반적으로 이는 사용자 입력과 애플리케이션 로직의 조합으로 구성됩니다. 이 애플리케이션 로직은 일반적으로 원시 사용자 입력을 가져와 언어 모델에 전달할 준비가 된 메시지 목록으로 변환합니다. 일반적인 변환에는 시스템 메시지를 추가하거나 사용자 입력으로 템플릿을 형식화하는 것이 포함됩니다.

프롬프트 템플릿은 이 변환을 지원하기 위해 LangChain에서 설계된 개념입니다. 이는 원시 사용자 입력을 받아 언어 모델에 전달할 준비가 된 데이터(프롬프트)를 반환합니다.

여기에서 프롬프트 템플릿을 만들어 보겠습니다. 이는 두 개의 사용자 변수를 입력으로 받습니다:

- `language`: 텍스트를 번역할 언어
- `text`: 번역할 텍스트

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Build a Simple LLM Application with LCEL"}]-->
from langchain_core.prompts import ChatPromptTemplate
```


먼저, 시스템 메시지로 형식화할 문자열을 생성해 보겠습니다:

```python
system_template = "Translate the following into {language}:"
```


다음으로, 프롬프트 템플릿을 생성할 수 있습니다. 이는 `system_template`과 번역할 텍스트를 넣을 간단한 템플릿의 조합이 될 것입니다.

```python
prompt_template = ChatPromptTemplate.from_messages(
    [("system", system_template), ("user", "{text}")]
)
```


이 프롬프트 템플릿의 입력은 사전입니다. 이 프롬프트 템플릿을 단독으로 사용하여 무엇을 하는지 살펴볼 수 있습니다.

```python
result = prompt_template.invoke({"language": "italian", "text": "hi"})

result
```


```output
ChatPromptValue(messages=[SystemMessage(content='Translate the following into italian:'), HumanMessage(content='hi')])
```


우리는 두 개의 메시지로 구성된 `ChatPromptValue`를 반환하는 것을 볼 수 있습니다. 메시지에 직접 접근하려면 다음과 같이 합니다:

```python
result.to_messages()
```


```output
[SystemMessage(content='Translate the following into italian:'),
 HumanMessage(content='hi')]
```


## LCEL로 구성 요소 연결하기

이제 위의 모델과 출력 파서와 결합하여 파이프(`|`) 연산자를 사용할 수 있습니다:

```python
chain = prompt_template | model | parser
```


```python
chain.invoke({"language": "italian", "text": "hi"})
```


```output
'ciao'
```


이는 [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language-lcel)을 사용하여 LangChain 모듈을 연결하는 간단한 예입니다. 이 접근 방식에는 최적화된 스트리밍 및 추적 지원을 포함한 여러 이점이 있습니다.

LangSmith 추적을 살펴보면, 세 가지 구성 요소가 모두 [LangSmith 추적](https://smith.langchain.com/public/bc49bec0-6b13-4726-967f-dbd3448b786d/r)에 나타나는 것을 볼 수 있습니다.

## LangServe로 서비스하기

이제 애플리케이션을 구축했으므로 이를 서비스해야 합니다. 여기서 LangServe가 등장합니다. LangServe는 개발자가 LangChain 체인을 REST API로 배포하는 데 도움을 줍니다. LangChain을 사용하기 위해 LangServe를 사용할 필요는 없지만, 이 가이드에서는 LangServe로 앱을 배포하는 방법을 보여줍니다.

이 가이드의 첫 번째 부분은 주피터 노트북이나 스크립트에서 실행되도록 설계되었지만, 이제 우리는 그곳을 벗어나겠습니다. Python 파일을 생성한 다음 명령줄에서 상호작용할 것입니다.

설치하려면:
```bash
pip install "langserve[all]"
```


### 서버

애플리케이션을 위한 서버를 만들기 위해 `serve.py` 파일을 만들 것입니다. 이 파일에는 애플리케이션을 제공하기 위한 로직이 포함됩니다. 이는 세 가지로 구성됩니다:
1. 위에서 구축한 체인의 정의
2. FastAPI 앱
3. 체인을 제공할 경로의 정의, 이는 `langserve.add_routes`로 수행됩니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Build a Simple LLM Application with LCEL"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Build a Simple LLM Application with LCEL"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Build a Simple LLM Application with LCEL"}]-->
#!/usr/bin/env python
from typing import List

from fastapi import FastAPI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import ChatOpenAI
from langserve import add_routes

# 1. Create prompt template
system_template = "Translate the following into {language}:"
prompt_template = ChatPromptTemplate.from_messages([
    ('system', system_template),
    ('user', '{text}')
])

# 2. Create model
model = ChatOpenAI()

# 3. Create parser
parser = StrOutputParser()

# 4. Create chain
chain = prompt_template | model | parser


# 4. App definition
app = FastAPI(
  title="LangChain Server",
  version="1.0",
  description="A simple API server using LangChain's Runnable interfaces",
)

# 5. Adding chain route

add_routes(
    app,
    chain,
    path="/chain",
)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="localhost", port=8000)
```


그게 전부입니다! 이 파일을 실행하면:
```bash
python serve.py
```

[http://localhost:8000](http://localhost:8000)에서 체인이 제공되는 것을 볼 수 있습니다.

### 플레이그라운드

모든 LangServe 서비스에는 스트리밍 출력 및 중간 단계에 대한 가시성을 통해 애플리케이션을 구성하고 호출할 수 있는 간단한 [내장 UI](https://github.com/langchain-ai/langserve/blob/main/README.md#playground)가 제공됩니다. [http://localhost:8000/chain/playground/](http://localhost:8000/chain/playground/)로 이동하여 사용해 보세요! 이전과 동일한 입력을 전달하세요 - `{"language": "italian", "text": "hi"}` - 그러면 이전과 동일하게 응답해야 합니다.

### 클라이언트

이제 서비스와 프로그래밍 방식으로 상호작용할 클라이언트를 설정해 보겠습니다. 우리는 [langserve.RemoteRunnable](/docs/langserve/#client)를 사용하여 이를 쉽게 수행할 수 있습니다. 이를 사용하면 클라이언트 측에서 실행되는 것처럼 제공된 체인과 상호작용할 수 있습니다.

```python
from langserve import RemoteRunnable

remote_chain = RemoteRunnable("http://localhost:8000/chain/")
remote_chain.invoke({"language": "italian", "text": "hi"})
```


```output
'Ciao'
```


LangServe의 많은 다른 기능에 대해 더 알아보려면 [여기](https://docs/langserve/)를 방문하세요.

## 결론

이게 전부입니다! 이 튜토리얼에서 여러분은 첫 번째 간단한 LLM 애플리케이션을 만드는 방법을 배웠습니다. 언어 모델을 사용하는 방법, 출력 파서를 사용하는 방법, 프롬프트 템플릿을 만드는 방법, LCEL로 체인을 연결하는 방법, LangSmith로 생성한 체인에 대한 훌륭한 가시성을 얻는 방법, 그리고 LangServe로 이를 배포하는 방법을 배웠습니다.

이는 여러분이 능숙한 AI 엔지니어가 되기 위해 배우고 싶어하는 것의 표면을 긁어내는 것에 불과합니다. 다행히도 - 우리는 많은 다른 리소스를 가지고 있습니다!

LangChain의 핵심 개념에 대한 추가 읽기를 원하신다면, 자세한 [개념 가이드](/docs/concepts)를 확인하세요.

이러한 개념에 대한 더 구체적인 질문이 있다면, 다음의 방법 가이드 섹션을 확인하세요:

- [LangChain 표현 언어 (LCEL)](/docs/how_to/#langchain-expression-language-lcel)
- [프롬프트 템플릿](/docs/how_to/#prompt-templates)
- [채팅 모델](/docs/how_to/#chat-models)
- [출력 파서](/docs/how_to/#output-parsers)
- [LangServe](/docs/langserve/)

그리고 LangSmith 문서:

- [LangSmith](https://docs.smith.langchain.com)