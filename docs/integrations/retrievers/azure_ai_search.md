---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/azure_ai_search.ipynb
description: Azure AI Search는 비구조적 쿼리에서 문서를 반환하는 통합 모듈인 `AzureAISearchRetriever`를
  제공합니다.
sidebar_label: Azure AI Search
---

# AzureAISearchRetriever

[Azure AI Search](https://learn.microsoft.com/azure/search/search-what-is-azure-search) (이전 이름: `Azure Cognitive Search`)는 개발자에게 대규모 벡터, 키워드 및 하이브리드 쿼리 정보 검색을 위한 인프라, API 및 도구를 제공하는 Microsoft 클라우드 검색 서비스입니다.

`AzureAISearchRetriever`는 비구조적 쿼리에서 문서를 반환하는 통합 모듈입니다. 이는 BaseRetriever 클래스를 기반으로 하며 Azure AI Search의 2023-11-01 안정적인 REST API 버전을 대상으로 하므로 벡터 인덱싱 및 쿼리를 지원합니다.

이 가이드는 Azure AI Search [retriever](/docs/concepts/#retrievers)를 시작하는 데 도움이 됩니다. `AzureAISearchRetriever`의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.azure_ai_search.AzureAISearchRetriever.html)에서 확인할 수 있습니다.

`AzureAISearchRetriever`는 곧 사용 중단될 `AzureCognitiveSearchRetriever`를 대체합니다. 최신 안정 버전의 검색 API를 기반으로 한 새 버전으로 전환하는 것을 권장합니다.

### 통합 세부정보

import {ItemTable} from "@theme/FeatureTables";

<ItemTable category="document_retrievers" item="AzureAISearchRetriever" />


## 설정

이 모듈을 사용하려면 다음이 필요합니다:

+ Azure AI Search 서비스. Azure 체험판에 가입하면 [무료로 생성](https://learn.microsoft.com/azure/search/search-create-service-portal)할 수 있습니다. 무료 서비스는 할당량이 낮지만 이 노트북에서 코드를 실행하는 데 충분합니다.
+ 벡터 필드가 있는 기존 인덱스. [벡터 저장소 모듈](../vectorstores/azuresearch.md)을 사용하여 생성하는 등 여러 가지 방법이 있습니다. 또는 [Azure AI Search REST API를 사용해 보세요](https://learn.microsoft.com/azure/search/search-get-started-vector).
+ API 키. API 키는 검색 서비스를 생성할 때 생성됩니다. 인덱스를 쿼리하는 경우 쿼리 API 키를 사용할 수 있으며, 그렇지 않으면 관리자 API 키를 사용하세요. 자세한 내용은 [API 키 찾기](https://learn.microsoft.com/azure/search/search-security-api-keys?tabs=rest-use%2Cportal-find%2Cportal-query#find-existing-keys)를 참조하세요.

그런 다음 검색 서비스 이름, 인덱스 이름 및 API 키를 환경 변수로 설정할 수 있습니다(또는 `AzureAISearchRetriever`에 인수로 전달할 수 있습니다). 검색 인덱스는 검색 가능한 콘텐츠를 제공합니다.

```python
import os

os.environ["AZURE_AI_SEARCH_SERVICE_NAME"] = "<YOUR_SEARCH_SERVICE_NAME>"
os.environ["AZURE_AI_SEARCH_INDEX_NAME"] = "<YOUR_SEARCH_INDEX_NAME>"
os.environ["AZURE_AI_SEARCH_API_KEY"] = "<YOUR_API_KEY>"
```


개별 쿼리에서 자동 추적을 받으려면 아래의 주석을 제거하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

이 리트리버는 `langchain-community` 패키지에 포함되어 있습니다. 추가 종속성이 필요합니다:

```python
%pip install --upgrade --quiet langchain-community
%pip install --upgrade --quiet langchain-openai
%pip install --upgrade --quiet  azure-search-documents>=11.4
%pip install --upgrade --quiet  azure-identity
```


## 인스턴스화

`AzureAISearchRetriever`의 경우 `index_name`, `content_key` 및 검색할 결과 수를 설정하는 `top_k`를 제공해야 합니다. `top_k`를 0(기본값)으로 설정하면 모든 결과가 반환됩니다.

```python
<!--IMPORTS:[{"imported": "AzureAISearchRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.azure_ai_search.AzureAISearchRetriever.html", "title": "AzureAISearchRetriever"}]-->
from langchain_community.retrievers import AzureAISearchRetriever

retriever = AzureAISearchRetriever(
    content_key="content", top_k=1, index_name="langchain-vector-demo"
)
```


## 사용법

이제 Azure AI Search에서 문서를 검색하는 데 사용할 수 있습니다.
이를 수행하기 위해 호출할 메서드입니다. 쿼리와 관련된 모든 문서를 반환합니다.

```python
retriever.invoke("here is my unstructured query string")
```


## 예제

이 섹션에서는 내장 샘플 데이터를 사용하여 리트리버를 사용하는 방법을 보여줍니다. 검색 서비스에 벡터 인덱스가 이미 있는 경우 이 단계를 건너뛸 수 있습니다.

엔드포인트와 키를 제공하는 것으로 시작합니다. 이 단계에서 벡터 인덱스를 생성하므로 텍스트의 벡터 표현을 얻기 위해 텍스트 임베딩 모델을 지정합니다. 이 예제는 text-embedding-ada-002 배포가 있는 Azure OpenAI를 가정합니다. 이 단계는 인덱스를 생성하므로 검색 서비스에 대해 관리자 API 키를 사용해야 합니다.

```python
<!--IMPORTS:[{"imported": "DirectoryLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.directory.DirectoryLoader.html", "title": "AzureAISearchRetriever"}, {"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "AzureAISearchRetriever"}, {"imported": "AzureAISearchRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.azure_ai_search.AzureAISearchRetriever.html", "title": "AzureAISearchRetriever"}, {"imported": "AzureSearch", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.azuresearch.AzureSearch.html", "title": "AzureAISearchRetriever"}, {"imported": "AzureOpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.azure.AzureOpenAIEmbeddings.html", "title": "AzureAISearchRetriever"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "AzureAISearchRetriever"}, {"imported": "TokenTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/base/langchain_text_splitters.base.TokenTextSplitter.html", "title": "AzureAISearchRetriever"}]-->
import os

from langchain_community.document_loaders import DirectoryLoader, TextLoader
from langchain_community.retrievers import AzureAISearchRetriever
from langchain_community.vectorstores import AzureSearch
from langchain_openai import AzureOpenAIEmbeddings, OpenAIEmbeddings
from langchain_text_splitters import TokenTextSplitter

os.environ["AZURE_AI_SEARCH_SERVICE_NAME"] = "<YOUR_SEARCH_SERVICE_NAME>"
os.environ["AZURE_AI_SEARCH_INDEX_NAME"] = "langchain-vector-demo"
os.environ["AZURE_AI_SEARCH_API_KEY"] = "<YOUR_SEARCH_SERVICE_ADMIN_API_KEY>"
azure_endpoint: str = "<YOUR_AZURE_OPENAI_ENDPOINT>"
azure_openai_api_key: str = "<YOUR_AZURE_OPENAI_API_KEY>"
azure_openai_api_version: str = "2023-05-15"
azure_deployment: str = "text-embedding-ada-002"
```


Azure OpenAI의 임베딩 모델을 사용하여 문서를 Azure AI Search 벡터 저장소에 저장된 임베딩으로 변환합니다. 인덱스 이름은 `langchain-vector-demo`로 설정합니다. 이렇게 하면 해당 인덱스 이름과 연결된 새 벡터 저장소가 생성됩니다.

```python
embeddings = AzureOpenAIEmbeddings(
    model=azure_deployment,
    azure_endpoint=azure_endpoint,
    openai_api_key=azure_openai_api_key,
)

vector_store: AzureSearch = AzureSearch(
    embedding_function=embeddings.embed_query,
    azure_search_endpoint=os.getenv("AZURE_AI_SEARCH_SERVICE_NAME"),
    azure_search_key=os.getenv("AZURE_AI_SEARCH_API_KEY"),
    index_name="langchain-vector-demo",
)
```


다음으로 새로 생성된 벡터 저장소에 데이터를 로드합니다. 이 예제에서는 `state_of_the_union.txt` 파일을 로드합니다. 텍스트를 400 토큰 청크로 나누되 겹치지 않도록 합니다. 마지막으로 문서는 임베딩으로서 벡터 저장소에 추가됩니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "AzureAISearchRetriever"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "AzureAISearchRetriever"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../how_to/state_of_the_union.txt", encoding="utf-8")

documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=400, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

vector_store.add_documents(documents=docs)
```


다음으로 리트리버를 생성합니다. 현재 `index_name` 변수는 마지막 단계에서의 `langchain-vector-demo`입니다. 벡터 저장소 생성을 건너뛰었다면 매개변수에 인덱스 이름을 제공하세요. 이 쿼리에서는 최상위 결과가 반환됩니다.

```python
retriever = AzureAISearchRetriever(
    content_key="content", top_k=1, index_name="langchain-vector-demo"
)
```


이제 업로드한 문서에서 쿼리와 관련된 데이터를 검색할 수 있습니다.

```python
retriever.invoke("does the president have a plan for covid-19?")
```


## 체인 내에서 사용

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "AzureAISearchRetriever"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "AzureAISearchRetriever"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "AzureAISearchRetriever"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "AzureAISearchRetriever"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_template(
    """Answer the question based only on the context provided.

Context: {context}

Question: {question}"""
)

llm = ChatOpenAI(model="gpt-3.5-turbo-0125")


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
chain.invoke("does the president have a plan for covid-19?")
```


## API 참조

`AzureAISearchRetriever`의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.azure_ai_search.AzureAISearchRetriever.html)에서 확인할 수 있습니다.

## 관련

- 리트리버 [개념 가이드](/docs/concepts/#retrievers)
- 리트리버 [사용 방법 가이드](/docs/how_to/#retrievers)