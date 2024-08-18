---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/milvus_hybrid_search.ipynb
description: Milvus 하이브리드 검색 리트리버는 밀러스의 밀집 및 희소 벡터 검색의 강점을 결합하여 비정형 데이터 검색을 용이하게 합니다.
sidebar_label: Milvus Hybrid Search
---

# Milvus 하이브리드 검색 리트리버

> [Milvus](https://milvus.io/docs)는 임베딩 유사성 검색 및 AI 애플리케이션을 지원하기 위해 구축된 오픈 소스 벡터 데이터베이스입니다. Milvus는 비구조적 데이터 검색을 보다 접근 가능하게 만들고, 배포 환경에 관계없이 일관된 사용자 경험을 제공합니다.

이 문서는 밀버스 하이브리드 검색 [리트리버](/docs/concepts/#retrievers)를 시작하는 데 도움이 될 것입니다. 이는 밀집 벡터 검색과 희소 벡터 검색의 강점을 결합합니다. `MilvusCollectionHybridSearchRetriever`의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_milvus.retrievers.milvus_hybrid_search.MilvusCollectionHybridSearchRetriever.html)에서 확인할 수 있습니다.

또한 Milvus 다중 벡터 검색 [문서](https://milvus.io/docs/multi-vector-search.md)를 참조하십시오.

### 통합 세부정보

import {ItemTable} from "@theme/FeatureTables";

<ItemTable category="document_retrievers" item="MilvusCollectionHybridSearchRetriever" />


## 설정

개별 쿼리에서 자동 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

이 리트리버는 `langchain-milvus` 패키지에 포함되어 있습니다. 이 가이드는 다음 종속성을 요구합니다:

```python
%pip install --upgrade --quiet pymilvus[model] langchain-milvus langchain-openai
```


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Milvus Hybrid Search Retriever"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Milvus Hybrid Search Retriever"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Milvus Hybrid Search Retriever"}, {"imported": "MilvusCollectionHybridSearchRetriever", "source": "langchain_milvus.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_milvus.retrievers.milvus_hybrid_search.MilvusCollectionHybridSearchRetriever.html", "title": "Milvus Hybrid Search Retriever"}, {"imported": "BM25SparseEmbedding", "source": "langchain_milvus.utils.sparse", "docs": "https://api.python.langchain.com/en/latest/utils/langchain_milvus.utils.sparse.BM25SparseEmbedding.html", "title": "Milvus Hybrid Search Retriever"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Milvus Hybrid Search Retriever"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Milvus Hybrid Search Retriever"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_milvus.retrievers import MilvusCollectionHybridSearchRetriever
from langchain_milvus.utils.sparse import BM25SparseEmbedding
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from pymilvus import (
    Collection,
    CollectionSchema,
    DataType,
    FieldSchema,
    WeightedRanker,
    connections,
)
```


### Milvus 서비스 시작

Milvus 서비스를 시작하려면 [Milvus 문서](https://milvus.io/docs/install_standalone-docker.md)를 참조하십시오.

Milvus를 시작한 후, Milvus 연결 URI를 지정해야 합니다.

```python
CONNECTION_URI = "http://localhost:19530"
```


### OpenAI API 키 준비

OpenAI API 키를 얻으려면 [OpenAI 문서](https://platform.openai.com/account/api-keys)를 참조하고, 이를 환경 변수로 설정하십시오.

```shell
export OPENAI_API_KEY=<your_api_key>
```


### 밀집 및 희소 임베딩 함수 준비

10개의 가상의 소설 설명을 만들어 봅시다. 실제 생산에서는 대량의 텍스트 데이터가 될 수 있습니다.

```python
texts = [
    "In 'The Whispering Walls' by Ava Moreno, a young journalist named Sophia uncovers a decades-old conspiracy hidden within the crumbling walls of an ancient mansion, where the whispers of the past threaten to destroy her own sanity.",
    "In 'The Last Refuge' by Ethan Blackwood, a group of survivors must band together to escape a post-apocalyptic wasteland, where the last remnants of humanity cling to life in a desperate bid for survival.",
    "In 'The Memory Thief' by Lila Rose, a charismatic thief with the ability to steal and manipulate memories is hired by a mysterious client to pull off a daring heist, but soon finds themselves trapped in a web of deceit and betrayal.",
    "In 'The City of Echoes' by Julian Saint Clair, a brilliant detective must navigate a labyrinthine metropolis where time is currency, and the rich can live forever, but at a terrible cost to the poor.",
    "In 'The Starlight Serenade' by Ruby Flynn, a shy astronomer discovers a mysterious melody emanating from a distant star, which leads her on a journey to uncover the secrets of the universe and her own heart.",
    "In 'The Shadow Weaver' by Piper Redding, a young orphan discovers she has the ability to weave powerful illusions, but soon finds herself at the center of a deadly game of cat and mouse between rival factions vying for control of the mystical arts.",
    "In 'The Lost Expedition' by Caspian Grey, a team of explorers ventures into the heart of the Amazon rainforest in search of a lost city, but soon finds themselves hunted by a ruthless treasure hunter and the treacherous jungle itself.",
    "In 'The Clockwork Kingdom' by Augusta Wynter, a brilliant inventor discovers a hidden world of clockwork machines and ancient magic, where a rebellion is brewing against the tyrannical ruler of the land.",
    "In 'The Phantom Pilgrim' by Rowan Welles, a charismatic smuggler is hired by a mysterious organization to transport a valuable artifact across a war-torn continent, but soon finds themselves pursued by deadly assassins and rival factions.",
    "In 'The Dreamwalker's Journey' by Lyra Snow, a young dreamwalker discovers she has the ability to enter people's dreams, but soon finds herself trapped in a surreal world of nightmares and illusions, where the boundaries between reality and fantasy blur.",
]
```


밀집 벡터를 생성하기 위해 [OpenAI Embedding](https://platform.openai.com/docs/guides/embeddings)을 사용하고, 희소 벡터를 생성하기 위해 [BM25 알고리즘](https://en.wikipedia.org/wiki/Okapi_BM25)을 사용합니다.

밀집 임베딩 함수를 초기화하고 차원을 가져옵니다.

```python
dense_embedding_func = OpenAIEmbeddings()
dense_dim = len(dense_embedding_func.embed_query(texts[1]))
dense_dim
```


```output
1536
```


희소 임베딩 함수를 초기화합니다.

희소 임베딩의 출력은 입력 텍스트의 키워드의 인덱스와 가중치를 나타내는 희소 벡터 집합입니다.

```python
sparse_embedding_func = BM25SparseEmbedding(corpus=texts)
sparse_embedding_func.embed_query(texts[1])
```


```output
{0: 0.4270424944042204,
 21: 1.845826690498331,
 22: 1.845826690498331,
 23: 1.845826690498331,
 24: 1.845826690498331,
 25: 1.845826690498331,
 26: 1.845826690498331,
 27: 1.2237754316221157,
 28: 1.845826690498331,
 29: 1.845826690498331,
 30: 1.845826690498331,
 31: 1.845826690498331,
 32: 1.845826690498331,
 33: 1.845826690498331,
 34: 1.845826690498331,
 35: 1.845826690498331,
 36: 1.845826690498331,
 37: 1.845826690498331,
 38: 1.845826690498331,
 39: 1.845826690498331}
```


### Milvus 컬렉션 생성 및 데이터 로드

연결 URI를 초기화하고 연결을 설정합니다.

```python
connections.connect(uri=CONNECTION_URI)
```


필드 이름과 데이터 유형을 정의합니다.

```python
pk_field = "doc_id"
dense_field = "dense_vector"
sparse_field = "sparse_vector"
text_field = "text"
fields = [
    FieldSchema(
        name=pk_field,
        dtype=DataType.VARCHAR,
        is_primary=True,
        auto_id=True,
        max_length=100,
    ),
    FieldSchema(name=dense_field, dtype=DataType.FLOAT_VECTOR, dim=dense_dim),
    FieldSchema(name=sparse_field, dtype=DataType.SPARSE_FLOAT_VECTOR),
    FieldSchema(name=text_field, dtype=DataType.VARCHAR, max_length=65_535),
]
```


정의된 스키마로 컬렉션을 생성합니다.

```python
schema = CollectionSchema(fields=fields, enable_dynamic_field=False)
collection = Collection(
    name="IntroductionToTheNovels", schema=schema, consistency_level="Strong"
)
```


밀집 및 희소 벡터에 대한 인덱스를 정의합니다.

```python
dense_index = {"index_type": "FLAT", "metric_type": "IP"}
collection.create_index("dense_vector", dense_index)
sparse_index = {"index_type": "SPARSE_INVERTED_INDEX", "metric_type": "IP"}
collection.create_index("sparse_vector", sparse_index)
collection.flush()
```


컬렉션에 엔티티를 삽입하고 컬렉션을 로드합니다.

```python
entities = []
for text in texts:
    entity = {
        dense_field: dense_embedding_func.embed_documents([text])[0],
        sparse_field: sparse_embedding_func.embed_documents([text])[0],
        text_field: text,
    }
    entities.append(entity)
collection.insert(entities)
collection.load()
```


## 인스턴스화

이제 리트리버를 인스턴스화하고 희소 및 밀집 필드에 대한 검색 매개변수를 정의할 수 있습니다:

```python
sparse_search_params = {"metric_type": "IP"}
dense_search_params = {"metric_type": "IP", "params": {}}
retriever = MilvusCollectionHybridSearchRetriever(
    collection=collection,
    rerank=WeightedRanker(0.5, 0.5),
    anns_fields=[dense_field, sparse_field],
    field_embeddings=[dense_embedding_func, sparse_embedding_func],
    field_search_params=[dense_search_params, sparse_search_params],
    top_k=3,
    text_field=text_field,
)
```


이 리트리버의 입력 매개변수에서 밀집 임베딩과 희소 임베딩을 사용하여 이 컬렉션의 두 필드에서 하이브리드 검색을 수행하고, 재순위를 위해 WeightedRanker를 사용합니다. 마지막으로, 상위 K개의 문서 3개가 반환됩니다.

## 사용법

```python
retriever.invoke("What are the story about ventures?")
```


```output
[Document(page_content="In 'The Lost Expedition' by Caspian Grey, a team of explorers ventures into the heart of the Amazon rainforest in search of a lost city, but soon finds themselves hunted by a ruthless treasure hunter and the treacherous jungle itself.", metadata={'doc_id': '449281835035545843'}),
 Document(page_content="In 'The Phantom Pilgrim' by Rowan Welles, a charismatic smuggler is hired by a mysterious organization to transport a valuable artifact across a war-torn continent, but soon finds themselves pursued by deadly assassins and rival factions.", metadata={'doc_id': '449281835035545845'}),
 Document(page_content="In 'The Dreamwalker's Journey' by Lyra Snow, a young dreamwalker discovers she has the ability to enter people's dreams, but soon finds herself trapped in a surreal world of nightmares and illusions, where the boundaries between reality and fantasy blur.", metadata={'doc_id': '449281835035545846'})]
```


## 체인 내에서 사용

ChatOpenAI를 초기화하고 프롬프트 템플릿을 정의합니다.

```python
llm = ChatOpenAI()

PROMPT_TEMPLATE = """
Human: You are an AI assistant, and provides answers to questions by using fact based and statistical information when possible.
Use the following pieces of information to provide a concise answer to the question enclosed in <question> tags.

<context>
{context}
</context>

<question>
{question}
</question>

Assistant:"""

prompt = PromptTemplate(
    template=PROMPT_TEMPLATE, input_variables=["context", "question"]
)
```


문서를 포맷하는 함수를 정의합니다.

```python
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)
```


리트리버 및 기타 구성 요소를 사용하여 체인을 정의합니다.

```python
rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)
```


정의된 체인을 사용하여 쿼리를 수행합니다.

```python
rag_chain.invoke("What novels has Lila written and what are their contents?")
```


```output
"Lila Rose has written 'The Memory Thief,' which follows a charismatic thief with the ability to steal and manipulate memories as they navigate a daring heist and a web of deceit and betrayal."
```


컬렉션을 삭제합니다.

```python
collection.drop()
```


## API 참조

`MilvusCollectionHybridSearchRetriever`의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_milvus.retrievers.milvus_hybrid_search.MilvusCollectionHybridSearchRetriever.html)에서 확인할 수 있습니다.

## 관련

- 리트리버 [개념 가이드](/docs/concepts/#retrievers)
- 리트리버 [사용 방법 가이드](/docs/how_to/#retrievers)