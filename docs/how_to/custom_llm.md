---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/custom_llm.ipynb
description: 이 문서는 사용자 정의 LLM 래퍼를 생성하는 방법을 설명하며, LangChain 프로그램에서 최소한의 코드 수정으로 LLM을
  사용할 수 있게 합니다.
---

# 사용자 정의 LLM 클래스 생성 방법

이 노트북은 LangChain에서 지원하는 것과 다른 래퍼나 자신의 LLM을 사용하고자 할 때 사용자 정의 LLM 래퍼를 만드는 방법을 다룹니다.

표준 `LLM` 인터페이스로 LLM을 래핑하면 최소한의 코드 수정으로 기존 LangChain 프로그램에서 LLM을 사용할 수 있습니다!

보너스로, 귀하의 LLM은 자동으로 LangChain `Runnable`이 되어 기본적으로 일부 최적화, 비동기 지원, `astream_events` API 등의 혜택을 누릴 수 있습니다.

## 구현

사용자 정의 LLM이 구현해야 하는 필수 사항은 두 가지입니다:

| 메서드        | 설명                                                               |
|---------------|-------------------------------------------------------------------|
| `_call`       | 문자열과 몇 가지 선택적 중지 단어를 받아 문자열을 반환합니다. `invoke`에서 사용됩니다. |
| `_llm_type`   | 문자열을 반환하는 속성으로, 로깅 목적으로만 사용됩니다.        

선택적 구현: 

| 메서드    | 설명                                                                                               |
|----------------------|-----------------------------------------------------------------------------------------------------------|
| `_identifying_params` | 모델 식별 및 LLM 인쇄에 도움을 주기 위해 사용됩니다; 사전(dictionary)을 반환해야 합니다. 이는 **@property**입니다.                 |
| `_acall`              | `_call`의 비동기 네이티브 구현을 제공하며, `ainvoke`에서 사용됩니다.                                    |
| `_stream`             | 출력 토큰을 하나씩 스트리밍하는 메서드입니다.                                                               |
| `_astream`            | `_stream`의 비동기 네이티브 구현을 제공하며, 최신 LangChain 버전에서는 기본적으로 `_stream`으로 설정됩니다. |

입력의 첫 n 문자를 반환하는 간단한 사용자 정의 LLM을 구현해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "CallbackManagerForLLMRun", "source": "langchain_core.callbacks.manager", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManagerForLLMRun.html", "title": "How to create a custom LLM class"}, {"imported": "LLM", "source": "langchain_core.language_models.llms", "docs": "https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.llms.LLM.html", "title": "How to create a custom LLM class"}, {"imported": "GenerationChunk", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.generation.GenerationChunk.html", "title": "How to create a custom LLM class"}]-->
from typing import Any, Dict, Iterator, List, Mapping, Optional

from langchain_core.callbacks.manager import CallbackManagerForLLMRun
from langchain_core.language_models.llms import LLM
from langchain_core.outputs import GenerationChunk


class CustomLLM(LLM):
    """A custom chat model that echoes the first `n` characters of the input.

    When contributing an implementation to LangChain, carefully document
    the model including the initialization parameters, include
    an example of how to initialize the model and include any relevant
    links to the underlying models documentation or API.

    Example:

        .. code-block:: python

            model = CustomChatModel(n=2)
            result = model.invoke([HumanMessage(content="hello")])
            result = model.batch([[HumanMessage(content="hello")],
                                 [HumanMessage(content="world")]])
    """

    n: int
    """The number of characters from the last message of the prompt to be echoed."""

    def _call(
        self,
        prompt: str,
        stop: Optional[List[str]] = None,
        run_manager: Optional[CallbackManagerForLLMRun] = None,
        **kwargs: Any,
    ) -> str:
        """Run the LLM on the given input.

        Override this method to implement the LLM logic.

        Args:
            prompt: The prompt to generate from.
            stop: Stop words to use when generating. Model output is cut off at the
                first occurrence of any of the stop substrings.
                If stop tokens are not supported consider raising NotImplementedError.
            run_manager: Callback manager for the run.
            **kwargs: Arbitrary additional keyword arguments. These are usually passed
                to the model provider API call.

        Returns:
            The model output as a string. Actual completions SHOULD NOT include the prompt.
        """
        if stop is not None:
            raise ValueError("stop kwargs are not permitted.")
        return prompt[: self.n]

    def _stream(
        self,
        prompt: str,
        stop: Optional[List[str]] = None,
        run_manager: Optional[CallbackManagerForLLMRun] = None,
        **kwargs: Any,
    ) -> Iterator[GenerationChunk]:
        """Stream the LLM on the given prompt.

        This method should be overridden by subclasses that support streaming.

        If not implemented, the default behavior of calls to stream will be to
        fallback to the non-streaming version of the model and return
        the output as a single chunk.

        Args:
            prompt: The prompt to generate from.
            stop: Stop words to use when generating. Model output is cut off at the
                first occurrence of any of these substrings.
            run_manager: Callback manager for the run.
            **kwargs: Arbitrary additional keyword arguments. These are usually passed
                to the model provider API call.

        Returns:
            An iterator of GenerationChunks.
        """
        for char in prompt[: self.n]:
            chunk = GenerationChunk(text=char)
            if run_manager:
                run_manager.on_llm_new_token(chunk.text, chunk=chunk)

            yield chunk

    @property
    def _identifying_params(self) -> Dict[str, Any]:
        """Return a dictionary of identifying parameters."""
        return {
            # The model name allows users to specify custom token counting
            # rules in LLM monitoring applications (e.g., in LangSmith users
            # can provide per token pricing for their model and monitor
            # costs for the given LLM.)
            "model_name": "CustomChatModel",
        }

    @property
    def _llm_type(self) -> str:
        """Get the type of language model used by this chat model. Used for logging purposes only."""
        return "custom"
```


### 테스트해 보겠습니다 🧪

이 LLM은 LangChain의 표준 `Runnable` 인터페이스를 구현하며, 많은 LangChain 추상화에서 지원됩니다!

```python
llm = CustomLLM(n=5)
print(llm)
```

```output
[1mCustomLLM[0m
Params: {'model_name': 'CustomChatModel'}
```


```python
llm.invoke("This is a foobar thing")
```


```output
'This '
```


```python
await llm.ainvoke("world")
```


```output
'world'
```


```python
llm.batch(["woof woof woof", "meow meow meow"])
```


```output
['woof ', 'meow ']
```


```python
await llm.abatch(["woof woof woof", "meow meow meow"])
```


```output
['woof ', 'meow ']
```


```python
async for token in llm.astream("hello"):
    print(token, end="|", flush=True)
```

```output
h|e|l|l|o|
```

다른 `LangChain` API와 잘 통합되는지 확인해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to create a custom LLM class"}]-->
from langchain_core.prompts import ChatPromptTemplate
```


```python
prompt = ChatPromptTemplate.from_messages(
    [("system", "you are a bot"), ("human", "{input}")]
)
```


```python
llm = CustomLLM(n=7)
chain = prompt | llm
```


```python
idx = 0
async for event in chain.astream_events({"input": "hello there!"}, version="v1"):
    print(event)
    idx += 1
    if idx > 7:
        # Truncate
        break
```

```output
{'event': 'on_chain_start', 'run_id': '05f24b4f-7ea3-4fb6-8417-3aa21633462f', 'name': 'RunnableSequence', 'tags': [], 'metadata': {}, 'data': {'input': {'input': 'hello there!'}}}
{'event': 'on_prompt_start', 'name': 'ChatPromptTemplate', 'run_id': '7e996251-a926-4344-809e-c425a9846d21', 'tags': ['seq:step:1'], 'metadata': {}, 'data': {'input': {'input': 'hello there!'}}}
{'event': 'on_prompt_end', 'name': 'ChatPromptTemplate', 'run_id': '7e996251-a926-4344-809e-c425a9846d21', 'tags': ['seq:step:1'], 'metadata': {}, 'data': {'input': {'input': 'hello there!'}, 'output': ChatPromptValue(messages=[SystemMessage(content='you are a bot'), HumanMessage(content='hello there!')])}}
{'event': 'on_llm_start', 'name': 'CustomLLM', 'run_id': 'a8766beb-10f4-41de-8750-3ea7cf0ca7e2', 'tags': ['seq:step:2'], 'metadata': {}, 'data': {'input': {'prompts': ['System: you are a bot\nHuman: hello there!']}}}
{'event': 'on_llm_stream', 'name': 'CustomLLM', 'run_id': 'a8766beb-10f4-41de-8750-3ea7cf0ca7e2', 'tags': ['seq:step:2'], 'metadata': {}, 'data': {'chunk': 'S'}}
{'event': 'on_chain_stream', 'run_id': '05f24b4f-7ea3-4fb6-8417-3aa21633462f', 'tags': [], 'metadata': {}, 'name': 'RunnableSequence', 'data': {'chunk': 'S'}}
{'event': 'on_llm_stream', 'name': 'CustomLLM', 'run_id': 'a8766beb-10f4-41de-8750-3ea7cf0ca7e2', 'tags': ['seq:step:2'], 'metadata': {}, 'data': {'chunk': 'y'}}
{'event': 'on_chain_stream', 'run_id': '05f24b4f-7ea3-4fb6-8417-3aa21633462f', 'tags': [], 'metadata': {}, 'name': 'RunnableSequence', 'data': {'chunk': 'y'}}
```

## 기여하기

모든 채팅 모델 통합 기여를 감사히 생각합니다. 

귀하의 기여가 LangChain에 추가될 수 있도록 돕기 위한 체크리스트입니다:

문서화:

* 모델은 모든 초기화 인수에 대한 문서 문자열을 포함해야 하며, 이는 [APIReference](https://api.python.langchain.com/en/stable/langchain_api_reference.html)에서 표시됩니다.
* 모델의 클래스 문서 문자열에는 모델이 서비스에 의해 구동되는 경우 모델 API에 대한 링크가 포함되어야 합니다.

테스트:

* [ ] 재정의된 메서드에 단위 또는 통합 테스트를 추가합니다. 해당 코드를 재정의한 경우 `invoke`, `ainvoke`, `batch`, `stream`이 작동하는지 확인합니다.

스트리밍(구현하는 경우):

* [ ] `on_llm_new_token` 콜백을 호출해야 합니다.
* [ ] 청크를 제공하기 전에 `on_llm_new_token`이 호출됩니다.

중지 토큰 동작:

* [ ] 중지 토큰이 존중되어야 합니다.
* [ ] 중지 토큰은 응답의 일부로 포함되어야 합니다.

비밀 API 키:

* [ ] 모델이 API에 연결되는 경우 초기화의 일부로 API 키를 수락할 가능성이 높습니다. 비밀이 우연히 출력되지 않도록 Pydantic의 `SecretStr` 유형을 사용합니다.