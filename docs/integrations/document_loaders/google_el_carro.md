---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/google_el_carro.ipynb
description: Google El Carro를 사용하여 Oracle 데이터베이스를 Kubernetes에서 실행하고 Langchain 통합으로
  AI 경험을 구축하는 방법을 안내합니다.
---

# Google El Carro for Oracle Workloads

> Google [El Carro Oracle Operator](https://github.com/GoogleCloudPlatform/elcarro-oracle-operator)
는 Oracle 데이터베이스를 Kubernetes에서 포터블하고, 오픈 소스이며, 커뮤니티 주도, 공급업체 종속성이 없는 컨테이너 오케스트레이션 시스템으로 실행할 수 있는 방법을 제공합니다. El Carro는 포괄적이고 일관된 구성 및 배포를 위한 강력한 선언적 API와 실시간 운영 및 모니터링을 제공합니다. El Carro Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 Oracle 데이터베이스의 기능을 확장하세요.

이 가이드는 `ElCarroLoader` 및 `ElCarroDocumentSaver`를 사용하여 [langchain 문서 저장, 로드 및 삭제하기](/docs/how_to#document-loaders) 방법을 설명합니다. 이 통합은 실행 위치에 관계없이 모든 Oracle 데이터베이스에서 작동합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-el-carro-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-el-carro-python/blob/main/docs/document_loader.ipynb)

## 시작하기 전에

El Carro Oracle 데이터베이스를 설정하려면 README의 [시작하기](https://github.com/googleapis/langchain-google-el-carro-python/tree/main/README.md#getting-started) 섹션을 완료하세요.

### 🦜🔗 라이브러리 설치

통합은 자체 `langchain-google-el-carro` 패키지에 있으므로 설치해야 합니다.

```python
%pip install --upgrade --quiet langchain-google-el-carro
```


## 기본 사용법

### Oracle 데이터베이스 연결 설정
다음 변수를 Oracle 데이터베이스 연결 세부정보로 채우세요.

```python
# @title Set Your Values Here { display-mode: "form" }
HOST = "127.0.0.1"  # @param {type: "string"}
PORT = 3307  # @param {type: "integer"}
DATABASE = "my-database"  # @param {type: "string"}
TABLE_NAME = "message_store"  # @param {type: "string"}
USER = "my-user"  # @param {type: "string"}
PASSWORD = input("Please provide a password to be used for the database user: ")
```


El Carro를 사용하는 경우 El Carro Kubernetes 인스턴스의 상태에서 호스트 이름 및 포트 값을 찾을 수 있습니다. PDB에 대해 생성한 사용자 비밀번호를 사용하세요.

예시 출력:

```
kubectl get -w instances.oracle.db.anthosapis.com -n db
NAME   DB ENGINE   VERSION   EDITION      ENDPOINT      URL                DB NAMES   BACKUP ID   READYSTATUS   READYREASON        DBREADYSTATUS   DBREADYREASON

mydb   Oracle      18c       Express      mydb-svc.db   34.71.69.25:6021   ['pdbname']            TRUE          CreateComplete     True            CreateComplete
```


### ElCarroEngine 연결 풀

`ElCarroEngine`은 Oracle 데이터베이스에 대한 연결 풀을 구성하여 애플리케이션에서 성공적인 연결을 가능하게 하고 업계 모범 사례를 따릅니다.

```python
from langchain_google_el_carro import ElCarroEngine

elcarro_engine = ElCarroEngine.from_instance(
    db_host=HOST,
    db_port=PORT,
    db_name=DATABASE,
    db_user=USER,
    db_password=PASSWORD,
)
```


### 테이블 초기화

`elcarro_engine.init_document_table(<table_name>)`를 통해 기본 스키마의 테이블을 초기화합니다. 테이블 열:

- page_content (유형: text)
- langchain_metadata (유형: JSON)

```python
elcarro_engine.drop_document_table(TABLE_NAME)
elcarro_engine.init_document_table(
    table_name=TABLE_NAME,
)
```


### 문서 저장

`ElCarroDocumentSaver.add_documents(<documents>)`를 사용하여 langchain 문서를 저장합니다. `ElCarroDocumentSaver` 클래스를 초기화하려면 두 가지를 제공해야 합니다:

1. `elcarro_engine` - `ElCarroEngine` 엔진의 인스턴스.
2. `table_name` - langchain 문서를 저장할 Oracle 데이터베이스 내의 테이블 이름.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Google El Carro for Oracle Workloads"}]-->
from langchain_core.documents import Document
from langchain_google_el_carro import ElCarroDocumentSaver

doc = Document(
    page_content="Banana",
    metadata={"type": "fruit", "weight": 100, "organic": 1},
)

saver = ElCarroDocumentSaver(
    elcarro_engine=elcarro_engine,
    table_name=TABLE_NAME,
)
saver.add_documents([doc])
```


### 문서 로드

`ElCarroLoader.load()` 또는 `ElCarroLoader.lazy_load()`를 사용하여 langchain 문서를 로드합니다. `lazy_load`는 반복 중에만 데이터베이스를 쿼리하는 생성기를 반환합니다. `ElCarroLoader` 클래스를 초기화하려면 다음을 제공해야 합니다:

1. `elcarro_engine` - `ElCarroEngine` 엔진의 인스턴스.
2. `table_name` - langchain 문서를 저장할 Oracle 데이터베이스 내의 테이블 이름.

```python
from langchain_google_el_carro import ElCarroLoader

loader = ElCarroLoader(elcarro_engine=elcarro_engine, table_name=TABLE_NAME)
docs = loader.lazy_load()
for doc in docs:
    print("Loaded documents:", doc)
```


### 쿼리를 통한 문서 로드

테이블에서 문서를 로드하는 것 외에도 SQL 쿼리에서 생성된 뷰에서 문서를 로드하도록 선택할 수 있습니다. 예를 들어:

```python
from langchain_google_el_carro import ElCarroLoader

loader = ElCarroLoader(
    elcarro_engine=elcarro_engine,
    query=f"SELECT * FROM {TABLE_NAME} WHERE json_value(langchain_metadata, '$.organic') = '1'",
)
onedoc = loader.load()
print(onedoc)
```


SQL 쿼리에서 생성된 뷰는 기본 테이블과 다른 스키마를 가질 수 있습니다. 이러한 경우 ElCarroLoader의 동작은 비기본 스키마의 테이블에서 로드하는 것과 동일합니다. [사용자 정의 문서 페이지 콘텐츠 및 메타데이터로 문서 로드하기](#load-documents-with-customized-document-page-content--metadata) 섹션을 참조하세요.

### 문서 삭제

`ElCarroDocumentSaver.delete(<documents>)`를 사용하여 Oracle 테이블에서 langchain 문서 목록을 삭제합니다.

기본 스키마(페이지 콘텐츠, langchain 메타데이터)를 가진 테이블의 경우 삭제 기준은 다음과 같습니다:

`row`는 목록에 `document`가 존재하는 경우 삭제되어야 하며, 다음 조건을 충족해야 합니다:

- `document.page_content`는 `row[page_content]`와 같아야 합니다.
- `document.metadata`는 `row[langchain_metadata]`와 같아야 합니다.

```python
docs = loader.load()
print("Documents before delete:", docs)
saver.delete(onedoc)
print("Documents after delete:", loader.load())
```


## 고급 사용법

### 사용자 정의 문서 페이지 콘텐츠 및 메타데이터로 문서 로드

먼저 비기본 스키마의 예제 테이블을 준비하고 임의의 데이터로 채웁니다.

```python
import sqlalchemy

create_table_query = f"""CREATE TABLE {TABLE_NAME} (
    fruit_id NUMBER GENERATED BY DEFAULT AS IDENTITY (START WITH 1),
    fruit_name VARCHAR2(100) NOT NULL,
    variety VARCHAR2(50),
    quantity_in_stock NUMBER(10) NOT NULL,
    price_per_unit NUMBER(6,2) NOT NULL,
    organic NUMBER(3) NOT NULL
)"""
elcarro_engine.drop_document_table(TABLE_NAME)

with elcarro_engine.connect() as conn:
    conn.execute(sqlalchemy.text(create_table_query))
    conn.commit()
    conn.execute(
        sqlalchemy.text(
            f"""
            INSERT INTO {TABLE_NAME} (fruit_name, variety, quantity_in_stock, price_per_unit, organic)
            VALUES ('Apple', 'Granny Smith', 150, 0.99, 1)
            """
        )
    )
    conn.execute(
        sqlalchemy.text(
            f"""
            INSERT INTO {TABLE_NAME} (fruit_name, variety, quantity_in_stock, price_per_unit, organic)
            VALUES ('Banana', 'Cavendish', 200, 0.59, 0)
            """
        )
    )
    conn.execute(
        sqlalchemy.text(
            f"""
            INSERT INTO {TABLE_NAME} (fruit_name, variety, quantity_in_stock, price_per_unit, organic)
            VALUES ('Orange', 'Navel', 80, 1.29, 1)
            """
        )
    )
    conn.commit()
```


이 예제 테이블에서 `ElCarroLoader`의 기본 매개변수로 langchain 문서를 로드하면 로드된 문서의 `page_content`는 테이블의 첫 번째 열이 되고, `metadata`는 다른 모든 열의 키-값 쌍으로 구성됩니다.

```python
loader = ElCarroLoader(
    elcarro_engine=elcarro_engine,
    table_name=TABLE_NAME,
)
loaded_docs = loader.load()
print(f"Loaded Documents: [{loaded_docs}]")
```


`ElCarroLoader`를 초기화할 때 `content_columns` 및 `metadata_columns`를 설정하여 로드할 콘텐츠 및 메타데이터를 지정할 수 있습니다.

1. `content_columns`: 문서의 `page_content`에 기록할 열.
2. `metadata_columns`: 문서의 `metadata`에 기록할 열.

예를 들어, `content_columns`의 열 값은 공백으로 구분된 문자열로 결합되어 로드된 문서의 `page_content`가 되고, 로드된 문서의 `metadata`는 `metadata_columns`에 지정된 열의 키-값 쌍만 포함됩니다.

```python
loader = ElCarroLoader(
    elcarro_engine=elcarro_engine,
    table_name=TABLE_NAME,
    content_columns=[
        "variety",
        "quantity_in_stock",
        "price_per_unit",
        "organic",
    ],
    metadata_columns=["fruit_id", "fruit_name"],
)
loaded_docs = loader.load()
print(f"Loaded Documents: [{loaded_docs}]")
```


### 사용자 정의 페이지 콘텐츠 및 메타데이터로 문서 저장

사용자 정의 메타데이터 필드가 있는 테이블에 langchain 문서를 저장하려면 먼저 `ElCarroEngine.init_document_table()`를 통해 그런 테이블을 생성하고, 원하는 `metadata_columns` 목록을 지정해야 합니다. 이 예제에서 생성된 테이블은 다음과 같은 열을 가집니다:

- content (유형: text): 과일 설명을 저장합니다.
- type (유형: VARCHAR2(200)): 과일 유형을 저장합니다.
- weight (유형: INT): 과일 무게를 저장합니다.
- extra_json_metadata (유형: JSON): 과일의 기타 메타데이터 정보를 저장합니다.

다음 매개변수를 사용하여 `elcarro_engine.init_document_table()`로 테이블을 생성할 수 있습니다:

1. `table_name`: langchain 문서를 저장할 Oracle 데이터베이스 내의 테이블 이름.
2. `metadata_columns`: 필요한 메타데이터 열 목록을 나타내는 `sqlalchemy.Column` 목록.
3. `content_column`: langchain 문서의 `page_content`를 저장할 열 이름. 기본값: `"page_content", "VARCHAR2(4000)"`
4. `metadata_json_column`: langchain 문서의 추가 JSON `metadata`를 저장할 열 이름. 기본값: `"langchain_metadata", "VARCHAR2(4000)"`.

```python
elcarro_engine.drop_document_table(TABLE_NAME)
elcarro_engine.init_document_table(
    table_name=TABLE_NAME,
    metadata_columns=[
        sqlalchemy.Column("type", sqlalchemy.dialects.oracle.VARCHAR2(200)),
        sqlalchemy.Column("weight", sqlalchemy.INT),
    ],
    content_column="content",
    metadata_json_column="extra_json_metadata",
)
```


`ElCarroDocumentSaver.add_documents(<documents>)`로 문서를 저장합니다. 이 예제에서 볼 수 있듯이,

- `document.page_content`는 `content` 열에 저장됩니다.
- `document.metadata.type`는 `type` 열에 저장됩니다.
- `document.metadata.weight`는 `weight` 열에 저장됩니다.
- `document.metadata.organic`는 JSON 형식으로 `extra_json_metadata` 열에 저장됩니다.

```python
doc = Document(
    page_content="Banana",
    metadata={"type": "fruit", "weight": 100, "organic": 1},
)

print(f"Original Document: [{doc}]")

saver = ElCarroDocumentSaver(
    elcarro_engine=elcarro_engine,
    table_name=TABLE_NAME,
    content_column="content",
    metadata_json_column="extra_json_metadata",
)
saver.add_documents([doc])

loader = ElCarroLoader(
    elcarro_engine=elcarro_engine,
    table_name=TABLE_NAME,
    content_columns=["content"],
    metadata_columns=[
        "type",
        "weight",
    ],
    metadata_json_column="extra_json_metadata",
)

loaded_docs = loader.load()
print(f"Loaded Document: [{loaded_docs[0]}]")
```


### 사용자 정의 페이지 콘텐츠 및 메타데이터로 문서 삭제

사용자 정의 메타데이터 열이 있는 테이블에서 문서를 삭제할 수 있습니다. `ElCarroDocumentSaver.delete(<documents>)`를 통해 삭제 기준은 다음과 같습니다:

`row`는 목록에 `document`가 존재하는 경우 삭제되어야 하며, 다음 조건을 충족해야 합니다:

- `document.page_content`는 `row[page_content]`와 같아야 합니다.
- `document.metadata`의 모든 메타데이터 필드 `k`에 대해
  - `document.metadata[k]`는 `row[k]`와 같거나 `document.metadata[k]`는 `row[langchain_metadata][k]`와 같아야 합니다.
- `row`에 존재하지만 `document.metadata`에는 없는 추가 메타데이터 필드가 없어야 합니다.

```python
loader = ElCarroLoader(elcarro_engine=elcarro_engine, table_name=TABLE_NAME)
saver.delete(loader.load())
print(f"Documents left: {len(loader.load())}")
```


## 더 많은 예제

완전한 코드 예제를 보려면 [demo_doc_loader_basic.py](https://github.com/googleapis/langchain-google-el-carro-python/tree/main/samples/demo_doc_loader_basic.py) 및 [demo_doc_loader_advanced.py](https://github.com/googleapis/langchain-google-el-carro-python/tree/main/samples/demo_doc_loader_advanced.py)를 참조하세요.

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)