---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/uptrain.ipynb
description: UpTrain은 LLM 애플리케이션을 평가하고 개선하는 오픈 소스 플랫폼으로, 20개 이상의 사전 구성된 체크를 제공합니다.
---

<a target="_blank" href="https://colab.research.google.com/github/langchain-ai/langchain/blob/master/docs/docs/integrations/callbacks/uptrain.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>


# UpTrain

> UpTrain [[github](https://github.com/uptrain-ai/uptrain) || [website](https://uptrain.ai/) || [docs](https://docs.uptrain.ai/getting-started/introduction)]는 LLM 애플리케이션을 평가하고 개선하기 위한 오픈 소스 플랫폼입니다. 언어, 코드, 임베딩 사용 사례를 포함한 20개 이상의 사전 구성된 체크에 대한 점수를 제공하고, 실패 사례의 근본 원인 분석을 수행하며 이를 해결하기 위한 지침을 제공합니다.

## UpTrain 콜백 핸들러

이 노트북은 UpTrain 콜백 핸들러가 파이프라인에 원활하게 통합되어 다양한 평가를 촉진하는 모습을 보여줍니다. 우리는 체인을 평가하는 데 적합하다고 판단된 몇 가지 평가를 선택했습니다. 이러한 평가는 자동으로 실행되며 결과는 출력에 표시됩니다. UpTrain의 평가에 대한 더 많은 세부정보는 [여기](https://github.com/uptrain-ai/uptrain?tab=readme-ov-file#pre-built-evaluations-we-offer-)에서 확인할 수 있습니다.

시연을 위해 Langchain에서 선택된 검색기가 강조 표시됩니다:

### 1. **바닐라 RAG**:
RAG는 컨텍스트를 검색하고 응답을 생성하는 데 중요한 역할을 합니다. 성능과 응답 품질을 보장하기 위해 다음 평가를 수행합니다:

- **[컨텍스트 관련성](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-relevance)**: 쿼리에서 추출된 컨텍스트가 응답과 관련이 있는지 확인합니다.
- **[사실 정확성](https://docs.uptrain.ai/predefined-evaluations/context-awareness/factual-accuracy)**: LLM이 환각을 일으키거나 잘못된 정보를 제공하는지 평가합니다.
- **[응답 완전성](https://docs.uptrain.ai/predefined-evaluations/response-quality/response-completeness)**: 응답이 쿼리에서 요청한 모든 정보를 포함하고 있는지 확인합니다.

### 2. **다중 쿼리 생성**:
MultiQueryRetriever는 원래 질문과 유사한 의미를 가진 여러 변형의 질문을 생성합니다. 복잡성을 감안하여 이전 평가를 포함하고 다음을 추가합니다:

- **[다중 쿼리 정확성](https://docs.uptrain.ai/predefined-evaluations/query-quality/multi-query-accuracy)**: 생성된 다중 쿼리가 원래 쿼리와 동일한 의미인지 확인합니다.

### 3. **컨텍스트 압축 및 재순위 지정**:
재순위 지정은 쿼리와의 관련성에 따라 노드를 재정렬하고 상위 n개의 노드를 선택하는 과정입니다. 재순위 지정이 완료되면 노드 수가 줄어들 수 있으므로 다음 평가를 수행합니다:

- **[컨텍스트 재순위 지정](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-reranking)**: 재순위 지정된 노드의 순서가 원래 순서보다 쿼리와 더 관련성이 있는지 확인합니다.
- **[컨텍스트 간결성](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-conciseness)**: 줄어든 노드 수가 여전히 모든 필요한 정보를 제공하는지 검토합니다.

이러한 평가는 RAG, MultiQueryRetriever 및 체인 내 재순위 프로세스의 강력함과 효과성을 보장합니다.

## 종속성 설치

```python
%pip install -qU langchain langchain_openai langchain-community uptrain faiss-cpu flashrank
```

```output
huggingface/tokenizers: The current process just got forked, after parallelism has already been used. Disabling parallelism to avoid deadlocks...
To disable this warning, you can either:
	- Avoid using `tokenizers` before the fork if possible
	- Explicitly set the environment variable TOKENIZERS_PARALLELISM=(true | false)
``````output
[33mWARNING: There was an error checking the latest version of pip.[0m[33m
[0mNote: you may need to restart the kernel to use updated packages.
```

참고: GPU가 활성화된 라이브러리 버전을 사용하려면 `faiss-cpu` 대신 `faiss-gpu`를 설치할 수도 있습니다.

## 라이브러리 가져오기

```python
<!--IMPORTS:[{"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "UpTrain"}, {"imported": "ContextualCompressionRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.contextual_compression.ContextualCompressionRetriever.html", "title": "UpTrain"}, {"imported": "FlashrankRerank", "source": "langchain.retrievers.document_compressors", "docs": "https://api.python.langchain.com/en/latest/document_compressors/langchain_community.document_compressors.flashrank_rerank.FlashrankRerank.html", "title": "UpTrain"}, {"imported": "MultiQueryRetriever", "source": "langchain.retrievers.multi_query", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.multi_query.MultiQueryRetriever.html", "title": "UpTrain"}, {"imported": "UpTrainCallbackHandler", "source": "langchain_community.callbacks.uptrain_callback", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.uptrain_callback.UpTrainCallbackHandler.html", "title": "UpTrain"}, {"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "UpTrain"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "UpTrain"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers.string", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "UpTrain"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "UpTrain"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables.passthrough", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "UpTrain"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "UpTrain"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "UpTrain"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "UpTrain"}]-->
from getpass import getpass

from langchain.chains import RetrievalQA
from langchain.retrievers import ContextualCompressionRetriever
from langchain.retrievers.document_compressors import FlashrankRerank
from langchain.retrievers.multi_query import MultiQueryRetriever
from langchain_community.callbacks.uptrain_callback import UpTrainCallbackHandler
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import FAISS
from langchain_core.output_parsers.string import StrOutputParser
from langchain_core.prompts.chat import ChatPromptTemplate
from langchain_core.runnables.passthrough import RunnablePassthrough
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_text_splitters import (
    RecursiveCharacterTextSplitter,
)
```


## 문서 로드

```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
```


## 문서를 청크로 나누기

```python
text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
chunks = text_splitter.split_documents(documents)
```


## 검색기 생성

```python
embeddings = OpenAIEmbeddings()
db = FAISS.from_documents(chunks, embeddings)
retriever = db.as_retriever()
```


## LLM 정의

```python
llm = ChatOpenAI(temperature=0, model="gpt-4")
```


## 설정

UpTrain은 다음을 제공합니다:
1. 고급 드릴다운 및 필터링 옵션이 있는 대시보드
2. 실패 사례 간의 통찰력 및 공통 주제
3. 생산 데이터의 가시성 및 실시간 모니터링
4. CI/CD 파이프라인과의 원활한 통합을 통한 회귀 테스트

UpTrain을 사용하여 평가하기 위한 다음 옵션 중에서 선택할 수 있습니다:
### 1. **UpTrain의 오픈 소스 소프트웨어 (OSS)**:
오픈 소스 평가 서비스를 사용하여 모델을 평가할 수 있습니다. 이 경우 OpenAI API 키를 제공해야 합니다. UpTrain은 LLM이 생성한 응답을 평가하기 위해 GPT 모델을 사용합니다. [여기](https://platform.openai.com/account/api-keys)에서 키를 받을 수 있습니다.

UpTrain 대시보드에서 평가를 보려면 터미널에서 다음 명령을 실행하여 설정해야 합니다:

```bash
git clone https://github.com/uptrain-ai/uptrain
cd uptrain
bash run_uptrain.sh
```


이렇게 하면 로컬 머신에서 UpTrain 대시보드가 시작됩니다. `http://localhost:3000/dashboard`에서 액세스할 수 있습니다.

매개변수:
- key_type="openai"
- api_key="OPENAI_API_KEY"
- project_name="PROJECT_NAME"

### 2. **UpTrain 관리 서비스 및 대시보드**:
또는 UpTrain의 관리 서비스를 사용하여 모델을 평가할 수 있습니다. [여기](https://uptrain.ai/)에서 무료 UpTrain 계정을 만들고 무료 체험 크레딧을 받을 수 있습니다. 더 많은 체험 크레딧이 필요하면 [여기](https://calendly.com/uptrain-sourabh/30min)에서 UpTrain 유지 관리 팀과 통화 예약을 하세요.

관리 서비스를 사용할 때의 이점은 다음과 같습니다:
1. 로컬 머신에서 UpTrain 대시보드를 설정할 필요가 없습니다.
2. API 키 없이 많은 LLM에 액세스할 수 있습니다.

평가를 수행한 후에는 `https://dashboard.uptrain.ai/dashboard`의 UpTrain 대시보드에서 이를 볼 수 있습니다.

매개변수:
- key_type="uptrain"
- api_key="UPTRAIN_API_KEY"
- project_name="PROJECT_NAME"

**참고:** `project_name`은 수행된 평가가 UpTrain 대시보드에 표시될 프로젝트 이름입니다.

## API 키 설정

노트북에서 API 키를 입력하라는 메시지가 표시됩니다. 아래 셀에서 `key_type` 매개변수를 변경하여 OpenAI API 키 또는 UpTrain API 키 중에서 선택할 수 있습니다.

```python
KEY_TYPE = "openai"  # or "uptrain"
API_KEY = getpass()
```


# 1. 바닐라 RAG

UpTrain 콜백 핸들러는 쿼리, 컨텍스트 및 응답이 생성되면 자동으로 캡처하고 응답에 대해 다음 세 가지 평가를 실행합니다 *(0에서 1까지 등급)*:
- **[컨텍스트 관련성](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-relevance)**: 쿼리에서 추출된 컨텍스트가 응답과 관련이 있는지 확인합니다.
- **[사실 정확성](https://docs.uptrain.ai/predefined-evaluations/context-awareness/factual-accuracy)**: 응답이 얼마나 사실적으로 정확한지 확인합니다.
- **[응답 완전성](https://docs.uptrain.ai/predefined-evaluations/response-quality/response-completeness)**: 응답이 쿼리에서 요청한 모든 정보를 포함하고 있는지 확인합니다.

```python
# Create the RAG prompt
template = """Answer the question based only on the following context, which can include text and tables:
{context}
Question: {question}
"""
rag_prompt_text = ChatPromptTemplate.from_template(template)

# Create the chain
chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | rag_prompt_text
    | llm
    | StrOutputParser()
)

# Create the uptrain callback handler
uptrain_callback = UpTrainCallbackHandler(key_type=KEY_TYPE, api_key=API_KEY)
config = {"callbacks": [uptrain_callback]}

# Invoke the chain with a query
query = "What did the president say about Ketanji Brown Jackson"
docs = chain.invoke(query, config=config)
```

```output
[32m2024-04-17 17:03:44.969[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate_on_server[0m:[36m378[0m - [1mSending evaluation request for rows 0 to <50 to the Uptrain[0m
[32m2024-04-17 17:04:05.809[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate[0m:[36m367[0m - [1mLocal server not running, start the server to log data and visualize in the dashboard![0m
``````output

Question: What did the president say about Ketanji Brown Jackson
Response: The president mentioned that he had nominated Ketanji Brown Jackson to serve on the United States Supreme Court 4 days ago. He described her as one of the nation's top legal minds who will continue Justice Breyer’s legacy of excellence. He also mentioned that she is a former top litigator in private practice, a former federal public defender, and comes from a family of public school educators and police officers. He described her as a consensus builder and noted that since her nomination, she has received a broad range of support from various groups, including the Fraternal Order of Police and former judges appointed by both Democrats and Republicans.

Context Relevance Score: 1.0
Factual Accuracy Score: 1.0
Response Completeness Score: 1.0
```

# 2. 다중 쿼리 생성

**MultiQueryRetriever**는 RAG 파이프라인이 쿼리를 기반으로 최상의 문서 세트를 반환하지 않을 수 있는 문제를 해결하는 데 사용됩니다. 원래 쿼리와 동일한 의미를 가진 여러 쿼리를 생성한 다음 각 쿼리에 대한 문서를 가져옵니다.

이 검색기를 평가하기 위해 UpTrain은 다음 평가를 실행합니다:
- **[다중 쿼리 정확성](https://docs.uptrain.ai/predefined-evaluations/query-quality/multi-query-accuracy)**: 생성된 다중 쿼리가 원래 쿼리와 동일한 의미인지 확인합니다.

```python
# Create the retriever
multi_query_retriever = MultiQueryRetriever.from_llm(retriever=retriever, llm=llm)

# Create the uptrain callback
uptrain_callback = UpTrainCallbackHandler(key_type=KEY_TYPE, api_key=API_KEY)
config = {"callbacks": [uptrain_callback]}

# Create the RAG prompt
template = """Answer the question based only on the following context, which can include text and tables:
{context}
Question: {question}
"""
rag_prompt_text = ChatPromptTemplate.from_template(template)

chain = (
    {"context": multi_query_retriever, "question": RunnablePassthrough()}
    | rag_prompt_text
    | llm
    | StrOutputParser()
)

# Invoke the chain with a query
question = "What did the president say about Ketanji Brown Jackson"
docs = chain.invoke(question, config=config)
```

```output
[32m2024-04-17 17:04:10.675[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate_on_server[0m:[36m378[0m - [1mSending evaluation request for rows 0 to <50 to the Uptrain[0m
[32m2024-04-17 17:04:16.804[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate[0m:[36m367[0m - [1mLocal server not running, start the server to log data and visualize in the dashboard![0m
``````output

Question: What did the president say about Ketanji Brown Jackson
Multi Queries:
  - How did the president comment on Ketanji Brown Jackson?
  - What were the president's remarks regarding Ketanji Brown Jackson?
  - What statements has the president made about Ketanji Brown Jackson?

Multi Query Accuracy Score: 0.5
``````output
[32m2024-04-17 17:04:22.027[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate_on_server[0m:[36m378[0m - [1mSending evaluation request for rows 0 to <50 to the Uptrain[0m
[32m2024-04-17 17:04:44.033[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate[0m:[36m367[0m - [1mLocal server not running, start the server to log data and visualize in the dashboard![0m
``````output

Question: What did the president say about Ketanji Brown Jackson
Response: The president mentioned that he had nominated Circuit Court of Appeals Judge Ketanji Brown Jackson to serve on the United States Supreme Court 4 days ago. He described her as one of the nation's top legal minds who will continue Justice Breyer’s legacy of excellence. He also mentioned that since her nomination, she has received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans.

Context Relevance Score: 1.0
Factual Accuracy Score: 1.0
Response Completeness Score: 1.0
```

# 3. 컨텍스트 압축 및 재순위 지정

재순위 지정 프로세스는 쿼리와의 관련성에 따라 노드를 재정렬하고 상위 n개의 노드를 선택하는 과정입니다. 재순위 지정이 완료되면 노드 수가 줄어들 수 있으므로 다음 평가를 수행합니다:
- **[컨텍스트 재순위 지정](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-reranking)**: 재순위 지정된 노드의 순서가 원래 순서보다 쿼리와 더 관련성이 있는지 확인합니다.
- **[컨텍스트 간결성](https://docs.uptrain.ai/predefined-evaluations/context-awareness/context-conciseness)**: 줄어든 노드 수가 여전히 모든 필요한 정보를 제공하는지 확인합니다.

```python
# Create the retriever
compressor = FlashrankRerank()
compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor, base_retriever=retriever
)

# Create the chain
chain = RetrievalQA.from_chain_type(llm=llm, retriever=compression_retriever)

# Create the uptrain callback
uptrain_callback = UpTrainCallbackHandler(key_type=KEY_TYPE, api_key=API_KEY)
config = {"callbacks": [uptrain_callback]}

# Invoke the chain with a query
query = "What did the president say about Ketanji Brown Jackson"
result = chain.invoke(query, config=config)
```

```output
[32m2024-04-17 17:04:46.462[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate_on_server[0m:[36m378[0m - [1mSending evaluation request for rows 0 to <50 to the Uptrain[0m
[32m2024-04-17 17:04:53.561[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate[0m:[36m367[0m - [1mLocal server not running, start the server to log data and visualize in the dashboard![0m
``````output

Question: What did the president say about Ketanji Brown Jackson

Context Conciseness Score: 0.0
Context Reranking Score: 1.0
``````output
[32m2024-04-17 17:04:56.947[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate_on_server[0m:[36m378[0m - [1mSending evaluation request for rows 0 to <50 to the Uptrain[0m
[32m2024-04-17 17:05:16.551[0m | [1mINFO    [0m | [36muptrain.framework.evalllm[0m:[36mevaluate[0m:[36m367[0m - [1mLocal server not running, start the server to log data and visualize in the dashboard![0m
``````output

Question: What did the president say about Ketanji Brown Jackson
Response: The President mentioned that he nominated Circuit Court of Appeals Judge Ketanji Brown Jackson to serve on the United States Supreme Court 4 days ago. He described her as one of the nation's top legal minds who will continue Justice Breyer’s legacy of excellence.

Context Relevance Score: 1.0
Factual Accuracy Score: 1.0
Response Completeness Score: 0.5
```

# UpTrain의 대시보드 및 통찰력

대시보드와 통찰력을 보여주는 짧은 비디오입니다:

![langchain_uptrain.gif](https://uptrain-assets.s3.ap-south-1.amazonaws.com/images/langchain/langchain_uptrain.gif)