---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/output_parser_custom.ipynb
description: 사용자 정의 출력 파서를 만드는 방법에 대한 가이드를 제공합니다. 간단한 예제와 함께 RunnableLambda 및 RunnableGenerator
  사용법을 설명합니다.
---

# 사용자 정의 출력 파서 만들기

일부 상황에서는 모델 출력을 사용자 정의 형식으로 구조화하기 위해 사용자 정의 파서를 구현하고 싶을 수 있습니다.

사용자 정의 파서를 구현하는 방법은 두 가지가 있습니다:

1. LCEL의 `RunnableLambda` 또는 `RunnableGenerator` 사용 -- 대부분의 사용 사례에 대해 이 방법을 강력히 추천합니다.
2. 출력 파싱을 위한 기본 클래스 중 하나에서 상속받기 -- 이는 어려운 방법입니다.

두 접근 방식의 차이는 주로 피상적이며, 주로 어떤 콜백이 트리거되는지(예: `on_chain_start` 대 `on_parser_start`)와 실행 가능한 람다와 파서가 LangSmith와 같은 추적 플랫폼에서 어떻게 시각화되는지에 관한 것입니다.

## 실행 가능한 람다 및 생성기

추천하는 파싱 방법은 **실행 가능한 람다**와 **실행 가능한 생성기**를 사용하는 것입니다!

여기서는 모델의 출력을 반전시키는 간단한 파서를 만들 것입니다.

예를 들어, 모델이 "Meow"를 출력하면, 파서는 "mEOW"를 생성합니다.

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to create a custom Output Parser"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to create a custom Output Parser"}, {"imported": "AIMessageChunk", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html", "title": "How to create a custom Output Parser"}]-->
from typing import Iterable

from langchain_anthropic.chat_models import ChatAnthropic
from langchain_core.messages import AIMessage, AIMessageChunk

model = ChatAnthropic(model_name="claude-2.1")


def parse(ai_message: AIMessage) -> str:
    """Parse the AI message."""
    return ai_message.content.swapcase()


chain = model | parse
chain.invoke("hello")
```


```output
'hELLO!'
```


:::tip

LCEL은 `|` 구문을 사용하여 구성할 때 함수 `parse`를 `RunnableLambda(parse)`로 자동 업그레이드합니다.

이것이 마음에 들지 않으면 `RunnableLambda`를 수동으로 가져온 다음 `parse = RunnableLambda(parse)`를 실행할 수 있습니다.
:::

스트리밍이 작동하나요?

```python
for chunk in chain.stream("tell me about yourself in one sentence"):
    print(chunk, end="|", flush=True)
```

```output
i'M cLAUDE, AN ai ASSISTANT CREATED BY aNTHROPIC TO BE HELPFUL, HARMLESS, AND HONEST.|
```

아니요, 작동하지 않습니다. 왜냐하면 파서가 출력을 파싱하기 전에 입력을 집계하기 때문입니다.

스트리밍 파서를 구현하려면, 파서가 입력에 대한 반복 가능성을 수용하고 결과를 사용 가능한 대로 생성하도록 할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "RunnableGenerator", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableGenerator.html", "title": "How to create a custom Output Parser"}]-->
from langchain_core.runnables import RunnableGenerator


def streaming_parse(chunks: Iterable[AIMessageChunk]) -> Iterable[str]:
    for chunk in chunks:
        yield chunk.content.swapcase()


streaming_parse = RunnableGenerator(streaming_parse)
```


:::important

스트리밍 파서를 `RunnableGenerator`로 감싸주세요. `|` 구문으로 자동 업그레이드를 중지할 수 있습니다.
:::

```python
chain = model | streaming_parse
chain.invoke("hello")
```


```output
'hELLO!'
```


스트리밍이 작동하는지 확인해 봅시다!

```python
for chunk in chain.stream("tell me about yourself in one sentence"):
    print(chunk, end="|", flush=True)
```

```output
i|'M| cLAUDE|,| AN| ai| ASSISTANT| CREATED| BY| aN|THROP|IC| TO| BE| HELPFUL|,| HARMLESS|,| AND| HONEST|.|
```

## 파싱 기본 클래스에서 상속하기

파서를 구현하는 또 다른 접근 방식은 `BaseOutputParser`, `BaseGenerationOutputParser` 또는 필요한 것에 따라 다른 기본 파서에서 상속하는 것입니다.

일반적으로 우리는 대부분의 사용 사례에 대해 이 접근 방식을 **추천하지 않습니다**. 이는 상당한 이점 없이 더 많은 코드를 작성해야 하기 때문입니다.

가장 간단한 출력 파서는 `BaseOutputParser` 클래스를 확장하고 다음 메서드를 구현해야 합니다:

* `parse`: 모델의 문자열 출력을 받아 파싱합니다.
* (선택 사항) `_type`: 파서의 이름을 식별합니다.

채팅 모델 또는 LLM의 출력이 잘못된 형식일 경우, 잘못된 입력으로 인해 파싱이 실패했음을 나타내기 위해 `OutputParserException`을 발생시킬 수 있습니다. 이 예외를 사용하면 파서를 활용하는 코드가 예외를 일관되게 처리할 수 있습니다.

:::tip 파서는 실행 가능하다! 🏃

`BaseOutputParser`가 `Runnable` 인터페이스를 구현하기 때문에, 이 방법으로 생성하는 모든 사용자 정의 파서는 유효한 LangChain 실행 가능 객체가 되며 자동 비동기 지원, 배치 인터페이스, 로깅 지원 등의 혜택을 누릴 수 있습니다.
:::

### 간단한 파서

다음은 **문자열** 표현을 파싱하여 해당 `boolean` 유형으로 변환할 수 있는 간단한 파서입니다 (예: `YES` 또는 `NO`).

```python
<!--IMPORTS:[{"imported": "OutputParserException", "source": "langchain_core.exceptions", "docs": "https://api.python.langchain.com/en/latest/exceptions/langchain_core.exceptions.OutputParserException.html", "title": "How to create a custom Output Parser"}, {"imported": "BaseOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.base.BaseOutputParser.html", "title": "How to create a custom Output Parser"}]-->
from langchain_core.exceptions import OutputParserException
from langchain_core.output_parsers import BaseOutputParser


# The [bool] desribes a parameterization of a generic.
# It's basically indicating what the return type of parse is
# in this case the return type is either True or False
class BooleanOutputParser(BaseOutputParser[bool]):
    """Custom boolean parser."""

    true_val: str = "YES"
    false_val: str = "NO"

    def parse(self, text: str) -> bool:
        cleaned_text = text.strip().upper()
        if cleaned_text not in (self.true_val.upper(), self.false_val.upper()):
            raise OutputParserException(
                f"BooleanOutputParser expected output value to either be "
                f"{self.true_val} or {self.false_val} (case-insensitive). "
                f"Received {cleaned_text}."
            )
        return cleaned_text == self.true_val.upper()

    @property
    def _type(self) -> str:
        return "boolean_output_parser"
```


```python
parser = BooleanOutputParser()
parser.invoke("YES")
```


```output
True
```


```python
try:
    parser.invoke("MEOW")
except Exception as e:
    print(f"Triggered an exception of type: {type(e)}")
```

```output
Triggered an exception of type: <class 'langchain_core.exceptions.OutputParserException'>
```

매개변수 변경을 테스트해 봅시다.

```python
parser = BooleanOutputParser(true_val="OKAY")
parser.invoke("OKAY")
```


```output
True
```


다른 LCEL 메서드가 있는지 확인해 봅시다.

```python
parser.batch(["OKAY", "NO"])
```


```output
[True, False]
```


```python
await parser.abatch(["OKAY", "NO"])
```


```output
[True, False]
```


```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to create a custom Output Parser"}]-->
from langchain_anthropic.chat_models import ChatAnthropic

anthropic = ChatAnthropic(model_name="claude-2.1")
anthropic.invoke("say OKAY or NO")
```


```output
AIMessage(content='OKAY')
```


우리의 파서가 작동하는지 테스트해 봅시다!

```python
chain = anthropic | parser
chain.invoke("say OKAY or NO")
```


```output
True
```


:::note
파서는 LLM의 출력(문자열) 또는 채팅 모델의 출력(`AIMessage`) 모두에서 작동합니다!
:::

### 원시 모델 출력 파싱

때때로 원시 텍스트 외에 모델 출력에 중요한 추가 메타데이터가 있습니다. 그 예로는 도구 호출이 있으며, 호출된 함수에 전달될 인수가 별도의 속성으로 반환됩니다. 이러한 세밀한 제어가 필요하다면 `BaseGenerationOutputParser` 클래스를 대신 서브클래싱할 수 있습니다.

이 클래스는 단일 메서드 `parse_result`를 요구합니다. 이 메서드는 원시 모델 출력(예: `Generation` 또는 `ChatGeneration`의 목록)을 받아 파싱된 출력을 반환합니다.

`Generation`과 `ChatGeneration` 모두를 지원하면 파서가 일반 LLM뿐만 아니라 채팅 모델에서도 작동할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "OutputParserException", "source": "langchain_core.exceptions", "docs": "https://api.python.langchain.com/en/latest/exceptions/langchain_core.exceptions.OutputParserException.html", "title": "How to create a custom Output Parser"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to create a custom Output Parser"}, {"imported": "BaseGenerationOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.base.BaseGenerationOutputParser.html", "title": "How to create a custom Output Parser"}, {"imported": "ChatGeneration", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.chat_generation.ChatGeneration.html", "title": "How to create a custom Output Parser"}, {"imported": "Generation", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.generation.Generation.html", "title": "How to create a custom Output Parser"}]-->
from typing import List

from langchain_core.exceptions import OutputParserException
from langchain_core.messages import AIMessage
from langchain_core.output_parsers import BaseGenerationOutputParser
from langchain_core.outputs import ChatGeneration, Generation


class StrInvertCase(BaseGenerationOutputParser[str]):
    """An example parser that inverts the case of the characters in the message.

    This is an example parse shown just for demonstration purposes and to keep
    the example as simple as possible.
    """

    def parse_result(self, result: List[Generation], *, partial: bool = False) -> str:
        """Parse a list of model Generations into a specific format.

        Args:
            result: A list of Generations to be parsed. The Generations are assumed
                to be different candidate outputs for a single model input.
                Many parsers assume that only a single generation is passed it in.
                We will assert for that
            partial: Whether to allow partial results. This is used for parsers
                     that support streaming
        """
        if len(result) != 1:
            raise NotImplementedError(
                "This output parser can only be used with a single generation."
            )
        generation = result[0]
        if not isinstance(generation, ChatGeneration):
            # Say that this one only works with chat generations
            raise OutputParserException(
                "This output parser can only be used with a chat generation."
            )
        return generation.message.content.swapcase()


chain = anthropic | StrInvertCase()
```


새로운 파서를 만들어 봅시다! 모델의 출력을 반전시켜야 합니다.

```python
chain.invoke("Tell me a short sentence about yourself")
```


```output
'hELLO! mY NAME IS cLAUDE.'
```