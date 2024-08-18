---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/snowflake.ipynb
description: 이 노트북은 Snowflake에서 문서를 로드하는 방법에 대해 설명합니다. 코드 예제를 통해 자세한 과정을 안내합니다.
---

# 스노우플레이크

이 노트북은 스노우플레이크에서 문서를 로드하는 방법에 대해 설명합니다.

```python
%pip install --upgrade --quiet  snowflake-connector-python
```


```python
<!--IMPORTS:[{"imported": "SnowflakeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.snowflake_loader.SnowflakeLoader.html", "title": "Snowflake"}]-->
import settings as s
from langchain_community.document_loaders import SnowflakeLoader
```


```python
QUERY = "select text, survey_id from CLOUD_DATA_SOLUTIONS.HAPPY_OR_NOT.OPEN_FEEDBACK limit 10"
snowflake_loader = SnowflakeLoader(
    query=QUERY,
    user=s.SNOWFLAKE_USER,
    password=s.SNOWFLAKE_PASS,
    account=s.SNOWFLAKE_ACCOUNT,
    warehouse=s.SNOWFLAKE_WAREHOUSE,
    role=s.SNOWFLAKE_ROLE,
    database=s.SNOWFLAKE_DATABASE,
    schema=s.SNOWFLAKE_SCHEMA,
)
snowflake_documents = snowflake_loader.load()
print(snowflake_documents)
```


```python
import settings as s
from snowflakeLoader import SnowflakeLoader

QUERY = "select text, survey_id as source from CLOUD_DATA_SOLUTIONS.HAPPY_OR_NOT.OPEN_FEEDBACK limit 10"
snowflake_loader = SnowflakeLoader(
    query=QUERY,
    user=s.SNOWFLAKE_USER,
    password=s.SNOWFLAKE_PASS,
    account=s.SNOWFLAKE_ACCOUNT,
    warehouse=s.SNOWFLAKE_WAREHOUSE,
    role=s.SNOWFLAKE_ROLE,
    database=s.SNOWFLAKE_DATABASE,
    schema=s.SNOWFLAKE_SCHEMA,
    metadata_columns=["source"],
)
snowflake_documents = snowflake_loader.load()
print(snowflake_documents)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)