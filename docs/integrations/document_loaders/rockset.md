---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/rockset.ipynb
description: Rockset은 운영 부담 없이 대규모 반구조적 데이터를 실시간으로 분석할 수 있는 데이터베이스입니다. 빠른 쿼리 성능을 제공합니다.
---

# Rockset

> Rockset는 운영 부담 없이 대규모 반구조적 데이터에 대한 쿼리를 가능하게 하는 실시간 분석 데이터베이스입니다. Rockset을 사용하면 수집된 데이터가 1초 이내에 쿼리 가능하며, 해당 데이터에 대한 분석 쿼리는 일반적으로 밀리초 단위로 실행됩니다. Rockset은 컴퓨팅 최적화되어 있어 100TB 미만(또는 100TB 이상의 롤업) 범위의 높은 동시성 애플리케이션에 적합합니다.

이 노트북은 LangChain에서 문서 로더로 Rockset을 사용하는 방법을 보여줍니다. 시작하려면 Rockset 계정과 API 키가 필요합니다.

## 환경 설정

1. [Rockset 콘솔](https://console.rockset.com/apikeys)로 가서 API 키를 가져옵니다. [API 참조](https://rockset.com/docs/rest-api/#introduction)에서 API 지역을 찾습니다. 이 노트북의 목적을 위해 `Oregon(us-west-2)`에서 Rockset을 사용한다고 가정하겠습니다.
2. 환경 변수 `ROCKSET_API_KEY`를 설정합니다.
3. LangChain이 Rockset 데이터베이스와 상호작용하는 데 사용할 Rockset 파이썬 클라이언트를 설치합니다.

```python
%pip install --upgrade --quiet  rockset
```


# 문서 로딩
LangChain과의 Rockset 통합을 통해 SQL 쿼리를 사용하여 Rockset 컬렉션에서 문서를 로드할 수 있습니다. 이를 위해 `RocksetLoader` 객체를 구성해야 합니다. 다음은 `RocksetLoader`를 초기화하는 예제 코드입니다.

```python
<!--IMPORTS:[{"imported": "RocksetLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.rocksetdb.RocksetLoader.html", "title": "Rockset"}]-->
from langchain_community.document_loaders import RocksetLoader
from rockset import Regions, RocksetClient, models

loader = RocksetLoader(
    RocksetClient(Regions.usw2a1, "<api key>"),
    models.QueryRequestSql(query="SELECT * FROM langchain_demo LIMIT 3"),  # SQL query
    ["text"],  # content columns
    metadata_keys=["id", "date"],  # metadata columns
)
```


여기에서 다음 쿼리가 실행되는 것을 볼 수 있습니다:

```sql
SELECT * FROM langchain_demo LIMIT 3
```


컬렉션의 `text` 열은 페이지 콘텐츠로 사용되며, 레코드의 `id` 및 `date` 열은 메타데이터로 사용됩니다(만약 `metadata_keys`에 아무것도 전달하지 않으면 전체 Rockset 문서가 메타데이터로 사용됩니다).

쿼리를 실행하고 결과 `Document`에 대한 반복기를 액세스하려면 다음을 실행합니다:

```python
loader.lazy_load()
```


쿼리를 실행하고 모든 결과 `Document`를 한 번에 액세스하려면 다음을 실행합니다:

```python
loader.load()
```


다음은 `loader.load()`의 예제 응답입니다:
```python
[
    Document(
        page_content="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas a libero porta, dictum ipsum eget, hendrerit neque. Morbi blandit, ex ut suscipit viverra, enim velit tincidunt tellus, a tempor velit nunc et ex. Proin hendrerit odio nec convallis lobortis. Aenean in purus dolor. Vestibulum orci orci, laoreet eget magna in, commodo euismod justo.", 
        metadata={"id": 83209, "date": "2022-11-13T18:26:45.000000Z"}
    ),
    Document(
        page_content="Integer at finibus odio. Nam sit amet enim cursus lacus gravida feugiat vestibulum sed libero. Aenean eleifend est quis elementum tincidunt. Curabitur sit amet ornare erat. Nulla id dolor ut magna volutpat sodales fringilla vel ipsum. Donec ultricies, lacus sed fermentum dignissim, lorem elit aliquam ligula, sed suscipit sapien purus nec ligula.", 
        metadata={"id": 89313, "date": "2022-11-13T18:28:53.000000Z"}
    ),
    Document(
        page_content="Morbi tortor enim, commodo id efficitur vitae, fringilla nec mi. Nullam molestie faucibus aliquet. Praesent a est facilisis, condimentum justo sit amet, viverra erat. Fusce volutpat nisi vel purus blandit, et facilisis felis accumsan. Phasellus luctus ligula ultrices tellus tempor hendrerit. Donec at ultricies leo.", 
        metadata={"id": 87732, "date": "2022-11-13T18:49:04.000000Z"}
    )
]
```


## 여러 열을 콘텐츠로 사용하기

여러 열을 콘텐츠로 사용할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "RocksetLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.rocksetdb.RocksetLoader.html", "title": "Rockset"}]-->
from langchain_community.document_loaders import RocksetLoader
from rockset import Regions, RocksetClient, models

loader = RocksetLoader(
    RocksetClient(Regions.usw2a1, "<api key>"),
    models.QueryRequestSql(query="SELECT * FROM langchain_demo LIMIT 1 WHERE id=38"),
    ["sentence1", "sentence2"],  # TWO content columns
)
```


"sentence1" 필드가 `"This is the first sentence."`이고 "sentence2" 필드가 `"This is the second sentence."`라고 가정할 때, 결과 `Document`의 `page_content`는 다음과 같습니다:

```
This is the first sentence.
This is the second sentence.
```


`RocksetLoader` 생성자에서 `content_columns_joiner` 인수를 설정하여 콘텐츠 열을 결합하는 자체 함수를 정의할 수 있습니다. `content_columns_joiner`는 (열 이름, 열 값)의 튜플 목록을 인수로 받는 메서드입니다. 기본적으로 각 열 값을 새 줄로 결합하는 메서드입니다.

예를 들어, sentence1과 sentence2를 새 줄 대신 공백으로 결합하고 싶다면 `content_columns_joiner`를 다음과 같이 설정할 수 있습니다:

```python
RocksetLoader(
    RocksetClient(Regions.usw2a1, "<api key>"),
    models.QueryRequestSql(query="SELECT * FROM langchain_demo LIMIT 1 WHERE id=38"),
    ["sentence1", "sentence2"],
    content_columns_joiner=lambda docs: " ".join(
        [doc[1] for doc in docs]
    ),  # join with space instead of /n
)
```


결과 `Document`의 `page_content`는 다음과 같습니다:

```
This is the first sentence. This is the second sentence.
```


종종 `page_content`에 열 이름을 포함하고 싶습니다. 다음과 같이 할 수 있습니다:

```python
RocksetLoader(
    RocksetClient(Regions.usw2a1, "<api key>"),
    models.QueryRequestSql(query="SELECT * FROM langchain_demo LIMIT 1 WHERE id=38"),
    ["sentence1", "sentence2"],
    content_columns_joiner=lambda docs: "\n".join(
        [f"{doc[0]}: {doc[1]}" for doc in docs]
    ),
)
```


이렇게 하면 다음과 같은 `page_content`가 생성됩니다:

```
sentence1: This is the first sentence.
sentence2: This is the second sentence.
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)