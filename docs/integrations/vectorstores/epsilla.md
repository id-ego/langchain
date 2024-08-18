---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/epsilla.ipynb
description: Epsilla는 고급 병렬 그래프 탐색 기술을 활용한 오픈 소스 벡터 데이터베이스로, 벡터 인덱싱을 지원합니다.
---

# Epsilla

> [Epsilla](https://www.epsilla.com)는 벡터 인덱싱을 위한 고급 병렬 그래프 탐색 기술을 활용하는 오픈 소스 벡터 데이터베이스입니다. Epsilla는 GPL-3.0 라이센스 하에 제공됩니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

이 노트북은 `Epsilla` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

전제 조건으로, 실행 중인 Epsilla 벡터 데이터베이스(예: 우리의 도커 이미지)를 갖추고 `pyepsilla` 패키지를 설치해야 합니다. 전체 문서는 [docs](https://epsilla-inc.gitbook.io/epsilladb/quick-start)에서 확인할 수 있습니다.

```python
!pip/pip3 install pyepsilla
```


OpenAIEmbeddings를 사용하려면 OpenAI API 키를 받아야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


OpenAI API Key: ········

```python
<!--IMPORTS:[{"imported": "Epsilla", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.epsilla.Epsilla.html", "title": "Epsilla"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Epsilla"}]-->
from langchain_community.vectorstores import Epsilla
from langchain_openai import OpenAIEmbeddings
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Epsilla"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Epsilla"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()

documents = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0).split_documents(
    documents
)

embeddings = OpenAIEmbeddings()
```


Epsilla vectordb는 기본 호스트 "localhost"와 포트 "8888"에서 실행되고 있습니다. 우리는 기본값 대신 사용자 정의 db 경로, db 이름 및 컬렉션 이름을 가지고 있습니다.

```python
from pyepsilla import vectordb

client = vectordb.Client()
vector_store = Epsilla.from_documents(
    documents,
    embeddings,
    client,
    db_path="/tmp/mypath",
    db_name="MyDB",
    collection_name="MyCollection",
)
```


```python
query = "What did the president say about Ketanji Brown Jackson"
docs = vector_store.similarity_search(query)
print(docs[0].page_content)
```


주마다 새로운 법안이 통과되고 있으며, 이는 투표를 억압할 뿐만 아니라 전체 선거를 전복시키기 위한 것입니다.

우리는 이런 일이 발생하도록 두어서는 안 됩니다.

오늘 밤. 나는 상원에 요청합니다: 투표의 자유 법안을 통과시키십시오. 존 루이스 투표 권리 법안을 통과시키십시오. 그리고 그와 동시에, 미국인들이 우리의 선거를 누가 자금 지원하는지 알 수 있도록 공개 법안을 통과시키십시오.

오늘 밤, 이 나라를 위해 자신의 삶을 바친 한 사람을 기리고 싶습니다: 스티븐 브라이어 대법관—군인 퇴역자, 헌법 학자, 그리고 미국 대법원의 은퇴 대법관입니다. 브라이어 대법관님, 당신의 봉사에 감사드립니다.

대통령이 가장 심각한 헌법적 책임 중 하나는 미국 대법원에서 봉사할 사람을 지명하는 것입니다.

그리고 저는 4일 전, 항소 법원 판사 케탄지 브라운 잭슨을 지명했습니다. 우리나라 최고의 법률 전문가 중 한 명으로, 브라이어 대법관의 우수성의 유산을 계속 이어갈 것입니다.

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)