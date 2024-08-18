---
custom_edit_url: null
description: 다양한 템플릿 카테고리를 소개하며, 인기 및 고급 검색 기술을 활용한 챗봇 구축 방법을 안내합니다.
sidebar_class_name: hidden
---

# 템플릿

다양한 카테고리의 템플릿을 강조합니다.

## ⭐ 인기

시작하기에 더 인기 있는 템플릿입니다.

- [Retrieval Augmented Generation Chatbot](/docs/templates/rag-conversation): 데이터 위에 챗봇을 구축합니다. 기본값은 OpenAI 및 PineconeVectorStore입니다.
- [Extraction with OpenAI Functions](/docs/templates/extraction-openai-functions): 비구조화된 데이터에서 구조화된 데이터를 추출합니다. OpenAI 함수 호출을 사용합니다.
- [Local Retrieval Augmented Generation](/docs/templates/rag-chroma-private): 데이터 위에 챗봇을 구축합니다. 로컬 도구만 사용합니다: Ollama, GPT4all, Chroma.
- [OpenAI Functions Agent](/docs/templates/openai-functions-agent): 작업을 수행할 수 있는 챗봇을 구축합니다. OpenAI 함수 호출 및 Tavily를 사용합니다.
- [XML Agent](/docs/templates/xml-agent): 작업을 수행할 수 있는 챗봇을 구축합니다. Anthropic 및 You.com을 사용합니다.

## 📥 고급 검색

이 템플릿은 데이터베이스 또는 문서에 대한 채팅 및 QA에 사용할 수 있는 고급 검색 기술을 다룹니다.

- [Reranking](/docs/templates/rag-pinecone-rerank): 이 검색 기술은 Cohere의 재정렬 엔드포인트를 사용하여 초기 검색 단계에서 문서를 재정렬합니다.
- [Anthropic Iterative Search](/docs/templates/anthropic-iterative-search): 이 검색 기술은 반복 프롬프트를 사용하여 무엇을 검색할지 및 검색된 문서가 충분히 좋은지 판단합니다.
- **부모 문서 검색** [Neo4j](/docs/templates/neo4j-parent) 또는 [MongoDB](/docs/templates/mongo-parent-document-retrieval)를 사용하여: 이 검색 기술은 더 작은 청크에 대한 임베딩을 저장하지만, 모델 생성을 위해 더 큰 청크를 반환합니다.
- [Semi-Structured RAG](/docs/templates/rag-semi-structured): 이 템플릿은 반구조화된 데이터(예: 텍스트와 테이블이 모두 포함된 데이터)에 대한 검색 방법을 보여줍니다.
- [Temporal RAG](/docs/templates/rag-timescale-hybrid-search-time): 이 템플릿은 [Timescale Vector](https://www.timescale.com/ai?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)를 사용하여 시간 기반 구성 요소가 있는 데이터에 대한 하이브리드 검색 방법을 보여줍니다.

## 🔍고급 검색 - 쿼리 변환

원래 사용자 쿼리를 변환하는 고급 검색 방법의 선택으로, 검색 품질을 향상시킬 수 있습니다.

- [Hypothetical Document Embeddings](/docs/templates/hyde): 주어진 쿼리에 대한 가상의 문서를 생성한 다음, 해당 문서의 임베딩을 사용하여 의미 검색을 수행하는 검색 기술입니다. [논문](https://arxiv.org/abs/2212.10496).
- [Rewrite-Retrieve-Read](/docs/templates/rewrite-retrieve-read): 주어진 쿼리를 검색 엔진에 전달하기 전에 재작성하는 검색 기술입니다. [논문](https://arxiv.org/abs/2305.14283).
- [Step-back QA Prompting](/docs/templates/stepback-qa-prompting): "스텝백" 질문을 생성한 다음, 해당 질문과 원래 질문 모두와 관련된 문서를 검색하는 검색 기술입니다. [논문](https://arxiv.org/abs//2310.06117).
- [RAG-Fusion](/docs/templates/rag-fusion): 여러 쿼리를 생성한 다음, 상호 순위 융합을 사용하여 검색된 문서를 재정렬하는 검색 기술입니다. [기사](https://towardsdatascience.com/forget-rag-the-future-is-rag-fusion-1147298d8ad1).
- [Multi-Query Retriever](/docs/templates/rag-pinecone-multi-query): 이 검색 기술은 LLM을 사용하여 여러 쿼리를 생성한 다음, 모든 쿼리에 대한 문서를 가져옵니다.

## 🧠고급 검색 - 쿼리 구성

자연어와 별도의 DSL에서 쿼리를 구성하는 고급 검색 방법의 선택으로, 다양한 구조화된 데이터베이스에 대한 자연어 채팅을 가능하게 합니다.

- [Elastic Query Generator](/docs/templates/elastic-query-generator): 자연어에서 엘라스틱 검색 쿼리를 생성합니다.
- [Neo4j Cypher Generation](/docs/templates/neo4j-cypher): 자연어에서 사이퍼 문장을 생성합니다. ["전체 텍스트" 옵션](/docs/templates/neo4j-cypher-ft)도 제공됩니다.
- [Supabase Self Query](/docs/templates/self-query-supabase): 자연어 쿼리를 의미 쿼리 및 Supabase의 메타데이터 필터로 구문 분석합니다.

## 🦙 OSS 모델

이 템플릿은 민감한 데이터에 대한 프라이버시를 가능하게 하는 OSS 모델을 사용합니다.

- [Local Retrieval Augmented Generation](/docs/templates/rag-chroma-private): 데이터 위에 챗봇을 구축합니다. 로컬 도구만 사용합니다: Ollama, GPT4all, Chroma.
- [SQL Question Answering (Replicate)](/docs/templates/sql-llama2): [Replicate](https://replicate.com/)에 호스팅된 Llama2를 사용하여 SQL 데이터베이스에 대한 질문 응답입니다.
- [SQL Question Answering (LlamaCpp)](/docs/templates/sql-llamacpp): [LlamaCpp](https://github.com/ggerganov/llama.cpp)를 통해 Llama2를 사용하여 SQL 데이터베이스에 대한 질문 응답입니다.
- [SQL Question Answering (Ollama)](/docs/templates/sql-ollama): [Ollama](https://github.com/jmorganca/ollama)를 통해 Llama2를 사용하여 SQL 데이터베이스에 대한 질문 응답입니다.

## ⛏️ 추출

이 템플릿은 사용자 지정 스키마를 기반으로 구조화된 형식으로 데이터를 추출합니다.

- [Extraction Using OpenAI Functions](/docs/templates/extraction-openai-functions): OpenAI 함수 호출을 사용하여 텍스트에서 정보를 추출합니다.
- [Extraction Using Anthropic Functions](/docs/templates/extraction-anthropic-functions): 함수 호출을 시뮬레이션하기 위해 Anthropic 엔드포인트 주위에 LangChain 래퍼를 사용하여 텍스트에서 정보를 추출합니다.
- [Extract BioTech Plate Data](/docs/templates/plate-chain): 지저분한 Excel 스프레드시트에서 마이크로플레이트 데이터를 보다 정규화된 형식으로 추출합니다.

## ⛏️요약 및 태깅

이 템플릿은 문서 및 텍스트를 요약하거나 분류합니다.

- [Summarization using Anthropic](/docs/templates/summarize-anthropic): Anthropic의 Claude2를 사용하여 긴 문서를 요약합니다.

## 🤖 에이전트

이 템플릿은 작업을 수행할 수 있는 챗봇을 구축하여 작업을 자동화하는 데 도움을 줍니다.

- [OpenAI Functions Agent](/docs/templates/openai-functions-agent): 작업을 수행할 수 있는 챗봇을 구축합니다. OpenAI 함수 호출 및 Tavily를 사용합니다.
- [XML Agent](/docs/templates/xml-agent): 작업을 수행할 수 있는 챗봇을 구축합니다. Anthropic 및 You.com을 사용합니다.

## :rotating_light: 안전 및 평가

이 템플릿은 LLM 출력을 조정하거나 평가할 수 있게 해줍니다.

- [Guardrails Output Parser](/docs/templates/guardrails-output-parser): guardrails-ai를 사용하여 LLM 출력을 검증합니다.
- [Chatbot Feedback](/docs/templates/chat-bot-feedback): LangSmith를 사용하여 챗봇 응답을 평가합니다.