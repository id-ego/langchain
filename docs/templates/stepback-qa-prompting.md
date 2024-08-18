---
description: 이 문서는 복잡한 질문에 대한 성능을 향상시키는 "Step-Back" 프롬프트 기법을 설명하며, LangChain에서의 사용법을
  안내합니다.
---

# stepback-qa-prompting

이 템플릿은 "Step-Back" 프롬프트 기법을 복제하여 먼저 "단계 뒤로" 질문을 하여 복잡한 질문에 대한 성능을 향상시킵니다.

이 기법은 원래 질문과 단계 뒤로 질문 모두에 대해 검색을 수행하여 일반적인 질문-답변 응용 프로그램과 결합될 수 있습니다.

자세한 내용은 [여기](https://arxiv.org/abs/2310.06117) 논문과 Cobus Greyling의 훌륭한 블로그 게시물 [여기](https://cobusgreyling.medium.com/a-new-prompt-engineering-technique-has-been-introduced-called-step-back-prompting-b00e8954cacb)에서 확인하세요.

이 템플릿에서 채팅 모델과 더 잘 작동하도록 프롬프트를 약간 수정할 것입니다.

## 환경 설정

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 만들고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package stepback-qa-prompting
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add stepback-qa-prompting
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from stepback_qa_prompting.chain import chain as stepback_qa_prompting_chain

add_routes(app, stepback_qa_prompting_chain, path="/stepback-qa-prompting")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근할 수 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 로컬에서 [http://localhost:8000](http://localhost:8000)에서 서버가 실행됩니다.

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/stepback-qa-prompting/playground](http://127.0.0.1:8000/stepback-qa-prompting/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/stepback-qa-prompting")
```