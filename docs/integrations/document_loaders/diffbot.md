---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/diffbot.ipynb
description: Diffbot은 웹 데이터를 구조화하는 ML 기반 제품 모음으로, Extract API를 통해 페이지 내용을 JSON 형식으로
  변환합니다.
---

# Diffbot

> [Diffbot](https://docs.diffbot.com/docs/getting-started-with-diffbot)는 웹 데이터를 구조화하는 데 쉽게 사용할 수 있는 ML 기반 제품 모음입니다.

> Diffbot의 [Extract API](https://docs.diffbot.com/reference/extract-introduction)는 웹 페이지에서 데이터를 구조화하고 정규화하는 서비스입니다.

> 전통적인 웹 스크래핑 도구와 달리, `Diffbot Extract`는 페이지의 내용을 읽기 위한 규칙이 필요하지 않습니다. 컴퓨터 비전 모델을 사용하여 페이지를 20가지 가능한 유형 중 하나로 분류한 다음, 원시 HTML 마크업을 JSON으로 변환합니다. 결과로 생성된 구조화된 JSON은 일관된 [유형 기반 온톨로지](https://docs.diffbot.com/docs/ontology)를 따르므로 동일한 스키마를 가진 여러 다른 웹 소스에서 데이터를 쉽게 추출할 수 있습니다.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/langchain-ai/langchain/blob/master/docs/docs/integrations/document_loaders/diffbot.ipynb)

## 개요
이 가이드는 [Diffbot Extract API](https://www.diffbot.com/products/extract/)를 사용하여 URL 목록에서 데이터를 추출하여 우리가 하류에서 사용할 수 있는 구조화된 JSON으로 변환하는 방법을 다룹니다.

## 설정

필요한 패키지를 설치하는 것으로 시작합니다.

```python
%pip install --upgrade --quiet langchain-community
```


Diffbot의 Extract API는 API 토큰이 필요합니다. [무료 API 토큰 받기](/docs/integrations/providers/diffbot#installation-and-setup) 지침을 따르고 환경 변수를 설정하세요.

```python
%env DIFFBOT_API_TOKEN REPLACE_WITH_YOUR_TOKEN
```


## 문서 로더 사용하기

DiffbotLoader 모듈을 가져오고 URL 목록과 Diffbot 토큰으로 인스턴스를 생성합니다.

```python
<!--IMPORTS:[{"imported": "DiffbotLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.diffbot.DiffbotLoader.html", "title": "Diffbot"}]-->
import os

from langchain_community.document_loaders import DiffbotLoader

urls = [
    "https://python.langchain.com/",
]

loader = DiffbotLoader(urls=urls, api_token=os.environ.get("DIFFBOT_API_TOKEN"))
```


`.load()` 메서드를 사용하면 로드된 문서를 확인할 수 있습니다.

```python
loader.load()
```


```output
[Document(page_content="LangChain is a framework for developing applications powered by large language models (LLMs).\nLangChain simplifies every stage of the LLM application lifecycle:\nDevelopment: Build your applications using LangChain's open-source building blocks and components. Hit the ground running using third-party integrations and Templates.\nProductionization: Use LangSmith to inspect, monitor and evaluate your chains, so that you can continuously optimize and deploy with confidence.\nDeployment: Turn any chain into an API with LangServe.\nlangchain-core: Base abstractions and LangChain Expression Language.\nlangchain-community: Third party integrations.\nPartner packages (e.g. langchain-openai, langchain-anthropic, etc.): Some integrations have been further split into their own lightweight packages that only depend on langchain-core.\nlangchain: Chains, agents, and retrieval strategies that make up an application's cognitive architecture.\nlanggraph: Build robust and stateful multi-actor applications with LLMs by modeling steps as edges and nodes in a graph.\nlangserve: Deploy LangChain chains as REST APIs.\nThe broader ecosystem includes:\nLangSmith: A developer platform that lets you debug, test, evaluate, and monitor LLM applications and seamlessly integrates with LangChain.\nGet started\nWe recommend following our Quickstart guide to familiarize yourself with the framework by building your first LangChain application.\nSee here for instructions on how to install LangChain, set up your environment, and start building.\nnote\nThese docs focus on the Python LangChain library. Head here for docs on the JavaScript LangChain library.\nUse cases\nIf you're looking to build something specific or are more of a hands-on learner, check out our use-cases. They're walkthroughs and techniques for common end-to-end tasks, such as:\nQuestion answering with RAG\nExtracting structured output\nChatbots\nand more!\nExpression Language\nLangChain Expression Language (LCEL) is the foundation of many of LangChain's components, and is a declarative way to compose chains. LCEL was designed from day 1 to support putting prototypes in production, with no code changes, from the simplest “prompt + LLM” chain to the most complex chains.\nGet started: LCEL and its benefits\nRunnable interface: The standard interface for LCEL objects\nPrimitives: More on the primitives LCEL includes\nand more!\nEcosystem\n🦜🛠️ LangSmith\nTrace and evaluate your language model applications and intelligent agents to help you move from prototype to production.\n🦜🕸️ LangGraph\nBuild stateful, multi-actor applications with LLMs, built on top of (and intended to be used with) LangChain primitives.\n🦜🏓 LangServe\nDeploy LangChain runnables and chains as REST APIs.\nSecurity\nRead up on our Security best practices to make sure you're developing safely with LangChain.\nAdditional resources\nComponents\nLangChain provides standard, extendable interfaces and integrations for many different components, including:\nIntegrations\nLangChain is part of a rich ecosystem of tools that integrate with our framework and build on top of it. Check out our growing list of integrations.\nGuides\nBest practices for developing with LangChain.\nAPI reference\nHead to the reference section for full documentation of all classes and methods in the LangChain and LangChain Experimental Python packages.\nContributing\nCheck out the developer's guide for guidelines on contributing and help getting your dev environment set up.\nHelp us out by providing feedback on this documentation page:", metadata={'source': 'https://python.langchain.com/'})]
```


## 추출된 텍스트를 그래프 문서로 변환

구조화된 페이지 콘텐츠는 `DiffbotGraphTransformer`를 사용하여 엔터티와 관계를 그래프로 추출하는 추가 처리가 가능합니다.

```python
%pip install --upgrade --quiet langchain-experimental
```


```python
<!--IMPORTS:[{"imported": "DiffbotGraphTransformer", "source": "langchain_experimental.graph_transformers.diffbot", "docs": "https://api.python.langchain.com/en/latest/graph_transformers/langchain_experimental.graph_transformers.diffbot.DiffbotGraphTransformer.html", "title": "Diffbot"}]-->
from langchain_experimental.graph_transformers.diffbot import DiffbotGraphTransformer

diffbot_nlp = DiffbotGraphTransformer(
    diffbot_api_key=os.environ.get("DIFFBOT_API_TOKEN")
)
graph_documents = diffbot_nlp.convert_to_graph_documents(loader.load())
```


지식 그래프에 데이터를 계속 로드하려면 [`DiffbotGraphTransformer` 가이드](/docs/integrations/graphs/diffbot/#loading-the-data-into-a-knowledge-graph)를 따르세요.

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)