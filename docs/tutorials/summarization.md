---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/summarization.ipynb
description: 여러 문서의 내용을 요약하는 방법을 다루며, LLM을 활용한 정보 추출 및 요약 기술을 소개합니다.
sidebar_class_name: hidden
title: Summarize Text
---

# 텍스트 요약하기

문서 세트(PDF, Notion 페이지, 고객 질문 등)가 있고 그 내용을 요약하고 싶다고 가정해 보겠습니다.

LLM은 텍스트를 이해하고 종합하는 데 능숙하기 때문에 이 작업에 훌륭한 도구입니다.

[검색 보강 생성](/docs/tutorials/rag) 맥락에서 텍스트를 요약하는 것은 많은 검색된 문서의 정보를 정제하여 LLM에 대한 맥락을 제공하는 데 도움이 될 수 있습니다.

이 안내서에서는 LLM을 사용하여 여러 문서의 내용을 요약하는 방법을 살펴보겠습니다.

![이미지 설명](../../static/img/summarization_use_case_1.png)

## 개념

우리가 다룰 개념은 다음과 같습니다:

- [언어 모델](/docs/concepts/#chat-models) 사용하기.
- [문서 로더](/docs/concepts/#document-loaders), 특히 HTML 웹페이지에서 콘텐츠를 로드하기 위한 [WebBaseLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html) 사용하기.
- 문서를 요약하거나 결합하는 세 가지 방법.
  1. [Stuff](/docs/tutorials/summarization#stuff): 문서를 프롬프트에 단순히 연결합니다.
  2. [Map-reduce](/docs/tutorials/summarization#map-reduce): 문서를 배치로 나누고, 각각 요약한 다음 요약을 다시 요약합니다.
  3. [Refine](/docs/tutorials/summarization#refine): 문서를 순차적으로 반복하여 롤링 요약을 업데이트합니다.

상당히 많은 내용을 다룰 것입니다! 시작해 보겠습니다.

## 설정

### 주피터 노트북

이 가이드(및 문서의 다른 대부분의 가이드)는 [주피터 노트북](https://jupyter.org/)을 사용하며 독자가 이를 사용한다고 가정합니다. 주피터 노트북은 LLM 시스템을 다루는 방법을 배우기에 완벽합니다. 종종 예기치 않은 출력, API 다운 등 문제가 발생할 수 있으며, 대화형 환경에서 가이드를 진행하는 것은 이를 더 잘 이해하는 데 좋은 방법입니다.

이 가이드와 다른 튜토리얼은 주피터 노트북에서 가장 편리하게 실행할 수 있습니다. 설치 방법은 [여기](https://jupyter.org/install)를 참조하세요.

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

위 링크에서 가입한 후, 추적 로그를 시작하기 위해 환경 변수를 설정하세요:

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


## 개요

요약기를 구축하는 데 있어 중심 질문은 문서를 LLM의 컨텍스트 창으로 어떻게 전달할 것인가입니다. 이를 위한 세 가지 일반적인 접근 방식은 다음과 같습니다:

1. `Stuff`: 모든 문서를 단일 프롬프트에 "넣는" 것입니다. 이것이 가장 간단한 접근 방식입니다(이 방법에 사용되는 `create_stuff_documents_chain` 생성자에 대한 자세한 내용은 [여기](/docs/tutorials/rag#built-in-chains)를 참조하세요).
2. `Map-reduce`: 각 문서를 "맵" 단계에서 개별적으로 요약한 다음 요약을 "축소"하여 최종 요약으로 만듭니다(이 방법에 사용되는 `MapReduceDocumentsChain`에 대한 자세한 내용은 [여기](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.map_reduce.MapReduceDocumentsChain.html)를 참조하세요).
3. `Refine`: 문서를 순차적으로 반복하여 롤링 요약을 업데이트합니다.

![이미지 설명](../../static/img/summarization_use_case_2.png)

## 빠른 시작

미리보기로, 두 파이프라인은 단일 객체인 `load_summarize_chain`으로 래핑할 수 있습니다.

블로그 게시물을 요약하고 싶다고 가정해 보겠습니다. 몇 줄의 코드로 이를 생성할 수 있습니다.

먼저 환경 변수를 설정하고 패키지를 설치합니다:

```python
%pip install --upgrade --quiet  langchain-openai tiktoken chromadb langchain

# Set env var OPENAI_API_KEY or load from a .env file
# import dotenv

# dotenv.load_dotenv()
```


`chain_type="stuff"`를 사용할 수 있으며, 특히 다음과 같은 더 큰 컨텍스트 창 모델을 사용할 경우 유용합니다:

* 128k 토큰 OpenAI `gpt-4-turbo-2024-04-09`
* 200k 토큰 Anthropic `claude-3-sonnet-20240229`

`chain_type="map_reduce"` 또는 `chain_type="refine"`를 제공할 수도 있습니다.

먼저 문서를 로드합니다. 블로그 게시물을 로드하기 위해 [WebBaseLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html)를 사용하겠습니다:

```python
import os

os.environ["LANGCHAIN_TRACING_V2"] = "True"
```


```python
<!--IMPORTS:[{"imported": "load_summarize_chain", "source": "langchain.chains.summarize", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.summarize.chain.load_summarize_chain.html", "title": "Summarize Text"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "Summarize Text"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Summarize Text"}]-->
from langchain.chains.summarize import load_summarize_chain
from langchain_community.document_loaders import WebBaseLoader
from langchain_openai import ChatOpenAI

loader = WebBaseLoader("https://lilianweng.github.io/posts/2023-06-23-agent/")
docs = loader.load()

llm = ChatOpenAI(temperature=0, model_name="gpt-3.5-turbo-1106")
chain = load_summarize_chain(llm, chain_type="stuff")

result = chain.invoke(docs)

print(result["output_text"])
```

```output
The article discusses the concept of LLM-powered autonomous agents, with a focus on the components of planning, memory, and tool use. It includes case studies and proof-of-concept examples, as well as challenges and references to related research. The author emphasizes the potential of LLMs in creating powerful problem-solving agents, while also highlighting limitations such as finite context length and reliability of natural language interfaces.
```

## 옵션 1. Stuff {#stuff}

`load_summarize_chain`을 `chain_type="stuff"`와 함께 사용할 때, 우리는 [StuffDocumentsChain](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.StuffDocumentsChain.html#langchain.chains.combine_documents.stuff.StuffDocumentsChain)을 사용합니다.

체인은 문서 목록을 가져와 모두 프롬프트에 삽입하고 그 프롬프트를 LLM에 전달합니다:

```python
<!--IMPORTS:[{"imported": "StuffDocumentsChain", "source": "langchain.chains.combine_documents.stuff", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.StuffDocumentsChain.html", "title": "Summarize Text"}, {"imported": "LLMChain", "source": "langchain.chains.llm", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Summarize Text"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Summarize Text"}]-->
from langchain.chains.combine_documents.stuff import StuffDocumentsChain
from langchain.chains.llm import LLMChain
from langchain_core.prompts import PromptTemplate

# Define prompt
prompt_template = """Write a concise summary of the following:
"{text}"
CONCISE SUMMARY:"""
prompt = PromptTemplate.from_template(prompt_template)

# Define LLM chain
llm = ChatOpenAI(temperature=0, model_name="gpt-3.5-turbo-16k")
llm_chain = LLMChain(llm=llm, prompt=prompt)

# Define StuffDocumentsChain
stuff_chain = StuffDocumentsChain(llm_chain=llm_chain, document_variable_name="text")

docs = loader.load()
print(stuff_chain.invoke(docs)["output_text"])
```

```output
The article discusses the concept of building autonomous agents powered by large language models (LLMs). It explores the components of such agents, including planning, memory, and tool use. The article provides case studies and examples of proof-of-concept demos, highlighting the challenges and limitations of LLM-powered agents. It also includes references to related research papers and projects.
```

좋습니다! `load_summarize_chain`을 사용하여 이전 결과를 재현할 수 있음을 확인할 수 있습니다.

### 더 깊이 들어가기

* 프롬프트를 쉽게 사용자 정의할 수 있습니다.
* `llm` 매개변수를 통해 다양한 LLM을 쉽게 시도할 수 있습니다(예: [Claude](/docs/integrations/chat/anthropic)).

## 옵션 2. Map-Reduce {#map-reduce}

맵 리듀스 접근 방식을 살펴보겠습니다. 이를 위해 먼저 각 문서를 개별 요약으로 매핑하기 위해 `LLMChain`을 사용합니다. 그런 다음 `ReduceDocumentsChain`을 사용하여 이러한 요약을 단일 글로벌 요약으로 결합합니다.

먼저 각 문서를 개별 요약으로 매핑하는 데 사용할 LLMChain을 지정합니다:

```python
<!--IMPORTS:[{"imported": "MapReduceDocumentsChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.map_reduce.MapReduceDocumentsChain.html", "title": "Summarize Text"}, {"imported": "ReduceDocumentsChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.reduce.ReduceDocumentsChain.html", "title": "Summarize Text"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Summarize Text"}]-->
from langchain.chains import MapReduceDocumentsChain, ReduceDocumentsChain
from langchain_text_splitters import CharacterTextSplitter

llm = ChatOpenAI(temperature=0)

# Map
map_template = """The following is a set of documents
{docs}
Based on this list of docs, please identify the main themes 
Helpful Answer:"""
map_prompt = PromptTemplate.from_template(map_template)
map_chain = LLMChain(llm=llm, prompt=map_prompt)
```


프롬프트 허브를 사용하여 프롬프트를 저장하고 가져올 수도 있습니다.

이는 [LangSmith API 키](https://docs.smith.langchain.com/)와 함께 작동합니다.

예를 들어, 맵 프롬프트는 [여기](https://smith.langchain.com/hub/rlm/map-prompt)에서 확인할 수 있습니다.

```python
from langchain import hub

map_prompt = hub.pull("rlm/map-prompt")
map_chain = LLMChain(llm=llm, prompt=map_prompt)
```


`ReduceDocumentsChain`은 문서 매핑 결과를 가져와 단일 출력으로 축소하는 작업을 처리합니다. 이는 일반적인 `CombineDocumentsChain`(예: `StuffDocumentsChain`)을 래핑하지만, 누적 크기가 `token_max`를 초과할 경우 문서를 축소하여 `CombineDocumentsChain`에 전달할 수 있는 기능을 추가합니다. 이 예제에서는 문서를 결합하는 체인을 재사용하여 문서를 축소할 수 있습니다.

따라서 매핑된 문서의 누적 토큰 수가 4000 토큰을 초과하면, 4000 토큰 미만의 배치로 문서를 재귀적으로 `StuffDocumentsChain`에 전달하여 배치 요약을 생성합니다. 그리고 이러한 배치 요약이 누적적으로 4000 토큰 미만이 되면, 마지막으로 모든 요약을 `StuffDocumentsChain`에 전달하여 최종 요약을 생성합니다.

```python
# Reduce
reduce_template = """The following is set of summaries:
{docs}
Take these and distill it into a final, consolidated summary of the main themes. 
Helpful Answer:"""
reduce_prompt = PromptTemplate.from_template(reduce_template)
```


```python
# Note we can also get this from the prompt hub, as noted above
reduce_prompt = hub.pull("rlm/reduce-prompt")
```


```python
reduce_prompt
```


```output
ChatPromptTemplate(input_variables=['docs'], metadata={'lc_hub_owner': 'rlm', 'lc_hub_repo': 'map-prompt', 'lc_hub_commit_hash': 'de4fba345f211a462584fc25b7077e69c1ba6cdcf4e21b7ec9abe457ddb16c87'}, messages=[HumanMessagePromptTemplate(prompt=PromptTemplate(input_variables=['docs'], template='The following is a set of documents:\n{docs}\nBased on this list of docs, please identify the main themes \nHelpful Answer:'))])
```


```python
# Run chain
reduce_chain = LLMChain(llm=llm, prompt=reduce_prompt)

# Takes a list of documents, combines them into a single string, and passes this to an LLMChain
combine_documents_chain = StuffDocumentsChain(
    llm_chain=reduce_chain, document_variable_name="docs"
)

# Combines and iteratively reduces the mapped documents
reduce_documents_chain = ReduceDocumentsChain(
    # This is final chain that is called.
    combine_documents_chain=combine_documents_chain,
    # If documents exceed context for `StuffDocumentsChain`
    collapse_documents_chain=combine_documents_chain,
    # The maximum number of tokens to group documents into.
    token_max=4000,
)
```


맵과 리듀스 체인을 하나로 결합합니다:

```python
# Combining documents by mapping a chain over them, then combining results
map_reduce_chain = MapReduceDocumentsChain(
    # Map chain
    llm_chain=map_chain,
    # Reduce chain
    reduce_documents_chain=reduce_documents_chain,
    # The variable name in the llm_chain to put the documents in
    document_variable_name="docs",
    # Return the results of the map steps in the output
    return_intermediate_steps=False,
)

text_splitter = CharacterTextSplitter.from_tiktoken_encoder(
    chunk_size=1000, chunk_overlap=0
)
split_docs = text_splitter.split_documents(docs)
```

```output
Created a chunk of size 1003, which is longer than the specified 1000
```


```python
result = map_reduce_chain.invoke(split_docs)

print(result["output_text"])
```

```output
The main themes identified in the list of documents provided are related to large language models (LLMs), autonomous agents, prompting, steering language models, natural language processing (NLP), the use of tools to augment language models, reinforcement learning, reasoning, acting, self-reflection, and the integration of language models with external knowledge sources.
```


[Langsmith Trace](https://smith.langchain.com/public/3a1a6d51-68e5-4805-8d90-78920ce60a51/r)를 따르면 개별 LLM 요약을 볼 수 있으며, 요약을 요약하는 [최종 호출](https://smith.langchain.com/public/69482813-f0b7-46b0-a99f-86d56fc9644a/r)도 확인할 수 있습니다.

### 더 깊이 들어가기

**사용자 정의**

* 위에서 보여준 것처럼, 맵 및 리듀스 단계에 대한 LLM 및 프롬프트를 사용자 정의할 수 있습니다.

**실제 사용 사례**

* [이 블로그 게시물](https://blog.langchain.dev/llms-to-improve-documentation/)에서 LangChain 문서에 대한 사용자 상호작용 분석 사례 연구를 참조하세요!
* 블로그 게시물과 관련된 [레포](https://github.com/mendableai/QA_clustering)에서는 요약 수단으로 클러스터링을 소개합니다.
* 이는 `stuff` 또는 `map-reduce` 접근 방식 외에 고려할 가치가 있는 또 다른 경로를 열어줍니다.

![이미지 설명](../../static/img/summarization_use_case_3.png)

## 옵션 3. Refine {#refine}

[RefineDocumentsChain](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.refine.RefineDocumentsChain.html)은 맵-리듀스와 유사합니다:

> refine documents chain은 입력 문서를 반복하고 답변을 반복적으로 업데이트하여 응답을 구성합니다. 각 문서에 대해 모든 비문서 입력, 현재 문서 및 최신 중간 답변을 LLM 체인에 전달하여 새로운 답변을 얻습니다.

이는 `chain_type="refine"`로 쉽게 실행할 수 있습니다.

```python
chain = load_summarize_chain(llm, chain_type="refine")
result = chain.invoke(split_docs)

print(result["output_text"])
```

```output
The existing summary provides detailed instructions for implementing a project's architecture through code, focusing on creating core classes, functions, and methods in different files following best practices for the chosen language and framework. Assumptions about the model, view, and controller components are also outlined. The additional context highlights challenges in long-term planning and task decomposition, as well as the reliability issues with natural language interfaces in LLM-powered autonomous agents. These insights shed light on the limitations and potential pitfalls of using LLMs in agent systems, with references to recent research on LLM-powered autonomous agents and related technologies.
```


[Langsmith trace](https://smith.langchain.com/public/38017fa7-b190-4635-992c-e8554227a4bb/r)를 따르면 새로운 정보로 반복적으로 업데이트된 요약을 볼 수 있습니다.

프롬프트를 제공하고 중간 단계를 반환하는 것도 가능합니다.

```python
prompt_template = """Write a concise summary of the following:
{text}
CONCISE SUMMARY:"""
prompt = PromptTemplate.from_template(prompt_template)

refine_template = (
    "Your job is to produce a final summary\n"
    "We have provided an existing summary up to a certain point: {existing_answer}\n"
    "We have the opportunity to refine the existing summary"
    "(only if needed) with some more context below.\n"
    "------------\n"
    "{text}\n"
    "------------\n"
    "Given the new context, refine the original summary in Italian"
    "If the context isn't useful, return the original summary."
)
refine_prompt = PromptTemplate.from_template(refine_template)
chain = load_summarize_chain(
    llm=llm,
    chain_type="refine",
    question_prompt=prompt,
    refine_prompt=refine_prompt,
    return_intermediate_steps=True,
    input_key="input_documents",
    output_key="output_text",
)
result = chain.invoke({"input_documents": split_docs}, return_only_outputs=True)
```


```python
print(result["output_text"])
```

```output
Il presente articolo discute il concetto di costruire agenti autonomi utilizzando LLM (large language model) come controller principale. Esplora i diversi componenti di un sistema di agenti alimentato da LLM, tra cui la pianificazione, la memoria e l'uso degli strumenti. Dimostrazioni di concetto come AutoGPT mostrano il potenziale di LLM come risolutore generale di problemi. Approcci come Chain of Thought, Tree of Thoughts, LLM+P, ReAct e Reflexion consentono agli agenti autonomi di pianificare, riflettere su se stessi e migliorarsi iterativamente. Tuttavia, ci sono sfide da affrontare, come la limitata capacità di contesto che limita l'inclusione di informazioni storiche dettagliate e la difficoltà di pianificazione a lungo termine e decomposizione delle attività. Inoltre, l'affidabilità dell'interfaccia di linguaggio naturale tra LLM e componenti esterni come la memoria e gli strumenti è incerta, poiché i LLM possono commettere errori di formattazione e mostrare comportamenti ribelli. Nonostante ciò, il sistema AutoGPT viene menzionato come esempio di dimostrazione di concetto che utilizza LLM come controller principale per agenti autonomi. Questo articolo fa riferimento a diverse fonti che esplorano approcci e applicazioni specifiche di LLM nell'ambito degli agenti autonomi.
```


```python
print("\n\n".join(result["intermediate_steps"][:3]))
```


```output
This article discusses the concept of building autonomous agents using LLM (large language model) as the core controller. The article explores the different components of an LLM-powered agent system, including planning, memory, and tool use. It also provides examples of proof-of-concept demos and highlights the potential of LLM as a general problem solver.

Questo articolo discute del concetto di costruire agenti autonomi utilizzando LLM (large language model) come controller principale. L'articolo esplora i diversi componenti di un sistema di agenti alimentato da LLM, inclusa la pianificazione, la memoria e l'uso degli strumenti. Vengono forniti anche esempi di dimostrazioni di proof-of-concept e si evidenzia il potenziale di LLM come risolutore generale di problemi. Inoltre, vengono presentati approcci come Chain of Thought, Tree of Thoughts, LLM+P, ReAct e Reflexion che consentono agli agenti autonomi di pianificare, riflettere su se stessi e migliorare iterativamente.

Questo articolo discute del concetto di costruire agenti autonomi utilizzando LLM (large language model) come controller principale. L'articolo esplora i diversi componenti di un sistema di agenti alimentato da LLM, inclusa la pianificazione, la memoria e l'uso degli strumenti. Vengono forniti anche esempi di dimostrazioni di proof-of-concept e si evidenzia il potenziale di LLM come risolutore generale di problemi. Inoltre, vengono presentati approcci come Chain of Thought, Tree of Thoughts, LLM+P, ReAct e Reflexion che consentono agli agenti autonomi di pianificare, riflettere su se stessi e migliorare iterativamente. Il nuovo contesto riguarda l'approccio Chain of Hindsight (CoH) che permette al modello di migliorare autonomamente i propri output attraverso un processo di apprendimento supervisionato. Viene anche presentato l'approccio Algorithm Distillation (AD) che applica lo stesso concetto alle traiettorie di apprendimento per compiti di reinforcement learning.
```


## 단일 체인에서 분할 및 요약하기
편의상 긴 문서의 텍스트 분할과 요약을 단일 [체인](/docs/how_to/sequence)으로 래핑할 수 있습니다:

```python
def split_text(text: str):
    return text_splitter.create_documents([text])


summarize_document_chain = split_text | chain
```


## 다음 단계

다음에 대한 자세한 내용을 보려면 [사용 방법 가이드](/docs/how_to)를 확인하시기 바랍니다:

- 내장 [문서 로더](/docs/how_to/#document-loaders) 및 [텍스트 분할기](/docs/how_to/#text-splitters)
- 다양한 결합 문서 체인을 [RAG 애플리케이션](/docs/tutorials/rag/)에 통합하기
- [챗봇](/docs/how_to/chatbots_retrieval/)에 검색 통합하기

및 기타 개념.