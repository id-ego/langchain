---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/atlas.ipynb
description: Atlas는 Nomic이 제공하는 플랫폼으로, 비구조화된 대규모 데이터셋을 시각화하고 검색하며 공유할 수 있게 해줍니다.
---

# 아틀라스

> [아틀라스](https://docs.nomic.ai/index.html)는 Nomic이 만든 플랫폼으로, 소규모 및 인터넷 규모의 비구조화 데이터셋과 상호작용할 수 있도록 설계되었습니다. 이를 통해 누구나 브라우저에서 방대한 데이터셋을 시각화하고, 검색하며, 공유할 수 있습니다.

이 통합 기능을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

이 노트북은 `AtlasDB` 벡터 저장소와 관련된 기능을 사용하는 방법을 보여줍니다.

```python
%pip install --upgrade --quiet  spacy
```


```python
!python3 -m spacy download en_core_web_sm
```


```python
%pip install --upgrade --quiet  nomic
```


### 패키지 로드

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Atlas"}, {"imported": "AtlasDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.atlas.AtlasDB.html", "title": "Atlas"}, {"imported": "SpacyTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/spacy/langchain_text_splitters.spacy.SpacyTextSplitter.html", "title": "Atlas"}]-->
import time

from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import AtlasDB
from langchain_text_splitters import SpacyTextSplitter
```


```python
ATLAS_TEST_API_KEY = "7xDPkYXSYDc1_ErdTPIcoAR9RNd8YDlkS3nVNXcVoIMZ6"
```


### 데이터 준비

```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = SpacyTextSplitter(separator="|")
texts = []
for doc in text_splitter.split_documents(documents):
    texts.extend(doc.page_content.split("|"))

texts = [e.strip() for e in texts]
```


### Nomic의 아틀라스를 사용하여 데이터 매핑

```python
db = AtlasDB.from_texts(
    texts=texts,
    name="test_index_" + str(time.time()),  # unique name for your vector store
    description="test_index",  # a description for your vector store
    api_key=ATLAS_TEST_API_KEY,
    index_kwargs={"build_topic_model": True},
)
```


```python
db.project.wait_for_project_lock()
```


```python
db.project
```


이 코드를 실행한 결과로 생성된 맵입니다. 이 맵은 국정 연설의 텍스트를 표시합니다.
https://atlas.nomic.ai/map/3e4de075-89ff-486a-845c-36c23f30bb67/d8ce2284-8edb-4050-8b9b-9bb543d7f647

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)