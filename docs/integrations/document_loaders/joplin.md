---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/joplin.ipynb
description: Joplin은 오픈 소스 노트 작성 앱으로, REST API를 통해 로컬 데이터베이스에서 문서를 로드하는 방법을 설명합니다.
---

# Joplin

> [Joplin](https://joplinapp.org/)은 오픈 소스 노트 작성 앱입니다. 당신의 생각을 기록하고 어떤 장치에서든 안전하게 접근할 수 있습니다.

이 노트북은 `Joplin` 데이터베이스에서 문서를 로드하는 방법을 다룹니다.

`Joplin`은 로컬 데이터베이스에 접근하기 위한 [REST API](https://joplinapp.org/api/references/rest_api/)를 제공합니다. 이 로더는 API를 사용하여 데이터베이스의 모든 노트와 그 메타데이터를 검색합니다. 이를 위해서는 앱에서 다음 단계를 따라 얻을 수 있는 액세스 토큰이 필요합니다:

1. `Joplin` 앱을 엽니다. 문서가 로드되는 동안 앱은 열려 있어야 합니다.
2. 설정 / 옵션으로 가서 "웹 클리퍼"를 선택합니다.
3. 웹 클리퍼 서비스가 활성화되어 있는지 확인합니다.
4. "고급 옵션"에서 인증 토큰을 복사합니다.

액세스 토큰으로 로더를 직접 초기화하거나 환경 변수 JOPLIN_ACCESS_TOKEN에 저장할 수 있습니다.

이 접근 방식의 대안으로는 `Joplin`의 노트 데이터베이스를 마크다운 파일로 내보내고 (선택적으로, 프론트 매터 메타데이터와 함께) ObsidianLoader와 같은 마크다운 로더를 사용하여 로드하는 방법이 있습니다.

```python
<!--IMPORTS:[{"imported": "JoplinLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.joplin.JoplinLoader.html", "title": "Joplin"}]-->
from langchain_community.document_loaders import JoplinLoader
```


```python
loader = JoplinLoader(access_token="<access-token>")
```


```python
docs = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)