---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/usearch.ipynb
description: USearch는 FAISS와 유사한 기능을 제공하는 소형 및 고속 단일 파일 벡터 검색 엔진으로, 사용자 정의 메트릭에 중점을
  두고 설계되었습니다.
---

# USearch
> [USearch](https://unum-cloud.github.io/usearch/)는 더 작고 빠른 단일 파일 벡터 검색 엔진입니다.

> USearch의 기본 기능은 FAISS와 동일하며, 근사 최근접 이웃 검색을 조사한 적이 있다면 인터페이스가 익숙할 것입니다. FAISS는 고성능 벡터 검색 엔진을 위한 널리 인정받는 표준입니다. USearch와 FAISS는 모두 동일한 HNSW 알고리즘을 사용하지만, 설계 원칙에서 상당히 다릅니다. USearch는 성능을 희생하지 않으면서도 컴팩트하고 광범위하게 호환되며, 사용자 정의 메트릭과 적은 의존성에 주로 초점을 맞추고 있습니다.

```python
%pip install --upgrade --quiet  usearch langchain-community
```


OpenAIEmbeddings를 사용하려면 OpenAI API 키를 받아야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "USearch"}, {"imported": "USearch", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.usearch.USearch.html", "title": "USearch"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "USearch"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "USearch"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import USearch
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "USearch"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("../../../extras/modules/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


```python
db = USearch.from_documents(docs, embeddings)

query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)
```


```python
print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

## 점수가 있는 유사성 검색
`similarity_search_with_score` 메서드는 문서뿐만 아니라 쿼리와의 거리 점수도 반환할 수 있습니다. 반환된 거리 점수는 L2 거리입니다. 따라서 낮은 점수가 더 좋습니다.

```python
docs_and_scores = db.similarity_search_with_score(query)
```


```python
docs_and_scores[0]
```


```output
(Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': '../../../extras/modules/state_of_the_union.txt'}),
 0.1845687)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)