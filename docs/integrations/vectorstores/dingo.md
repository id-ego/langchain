---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/dingo.ipynb
description: DingoDB는 데이터 레이크와 벡터 데이터베이스의 특성을 결합한 분산 멀티 모드 벡터 데이터베이스입니다. 다양한 데이터 유형을
  저장하고 실시간 처리 기능을 제공합니다.
---

# DingoDB

> [DingoDB](https://dingodb.readthedocs.io/en/latest/)는 데이터 레이크와 벡터 데이터베이스의 특성을 결합한 분산 다중 모드 벡터 데이터베이스로, 모든 유형과 크기(키-값, PDF, 오디오, 비디오 등)의 데이터를 저장할 수 있습니다. 실시간 저지연 처리 기능을 갖추고 있어 신속한 통찰력과 응답을 달성하며, 즉각적인 분석을 효율적으로 수행하고 다중 모드 데이터를 처리할 수 있습니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

이 노트북은 DingoDB 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

실행하려면 [DingoDB 인스턴스가 실행 중이어야](https://github.com/dingodb/dingo-deploy/blob/main/README.md) 합니다.

```python
%pip install --upgrade --quiet  dingodb
# or install latest:
%pip install --upgrade --quiet  git+https://git@github.com/dingodb/pydingo.git
```


OpenAIEmbeddings를 사용하려면 OpenAI API 키를 받아야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```

```output
OpenAI API Key:········
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "DingoDB"}, {"imported": "Dingo", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.dingo.Dingo.html", "title": "DingoDB"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "DingoDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "DingoDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import Dingo
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "DingoDB"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


```python
from dingodb import DingoDB

index_name = "langchain_demo"

dingo_client = DingoDB(user="", password="", host=["127.0.0.1:13000"])
# First, check if our index already exists. If it doesn't, we create it
if (
    index_name not in dingo_client.get_index()
    and index_name.upper() not in dingo_client.get_index()
):
    # we create a new index, modify to your own
    dingo_client.create_index(
        index_name=index_name, dimension=1536, metric_type="cosine", auto_id=False
    )

# The OpenAI embedding model `text-embedding-ada-002 uses 1536 dimensions`
docsearch = Dingo.from_documents(
    docs, embeddings, client=dingo_client, index_name=index_name
)
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "DingoDB"}, {"imported": "Dingo", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.dingo.Dingo.html", "title": "DingoDB"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "DingoDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "DingoDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import Dingo
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
query = "What did the president say about Ketanji Brown Jackson"
docs = docsearch.similarity_search(query)
```


```python
print(docs[0].page_content)
```


### 기존 인덱스에 텍스트 추가하기

기존 Dingo 인덱스에 더 많은 텍스트를 삽입하고 업데이트하려면 `add_texts` 함수를 사용할 수 있습니다.

```python
vectorstore = Dingo(embeddings, "text", client=dingo_client, index_name=index_name)

vectorstore.add_texts(["More text!"])
```


### 최대 한계 관련 검색

검색기 객체에서 유사성 검색을 사용하는 것 외에도 `mmr`을 검색기로 사용할 수 있습니다.

```python
retriever = docsearch.as_retriever(search_type="mmr")
matched_docs = retriever.invoke(query)
for i, d in enumerate(matched_docs):
    print(f"\n## Document {i}\n")
    print(d.page_content)
```


또는 `max_marginal_relevance_search`를 직접 사용할 수 있습니다:

```python
found_docs = docsearch.max_marginal_relevance_search(query, k=2, fetch_k=10)
for i, doc in enumerate(found_docs):
    print(f"{i + 1}.", doc.page_content, "\n")
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)