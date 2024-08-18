---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/surrealdb.ipynb
description: SurrealDB는 현대 애플리케이션을 위한 클라우드 네이티브 데이터베이스로, 개발 시간을 단축하고 안전하고 효율적인 앱을
  신속하게 구축할 수 있습니다.
---

# SurrealDB

> [SurrealDB](https://surrealdb.com/)는 웹, 모바일, 서버리스, Jamstack, 백엔드 및 전통적인 애플리케이션을 포함한 현대 애플리케이션을 위해 설계된 엔드 투 엔드 클라우드 네이티브 데이터베이스입니다. SurrealDB를 사용하면 데이터베이스 및 API 인프라를 단순화하고 개발 시간을 줄이며 안전하고 성능이 뛰어난 애플리케이션을 빠르고 비용 효율적으로 구축할 수 있습니다.
> 
> **SurrealDB의 주요 기능은 다음과 같습니다:**
> 
> * **개발 시간 단축:** SurrealDB는 대부분의 서버 측 구성 요소를 제거하여 데이터베이스 및 API 스택을 단순화하므로 안전하고 성능이 뛰어난 애플리케이션을 더 빠르고 저렴하게 구축할 수 있습니다.
> * **실시간 협업 API 백엔드 서비스:** SurrealDB는 데이터베이스와 API 백엔드 서비스로 기능하여 실시간 협업을 가능하게 합니다.
> * **다양한 쿼리 언어 지원:** SurrealDB는 클라이언트 장치에서 SQL 쿼리, GraphQL, ACID 트랜잭션, WebSocket 연결, 구조화된 데이터 및 비구조화된 데이터, 그래프 쿼리, 전체 텍스트 인덱싱 및 지리 공간 쿼리를 지원합니다.
> * **세분화된 접근 제어:** SurrealDB는 행 수준의 권한 기반 접근 제어를 제공하여 데이터 접근을 정밀하게 관리할 수 있는 능력을 제공합니다.
> 
> [기능](https://surrealdb.com/features), 최신 [릴리스](https://surrealdb.com/releases) 및 [문서](https://surrealdb.com/docs)를 확인하세요.

이 노트북은 `SurrealDBLoader`와 관련된 기능을 사용하는 방법을 보여줍니다.

## 개요

SurrealDB 문서 로더는 SurrealDB 데이터베이스에서 Langchain 문서 목록을 반환합니다.

문서 로더는 다음과 같은 선택적 매개변수를 사용합니다:

* `dburl`: 웹소켓 엔드포인트에 대한 연결 문자열. 기본값: `ws://localhost:8000/rpc`
* `ns`: 네임스페이스의 이름. 기본값: `langchain`
* `db`: 데이터베이스의 이름. 기본값: `database`
* `table`: 테이블의 이름. 기본값: `documents`
* `db_user`: 필요한 경우 SurrealDB 자격 증명: db 사용자 이름.
* `db_pass`: 필요한 경우 SurrealDB 자격 증명: db 비밀번호.
* `filter_criteria`: 테이블에서 결과를 필터링하기 위한 `WHERE` 절을 구성하는 사전.

출력 `Document`는 다음과 같은 형태를 가집니다:
```
Document(
    page_content=<json encoded string containing the result document>,
    metadata={
        'id': <document id>,
        'ns': <namespace name>,
        'db': <database_name>,
        'table': <table name>,
        ... <additional fields from metadata property of the document>
    }
)
```


## 설정

아래 셀의 주석을 제거하여 surrealdb와 langchain을 설치합니다.

```python
# %pip install --upgrade --quiet  surrealdb langchain langchain-community
```


```python
# add this import for running in jupyter notebook
import nest_asyncio

nest_asyncio.apply()
```


```python
<!--IMPORTS:[{"imported": "SurrealDBLoader", "source": "langchain_community.document_loaders.surrealdb", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.surrealdb.SurrealDBLoader.html", "title": "SurrealDB"}]-->
import json

from langchain_community.document_loaders.surrealdb import SurrealDBLoader
```


```python
loader = SurrealDBLoader(
    dburl="ws://localhost:8000/rpc",
    ns="langchain",
    db="database",
    table="documents",
    db_user="root",
    db_pass="root",
    filter_criteria={},
)
docs = loader.load()
len(docs)
```


```output
42
```


```python
doc = docs[-1]
doc.metadata
```


```output
{'id': 'documents:zzz434sa584xl3b4ohvk',
 'source': '../../how_to/state_of_the_union.txt',
 'ns': 'langchain',
 'db': 'database',
 'table': 'documents'}
```


```python
len(doc.page_content)
```


```output
18078
```


```python
page_content = json.loads(doc.page_content)
```


```python
page_content["text"]
```


```output
'When we use taxpayer dollars to rebuild America – we are going to Buy American: buy American products to support American jobs. \n\nThe federal government spends about $600 Billion a year to keep the country safe and secure. \n\nThere’s been a law on the books for almost a century \nto make sure taxpayers’ dollars support American jobs and businesses. \n\nEvery Administration says they’ll do it, but we are actually doing it. \n\nWe will buy American to make sure everything from the deck of an aircraft carrier to the steel on highway guardrails are made in America. \n\nBut to compete for the best jobs of the future, we also need to level the playing field with China and other competitors. \n\nThat’s why it is so important to pass the Bipartisan Innovation Act sitting in Congress that will make record investments in emerging technologies and American manufacturing. \n\nLet me give you one example of why it’s so important to pass it.'
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)