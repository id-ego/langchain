---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/toml.ipynb
description: TOML은 구성 파일을 위한 읽기 쉽고 쓰기 쉬운 파일 형식으로, 사전과 명확하게 매핑되도록 설계되었습니다.
---

# TOML

> [TOML](https://en.wikipedia.org/wiki/TOML)은 구성 파일을 위한 파일 형식입니다. 읽고 쓰기 쉽도록 설계되었으며, 사전과 명확하게 매핑되도록 설계되었습니다. 그 사양은 오픈 소스입니다. `TOML`은 많은 프로그래밍 언어에서 구현됩니다. `TOML`이라는 이름은 그 창시자인 Tom Preston-Werner를 지칭하는 "Tom의 명백하고 최소한의 언어"의 약어입니다.

`Toml` 파일을 로드해야 하는 경우, `TomlLoader`를 사용하세요.

```python
<!--IMPORTS:[{"imported": "TomlLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.toml.TomlLoader.html", "title": "TOML"}]-->
from langchain_community.document_loaders import TomlLoader
```


```python
loader = TomlLoader("example_data/fake_rule.toml")
```


```python
rule = loader.load()
```


```python
rule
```


```output
[Document(page_content='{"internal": {"creation_date": "2023-05-01", "updated_date": "2022-05-01", "release": ["release_type"], "min_endpoint_version": "some_semantic_version", "os_list": ["operating_system_list"]}, "rule": {"uuid": "some_uuid", "name": "Fake Rule Name", "description": "Fake description of rule", "query": "process where process.name : \\"somequery\\"\\n", "threat": [{"framework": "MITRE ATT&CK", "tactic": {"name": "Execution", "id": "TA0002", "reference": "https://attack.mitre.org/tactics/TA0002/"}}]}}', metadata={'source': 'example_data/fake_rule.toml'})]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)