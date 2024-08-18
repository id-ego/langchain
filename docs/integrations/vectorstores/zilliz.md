---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/zilliz.ipynb
description: Zilliz Cloud는 LF AI Milvus®를 위한 완전 관리형 클라우드 서비스로, 벡터 데이터베이스 기능을 제공합니다.
---

# Zilliz

> [Zilliz Cloud](https://zilliz.com/doc/quick_start)는 `LF AI Milvus®`를 위한 완전 관리형 클라우드 서비스입니다.

이 노트북은 Zilliz Cloud 관리형 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

실행하려면 `Zilliz Cloud` 인스턴스가 실행 중이어야 합니다. 설치 지침은 [여기](https://zilliz.com/cloud)를 참조하세요.

```python
%pip install --upgrade --quiet  pymilvus
```


`OpenAIEmbeddings`를 사용하려고 하므로 OpenAI API 키를 얻어야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```

```output
OpenAI API Key:········
```


```python
# replace
ZILLIZ_CLOUD_URI = ""  # example: "https://in01-17f69c292d4a5sa.aws-us-west-2.vectordb.zillizcloud.com:19536"
ZILLIZ_CLOUD_USERNAME = ""  # example: "username"
ZILLIZ_CLOUD_PASSWORD = ""  # example: "*********"
ZILLIZ_CLOUD_API_KEY = ""  # example: "*********" (for serverless clusters which can be used as replacements for user and password)
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Zilliz"}, {"imported": "Milvus", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.milvus.Milvus.html", "title": "Zilliz"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Zilliz"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Zilliz"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import Milvus
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Zilliz"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


```python
vector_db = Milvus.from_documents(
    docs,
    embeddings,
    connection_args={
        "uri": ZILLIZ_CLOUD_URI,
        "user": ZILLIZ_CLOUD_USERNAME,
        "password": ZILLIZ_CLOUD_PASSWORD,
        # "token": ZILLIZ_CLOUD_API_KEY,  # API key, for serverless clusters which can be used as replacements for user and password
        "secure": True,
    },
)
```


```python
query = "What did the president say about Ketanji Brown Jackson"
docs = vector_db.similarity_search(query)
```


```python
docs[0].page_content
```


```output
'Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.'
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)