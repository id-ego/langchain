---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/athena.ipynb
description: 아마존 아테나는 서버리스 인터랙티브 분석 서비스로, S3 데이터 레이크와 다양한 데이터 소스를 SQL 또는 Python으로
  분석할 수 있습니다.
---

# 아테나

> [아마존 아테나](https://aws.amazon.com/athena/)는 오픈 소스 프레임워크를 기반으로 구축된 서버리스 대화형 분석 서비스로, 오픈 테이블 및 파일 형식을 지원합니다. `아테나`는 데이터가 있는 곳에서 페타바이트의 데이터를 분석하는 간소화되고 유연한 방법을 제공합니다. SQL 또는 Python을 사용하여 아마존 간단 저장 서비스(S3) 데이터 레이크와 온프레미스 데이터 소스 또는 기타 클라우드 시스템을 포함한 30개의 데이터 소스에서 데이터를 분석하거나 애플리케이션을 구축할 수 있습니다. `아테나`는 오픈 소스 `트리노`와 `프레스토` 엔진 및 `아파치 스파크` 프레임워크를 기반으로 하며, 프로비저닝이나 구성 작업이 필요하지 않습니다.

이 노트북은 `AWS 아테나`에서 문서를 로드하는 방법을 다룹니다.

## 설정하기

[AWS 계정을 설정하는 방법](https://docs.aws.amazon.com/athena/latest/ug/setting-up.html)을 따르세요.

파이썬 라이브러리를 설치합니다:

```python
! pip install boto3
```


## 예시

```python
<!--IMPORTS:[{"imported": "AthenaLoader", "source": "langchain_community.document_loaders.athena", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.athena.AthenaLoader.html", "title": "Athena"}]-->
from langchain_community.document_loaders.athena import AthenaLoader
```


```python
database_name = "my_database"
s3_output_path = "s3://my_bucket/query_results/"
query = "SELECT * FROM my_table"
profile_name = "my_profile"

loader = AthenaLoader(
    query=query,
    database=database_name,
    s3_output_uri=s3_output_path,
    profile_name=profile_name,
)

documents = loader.load()
print(documents)
```


메타데이터 열이 있는 예시

```python
database_name = "my_database"
s3_output_path = "s3://my_bucket/query_results/"
query = "SELECT * FROM my_table"
profile_name = "my_profile"
metadata_columns = ["_row", "_created_at"]

loader = AthenaLoader(
    query=query,
    database=database_name,
    s3_output_uri=s3_output_path,
    profile_name=profile_name,
    metadata_columns=metadata_columns,
)

documents = loader.load()
print(documents)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)