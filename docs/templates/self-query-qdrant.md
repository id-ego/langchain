---
description: 이 템플릿은 Qdrant와 OpenAI를 사용하여 자기 질의를 수행합니다. 기본적으로 10개의 문서로 구성된 인공 데이터셋을
  사용합니다.
---

# self-query-qdrant

이 템플릿은 Qdrant와 OpenAI를 사용하여 [자기 쿼리](https://python.langchain.com/docs/modules/data_connection/retrievers/self_query/)를 수행합니다. 기본적으로 10개의 문서로 구성된 인공 데이터셋을 사용하지만, 자신의 데이터셋으로 교체할 수 있습니다.

## 환경 설정

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정합니다.

Qdrant 인스턴스의 URL로 `QDRANT_URL`을 설정합니다. [Qdrant Cloud](https://cloud.qdrant.io)를 사용하는 경우 `QDRANT_API_KEY` 환경 변수도 설정해야 합니다. 둘 중 하나라도 설정하지 않으면, 템플릿은 `http://localhost:6333`의 로컬 Qdrant 인스턴스에 연결을 시도합니다.

```shell
export QDRANT_URL=
export QDRANT_API_KEY=

export OPENAI_API_KEY=
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치합니다:

```shell
pip install -U "langchain-cli[serve]"
```


새로운 LangChain 프로젝트를 생성하고 이 패키지를 유일한 패키지로 설치합니다:

```shell
langchain app new my-app --package self-query-qdrant
```


기존 프로젝트에 추가하려면 다음을 실행합니다:

```shell
langchain app add self-query-qdrant
```


### 기본값

서버를 시작하기 전에 Qdrant 컬렉션을 생성하고 문서를 인덱싱해야 합니다.
다음 명령어를 실행하여 수행할 수 있습니다:

```python
from self_query_qdrant.chain import initialize

initialize()
```


다음 코드를 `app/server.py` 파일에 추가합니다:

```python
from self_query_qdrant.chain import chain

add_routes(app, chain, path="/self-query-qdrant")
```


기본 데이터셋은 요리에 대한 10개의 문서와 그 가격 및 레스토랑 정보를 포함합니다.
문서는 `packages/self-query-qdrant/self_query_qdrant/defaults.py` 파일에서 찾을 수 있습니다.
다음은 문서 중 하나입니다:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "self-query-qdrant"}]-->
from langchain_core.documents import Document

Document(
    page_content="Spaghetti with meatballs and tomato sauce",
    metadata={
        "price": 12.99,
        "restaurant": {
            "name": "Olive Garden",
            "location": ["New York", "Chicago", "Los Angeles"],
        },
    },
)
```


자기 쿼리는 메타데이터를 기반으로 추가 필터링을 통해 문서에 대한 의미론적 검색을 수행할 수 있게 해줍니다. 예를 들어, $15 미만의 요리와 뉴욕에서 제공되는 요리를 검색할 수 있습니다.

### 사용자 정의

위의 모든 예는 기본값만으로 템플릿을 시작하려는 경우를 가정합니다.
템플릿을 사용자 정의하려면 `app/server.py` 파일의 `create_chain` 함수에 매개변수를 전달하여 수행할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "Cohere", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.cohere.Cohere.html", "title": "self-query-qdrant"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "self-query-qdrant"}, {"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.schema", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "self-query-qdrant"}]-->
from langchain_community.llms import Cohere
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain.chains.query_constructor.schema import AttributeInfo

from self_query_qdrant.chain import create_chain

chain = create_chain(
    llm=Cohere(),
    embeddings=HuggingFaceEmbeddings(),
    document_contents="Descriptions of cats, along with their names and breeds.",
    metadata_field_info=[
        AttributeInfo(name="name", description="Name of the cat", type="string"),
        AttributeInfo(name="breed", description="Cat's breed", type="string"),
    ],
    collection_name="cats",
)
```


문서를 인덱싱하고 Qdrant 컬렉션을 생성하는 `initialize` 함수에도 동일하게 적용됩니다:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "self-query-qdrant"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "self-query-qdrant"}]-->
from langchain_core.documents import Document
from langchain_community.embeddings import HuggingFaceEmbeddings

from self_query_qdrant.chain import initialize

initialize(
    embeddings=HuggingFaceEmbeddings(),
    collection_name="cats",
    documents=[
        Document(
            page_content="A mean lazy old cat who destroys furniture and eats lasagna",
            metadata={"name": "Garfield", "breed": "Tabby"},
        ),
        ...
    ]
)
```


템플릿은 유연하며 다양한 문서 세트에 쉽게 사용할 수 있습니다.

### LangSmith

(선택 사항) LangSmith에 접근할 수 있는 경우, LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움이 되도록 구성합니다. 접근할 수 없는 경우 이 섹션을 건너뜁니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면, 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


### 로컬 서버

이것은 FastAPI 앱을 시작하여 [http://localhost:8000](http://localhost:8000)에서 로컬로 실행되는 서버를 시작합니다.

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/self-query-qdrant/playground](http://127.0.0.1:8000/self-query-qdrant/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/self-query-qdrant")
```