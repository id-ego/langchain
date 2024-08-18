---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/singlestoredb.ipynb
description: SingleStoreDB는 클라우드 및 온프레미스에서 배포 가능한 고성능 분산 SQL 데이터베이스로, AI 애플리케이션을 위한
  벡터 저장 및 기능을 지원합니다.
---

# SingleStoreDB

> [SingleStoreDB](https://singlestore.com/)는 클라우드([cloud](https://www.singlestore.com/cloud/))와 온프레미스에서 배포를 지원하는 고성능 분산 SQL 데이터베이스입니다. 벡터 저장소 및 [dot_product](https://docs.singlestore.com/managed-service/en/reference/sql-reference/vector-functions/dot_product.html)와 [euclidean_distance](https://docs.singlestore.com/managed-service/en/reference/sql-reference/vector-functions/euclidean_distance.html)와 같은 벡터 기능을 제공하여 텍스트 유사성 매칭이 필요한 AI 애플리케이션을 지원합니다.

이 노트북은 `SingleStoreDB`를 사용하는 검색기를 사용하는 방법을 보여줍니다.

```python
# Establishing a connection to the database is facilitated through the singlestoredb Python connector.
# Please ensure that this connector is installed in your working environment.
%pip install --upgrade --quiet  singlestoredb
```


## 벡터 저장소에서 검색기 생성

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "SingleStoreDB"}, {"imported": "SingleStoreDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.singlestoredb.SingleStoreDB.html", "title": "SingleStoreDB"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "SingleStoreDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "SingleStoreDB"}]-->
import getpass
import os

# We want to use OpenAIEmbeddings so we have to get the OpenAI API Key.
os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")

from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import SingleStoreDB
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()

# Setup connection url as environment variable
os.environ["SINGLESTOREDB_URL"] = "root:pass@localhost:3306/db"

# Load documents to the store
docsearch = SingleStoreDB.from_documents(
    docs,
    embeddings,
    table_name="notebook",  # use table with a custom name
)

# create retriever from the vector store
retriever = docsearch.as_retriever(search_kwargs={"k": 2})
```


## 검색기로 검색

```python
result = retriever.invoke("What did the president say about Ketanji Brown Jackson")
print(docs[0].page_content)
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)