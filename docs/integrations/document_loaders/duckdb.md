---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/duckdb.ipynb
description: DuckDB는 SQL OLAP 데이터베이스 관리 시스템으로, 각 행에 하나의 문서를 로드하고 메타데이터를 지정하는 방법을 설명합니다.
---

# DuckDB

> [DuckDB](https://duckdb.org/)는 인프로세스 SQL OLAP 데이터베이스 관리 시스템입니다.

각 행에 하나의 문서가 있는 `DuckDB` 쿼리를 로드합니다.

```python
%pip install --upgrade --quiet  duckdb
```


```python
<!--IMPORTS:[{"imported": "DuckDBLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.duckdb_loader.DuckDBLoader.html", "title": "DuckDB"}]-->
from langchain_community.document_loaders import DuckDBLoader
```


```python
%%file example.csv
Team,Payroll
Nationals,81.34
Reds,82.20
```

```output
Writing example.csv
```


```python
loader = DuckDBLoader("SELECT * FROM read_csv_auto('example.csv')")

data = loader.load()
```


```python
print(data)
```

```output
[Document(page_content='Team: Nationals\nPayroll: 81.34', metadata={}), Document(page_content='Team: Reds\nPayroll: 82.2', metadata={})]
```

## 콘텐츠와 메타데이터의 열 지정

```python
loader = DuckDBLoader(
    "SELECT * FROM read_csv_auto('example.csv')",
    page_content_columns=["Team"],
    metadata_columns=["Payroll"],
)

data = loader.load()
```


```python
print(data)
```

```output
[Document(page_content='Team: Nationals', metadata={'Payroll': 81.34}), Document(page_content='Team: Reds', metadata={'Payroll': 82.2})]
```

## 메타데이터에 소스 추가

```python
loader = DuckDBLoader(
    "SELECT Team, Payroll, Team As source FROM read_csv_auto('example.csv')",
    metadata_columns=["source"],
)

data = loader.load()
```


```python
print(data)
```

```output
[Document(page_content='Team: Nationals\nPayroll: 81.34\nsource: Nationals', metadata={'source': 'Nationals'}), Document(page_content='Team: Reds\nPayroll: 82.2\nsource: Reds', metadata={'source': 'Reds'})]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)