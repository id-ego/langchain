---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/glue_catalog.ipynb
description: AWS Glue Data Catalog는 AWS에 저장된 데이터에 대한 메타데이터를 관리하고 접근할 수 있는 중앙 집중식 저장소입니다.
---

# Glue Catalog

[AWS Glue Data Catalog](https://docs.aws.amazon.com/en_en/glue/latest/dg/catalog-and-crawler.html)는 AWS에 저장된 데이터에 대한 메타데이터를 관리, 접근 및 공유할 수 있는 중앙 집중식 메타데이터 저장소입니다. 이는 데이터 자산에 대한 메타데이터 저장소 역할을 하여 다양한 AWS 서비스와 애플리케이션이 필요한 데이터에 효율적으로 쿼리하고 연결할 수 있도록 합니다.

AWS Glue에서 데이터 소스, 변환 및 대상을 정의할 때 이러한 요소에 대한 메타데이터는 데이터 카탈로그에 저장됩니다. 여기에는 데이터 위치, 스키마 정의, 런타임 메트릭스 등에 대한 정보가 포함됩니다. Amazon S3, Amazon RDS, Amazon Redshift 및 JDBC와 호환되는 외부 데이터베이스와 같은 다양한 데이터 저장소 유형을 지원합니다. 또한 Amazon Athena, Amazon Redshift Spectrum 및 Amazon EMR과 직접 통합되어 이러한 서비스가 데이터에 직접 접근하고 쿼리할 수 있도록 합니다.

Langchain GlueCatalogLoader는 주어진 Glue 데이터베이스 내의 모든 테이블의 스키마를 Pandas dtype과 동일한 형식으로 가져옵니다.

## 설정

- [AWS 계정 설정 지침](https://docs.aws.amazon.com/athena/latest/ug/setting-up.html)을 따르세요.
- boto3 라이브러리를 설치하세요: `pip install boto3`

## 예제

```python
<!--IMPORTS:[{"imported": "GlueCatalogLoader", "source": "langchain_community.document_loaders.glue_catalog", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.glue_catalog.GlueCatalogLoader.html", "title": "Glue Catalog"}]-->
from langchain_community.document_loaders.glue_catalog import GlueCatalogLoader
```


```python
database_name = "my_database"
profile_name = "my_profile"

loader = GlueCatalogLoader(
    database=database_name,
    profile_name=profile_name,
)

schemas = loader.load()
print(schemas)
```


## 테이블 필터링이 포함된 예제

테이블 필터링을 사용하면 Glue 데이터베이스 내의 특정 테이블 하위 집합에 대한 스키마 정보를 선택적으로 검색할 수 있습니다. 모든 테이블의 스키마를 로드하는 대신, `table_filter` 인수를 사용하여 관심 있는 테이블을 정확히 지정할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "GlueCatalogLoader", "source": "langchain_community.document_loaders.glue_catalog", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.glue_catalog.GlueCatalogLoader.html", "title": "Glue Catalog"}]-->
from langchain_community.document_loaders.glue_catalog import GlueCatalogLoader
```


```python
database_name = "my_database"
profile_name = "my_profile"
table_filter = ["table1", "table2", "table3"]

loader = GlueCatalogLoader(
    database=database_name, profile_name=profile_name, table_filter=table_filter
)

schemas = loader.load()
print(schemas)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)