---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/google_vertex_ai_search.ipynb
description: 구글의 Vertex AI Search는 기업이 AI 기반 검색 엔진을 구축할 수 있도록 지원하며, 자연어 처리로 더 관련성
  높은 결과를 제공합니다.
sidebar_label: Google Vertex AI Search
---

# Google Vertex AI Search

> [Google Vertex AI Search](https://cloud.google.com/enterprise-search) (이전 명칭: `Generative AI App Builder`의 `Enterprise Search`)는 `Google Cloud`에서 제공하는 [Vertex AI](https://cloud.google.com/vertex-ai) 머신러닝 플랫폼의 일부입니다.
> 
> `Vertex AI Search`는 조직이 고객과 직원들을 위해 생성 AI 기반의 검색 엔진을 신속하게 구축할 수 있도록 합니다. 이는 자연어 처리 및 머신러닝 기술을 사용하여 콘텐츠 내의 관계와 사용자의 쿼리 입력에서 의도를 유추함으로써 전통적인 키워드 기반 검색 기술보다 더 관련성 높은 결과를 제공하는 의미론적 검색을 포함한 다양한 `Google Search` 기술에 기반하고 있습니다. Vertex AI Search는 또한 사용자가 검색하는 방식을 이해하는 Google의 전문성을 활용하여 콘텐츠의 관련성을 고려하여 표시된 결과의 순서를 정합니다.

> `Vertex AI Search`는 `Google Cloud Console` 및 API를 통해 기업 워크플로 통합을 위해 사용할 수 있습니다.

이 노트북은 `Vertex AI Search`를 구성하고 Vertex AI Search [retriever](/docs/concepts/#retrievers)를 사용하는 방법을 보여줍니다. Vertex AI Search retriever는 [Python 클라이언트 라이브러리](https://cloud.google.com/generative-ai-app-builder/docs/libraries#client-libraries-install-python)를 캡슐화하고 이를 사용하여 [Search Service API](https://cloud.google.com/python/docs/reference/discoveryengine/latest/google.cloud.discoveryengine_v1beta.services.search_service)에 접근합니다.

모든 `VertexAISearchRetriever` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/vertex_ai_search/langchain_google_community.vertex_ai_search.VertexAISearchRetriever.html)에서 확인할 수 있습니다.

### 통합 세부정보

import {ItemTable} from "@theme/FeatureTables";

<ItemTable category="document_retrievers" item="VertexAISearchRetriever" />


## 설정

### 설치

Vertex AI Search retriever를 사용하려면 `langchain-google-community` 및 `google-cloud-discoveryengine` 패키지를 설치해야 합니다.

```python
%pip install -qU langchain-google-community google-cloud-discoveryengine
```


### Google Cloud 및 Vertex AI Search에 대한 접근 구성

Vertex AI Search는 2023년 8월부터 허용 목록 없이 일반적으로 사용할 수 있습니다.

retriever를 사용하기 전에 다음 단계를 완료해야 합니다:

#### 검색 엔진 생성 및 비구조적 데이터 저장소 채우기

- [Vertex AI Search 시작하기 가이드](https://cloud.google.com/generative-ai-app-builder/docs/try-enterprise-search)의 지침을 따라 Google Cloud 프로젝트 및 Vertex AI Search를 설정합니다.
- [Google Cloud Console을 사용하여 비구조적 데이터 저장소를 생성합니다](https://cloud.google.com/generative-ai-app-builder/docs/create-engine-es#unstructured-data)
  - `gs://cloud-samples-data/gen-app-builder/search/alphabet-investor-pdfs` Cloud Storage 폴더의 예제 PDF 문서로 채웁니다.
  - `Cloud Storage (without metadata)` 옵션을 사용해야 합니다.

#### Vertex AI Search API에 접근하기 위한 자격 증명 설정

Vertex AI Search retriever에서 사용하는 [Vertex AI Search 클라이언트 라이브러리](https://cloud.google.com/generative-ai-app-builder/docs/libraries)는 Google Cloud에 프로그래밍 방식으로 인증하기 위한 고급 언어 지원을 제공합니다.
클라이언트 라이브러리는 [Application Default Credentials (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials)를 지원합니다; 라이브러리는 정의된 위치 집합에서 자격 증명을 찾아 API에 대한 요청을 인증하는 데 사용합니다.
ADC를 사용하면 로컬 개발 또는 프로덕션과 같은 다양한 환경에서 애플리케이션에 자격 증명을 제공할 수 있으며, 애플리케이션 코드를 수정할 필요가 없습니다.

[Google Colab](https://colab.google)에서 실행하는 경우 `google.colab.google.auth`로 인증하고, 그렇지 않은 경우 [지원되는 방법](https://cloud.google.com/docs/authentication/application-default-credentials) 중 하나를 따라 Application Default Credentials가 올바르게 설정되었는지 확인합니다.

```python
import sys

if "google.colab" in sys.modules:
    from google.colab import auth as google_auth

    google_auth.authenticate_user()
```


### Vertex AI Search retriever 구성 및 사용

Vertex AI Search retriever는 `langchain_google_community.VertexAISearchRetriever` 클래스에 구현되어 있습니다. `get_relevant_documents` 메서드는 각 문서의 `page_content` 필드가 문서 내용으로 채워진 `langchain.schema.Document` 문서 목록을 반환합니다.
Vertex AI Search에서 사용되는 데이터 유형(웹사이트, 구조적 또는 비구조적)에 따라 `page_content` 필드는 다음과 같이 채워집니다:

- 고급 인덱싱이 있는 웹사이트: 쿼리와 일치하는 `추출적 답변`. `metadata` 필드는 세그먼트 또는 답변이 추출된 문서의 메타데이터(있는 경우)로 채워집니다.
- 비구조적 데이터 소스: 쿼리와 일치하는 `추출적 세그먼트` 또는 `추출적 답변`. `metadata` 필드는 세그먼트 또는 답변이 추출된 문서의 메타데이터(있는 경우)로 채워집니다.
- 구조적 데이터 소스: 구조적 데이터 소스에서 반환된 모든 필드를 포함하는 문자열 JSON. `metadata` 필드는 문서의 메타데이터(있는 경우)로 채워집니다.

#### 추출적 답변 및 추출적 세그먼트

추출적 답변은 각 검색 결과와 함께 반환되는 원문 텍스트입니다. 이는 원본 문서에서 직접 추출됩니다. 추출적 답변은 일반적으로 웹 페이지 상단 근처에 표시되어 최종 사용자에게 쿼리와 관련된 간단한 답변을 제공합니다. 추출적 답변은 웹사이트 및 비구조적 검색에 대해 사용할 수 있습니다.

추출적 세그먼트는 각 검색 결과와 함께 반환되는 원문 텍스트입니다. 추출적 세그먼트는 일반적으로 추출적 답변보다 더 자세합니다. 추출적 세그먼트는 쿼리에 대한 답변으로 표시될 수 있으며, 후처리 작업을 수행하고 대형 언어 모델에 대한 입력으로 사용하여 답변이나 새로운 텍스트를 생성하는 데 사용할 수 있습니다. 추출적 세그먼트는 비구조적 검색에 대해 사용할 수 있습니다.

추출적 세그먼트 및 추출적 답변에 대한 자세한 내용은 [제품 문서](https://cloud.google.com/generative-ai-app-builder/docs/snippets)를 참조하십시오.

참고: 추출적 세그먼트는 [Enterprise edition](https://cloud.google.com/generative-ai-app-builder/docs/about-advanced-features#enterprise-features) 기능이 활성화되어야 합니다.

retriever의 인스턴스를 생성할 때 어떤 데이터 저장소에 접근할지 및 자연어 쿼리를 처리하는 방법을 제어하는 여러 매개변수를 지정할 수 있으며, 추출적 답변 및 세그먼트에 대한 구성도 포함됩니다.

#### 필수 매개변수는 다음과 같습니다:

- `project_id` - 귀하의 Google Cloud 프로젝트 ID.
- `location_id` - 데이터 저장소의 위치.
  - `global` (기본값)
  - `us`
  - `eu`

다음 중 하나:
- `search_engine_id` - 사용하려는 검색 앱의 ID. (혼합 검색에 필요)
- `data_store_id` - 사용하려는 데이터 저장소의 ID.

`project_id`, `search_engine_id` 및 `data_store_id` 매개변수는 retriever의 생성자에서 명시적으로 제공하거나 환경 변수 - `PROJECT_ID`, `SEARCH_ENGINE_ID` 및 `DATA_STORE_ID`를 통해 제공할 수 있습니다.

다음과 같은 여러 선택적 매개변수도 구성할 수 있습니다:

- `max_documents` - 추출적 세그먼트 또는 추출적 답변을 제공하는 데 사용되는 최대 문서 수
- `get_extractive_answers` - 기본적으로 retriever는 추출적 세그먼트를 반환하도록 구성되어 있습니다.
  - 이 필드를 `True`로 설정하면 추출적 답변이 반환됩니다. 이는 `engine_data_type`이 `0`(비구조적)으로 설정될 때만 사용됩니다.
- `max_extractive_answer_count` - 각 검색 결과에서 반환되는 최대 추출적 답변 수.
  - 최대 5개의 답변이 반환됩니다. 이는 `engine_data_type`이 `0`(비구조적)으로 설정될 때만 사용됩니다.
- `max_extractive_segment_count` - 각 검색 결과에서 반환되는 최대 추출적 세그먼트 수.
  - 현재 하나의 세그먼트가 반환됩니다. 이는 `engine_data_type`이 `0`(비구조적)으로 설정될 때만 사용됩니다.
- `filter` - 데이터 저장소의 문서와 관련된 메타데이터를 기반으로 검색 결과에 대한 필터 표현식.
- `query_expansion_condition` - 쿼리 확장이 발생할 조건을 결정하는 사양.
  - `0` - 지정되지 않은 쿼리 확장 조건. 이 경우 서버 동작은 기본적으로 비활성화됩니다.
  - `1` - 비활성화된 쿼리 확장. 검색 쿼리는 정확히 사용되며, SearchResponse.total_size가 0일지라도 사용됩니다.
  - `2` - Search API에 의해 생성된 자동 쿼리 확장.
- `engine_data_type` - Vertex AI Search 데이터 유형 정의
  - `0` - 비구조적 데이터
  - `1` - 구조적 데이터
  - `2` - 웹사이트 데이터
  - `3` - [혼합 검색](https://cloud.google.com/generative-ai-app-builder/docs/create-data-store-es#multi-data-stores)

### `GoogleCloudEnterpriseSearchRetriever`에 대한 마이그레이션 가이드

이전 버전에서는 이 retriever가 `GoogleCloudEnterpriseSearchRetriever`라고 불렸습니다.

새 retriever로 업데이트하려면 다음 변경을 수행하십시오:

- 가져오기를 변경: `from langchain.retrievers import GoogleCloudEnterpriseSearchRetriever` -> `from langchain_google_community import VertexAISearchRetriever`.
- 모든 클래스 참조를 변경: `GoogleCloudEnterpriseSearchRetriever` -> `VertexAISearchRetriever`.

참고: retriever를 사용할 때 개별 쿼리에서 자동 추적을 받으려면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 인스턴스화

### 추출적 세그먼트가 있는 **비구조적** 데이터에 대한 retriever 구성 및 사용

```python
from langchain_google_community import (
    VertexAIMultiTurnSearchRetriever,
    VertexAISearchRetriever,
)

PROJECT_ID = "<YOUR PROJECT ID>"  # Set to your Project ID
LOCATION_ID = "<YOUR LOCATION>"  # Set to your data store location
SEARCH_ENGINE_ID = "<YOUR SEARCH APP ID>"  # Set to your search app ID
DATA_STORE_ID = "<YOUR DATA STORE ID>"  # Set to your data store ID
```


```python
retriever = VertexAISearchRetriever(
    project_id=PROJECT_ID,
    location_id=LOCATION_ID,
    data_store_id=DATA_STORE_ID,
    max_documents=3,
)
```


```python
query = "What are Alphabet's Other Bets?"

result = retriever.invoke(query)
for doc in result:
    print(doc)
```


### 추출적 답변이 있는 **비구조적** 데이터에 대한 retriever 구성 및 사용

```python
retriever = VertexAISearchRetriever(
    project_id=PROJECT_ID,
    location_id=LOCATION_ID,
    data_store_id=DATA_STORE_ID,
    max_documents=3,
    max_extractive_answer_count=3,
    get_extractive_answers=True,
)

result = retriever.invoke(query)
for doc in result:
    print(doc)
```


### **구조적** 데이터에 대한 retriever 구성 및 사용

```python
retriever = VertexAISearchRetriever(
    project_id=PROJECT_ID,
    location_id=LOCATION_ID,
    data_store_id=DATA_STORE_ID,
    max_documents=3,
    engine_data_type=1,
)

result = retriever.invoke(query)
for doc in result:
    print(doc)
```


### 고급 웹사이트 인덱싱이 있는 **웹사이트** 데이터에 대한 retriever 구성 및 사용

```python
retriever = VertexAISearchRetriever(
    project_id=PROJECT_ID,
    location_id=LOCATION_ID,
    data_store_id=DATA_STORE_ID,
    max_documents=3,
    max_extractive_answer_count=3,
    get_extractive_answers=True,
    engine_data_type=2,
)

result = retriever.invoke(query)
for doc in result:
    print(doc)
```


### 혼합 데이터에 대한 retriever 구성 및 사용

```python
retriever = VertexAISearchRetriever(
    project_id=PROJECT_ID,
    location_id=LOCATION_ID,
    search_engine_id=SEARCH_ENGINE_ID,
    max_documents=3,
    engine_data_type=3,
)

result = retriever.invoke(query)
for doc in result:
    print(doc)
```


### 다중 턴 검색에 대한 retriever 구성 및 사용

[후속 질문으로 검색하기](https://cloud.google.com/generative-ai-app-builder/docs/multi-turn-search)는 생성 AI 모델을 기반으로 하며 일반 비구조적 데이터 검색과 다릅니다.

```python
retriever = VertexAIMultiTurnSearchRetriever(
    project_id=PROJECT_ID, location_id=LOCATION_ID, data_store_id=DATA_STORE_ID
)

result = retriever.invoke(query)
for doc in result:
    print(doc)
```


## 사용법

위의 예를 따라 `.invoke`를 사용하여 단일 쿼리를 발행합니다. retriever는 Runnables이므로 [Runnable 인터페이스](/docs/concepts/#runnable-interface)의 모든 메서드, 예를 들어 `.batch`를 사용할 수 있습니다.

## 체인 내에서 사용

우리는 또한 retriever를 [체인](/docs/how_to/sequence/)에 통합하여 간단한 [RAG](/docs/tutorials/rag/) 애플리케이션과 같은 더 큰 애플리케이션을 구축할 수 있습니다. 시연을 위해 VertexAI 채팅 모델도 인스턴스화합니다. 설정 지침은 해당 Vertex [통합 문서](/docs/integrations/chat/google_vertex_ai_palm/)를 참조하십시오.

```python
%pip install -qU langchain-google-vertexai
```


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Google Vertex AI Search"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Google Vertex AI Search"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Google Vertex AI Search"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_google_vertexai import ChatVertexAI

prompt = ChatPromptTemplate.from_template(
    """Answer the question based only on the context provided.

Context: {context}

Question: {question}"""
)

llm = ChatVertexAI(model_name="chat-bison", temperature=0)


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)
```


```python
chain.invoke(query)
```


## API 참조

모든 `VertexAISearchRetriever` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/vertex_ai_search/langchain_google_community.vertex_ai_search.VertexAISearchRetriever.html)에서 확인할 수 있습니다.

## 관련

- Retriever [개념 가이드](/docs/concepts/#retrievers)
- Retriever [사용 방법 가이드](/docs/how_to/#retrievers)