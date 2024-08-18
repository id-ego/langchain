---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/alibaba_cloud_maxcompute.ipynb
description: Alibaba Cloud MaxCompute는 대규모 데이터 웨어하우징을 위한 완전 관리형 데이터 처리 플랫폼으로, 효율적인
  데이터 쿼리와 보안을 제공합니다.
---

# Alibaba Cloud MaxCompute

> [Alibaba Cloud MaxCompute](https://www.alibabacloud.com/product/maxcompute) (이전 이름: ODPS)는 대규모 데이터 웨어하우징을 위한 일반 목적의 완전 관리형 다중 테넌시 데이터 처리 플랫폼입니다. MaxCompute는 다양한 데이터 가져오기 솔루션과 분산 컴퓨팅 모델을 지원하여 사용자가 방대한 데이터 세트를 효과적으로 쿼리하고, 생산 비용을 줄이며, 데이터 보안을 보장할 수 있도록 합니다.

`MaxComputeLoader`를 사용하면 MaxCompute SQL 쿼리를 실행하고 결과를 행당 하나의 문서로 로드할 수 있습니다.

```python
%pip install --upgrade --quiet  pyodps
```

```output
Collecting pyodps
  Downloading pyodps-0.11.4.post0-cp39-cp39-macosx_10_9_universal2.whl (2.0 MB)
[2K     [90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m [32m2.0/2.0 MB[0m [31m1.7 MB/s[0m eta [36m0:00:00[0m00:01[0m00:01[0m0m
[?25hRequirement already satisfied: charset-normalizer>=2 in /Users/newboy/anaconda3/envs/langchain/lib/python3.9/site-packages (from pyodps) (3.1.0)
Requirement already satisfied: urllib3<2.0,>=1.26.0 in /Users/newboy/anaconda3/envs/langchain/lib/python3.9/site-packages (from pyodps) (1.26.15)
Requirement already satisfied: idna>=2.5 in /Users/newboy/anaconda3/envs/langchain/lib/python3.9/site-packages (from pyodps) (3.4)
Requirement already satisfied: certifi>=2017.4.17 in /Users/newboy/anaconda3/envs/langchain/lib/python3.9/site-packages (from pyodps) (2023.5.7)
Installing collected packages: pyodps
Successfully installed pyodps-0.11.4.post0
```

## 기본 사용법
로더를 인스턴스화하려면 실행할 SQL 쿼리, MaxCompute 엔드포인트 및 프로젝트 이름, 액세스 ID 및 비밀 액세스 키가 필요합니다. 액세스 ID 및 비밀 액세스 키는 `access_id` 및 `secret_access_key` 매개변수를 통해 직접 전달하거나 환경 변수 `MAX_COMPUTE_ACCESS_ID` 및 `MAX_COMPUTE_SECRET_ACCESS_KEY`로 설정할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "MaxComputeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.max_compute.MaxComputeLoader.html", "title": "Alibaba Cloud MaxCompute"}]-->
from langchain_community.document_loaders import MaxComputeLoader
```


```python
base_query = """
SELECT *
FROM (
    SELECT 1 AS id, 'content1' AS content, 'meta_info1' AS meta_info
    UNION ALL
    SELECT 2 AS id, 'content2' AS content, 'meta_info2' AS meta_info
    UNION ALL
    SELECT 3 AS id, 'content3' AS content, 'meta_info3' AS meta_info
) mydata;
"""
```


```python
endpoint = "<ENDPOINT>"
project = "<PROJECT>"
ACCESS_ID = "<ACCESS ID>"
SECRET_ACCESS_KEY = "<SECRET ACCESS KEY>"
```


```python
loader = MaxComputeLoader.from_params(
    base_query,
    endpoint,
    project,
    access_id=ACCESS_ID,
    secret_access_key=SECRET_ACCESS_KEY,
)
data = loader.load()
```


```python
print(data)
```

```output
[Document(page_content='id: 1\ncontent: content1\nmeta_info: meta_info1', metadata={}), Document(page_content='id: 2\ncontent: content2\nmeta_info: meta_info2', metadata={}), Document(page_content='id: 3\ncontent: content3\nmeta_info: meta_info3', metadata={})]
```


```python
print(data[0].page_content)
```

```output
id: 1
content: content1
meta_info: meta_info1
```


```python
print(data[0].metadata)
```

```output
{}
```

## 콘텐츠와 메타데이터로 사용할 열 지정
어떤 열의 하위 집합을 문서의 내용으로 로드할지, 어떤 열을 메타데이터로 로드할지를 `page_content_columns` 및 `metadata_columns` 매개변수를 사용하여 구성할 수 있습니다.

```python
loader = MaxComputeLoader.from_params(
    base_query,
    endpoint,
    project,
    page_content_columns=["content"],  # Specify Document page content
    metadata_columns=["id", "meta_info"],  # Specify Document metadata
    access_id=ACCESS_ID,
    secret_access_key=SECRET_ACCESS_KEY,
)
data = loader.load()
```


```python
print(data[0].page_content)
```

```output
content: content1
```


```python
print(data[0].metadata)
```

```output
{'id': 1, 'meta_info': 'meta_info1'}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)