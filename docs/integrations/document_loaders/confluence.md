---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/confluence.ipynb
description: Confluence는 프로젝트 관련 자료를 저장하고 조직하는 위키 협업 플랫폼으로, 콘텐츠 관리 활동을 주로 처리하는 지식
  기반입니다.
---

# Confluence

> [Confluence](https://www.atlassian.com/software/confluence)는 모든 프로젝트 관련 자료를 저장하고 조직하는 위키 협업 플랫폼입니다. `Confluence`는 주로 콘텐츠 관리 활동을 처리하는 지식 기반입니다.

`Confluence` 페이지를 위한 로더입니다.

현재 `username/api_key`, `Oauth2 로그인`을 지원합니다. 또한, 온프레미스 설치는 `token` 인증도 지원합니다.

해당 페이지를 Document 객체로 로드하기 위해 `page_id`-s 및/또는 `space_key` 목록을 지정하십시오. 두 가지 모두 지정된 경우 두 집합의 합집합이 반환됩니다.

첨부파일을 포함하려면 부울 `include_attachments`를 지정할 수 있으며, 기본값은 False로 설정되어 있습니다. True로 설정하면 모든 첨부파일이 다운로드되고 ConfluenceReader가 첨부파일에서 텍스트를 추출하여 Document 객체에 추가합니다. 현재 지원되는 첨부파일 유형은: `PDF`, `PNG`, `JPEG/JPG`, `SVG`, `Word` 및 `Excel`입니다.

힌트: `space_key`와 `page_id`는 모두 Confluence의 페이지 URL에서 찾을 수 있습니다 - https://yoursite.atlassian.com/wiki/spaces/<space_key>/pages/<page_id>

ConfluenceLoader를 사용하기 전에 atlassian-python-api 패키지의 최신 버전이 설치되어 있는지 확인하십시오:

```python
%pip install --upgrade --quiet  atlassian-python-api
```


## 예시

### 사용자 이름과 비밀번호 또는 사용자 이름과 API 토큰 (Atlassian Cloud 전용)

이 예시는 사용자 이름과 비밀번호를 사용하거나, Atlassian Cloud에서 호스팅된 Confluence 버전에 연결하는 경우 사용자 이름과 API 토큰을 사용하여 인증합니다.
API 토큰은 다음에서 생성할 수 있습니다: https://id.atlassian.com/manage-profile/security/api-tokens.

`limit` 매개변수는 한 번의 호출로 검색될 문서 수를 지정하며, 총 검색될 문서 수를 지정하지 않습니다.
기본적으로 코드는 50개 문서 배치로 최대 1000개의 문서를 반환합니다. 총 문서 수를 제어하려면 `max_pages` 매개변수를 사용하십시오.
atlassian-python-api 패키지에서 `limit` 매개변수의 최대 값은 현재 100입니다.

```python
<!--IMPORTS:[{"imported": "ConfluenceLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.confluence.ConfluenceLoader.html", "title": "Confluence"}]-->
from langchain_community.document_loaders import ConfluenceLoader

loader = ConfluenceLoader(
    url="https://yoursite.atlassian.com/wiki", username="me", api_key="12345"
)
documents = loader.load(space_key="SPACE", include_attachments=True, limit=50)
```


### 개인 액세스 토큰 (서버/온프레미스 전용)

이 방법은 데이터 센터/서버 온프레미스 에디션에만 유효합니다.
개인 액세스 토큰(PAT)을 생성하는 방법에 대한 자세한 내용은 공식 Confluence 문서를 참조하십시오: https://confluence.atlassian.com/enterprise/using-personal-access-tokens-1026032365.html.
PAT를 사용할 때는 토큰 값만 제공하며, 사용자 이름을 제공할 수 없습니다.
ConfluenceLoader는 PAT를 생성한 사용자의 권한으로 실행되며, 해당 사용자가 접근할 수 있는 문서만 로드할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ConfluenceLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.confluence.ConfluenceLoader.html", "title": "Confluence"}]-->
from langchain_community.document_loaders import ConfluenceLoader

loader = ConfluenceLoader(url="https://yoursite.atlassian.com/wiki", token="12345")
documents = loader.load(
    space_key="SPACE", include_attachments=True, limit=50, max_pages=50
)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)