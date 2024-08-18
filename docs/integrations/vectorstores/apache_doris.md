---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/apache_doris.ipynb
description: Apache Doris는 실시간 데이터에 대한 빠른 분석을 제공하는 현대적인 데이터 웨어하우스입니다. OLAP 성능이 뛰어나며
  벡터 데이터베이스로도 사용 가능합니다.
---

# 아파치 도리스

> [아파치 도리스](https://doris.apache.org/)는 실시간 분석을 위한 현대적인 데이터 웨어하우스입니다.  
실시간 데이터에 대한 번개처럼 빠른 분석을 대규모로 제공합니다.

> 일반적으로 `아파치 도리스`는 OLAP으로 분류되며, [ClickBench — 분석 DBMS 벤치마크](https://benchmark.clickhouse.com/)에서 뛰어난 성능을 보여주었습니다. 초고속 벡터화 실행 엔진을 갖추고 있어 빠른 벡터 DB로도 사용할 수 있습니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

여기서는 아파치 도리스 벡터 저장소를 사용하는 방법을 보여줍니다.

## 설정

```python
%pip install --upgrade --quiet  pymysql
```


시작 부분에 `update_vectordb = False`로 설정합니다. 문서가 업데이트되지 않으면 문서의 임베딩을 재구성할 필요가 없습니다.

```python
!pip install  sqlalchemy
!pip install langchain
```


```python
<!--IMPORTS:[{"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "Apache Doris"}, {"imported": "DirectoryLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.directory.DirectoryLoader.html", "title": "Apache Doris"}, {"imported": "UnstructuredMarkdownLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html", "title": "Apache Doris"}, {"imported": "ApacheDoris", "source": "langchain_community.vectorstores.apache_doris", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.apache_doris.ApacheDoris.html", "title": "Apache Doris"}, {"imported": "ApacheDorisSettings", "source": "langchain_community.vectorstores.apache_doris", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.apache_doris.ApacheDorisSettings.html", "title": "Apache Doris"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Apache Doris"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Apache Doris"}, {"imported": "TokenTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/base/langchain_text_splitters.base.TokenTextSplitter.html", "title": "Apache Doris"}]-->
from langchain.chains import RetrievalQA
from langchain_community.document_loaders import (
    DirectoryLoader,
    UnstructuredMarkdownLoader,
)
from langchain_community.vectorstores.apache_doris import (
    ApacheDoris,
    ApacheDorisSettings,
)
from langchain_openai import OpenAI, OpenAIEmbeddings
from langchain_text_splitters import TokenTextSplitter

update_vectordb = False
```


## 문서 로드 및 토큰으로 분할

`docs` 디렉토리 아래의 모든 마크다운 파일을 로드합니다.

아파치 도리스 문서의 경우 https://github.com/apache/doris에서 리포지토리를 클론할 수 있으며, 그 안에 `docs` 디렉토리가 있습니다.

```python
loader = DirectoryLoader(
    "./docs", glob="**/*.md", loader_cls=UnstructuredMarkdownLoader
)
documents = loader.load()
```


문서를 토큰으로 분할하고, 새로운 문서/토큰이 있으므로 `update_vectordb = True`로 설정합니다.

```python
# load text splitter and split docs into snippets of text
text_splitter = TokenTextSplitter(chunk_size=400, chunk_overlap=50)
split_docs = text_splitter.split_documents(documents)

# tell vectordb to update text embeddings
update_vectordb = True
```


split_docs[-20]

print("# docs  = %d, # splits = %d" % (len(documents), len(split_docs)))

## 벡터 DB 인스턴스 생성

### 아파치 도리스를 벡터 DB로 사용

```python
def gen_apache_doris(update_vectordb, embeddings, settings):
    if update_vectordb:
        docsearch = ApacheDoris.from_documents(split_docs, embeddings, config=settings)
    else:
        docsearch = ApacheDoris(embeddings, settings)
    return docsearch
```


## 토큰을 임베딩으로 변환하고 벡터 DB에 넣기

여기서는 아파치 도리스를 벡터 DB로 사용하며, `ApacheDorisSettings`를 통해 아파치 도리스 인스턴스를 구성할 수 있습니다.

아파치 도리스 인스턴스를 구성하는 것은 mysql 인스턴스를 구성하는 것과 매우 유사합니다. 다음을 지정해야 합니다:
1. 호스트/포트
2. 사용자 이름(기본값: 'root')
3. 비밀번호(기본값: '')
4. 데이터베이스(기본값: 'default')
5. 테이블(기본값: 'langchain')

```python
import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


```python
update_vectordb = True

embeddings = OpenAIEmbeddings()

# configure Apache Doris settings(host/port/user/pw/db)
settings = ApacheDorisSettings()
settings.port = 9030
settings.host = "172.30.34.130"
settings.username = "root"
settings.password = ""
settings.database = "langchain"
docsearch = gen_apache_doris(update_vectordb, embeddings, settings)

print(docsearch)

update_vectordb = False
```


## QA 구축 및 질문하기

```python
llm = OpenAI()
qa = RetrievalQA.from_chain_type(
    llm=llm, chain_type="stuff", retriever=docsearch.as_retriever()
)
query = "what is apache doris"
resp = qa.run(query)
print(resp)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)