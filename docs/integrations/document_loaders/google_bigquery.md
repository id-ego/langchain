---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/google_bigquery.ipynb
description: 구글 빅쿼리는 서버리스 및 비용 효율적인 엔터프라이즈 데이터 웨어하우스로, 클라우드 간에 작동하며 데이터에 따라 확장됩니다.
---

# 구글 빅쿼리

> [구글 빅쿼리](https://cloud.google.com/bigquery)는 서버리스이며 비용 효율적인 기업 데이터 웨어하우스로, 클라우드 간에 작동하고 데이터에 따라 확장됩니다.  
`BigQuery`는 `Google Cloud Platform`의 일부입니다.

각 행에 문서가 있는 `BigQuery` 쿼리를 로드합니다.

```python
%pip install --upgrade --quiet langchain-google-community[bigquery]
```


```python
from langchain_google_community import BigQueryLoader
```


```python
BASE_QUERY = """
SELECT
  id,
  dna_sequence,
  organism
FROM (
  SELECT
    ARRAY (
    SELECT
      AS STRUCT 1 AS id, "ATTCGA" AS dna_sequence, "Lokiarchaeum sp. (strain GC14_75)." AS organism
    UNION ALL
    SELECT
      AS STRUCT 2 AS id, "AGGCGA" AS dna_sequence, "Heimdallarchaeota archaeon (strain LC_2)." AS organism
    UNION ALL
    SELECT
      AS STRUCT 3 AS id, "TCCGGA" AS dna_sequence, "Acidianus hospitalis (strain W1)." AS organism) AS new_array),
  UNNEST(new_array)
"""
```


## 기본 사용법

```python
loader = BigQueryLoader(BASE_QUERY)

data = loader.load()
```


```python
print(data)
```
  
```output
[Document(page_content='id: 1\ndna_sequence: ATTCGA\norganism: Lokiarchaeum sp. (strain GC14_75).', lookup_str='', metadata={}, lookup_index=0), Document(page_content='id: 2\ndna_sequence: AGGCGA\norganism: Heimdallarchaeota archaeon (strain LC_2).', lookup_str='', metadata={}, lookup_index=0), Document(page_content='id: 3\ndna_sequence: TCCGGA\norganism: Acidianus hospitalis (strain W1).', lookup_str='', metadata={}, lookup_index=0)]
```
  
## 콘텐츠와 메타데이터의 열 지정

```python
loader = BigQueryLoader(
    BASE_QUERY,
    page_content_columns=["dna_sequence", "organism"],
    metadata_columns=["id"],
)

data = loader.load()
```


```python
print(data)
```
  
```output
[Document(page_content='dna_sequence: ATTCGA\norganism: Lokiarchaeum sp. (strain GC14_75).', lookup_str='', metadata={'id': 1}, lookup_index=0), Document(page_content='dna_sequence: AGGCGA\norganism: Heimdallarchaeota archaeon (strain LC_2).', lookup_str='', metadata={'id': 2}, lookup_index=0), Document(page_content='dna_sequence: TCCGGA\norganism: Acidianus hospitalis (strain W1).', lookup_str='', metadata={'id': 3}, lookup_index=0)]
```
  
## 메타데이터에 소스 추가

```python
# Note that the `id` column is being returned twice, with one instance aliased as `source`
ALIASED_QUERY = """
SELECT
  id,
  dna_sequence,
  organism,
  id as source
FROM (
  SELECT
    ARRAY (
    SELECT
      AS STRUCT 1 AS id, "ATTCGA" AS dna_sequence, "Lokiarchaeum sp. (strain GC14_75)." AS organism
    UNION ALL
    SELECT
      AS STRUCT 2 AS id, "AGGCGA" AS dna_sequence, "Heimdallarchaeota archaeon (strain LC_2)." AS organism
    UNION ALL
    SELECT
      AS STRUCT 3 AS id, "TCCGGA" AS dna_sequence, "Acidianus hospitalis (strain W1)." AS organism) AS new_array),
  UNNEST(new_array)
"""
```


```python
loader = BigQueryLoader(ALIASED_QUERY, metadata_columns=["source"])

data = loader.load()
```


```python
print(data)
```
  
```output
[Document(page_content='id: 1\ndna_sequence: ATTCGA\norganism: Lokiarchaeum sp. (strain GC14_75).\nsource: 1', lookup_str='', metadata={'source': 1}, lookup_index=0), Document(page_content='id: 2\ndna_sequence: AGGCGA\norganism: Heimdallarchaeota archaeon (strain LC_2).\nsource: 2', lookup_str='', metadata={'source': 2}, lookup_index=0), Document(page_content='id: 3\ndna_sequence: TCCGGA\norganism: Acidianus hospitalis (strain W1).\nsource: 3', lookup_str='', metadata={'source': 3}, lookup_index=0)]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)  
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)