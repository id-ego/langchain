---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/tidb.ipynb
description: TiDB Cloud는 AI 애플리케이션 개발을 위한 벡터 검색 기능을 통합한 DBaaS 솔루션입니다. TiDBLoader를
  사용하여 데이터를 로드하는 방법을 소개합니다.
---

# TiDB

> [TiDB Cloud](https://tidbcloud.com/)는 전용 및 서버리스 옵션을 제공하는 종합 데이터베이스 서비스(DBaaS) 솔루션입니다. TiDB Serverless는 이제 MySQL 환경에 내장된 벡터 검색을 통합하고 있습니다. 이 향상을 통해 새로운 데이터베이스나 추가 기술 스택 없이 TiDB Serverless를 사용하여 AI 애플리케이션을 원활하게 개발할 수 있습니다. https://tidb.cloud/ai에서 비공식 베타의 대기자 명단에 가입하여 가장 먼저 경험해 보세요.

이 노트북에서는 langchain에서 TiDB의 데이터를 로드하는 방법인 `TiDBLoader` 사용법을 소개합니다.

## 필수 조건

`TiDBLoader`를 사용하기 전에 다음 종속성을 설치합니다:

```python
%pip install --upgrade --quiet langchain
```


그런 다음 TiDB에 대한 연결을 구성합니다. 이 노트북에서는 TiDB Cloud에서 제공하는 표준 연결 방법을 따라 안전하고 효율적인 데이터베이스 연결을 설정합니다.

```python
import getpass

# copy from tidb cloud console，replace it with your own
tidb_connection_string_template = "mysql+pymysql://<USER>:<PASSWORD>@<HOST>:4000/<DB>?ssl_ca=/etc/ssl/cert.pem&ssl_verify_cert=true&ssl_verify_identity=true"
tidb_password = getpass.getpass("Input your TiDB password:")
tidb_connection_string = tidb_connection_string_template.replace(
    "<PASSWORD>", tidb_password
)
```


## TiDB에서 데이터 로드하기

다음은 `TiDBLoader`의 동작을 사용자 정의하는 데 사용할 수 있는 몇 가지 주요 인수에 대한 설명입니다:

- `query` (str): TiDB 데이터베이스에 대해 실행할 SQL 쿼리입니다. 쿼리는 `Document` 객체에 로드할 데이터를 선택해야 합니다. 예를 들어, `"SELECT * FROM my_table"`와 같은 쿼리를 사용하여 `my_table`에서 모든 데이터를 가져올 수 있습니다.
- `page_content_columns` (Optional[List[str]]): 각 `Document` 객체의 `page_content`에 포함되어야 하는 열 이름 목록을 지정합니다. 기본값인 `None`으로 설정하면 쿼리에서 반환된 모든 열이 `page_content`에 포함됩니다. 이를 통해 데이터의 특정 열을 기반으로 각 문서의 내용을 조정할 수 있습니다.
- `metadata_columns` (Optional[List[str]]): 각 `Document` 객체의 `metadata`에 포함되어야 하는 열 이름 목록을 지정합니다. 기본적으로 이 목록은 비어 있으며, 명시적으로 지정하지 않는 한 메타데이터가 포함되지 않습니다. 이는 주요 내용의 일부가 아니지만 처리 또는 분석에 여전히 유용한 각 문서에 대한 추가 정보를 포함하는 데 유용합니다.

```python
from sqlalchemy import Column, Integer, MetaData, String, Table, create_engine

# Connect to the database
engine = create_engine(tidb_connection_string)
metadata = MetaData()
table_name = "test_tidb_loader"

# Create a table
test_table = Table(
    table_name,
    metadata,
    Column("id", Integer, primary_key=True),
    Column("name", String(255)),
    Column("description", String(255)),
)
metadata.create_all(engine)


with engine.connect() as connection:
    transaction = connection.begin()
    try:
        connection.execute(
            test_table.insert(),
            [
                {"name": "Item 1", "description": "Description of Item 1"},
                {"name": "Item 2", "description": "Description of Item 2"},
                {"name": "Item 3", "description": "Description of Item 3"},
            ],
        )
        transaction.commit()
    except:
        transaction.rollback()
        raise
```


```python
<!--IMPORTS:[{"imported": "TiDBLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.tidb.TiDBLoader.html", "title": "TiDB"}]-->
from langchain_community.document_loaders import TiDBLoader

# Setup TiDBLoader to retrieve data
loader = TiDBLoader(
    connection_string=tidb_connection_string,
    query=f"SELECT * FROM {table_name};",
    page_content_columns=["name", "description"],
    metadata_columns=["id"],
)

# Load data
documents = loader.load()

# Display the loaded documents
for doc in documents:
    print("-" * 30)
    print(f"content: {doc.page_content}\nmetada: {doc.metadata}")
```

```output
------------------------------
content: name: Item 1
description: Description of Item 1
metada: {'id': 1}
------------------------------
content: name: Item 2
description: Description of Item 2
metada: {'id': 2}
------------------------------
content: name: Item 3
description: Description of Item 3
metada: {'id': 3}
```


```python
test_table.drop(bind=engine)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)