---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/huawei_obs_file.ipynb
description: Huawei OBS에서 객체를 로드하는 방법과 인증 정보 설정, ECS에서 보안 토큰 가져오기, 공개 객체 접근 방법을 설명합니다.
---

# 화웨이 OBS 파일
다음 코드는 화웨이 OBS(객체 저장 서비스)에서 문서로 객체를 로드하는 방법을 보여줍니다.

```python
# Install the required package
# pip install esdk-obs-python
```


```python
<!--IMPORTS:[{"imported": "OBSFileLoader", "source": "langchain_community.document_loaders.obs_file", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.obs_file.OBSFileLoader.html", "title": "Huawei OBS File"}]-->
from langchain_community.document_loaders.obs_file import OBSFileLoader
```


```python
endpoint = "your-endpoint"
```


```python
from obs import ObsClient

obs_client = ObsClient(
    access_key_id="your-access-key",
    secret_access_key="your-secret-key",
    server=endpoint,
)
loader = OBSFileLoader("your-bucket-name", "your-object-key", client=obs_client)
```


```python
loader.load()
```


## 각 로더에 대한 별도의 인증 정보
다른 로더 간에 OBS 연결을 재사용할 필요가 없다면, `config`를 직접 구성할 수 있습니다. 로더는 구성 정보를 사용하여 자체 OBS 클라이언트를 초기화합니다.

```python
# Configure your access credentials\n
config = {"ak": "your-access-key", "sk": "your-secret-key"}
loader = OBSFileLoader(
    "your-bucket-name", "your-object-key", endpoint=endpoint, config=config
)
```


```python
loader.load()
```


## ECS에서 인증 정보 가져오기
당신의 langchain이 화웨이 클라우드 ECS에 배포되어 있고 [에이전시가 설정되어 있다면](https://support.huaweicloud.com/intl/en-us/usermanual-ecs/ecs_03_0166.html#section7), 로더는 액세스 키와 비밀 키 없이 ECS에서 보안 토큰을 직접 가져올 수 있습니다.

```python
config = {"get_token_from_ecs": True}
loader = OBSFileLoader(
    "your-bucket-name", "your-object-key", endpoint=endpoint, config=config
)
```


```python
loader.load()
```


## 공개적으로 접근 가능한 객체에 접근하기
접근하려는 객체가 익명 사용자 접근을 허용하는 경우(익명 사용자는 `GetObject` 권한을 가집니다), `config` 매개변수를 구성하지 않고도 객체를 직접 로드할 수 있습니다.

```python
loader = OBSFileLoader("your-bucket-name", "your-object-key", endpoint=endpoint)
```


```python
loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)