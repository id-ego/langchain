---
description: 이 문서는 사용자 피드백 없이 챗봇을 평가하는 템플릿을 제공하며, 챗봇의 응답 효과성을 점수화하는 방법을 설명합니다.
---

# 챗봇 피드백 템플릿

이 템플릿은 명시적인 사용자 피드백 없이 챗봇을 평가하는 방법을 보여줍니다. [chain.py](https://github.com/langchain-ai/langchain/blob/master/templates/chat-bot-feedback/chat_bot_feedback/chain.py)에서 간단한 챗봇을 정의하고, 후속 사용자 응답에 따라 챗봇 응답의 효과를 점수화하는 사용자 정의 평가자를 정의합니다. 이 실행 평가자를 챗봇에 적용하려면 서비스를 제공하기 전에 챗봇에서 `with_config`를 호출하면 됩니다. 이 템플릿을 사용하여 챗 앱을 직접 배포할 수도 있습니다.

[챗봇](https://python.langchain.com/docs/use_cases/chatbots)은 LLM을 배포하는 가장 일반적인 인터페이스 중 하나입니다. 챗봇의 품질은 다양하므로 지속적인 개발이 중요합니다. 그러나 사용자는 종종 좋아요 또는 싫어요 버튼과 같은 메커니즘을 통해 명시적인 피드백을 남기기 마련입니다. 또한 "세션 길이"나 "대화 길이"와 같은 전통적인 분석은 종종 명확성이 부족합니다. 그러나 챗봇과의 다중 턴 대화는 풍부한 정보를 제공할 수 있으며, 이를 통해 미세 조정, 평가 및 제품 분석을 위한 지표로 변환할 수 있습니다.

[Chat Langchain](https://chat.langchain.com/)을 사례 연구로 삼았을 때, 모든 쿼리의 약 0.04%만이 명시적인 피드백을 받습니다. 그러나 약 70%의 쿼리는 이전 질문에 대한 후속 질문입니다. 이러한 후속 쿼리의 상당 부분은 이전 AI 응답의 품질을 추론하는 데 사용할 수 있는 유용한 정보를 계속 제공합니다.

이 템플릿은 "피드백 부족" 문제를 해결하는 데 도움이 됩니다. 아래는 이 챗봇의 예시 호출입니다:

[](https://smith.langchain.com/public/3378daea-133c-4fe8-b4da-0a3044c5dbe8/r?runtab=1)

사용자가 이 ([링크](https://smith.langchain.com/public/a7e2df54-4194-455d-9978-cecd8be0df1e/r))에 응답하면, 응답 평가자가 호출되어 다음과 같은 평가 실행 결과를 생성합니다:

[](https://smith.langchain.com/public/534184ee-db8f-4831-a386-3f578145114c/r)

보시다시피, 평가자는 사용자가 점점 더 불만을 느끼고 있음을 확인하며, 이는 이전 응답이 효과적이지 않았음을 나타냅니다.

## LangSmith 피드백

[LangSmith](https://smith.langchain.com/)는 프로덕션 등급 LLM 애플리케이션을 구축하기 위한 플랫폼입니다. 디버깅 및 오프라인 평가 기능을 넘어, LangSmith는 사용자 및 모델 지원 피드백을 캡처하여 LLM 애플리케이션을 개선하는 데 도움을 줍니다. 이 템플릿은 LLM을 사용하여 애플리케이션에 대한 피드백을 생성하며, 이를 통해 서비스를 지속적으로 개선할 수 있습니다. LangSmith를 사용하여 피드백을 수집하는 더 많은 예시는 [문서](https://docs.smith.langchain.com/cookbook/feedback-examples)를 참조하십시오.

## 평가자 구현

사용자 피드백은 사용자 정의 `RunEvaluator`에 의해 추론됩니다. 이 평가자는 `EvaluatorCallbackHandler`를 사용하여 호출되며, 챗봇의 런타임에 간섭하지 않도록 별도의 스레드에서 실행됩니다. 이 사용자 정의 평가자는 LangChain 객체에서 다음 함수를 호출하여 호환되는 모든 챗봇에서 사용할 수 있습니다:

```python
my_chain.with_config(
    callbacks=[
        EvaluatorCallbackHandler(
            evaluators=[
                ResponseEffectivenessEvaluator(evaluate_response_effectiveness)
            ]
        )
    ],
)
```


평가자는 LLM, 특히 `gpt-3.5-turbo`에게 사용자의 후속 응답에 따라 AI의 가장 최근 챗 메시지를 평가하도록 지시합니다. 이는 점수와 함께 이유를 생성하며, 이는 LangSmith에서 피드백으로 변환되어 `last_run_id`로 제공된 값에 적용됩니다.

LLM 내에서 사용되는 프롬프트는 [허브에서 확인할 수 있습니다](https://smith.langchain.com/hub/wfh/response-effectiveness). 애플리케이션의 목표나 응답해야 할 질문 유형과 같은 추가 애플리케이션 컨텍스트나 LLM이 집중하기를 원하는 "증상"으로 사용자 정의할 수 있습니다. 이 평가자는 또한 OpenAI의 함수 호출 API를 활용하여 점수에 대한 보다 일관되고 구조화된 출력을 보장합니다.

## 환경 변수

OpenAI 모델을 사용하려면 `OPENAI_API_KEY`가 설정되어 있어야 합니다. 또한 `LANGSMITH_API_KEY`를 설정하여 LangSmith를 구성하십시오.

```bash
export OPENAI_API_KEY=sk-...
export LANGSMITH_API_KEY=...
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_PROJECT=my-project # Set to the project you want to save to
```


## 사용법

`LangServe`를 통해 배포하는 경우, 서버가 콜백 이벤트를 반환하도록 구성하는 것이 좋습니다. 이렇게 하면 백엔드 추적이 `RemoteRunnable`을 사용하여 생성하는 모든 추적에 포함됩니다.

```python
from chat_bot_feedback.chain import chain

add_routes(app, chain, path="/chat-bot-feedback", include_callback_events=True)
```


서버가 실행 중일 때, 다음 코드 스니펫을 사용하여 2턴 대화를 위한 챗봇 응답을 스트리밍할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "tracing_v2_enabled", "source": "langchain.callbacks.manager", "docs": "https://api.python.langchain.com/en/latest/tracers/langchain_core.tracers.context.tracing_v2_enabled.html", "title": "Chat Bot Feedback Template"}, {"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "Chat Bot Feedback Template"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Chat Bot Feedback Template"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Chat Bot Feedback Template"}]-->
from functools import partial
from typing import Dict, Optional, Callable, List
from langserve import RemoteRunnable
from langchain.callbacks.manager import tracing_v2_enabled
from langchain_core.messages import BaseMessage, AIMessage, HumanMessage

# Update with the URL provided by your LangServe server
chain = RemoteRunnable("http://127.0.0.1:8031/chat-bot-feedback")

def stream_content(
    text: str,
    chat_history: Optional[List[BaseMessage]] = None,
    last_run_id: Optional[str] = None,
    on_chunk: Callable = None,
):
    results = []
    with tracing_v2_enabled() as cb:
        for chunk in chain.stream(
            {"text": text, "chat_history": chat_history, "last_run_id": last_run_id},
        ):
            on_chunk(chunk)
            results.append(chunk)
        last_run_id = cb.latest_run.id if cb.latest_run else None
    return last_run_id, "".join(results)

chat_history = []
text = "Where are my keys?"
last_run_id, response_message = stream_content(text, on_chunk=partial(print, end=""))
print()
chat_history.extend([HumanMessage(content=text), AIMessage(content=response_message)])
text = "I CAN'T FIND THEM ANYWHERE"  # The previous response will likely receive a low score,
# as the user's frustration appears to be escalating.
last_run_id, response_message = stream_content(
    text,
    chat_history=chat_history,
    last_run_id=str(last_run_id),
    on_chunk=partial(print, end=""),
)
print()
chat_history.extend([HumanMessage(content=text), AIMessage(content=response_message)])
```


이는 `tracing_v2_enabled` 콜백 관리자를 사용하여 호출의 실행 ID를 가져오며, 이는 동일한 챗 스레드의 후속 호출에서 제공되어 평가자가 적절한 추적에 피드백을 할당할 수 있도록 합니다.

## 결론

이 템플릿은 LangServe를 사용하여 직접 배포할 수 있는 간단한 챗봇 정의를 제공합니다. 이는 명시적인 사용자 평가 없이 챗봇에 대한 평가 피드백을 기록하기 위한 사용자 정의 평가자를 정의합니다. 이는 분석을 보강하고 미세 조정 및 평가를 위한 데이터 포인트를 더 잘 선택하는 효과적인 방법입니다.