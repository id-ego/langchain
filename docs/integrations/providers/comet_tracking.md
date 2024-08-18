---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/comet_tracking.ipynb
description: Comet 플랫폼을 통해 Langchain 실험, 평가 지표 및 LLM 세션을 추적하는 방법을 안내합니다. 머신러닝 최적화를
  위한 필수 가이드입니다.
---

# 코멧

> [코멧](https://www.comet.com/) 머신 러닝 플랫폼은 기존 인프라 및 도구와 통합되어 모델을 관리, 시각화 및 최적화할 수 있도록 합니다. - 훈련 실행부터 프로덕션 모니터링까지

![](https://user-images.githubusercontent.com/7529846/230328046-a8b18c51-12e3-4617-9b39-97614a571a2d.png)

이 가이드에서는 [코멧](https://www.comet.com/site/?utm_source=langchain&utm_medium=referral&utm_campaign=comet_notebook)과 함께 Langchain 실험, 평가 메트릭 및 LLM 세션을 추적하는 방법을 보여줍니다.  

<a target="_blank" href="https://colab.research.google.com/github/hwchase17/langchain/blob/master/docs/ecosystem/comet_tracking">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>


**예제 프로젝트:** [LangChain과 함께하는 코멧](https://www.comet.com/examples/comet-example-langchain/view/b5ZThK6OFdhKWVSP3fDfRtrNF/panels?utm_source=langchain&utm_medium=referral&utm_campaign=comet_notebook)

![](https://user-images.githubusercontent.com/7529846/230326720-a9711435-9c6f-4edb-a707-94b67271ab25.png)

### 코멧 및 의존성 설치

```python
%pip install --upgrade --quiet  comet_ml langchain langchain-openai google-search-results spacy textstat pandas


!{sys.executable} -m spacy download en_core_web_sm
```


### 코멧 초기화 및 자격 증명 설정

[코멧 API 키를 여기서 가져올 수 있습니다](https://www.comet.com/signup?utm_source=langchain&utm_medium=referral&utm_campaign=comet_notebook) 또는 코멧을 초기화한 후 링크를 클릭하세요.

```python
import comet_ml

comet_ml.init(project_name="comet-example-langchain")
```


### OpenAI 및 SerpAPI 자격 증명 설정

다음 예제를 실행하려면 [OpenAI API 키](https://platform.openai.com/account/api-keys)와 [SerpAPI API 키](https://serpapi.com/dashboard)가 필요합니다.

```python
import os

os.environ["OPENAI_API_KEY"] = "..."
# os.environ["OPENAI_ORGANIZATION"] = "..."
os.environ["SERPAPI_API_KEY"] = "..."
```


### 시나리오 1: LLM만 사용하기

```python
<!--IMPORTS:[{"imported": "CometCallbackHandler", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.comet_ml_callback.CometCallbackHandler.html", "title": "Comet"}, {"imported": "StdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.stdout.StdOutCallbackHandler.html", "title": "Comet"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Comet"}]-->
from langchain_community.callbacks import CometCallbackHandler
from langchain_core.callbacks import StdOutCallbackHandler
from langchain_openai import OpenAI

comet_callback = CometCallbackHandler(
    project_name="comet-example-langchain",
    complexity_metrics=True,
    stream_logs=True,
    tags=["llm"],
    visualizations=["dep"],
)
callbacks = [StdOutCallbackHandler(), comet_callback]
llm = OpenAI(temperature=0.9, callbacks=callbacks, verbose=True)

llm_result = llm.generate(["Tell me a joke", "Tell me a poem", "Tell me a fact"] * 3)
print("LLM result", llm_result)
comet_callback.flush_tracker(llm, finish=True)
```


### 시나리오 2: 체인에서 LLM 사용하기

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Comet"}, {"imported": "CometCallbackHandler", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.comet_ml_callback.CometCallbackHandler.html", "title": "Comet"}, {"imported": "StdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.stdout.StdOutCallbackHandler.html", "title": "Comet"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Comet"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Comet"}]-->
from langchain.chains import LLMChain
from langchain_community.callbacks import CometCallbackHandler
from langchain_core.callbacks import StdOutCallbackHandler
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI

comet_callback = CometCallbackHandler(
    complexity_metrics=True,
    project_name="comet-example-langchain",
    stream_logs=True,
    tags=["synopsis-chain"],
)
callbacks = [StdOutCallbackHandler(), comet_callback]
llm = OpenAI(temperature=0.9, callbacks=callbacks)

template = """You are a playwright. Given the title of play, it is your job to write a synopsis for that title.
Title: {title}
Playwright: This is a synopsis for the above play:"""
prompt_template = PromptTemplate(input_variables=["title"], template=template)
synopsis_chain = LLMChain(llm=llm, prompt=prompt_template, callbacks=callbacks)

test_prompts = [{"title": "Documentary about Bigfoot in Paris"}]
print(synopsis_chain.apply(test_prompts))
comet_callback.flush_tracker(synopsis_chain, finish=True)
```


### 시나리오 3: 도구와 함께 에이전트 사용하기

```python
<!--IMPORTS:[{"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Comet"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "Comet"}, {"imported": "CometCallbackHandler", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.comet_ml_callback.CometCallbackHandler.html", "title": "Comet"}, {"imported": "StdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.stdout.StdOutCallbackHandler.html", "title": "Comet"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Comet"}]-->
from langchain.agents import initialize_agent, load_tools
from langchain_community.callbacks import CometCallbackHandler
from langchain_core.callbacks import StdOutCallbackHandler
from langchain_openai import OpenAI

comet_callback = CometCallbackHandler(
    project_name="comet-example-langchain",
    complexity_metrics=True,
    stream_logs=True,
    tags=["agent"],
)
callbacks = [StdOutCallbackHandler(), comet_callback]
llm = OpenAI(temperature=0.9, callbacks=callbacks)

tools = load_tools(["serpapi", "llm-math"], llm=llm, callbacks=callbacks)
agent = initialize_agent(
    tools,
    llm,
    agent="zero-shot-react-description",
    callbacks=callbacks,
    verbose=True,
)
agent.run(
    "Who is Leo DiCaprio's girlfriend? What is her current age raised to the 0.43 power?"
)
comet_callback.flush_tracker(agent, finish=True)
```


### 시나리오 4: 사용자 정의 평가 메트릭 사용하기

`CometCallbackManager`를 사용하면 모델에서 생성된 출력을 평가하기 위해 사용자 정의 평가 메트릭을 정의하고 사용할 수 있습니다. 이것이 어떻게 작동하는지 살펴보겠습니다. 

아래 코드 조각에서는 [ROUGE](https://huggingface.co/spaces/evaluate-metric/rouge) 메트릭을 사용하여 입력 프롬프트의 생성된 요약 품질을 평가합니다. 

```python
%pip install --upgrade --quiet  rouge-score
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Comet"}, {"imported": "CometCallbackHandler", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.comet_ml_callback.CometCallbackHandler.html", "title": "Comet"}, {"imported": "StdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.stdout.StdOutCallbackHandler.html", "title": "Comet"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Comet"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Comet"}]-->
from langchain.chains import LLMChain
from langchain_community.callbacks import CometCallbackHandler
from langchain_core.callbacks import StdOutCallbackHandler
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI
from rouge_score import rouge_scorer


class Rouge:
    def __init__(self, reference):
        self.reference = reference
        self.scorer = rouge_scorer.RougeScorer(["rougeLsum"], use_stemmer=True)

    def compute_metric(self, generation, prompt_idx, gen_idx):
        prediction = generation.text
        results = self.scorer.score(target=self.reference, prediction=prediction)

        return {
            "rougeLsum_score": results["rougeLsum"].fmeasure,
            "reference": self.reference,
        }


reference = """
The tower is 324 metres (1,063 ft) tall, about the same height as an 81-storey building.
It was the first structure to reach a height of 300 metres.

It is now taller than the Chrysler Building in New York City by 5.2 metres (17 ft)
Excluding transmitters, the Eiffel Tower is the second tallest free-standing structure in France .
"""
rouge_score = Rouge(reference=reference)

template = """Given the following article, it is your job to write a summary.
Article:
{article}
Summary: This is the summary for the above article:"""
prompt_template = PromptTemplate(input_variables=["article"], template=template)

comet_callback = CometCallbackHandler(
    project_name="comet-example-langchain",
    complexity_metrics=False,
    stream_logs=True,
    tags=["custom_metrics"],
    custom_metrics=rouge_score.compute_metric,
)
callbacks = [StdOutCallbackHandler(), comet_callback]
llm = OpenAI(temperature=0.9)

synopsis_chain = LLMChain(llm=llm, prompt=prompt_template)

test_prompts = [
    {
        "article": """
                 The tower is 324 metres (1,063 ft) tall, about the same height as
                 an 81-storey building, and the tallest structure in Paris. Its base is square,
                 measuring 125 metres (410 ft) on each side.
                 During its construction, the Eiffel Tower surpassed the
                 Washington Monument to become the tallest man-made structure in the world,
                 a title it held for 41 years until the Chrysler Building
                 in New York City was finished in 1930.

                 It was the first structure to reach a height of 300 metres.
                 Due to the addition of a broadcasting aerial at the top of the tower in 1957,
                 it is now taller than the Chrysler Building by 5.2 metres (17 ft).

                 Excluding transmitters, the Eiffel Tower is the second tallest
                 free-standing structure in France after the Millau Viaduct.
                 """
    }
]
print(synopsis_chain.apply(test_prompts, callbacks=callbacks))
comet_callback.flush_tracker(synopsis_chain, finish=True)
```


### 콜백 추적기

코멧과의 또 다른 통합이 있습니다:

[예제 보기](/docs/integrations/callbacks/comet_tracing).

```python
<!--IMPORTS:[{"imported": "CometTracer", "source": "langchain_community.callbacks.tracers.comet", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.tracers.comet.CometTracer.html", "title": "Comet"}]-->
from langchain_community.callbacks.tracers.comet import CometTracer
```