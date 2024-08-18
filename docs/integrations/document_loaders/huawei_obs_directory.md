---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/huawei_obs_directory.ipynb
description: Huawei OBS에서 객체를 문서로 로드하는 방법과 특정 접두사로 객체를 로드하는 방법에 대한 설명을 제공합니다.
---

# 화웨이 OBS 디렉토리
다음 코드는 화웨이 OBS(객체 저장 서비스)에서 객체를 문서로 로드하는 방법을 보여줍니다.

```python
# Install the required package
# pip install esdk-obs-python
```


```python
<!--IMPORTS:[{"imported": "OBSDirectoryLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.obs_directory.OBSDirectoryLoader.html", "title": "Huawei OBS Directory"}]-->
from langchain_community.document_loaders import OBSDirectoryLoader
```


```python
endpoint = "your-endpoint"
```


```python
# Configure your access credentials\n
config = {"ak": "your-access-key", "sk": "your-secret-key"}
loader = OBSDirectoryLoader("your-bucket-name", endpoint=endpoint, config=config)
```


```python
loader.load()
```


## 로드를 위한 접두사 지정
버킷에서 특정 접두사를 가진 객체를 로드하려면 다음 코드를 사용할 수 있습니다:

```python
loader = OBSDirectoryLoader(
    "your-bucket-name", endpoint=endpoint, config=config, prefix="test_prefix"
)
```


```python
loader.load()
```


## ECS에서 인증 정보 가져오기
당신의 langchain이 화웨이 클라우드 ECS에 배포되어 있고 [에이전시가 설정되어](https://support.huaweicloud.com/intl/en-us/usermanual-ecs/ecs_03_0166.html#section7) 있다면, 로더는 액세스 키와 비밀 키 없이 ECS에서 보안 토큰을 직접 가져올 수 있습니다.

```python
config = {"get_token_from_ecs": True}
loader = OBSDirectoryLoader("your-bucket-name", endpoint=endpoint, config=config)
```


```python
loader.load()
```


## 공개 버킷 사용
버킷의 버킷 정책이 익명 액세스를 허용하는 경우(익명 사용자는 `listBucket` 및 `GetObject` 권한을 가짐), `config` 매개변수를 구성하지 않고도 객체를 직접 로드할 수 있습니다.

```python
loader = OBSDirectoryLoader("your-bucket-name", endpoint=endpoint)
```


```python
loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)