---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/redis.ipynb
description: Redis는 빠른 속도의 벡터 데이터베이스로, 캐시, 메시지 브로커 및 데이터베이스로 사용되며 Langchain과 통합할 수
  있습니다.
---

# Redis

> [Redis 벡터 데이터베이스](https://redis.io/docs/get-started/vector-database/) 소개 및 Langchain 통합 가이드.

## Redis란 무엇인가?

웹 서비스 배경을 가진 대부분의 개발자는 `Redis`에 익숙합니다. `Redis`는 본질적으로 캐시, 메시지 브로커 및 데이터베이스로 사용되는 오픈 소스 키-값 저장소입니다. 개발자들은 `Redis`가 빠르고, 클라이언트 라이브러리의 생태계가 크며, 주요 기업들에 의해 수년간 배포되어 왔기 때문에 선택합니다.

이러한 전통적인 사용 사례 외에도 `Redis`는 사용자가 `Redis` 내에서 보조 인덱스 구조를 생성할 수 있는 검색 및 쿼리 기능과 같은 추가 기능을 제공합니다. 이를 통해 `Redis`는 캐시 속도로 벡터 데이터베이스가 될 수 있습니다.

## 벡터 데이터베이스로서의 Redis

`Redis`는 빠른 인덱싱을 위해 압축된 역 인덱스를 사용하며, 낮은 메모리 사용량을 자랑합니다. 또한 다음과 같은 여러 고급 기능을 지원합니다:

* Redis 해시 및 `JSON`의 여러 필드 인덱싱
* 벡터 유사도 검색 (`HNSW` (ANN) 또는 `FLAT` (KNN) 사용)
* 벡터 범위 검색 (예: 쿼리 벡터의 반경 내 모든 벡터 찾기)
* 성능 손실 없이 점진적 인덱싱
* 문서 순위 매기기 ([tf-idf](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) 사용, 선택적으로 사용자 제공 가중치 포함)
* 필드 가중치
* `AND`, `OR`, `NOT` 연산자를 사용한 복잡한 불리언 쿼리
* 접두사 일치, 퍼지 일치 및 정확한 구문 쿼리
* [더블 메타폰 음성 일치](https://redis.io/docs/stack/search/reference/phonetic_matching/) 지원
* 자동 완성 제안 (퍼지 접두사 제안 포함)
* [여러 언어](https://redis.io/docs/stack/search/reference/stemming/)에서의 형태소 기반 쿼리 확장 (using [Snowball](http://snowballstem.org/))
* 중국어 토큰화 및 쿼리 지원 (using [Friso](https://github.com/lionsoul2014/friso))
* 숫자 필터 및 범위
* Redis 지리 공간 인덱싱을 사용한 지리 공간 검색
* 강력한 집계 엔진
* 모든 `utf-8` 인코딩 텍스트 지원
* 전체 문서, 선택된 필드 또는 문서 ID만 검색
* 결과 정렬 (예: 생성 날짜 기준)

## 클라이언트

`Redis`는 단순한 벡터 데이터베이스 그 이상이기 때문에, `LangChain` 통합 외에도 `Redis` 클라이언트를 사용할 필요가 있는 경우가 많습니다. 검색 및 쿼리 명령을 실행하기 위해 표준 `Redis` 클라이언트 라이브러리를 사용할 수 있지만, 검색 및 쿼리 API를 래핑하는 라이브러리를 사용하는 것이 가장 쉽습니다. 아래는 몇 가지 예시이며, 더 많은 클라이언트 라이브러리는 [여기](https://redis.io/resources/clients/)에서 찾을 수 있습니다.

| 프로젝트 | 언어 | 라이센스 | 저자 | 별점 |
|----------|---------|--------|---------|-------|
| [jedis][jedis-url] | Java | MIT | [Redis][redis-url] | ![Stars](https://img.shields.io/github/stars/redis/jedis.svg?style=social&amp;label=Star&amp;maxAge=2592000) |
| [redisvl][redisvl-url] | Python | MIT | [Redis][redis-url] | ![Stars](https://img.shields.io/github/stars/RedisVentures/redisvl.svg?style=social&amp;label=Star&amp;maxAge=2592000) |
| [redis-py][redis-py-url] | Python | MIT | [Redis][redis-url] | ![Stars](https://img.shields.io/github/stars/redis/redis-py.svg?style=social&amp;label=Star&amp;maxAge=2592000) |
| [node-redis][node-redis-url] | Node.js | MIT | [Redis][redis-url] | ![Stars](https://img.shields.io/github/stars/redis/node-redis.svg?style=social&amp;label=Star&amp;maxAge=2592000) |
| [nredisstack][nredisstack-url] | .NET | MIT | [Redis][redis-url] | ![Stars](https://img.shields.io/github/stars/redis/nredisstack.svg?style=social&amp;label=Star&amp;maxAge=2592000) |

[redis-url]: https://redis.com

[redisvl-url]: https://github.com/RedisVentures/redisvl
[redisvl-stars]: https://img.shields.io/github/stars/RedisVentures/redisvl.svg?style=social&amp;label=Star&amp;maxAge=2592000
[redisvl-package]: https://pypi.python.org/pypi/redisvl

[redis-py-url]: https://github.com/redis/redis-py
[redis-py-stars]: https://img.shields.io/github/stars/redis/redis-py.svg?style=social&amp;label=Star&amp;maxAge=2592000
[redis-py-package]: https://pypi.python.org/pypi/redis

[jedis-url]: https://github.com/redis/jedis
[jedis-stars]: https://img.shields.io/github/stars/redis/jedis.svg?style=social&amp;label=Star&amp;maxAge=2592000
[jedis-package]: https://search.maven.org/artifact/redis.clients/jedis

[nredisstack-url]: https://github.com/redis/nredisstack
[nredisstack-stars]: https://img.shields.io/github/stars/redis/nredisstack.svg?style=social&amp;label=Star&amp;maxAge=2592000
[nredisstack-package]: https://www.nuget.org/packages/nredisstack/

[node-redis-url]: https://github.com/redis/node-redis
[node-redis-stars]: https://img.shields.io/github/stars/redis/node-redis.svg?style=social&amp;label=Star&amp;maxAge=2592000
[node-redis-package]: https://www.npmjs.com/package/redis

[redis-om-python-url]: https://github.com/redis/redis-om-python
[redis-om-python-author]: https://redis.com
[redis-om-python-stars]: https://img.shields.io/github/stars/redis/redis-om-python.svg?style=social&amp;label=Star&amp;maxAge=2592000

[redisearch-go-url]: https://github.com/RediSearch/redisearch-go
[redisearch-go-author]: https://redis.com
[redisearch-go-stars]: https://img.shields.io/github/stars/RediSearch/redisearch-go.svg?style=social&amp;label=Star&amp;maxAge=2592000

[redisearch-api-rs-url]: https://github.com/RediSearch/redisearch-api-rs
[redisearch-api-rs-author]: https://redis.com
[redisearch-api-rs-stars]: https://img.shields.io/github/stars/RediSearch/redisearch-api-rs.svg?style=social&amp;label=Star&amp;maxAge=2592000

## 배포 옵션

Redis와 RediSearch를 배포하는 방법은 여러 가지가 있습니다. 시작하는 가장 쉬운 방법은 Docker를 사용하는 것이지만, 다음과 같은 여러 배포 옵션이 있습니다.

- [Redis Cloud](https://redis.com/redis-enterprise-cloud/overview/)
- [Docker (Redis Stack)](https://hub.docker.com/r/redis/redis-stack)
- 클라우드 마켓플레이스: [AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-e6y7ork67pjwg?sr=0-2&ref_=beagle&applicationId=AWSMPContessa), [Google Marketplace](https://console.cloud.google.com/marketplace/details/redislabs-public/redis-enterprise?pli=1), 또는 [Azure Marketplace](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/garantiadata.redis_enterprise_1sp_public_preview?tab=Overview)
- 온프레미스: [Redis Enterprise Software](https://redis.com/redis-enterprise-software/overview/)
- Kubernetes: [Kubernetes에서의 Redis Enterprise Software](https://docs.redis.com/latest/kubernetes/)

## 추가 예제

많은 예제는 [Redis AI 팀의 GitHub](https://github.com/RedisVentures/)에서 찾을 수 있습니다.

- [Awesome Redis AI Resources](https://github.com/RedisVentures/redis-ai-resources) - AI 작업에서 Redis를 사용하는 예제 목록
- [Azure OpenAI Embeddings Q&A](https://github.com/ruoccofabrizio/azure-open-ai-embeddings-qna) - Azure에서 OpenAI와 Redis를 Q&A 서비스로 사용
- [ArXiv Paper Search](https://github.com/RedisVentures/redis-arXiv-search) - arXiv 학술 논문에 대한 의미적 검색
- [Azure에서의 벡터 검색](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-tutorial-vector-similarity) - Azure Cache for Redis 및 Azure OpenAI를 사용한 Azure에서의 벡터 검색

## 더 많은 리소스

Redis를 벡터 데이터베이스로 사용하는 방법에 대한 자세한 정보는 다음 리소스를 확인하세요:

- [RedisVL 문서](https://redisvl.com) - Redis 벡터 라이브러리 클라이언트에 대한 문서
- [Redis 벡터 유사도 문서](https://redis.io/docs/stack/search/reference/vectors/) - 벡터 검색에 대한 Redis 공식 문서.
- [Redis-py 검색 문서](https://redis.readthedocs.io/en/latest/redismodules.html#redisearch-commands) - redis-py 클라이언트 라이브러리에 대한 문서
- [벡터 유사도 검색: 기초부터 생산까지](https://mlops.community/vector-similarity-search-from-basics-to-production/) - VSS 및 Redis를 벡터 DB로 소개하는 블로그 게시물.

## 설정

`Redis-py`는 Redis에서 공식적으로 지원하는 클라이언트입니다. 최근에 벡터 데이터베이스 사용 사례를 위해 특별히 제작된 `RedisVL` 클라이언트가 출시되었습니다. 두 클라이언트 모두 pip로 설치할 수 있습니다.

```python
%pip install -qU redis redisvl langchain-community
```


### Redis를 로컬로 배포하기

로컬에서 Redis를 배포하려면 다음을 실행하세요:

```console
docker run -d -p 6379:6379 -p 8001:8001 redis/redis-stack:latest
```

정상적으로 실행되고 있다면 `http://localhost:8001`에서 멋진 Redis UI를 볼 수 있어야 합니다. 다른 배포 방법에 대한 정보는 위의 [배포 옵션](#deployment-options) 섹션을 참조하세요.

### Redis 연결 URL 스키마

유효한 Redis URL 스키마는 다음과 같습니다:
1. `redis://`  - 암호화되지 않은 Redis 독립형 연결
2. `rediss://` - TLS 암호화된 Redis 독립형 연결
3. `redis+sentinel://`  - 암호화되지 않은 Redis Sentinel을 통한 Redis 서버 연결
4. `rediss+sentinel://` - TLS 암호화된 Redis Sentinel을 통한 Redis 서버 연결

추가 연결 매개변수에 대한 정보는 [redis-py 문서](https://redis-py.readthedocs.io/en/stable/connections.html)에서 확인할 수 있습니다.

```python
# connection to redis standalone at localhost, db 0, no password
redis_url = "redis://localhost:6379"
# connection to host "redis" port 7379 with db 2 and password "secret" (old style authentication scheme without username / pre 6.x)
redis_url = "redis://:secret@redis:7379/2"
# connection to host redis on default port with user "joe", pass "secret" using redis version 6+ ACLs
redis_url = "redis://joe:secret@redis/0"

# connection to sentinel at localhost with default group mymaster and db 0, no password
redis_url = "redis+sentinel://localhost:26379"
# connection to sentinel at host redis with default port 26379 and user "joe" with password "secret" with default group mymaster and db 0
redis_url = "redis+sentinel://joe:secret@redis"
# connection to sentinel, no auth with sentinel monitoring group "zone-1" and database 2
redis_url = "redis+sentinel://redis:26379/zone-1/2"

# connection to redis standalone at localhost, db 0, no password but with TLS support
redis_url = "rediss://localhost:6379"
# connection to redis sentinel at localhost and default port, db 0, no password
# but with TLS support for booth Sentinel and Redis server
redis_url = "rediss+sentinel://localhost"
```


모델 호출의 자동 추적을 최상으로 설정하려면 아래 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 초기화

Redis VectorStore 인스턴스는 여러 방법으로 초기화할 수 있습니다. Redis VectorStore 인스턴스를 초기화하는 데 사용할 수 있는 여러 클래스 메서드가 있습니다.

- `Redis.__init__` - 직접 초기화
- `Redis.from_documents` - `Langchain.docstore.Document` 객체 목록에서 초기화
- `Redis.from_texts` - 텍스트 목록에서 초기화 (선택적으로 메타데이터 포함)
- `Redis.from_texts_return_keys` - 텍스트 목록에서 초기화 (선택적으로 메타데이터 포함)하고 키 반환
- `Redis.from_existing_index` - 기존 Redis 인덱스에서 초기화

아래에서는 `Redis.__init__` 메서드를 사용할 것입니다.

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "Redis", "source": "langchain_community.vectorstores.redis", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.base.Redis.html", "title": "Redis"}]-->
from langchain_community.vectorstores.redis import Redis

vector_store = Redis(
    redis_url="redis://localhost:6379",
    embedding=embeddings,
    index_name="users",
)
```


## 벡터 저장소 관리

벡터 저장소를 생성한 후에는 다양한 항목을 추가하고 삭제하여 상호작용할 수 있습니다.

### 벡터 저장소에 항목 추가

`add_documents` 함수를 사용하여 벡터 저장소에 항목을 추가할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Redis"}]-->
from uuid import uuid4

from langchain_core.documents import Document

document_1 = Document(
    page_content="I had chocalate chip pancakes and scrambled eggs for breakfast this morning.",
    metadata={"source": "tweet"},
)

document_2 = Document(
    page_content="The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees.",
    metadata={"source": "news"},
)

document_3 = Document(
    page_content="Building an exciting new project with LangChain - come check it out!",
    metadata={"source": "tweet"},
)

document_4 = Document(
    page_content="Robbers broke into the city bank and stole $1 million in cash.",
    metadata={"source": "news"},
)

document_5 = Document(
    page_content="Wow! That was an amazing movie. I can't wait to see it again.",
    metadata={"source": "tweet"},
)

document_6 = Document(
    page_content="Is the new iPhone worth the price? Read this review to find out.",
    metadata={"source": "website"},
)

document_7 = Document(
    page_content="The top 10 soccer players in the world right now.",
    metadata={"source": "website"},
)

document_8 = Document(
    page_content="LangGraph is the best framework for building stateful, agentic applications!",
    metadata={"source": "tweet"},
)

document_9 = Document(
    page_content="The stock market is down 500 points today due to fears of a recession.",
    metadata={"source": "news"},
)

document_10 = Document(
    page_content="I have a bad feeling I am going to get deleted :(",
    metadata={"source": "tweet"},
)

documents = [
    document_1,
    document_2,
    document_3,
    document_4,
    document_5,
    document_6,
    document_7,
    document_8,
    document_9,
    document_10,
]
uuids = [str(uuid4()) for _ in range(len(documents))]

vector_store.add_documents(documents=documents, ids=uuids)
```


```output
['doc:users:622f5f19-9b4b-4896-9a16-e1e95f19db4b',
 'doc:users:032b489f-d37e-4bf1-85ec-4c2275be48ef',
 'doc:users:5daf0855-b352-45bd-9d29-e21ff66e38c8',
 'doc:users:b9204897-190b-4dd9-af2b-081ed4e9cbb0',
 'doc:users:9395caff-1a6a-46c1-bc5c-7c5558eadf46',
 'doc:users:28243c3d-463d-4662-936e-003a2dc0dc30',
 'doc:users:1e1cdb91-c226-4836-b38e-ee4b61444913',
 'doc:users:4005bba2-2a08-4160-a16f-5cc3cf9d4aea',
 'doc:users:8c88440a-06d2-4a68-95f1-c58d0cf99d29',
 'doc:users:cc20438f-741a-40fd-bed8-4f1cee113680']
```


### 벡터 저장소에서 항목 삭제

```python
vector_store.delete(ids=[uuids[-1]])
```


```output
True
```


### 생성된 인덱스 검사

`Redis` VectorStore 객체가 구성되면, 이미 존재하지 않았다면 Redis에 인덱스가 생성됩니다. 인덱스는 `rvl` 및 `redis-cli` 명령줄 도구를 사용하여 검사할 수 있습니다. 위에서 `redisvl`을 설치한 경우, `rvl` 명령줄 도구를 사용하여 인덱스를 검사할 수 있습니다.

```python
# assumes you're running Redis locally (use --host, --port, --password, --username, to change this)
!rvl index listall --port 6379
```

```output
[32m17:24:03[0m [34m[RedisVL][0m [1;30mINFO[0m   Indices:
[32m17:24:03[0m [34m[RedisVL][0m [1;30mINFO[0m   1. users
```

`Redis` VectorStore 구현은 `from_texts`, `from_texts_return_keys`, 및 `from_documents` 메서드를 통해 전달된 메타데이터에 대해 인덱스 스키마(필터링을 위한 필드)를 생성하려고 시도합니다. 이렇게 하면 전달된 모든 메타데이터가 Redis 검색 인덱스에 인덱싱되어 해당 필드에 대한 필터링이 가능해집니다.

아래에서는 우리가 위에서 정의한 메타데이터로부터 생성된 필드를 보여줍니다.

```python
!rvl index info -i users --port 6379
```

```output


Index Information:
╭──────────────┬────────────────┬───────────────┬─────────────────┬────────────╮
│ Index Name   │ Storage Type   │ Prefixes      │ Index Options   │   Indexing │
├──────────────┼────────────────┼───────────────┼─────────────────┼────────────┤
│ users        │ HASH           │ ['doc:users'] │ []              │          0 │
╰──────────────┴────────────────┴───────────────┴─────────────────┴────────────╯
Index Fields:
╭────────────────┬────────────────┬────────┬────────────────┬────────────────┬────────────────┬────────────────┬────────────────┬────────────────┬─────────────────┬────────────────╮
│ Name           │ Attribute      │ Type   │ Field Option   │ Option Value   │ Field Option   │ Option Value   │ Field Option   │   Option Value │ Field Option    │ Option Value   │
├────────────────┼────────────────┼────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┼─────────────────┼────────────────┤
│ content        │ content        │ TEXT   │ WEIGHT         │ 1              │                │                │                │                │                 │                │
│ content_vector │ content_vector │ VECTOR │ algorithm      │ FLAT           │ data_type      │ FLOAT32        │ dim            │           3072 │ distance_metric │ COSINE         │
╰────────────────┴────────────────┴────────┴────────────────┴────────────────┴────────────────┴────────────────┴────────────────┴────────────────┴─────────────────┴────────────────╯
```


```python
!rvl stats -i users --port 6379
```

```output

Statistics:
╭─────────────────────────────┬─────────────╮
│ Stat Key                    │ Value       │
├─────────────────────────────┼─────────────┤
│ num_docs                    │ 10          │
│ num_terms                   │ 100         │
│ max_doc_id                  │ 10          │
│ num_records                 │ 116         │
│ percent_indexed             │ 1           │
│ hash_indexing_failures      │ 0           │
│ number_of_uses              │ 1           │
│ bytes_per_record_avg        │ 88.2931     │
│ doc_table_size_mb           │ 0.00108719  │
│ inverted_sz_mb              │ 0.00976753  │
│ key_table_size_mb           │ 0.000304222 │
│ offset_bits_per_record_avg  │ 8           │
│ offset_vectors_sz_mb        │ 0.000102043 │
│ offsets_per_term_avg        │ 0.922414    │
│ records_per_doc_avg         │ 11.6        │
│ sortable_values_size_mb     │ 0           │
│ total_indexing_time         │ 1.373       │
│ total_inverted_index_blocks │ 100         │
│ vector_index_sz_mb          │ 12.0086     │
╰─────────────────────────────┴─────────────╯
```

`user`, `job`, `credit_score`, 및 `age`가 메타데이터에서 인덱스 내 필드로 지정되지 않았다는 점에 유의하는 것이 중요합니다. 이는 `Redis` VectorStore 객체가 전달된 메타데이터로부터 인덱스 스키마를 자동으로 생성하기 때문입니다. 인덱스 필드 생성에 대한 자세한 정보는 API 문서를 참조하세요.

## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면, 체인 또는 에이전트를 실행하는 동안 쿼리하고 싶을 것입니다.

### 직접 쿼리

#### 유사도 검색

간단한 유사도 검색은 다음과 같이 수행할 수 있습니다:

```python
results = vector_store.similarity_search(
    "LangChain provides abstractions to make working with LLMs easy", k=2
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```

```output
* Building an exciting new project with LangChain - come check it out! [{'id': 'doc:users:5daf0855-b352-45bd-9d29-e21ff66e38c8'}]
* LangGraph is the best framework for building stateful, agentic applications! [{'id': 'doc:users:4005bba2-2a08-4160-a16f-5cc3cf9d4aea'}]
```

#### 점수와 함께 유사도 검색

점수와 함께 검색할 수도 있습니다:

```python
results = vector_store.similarity_search_with_score("Will it be hot tomorrow?", k=1)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```

```output
* [SIM=0.446900] The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees. [{'id': 'doc:users:032b489f-d37e-4bf1-85ec-4c2275be48ef'}]
```

#### 기타 검색 방법

`Redis` 벡터 저장소에서 사용할 수 있는 모든 검색 함수 목록은 [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.base.Redis.html)를 참조하세요.
## 기존 인덱스에 연결하기

`Redis` VectorStore를 사용할 때 동일한 메타데이터가 인덱싱되도록 하려면, `index_schema`를 yaml 파일의 경로 또는 사전으로 전달해야 합니다. 다음은 인덱스에서 스키마를 얻고 기존 인덱스에 연결하는 방법을 보여줍니다.

```python
# write the schema to a yaml file
vector_store.write_schema("redis_schema.yaml")
```


```python
# now we can connect to our existing index as follows

new_rds = Redis.from_existing_index(
    embeddings,
    index_name="users",
    redis_url="redis://localhost:6379",
    schema="redis_schema.yaml",
)
results = new_rds.similarity_search("foo", k=3)
print(results[0].metadata)
```

```output
{'id': 'doc:users:8484c48a032d4c4cbe3cc2ed6845fabb', 'user': 'john', 'job': 'engineer', 'credit_score': 'high', 'age': '18'}
```


```python
# see the schemas are the same
new_rds.schema == vector_store.schema
```


```output
True
```


## 사용자 정의 메타데이터 인덱싱

경우에 따라 메타데이터가 매핑되는 필드를 제어하고 싶을 수 있습니다. 예를 들어, `credit_score` 필드를 텍스트 필드 대신 범주형 필드로 설정하고 싶을 수 있습니다(모든 문자열 필드의 기본 동작). 이 경우, 위의 초기화 방법 각각에서 `index_schema` 매개변수를 사용하여 인덱스의 스키마를 지정할 수 있습니다. 사용자 정의 인덱스 스키마는 사전 또는 YAML 파일의 경로로 전달할 수 있습니다.

스키마의 모든 인수는 이름을 제외하고 기본값이 있으므로 변경하려는 필드만 지정할 수 있습니다. 모든 이름은 `redis-cli` 또는 `redis-py`에서 사용할 인수의 스네이크/소문자 버전과 일치합니다. 각 필드의 인수에 대한 자세한 내용은 [문서](https://redis.io/docs/interact/search-and-query/basic-constructs/field-and-type-options/)를 참조하십시오.

아래 예시는 `credit_score` 필드를 텍스트 필드 대신 태그(범주형) 필드로 지정하는 방법을 보여줍니다.

```yaml
# index_schema.yml
tag:
    - name: credit_score
text:
    - name: user
    - name: job
numeric:
    - name: age
```


Python에서는 다음과 같이 보일 것입니다:

```python

index_schema = {
    "tag": [{"name": "credit_score"}],
    "text": [{"name": "user"}, {"name": "job"}],
    "numeric": [{"name": "age"}],
}

```


오직 `name` 필드만 지정하면 된다는 점에 유의하십시오. 다른 모든 필드는 기본값을 가집니다.

```python
# create a new index with the new schema defined above
index_schema = {
    "tag": [{"name": "credit_score"}],
    "text": [{"name": "user"}, {"name": "job"}],
    "numeric": [{"name": "age"}],
}
texts = []  # list of texts
metadata = {}  # dictionary of metadata

rds, keys = Redis.from_texts_return_keys(
    texts,
    embeddings,
    metadatas=metadata,
    redis_url="redis://localhost:6379",
    index_name="users_modified",
    index_schema=index_schema,  # pass in the new index schema
)
```

```output
`index_schema` does not match generated metadata schema.
If you meant to manually override the schema, please ignore this message.
index_schema: {'tag': [{'name': 'credit_score'}], 'text': [{'name': 'user'}, {'name': 'job'}], 'numeric': [{'name': 'age'}]}
generated_schema: {'text': [{'name': 'user'}, {'name': 'job'}, {'name': 'credit_score'}], 'numeric': [{'name': 'age'}], 'tag': []}
```

위의 경고는 사용자가 기본 동작을 재정의할 때 알리기 위한 것입니다. 의도적으로 동작을 재정의하는 경우 무시하십시오.

## 하이브리드 필터링

LangChain에 내장된 Redis 필터 표현 언어를 사용하면 검색 결과를 필터링하는 데 사용할 수 있는 하이브리드 필터의 임의의 긴 체인을 생성할 수 있습니다. 표현 언어는 [RedisVL 표현 구문](https://redisvl.com)에서 파생되었으며 사용하기 쉽고 이해하기 쉽도록 설계되었습니다.

다음은 사용 가능한 필터 유형입니다:
- `RedisText`: 메타데이터 필드에 대한 전체 텍스트 검색으로 필터링합니다. 정확한 일치, 퍼지 일치 및 와일드카드 일치를 지원합니다.
- `RedisNum`: 메타데이터 필드에 대한 숫자 범위로 필터링합니다.
- `RedisTag`: 문자열 기반 범주형 메타데이터 필드에 대한 정확한 일치로 필터링합니다. "tag1,tag2,tag3"와 같이 여러 태그를 지정할 수 있습니다.

다음은 이러한 필터를 활용하는 예시입니다.

```python
<!--IMPORTS:[{"imported": "RedisText", "source": "langchain_community.vectorstores.redis", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.filters.RedisText.html", "title": "Redis"}, {"imported": "RedisNum", "source": "langchain_community.vectorstores.redis", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.filters.RedisNum.html", "title": "Redis"}, {"imported": "RedisTag", "source": "langchain_community.vectorstores.redis", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.filters.RedisTag.html", "title": "Redis"}]-->

from langchain_community.vectorstores.redis import RedisText, RedisNum, RedisTag

# exact matching
has_high_credit = RedisTag("credit_score") == "high"
does_not_have_high_credit = RedisTag("credit_score") != "low"

# fuzzy matching
job_starts_with_eng = RedisText("job") % "eng*"
job_is_engineer = RedisText("job") == "engineer"
job_is_not_engineer = RedisText("job") != "engineer"

# numeric filtering
age_is_18 = RedisNum("age") == 18
age_is_not_18 = RedisNum("age") != 18
age_is_greater_than_18 = RedisNum("age") > 18
age_is_less_than_18 = RedisNum("age") < 18
age_is_greater_than_or_equal_to_18 = RedisNum("age") >= 18
age_is_less_than_or_equal_to_18 = RedisNum("age") <= 18

```


`RedisFilter` 클래스는 이러한 필터의 가져오기를 간소화하는 데 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "RedisFilter", "source": "langchain_community.vectorstores.redis", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.filters.RedisFilter.html", "title": "Redis"}]-->

from langchain_community.vectorstores.redis import RedisFilter

# same examples as above
has_high_credit = RedisFilter.tag("credit_score") == "high"
does_not_have_high_credit = RedisFilter.num("age") > 8
job_starts_with_eng = RedisFilter.text("job") % "eng*"
```


다음은 검색을 위한 하이브리드 필터 사용 예시입니다.

```python
<!--IMPORTS:[{"imported": "RedisText", "source": "langchain_community.vectorstores.redis", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.filters.RedisText.html", "title": "Redis"}]-->
from langchain_community.vectorstores.redis import RedisText

is_engineer = RedisText("job") == "engineer"
results = rds.similarity_search("foo", k=3, filter=is_engineer)

print("Job:", results[0].metadata["job"])
print("Engineers in the dataset:", len(results))
```

```output
Job: engineer
Engineers in the dataset: 2
```


```python
# fuzzy match
starts_with_doc = RedisText("job") % "doc*"
results = rds.similarity_search("foo", k=3, filter=starts_with_doc)

for result in results:
    print("Job:", result.metadata["job"])
print("Jobs in dataset that start with 'doc':", len(results))
```

```output
Job: doctor
Job: doctor
Jobs in dataset that start with 'doc': 2
```


```python
<!--IMPORTS:[{"imported": "RedisNum", "source": "langchain_community.vectorstores.redis", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.filters.RedisNum.html", "title": "Redis"}]-->
from langchain_community.vectorstores.redis import RedisNum

is_over_18 = RedisNum("age") > 18
is_under_99 = RedisNum("age") < 99
age_range = is_over_18 & is_under_99
results = rds.similarity_search("foo", filter=age_range)

for result in results:
    print("User:", result.metadata["user"], "is", result.metadata["age"])
```

```output
User: derrick is 45
User: nancy is 94
User: joe is 35
```


```python
# make sure to use parenthesis around FilterExpressions
# if initializing them while constructing them
age_range = (RedisNum("age") > 18) & (RedisNum("age") < 99)
results = rds.similarity_search("foo", filter=age_range)

for result in results:
    print("User:", result.metadata["user"], "is", result.metadata["age"])
```

```output
User: derrick is 45
User: nancy is 94
User: joe is 35
```

### 검색기로 변환하여 쿼리하기

벡터 저장소를 검색기로 변환하여 체인에서 더 쉽게 사용할 수 있습니다. 여기서는 벡터 저장소를 검색기로 사용하는 다양한 옵션을 살펴봅니다.

검색을 수행하기 위해 사용할 수 있는 세 가지 검색 방법이 있습니다. 기본적으로 의미적 유사성을 사용합니다. 모든 옵션을 보려면 [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.base.Redis.html#langchain_community.vectorstores.redis.base.Redis.as_retriever)를 참조하십시오.

```python
retriever = vector_store.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"k": 1, "score_threshold": 0.2},
)
retriever.invoke("Stealing from the bank is a crime")
```


```output
[Document(metadata={'id': 'doc:users:b9204897-190b-4dd9-af2b-081ed4e9cbb0'}, page_content='Robbers broke into the city bank and stole $1 million in cash.')]
```


## 검색 보강 생성에 대한 사용법

이 벡터 저장소를 검색 보강 생성(RAG)에 사용하는 방법에 대한 가이드는 다음 섹션을 참조하십시오:

- [튜토리얼: 외부 지식과 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [사용 방법: RAG를 통한 질문 및 답변](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

## API 참조

모든 `Redis` 벡터 저장소 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하십시오: https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.base.Redis.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)