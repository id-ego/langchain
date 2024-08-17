---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/snowflake/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/snowflake.ipynb
---

# Snowflake

This notebooks goes over how to load documents from Snowflake


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


## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)