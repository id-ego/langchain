---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/quip.ipynb
description: Quip는 모바일 및 웹에서 협업할 수 있는 생산성 소프트웨어로, 그룹이 문서와 스프레드시트를 공동으로 작성하고 편집할 수
  있게 해줍니다.
---

# Quip

> [Quip](https://quip.com)은 모바일 및 웹을 위한 협업 생산성 소프트웨어 모음입니다. 이는 사람들이 그룹으로 문서 및 스프레드시트를 생성하고 편집할 수 있도록 하며, 일반적으로 비즈니스 목적으로 사용됩니다.

`Quip` 문서용 로더입니다.

개인 액세스 토큰을 얻는 방법은 [여기](https://quip.com/dev/automation/documentation/current#section/Authentication/Get-Access-to-Quip's-APIs)를 참조하십시오.

해당 문서를 Document 객체로 로드하기 위해 `folder_ids` 및/또는 `thread_ids` 목록을 지정하십시오. 두 가지가 모두 지정되면 로더는 `folder_ids`에 따라 이 폴더에 속하는 모든 `thread_ids`를 가져오고, 전달된 `thread_ids`와 결합하여 두 집합의 합집합을 반환합니다.

* folder_id를 아는 방법은?
quip 폴더로 이동하여 폴더를 마우스 오른쪽 버튼으로 클릭하고 링크를 복사한 후, 링크에서 접미사를 추출하여 folder_id로 사용합니다. 힌트: `https://example.quip.com/<folder_id>`
* thread_id를 아는 방법은?
thread_id는 문서 ID입니다. quip 문서로 이동하여 문서를 마우스 오른쪽 버튼으로 클릭하고 링크를 복사한 후, 링크에서 접미사를 추출하여 thread_id로 사용합니다. 힌트: `https://exmaple.quip.com/<thread_id>`

`include_all_folders`를 `True`로 설정하면 group_folder_ids를 가져옵니다.
또한 첨부 파일을 포함하기 위해 불리언 `include_attachments`를 지정할 수 있으며, 기본값은 False입니다. True로 설정하면 모든 첨부 파일이 다운로드되고 QuipLoader가 첨부 파일에서 텍스트를 추출하여 Document 객체에 추가합니다. 현재 지원되는 첨부 파일 유형은: `PDF`, `PNG`, `JPEG/JPG`, `SVG`, `Word` 및 `Excel`입니다. 또한 문서에 주석을 포함하기 위해 불리언 `include_comments`를 지정할 수 있으며, 기본값은 False입니다. True로 설정하면 문서의 모든 주석이 가져와지고 QuipLoader가 이를 Document 객체에 추가합니다.

QuipLoader를 사용하기 전에 quip-api 패키지의 최신 버전이 설치되어 있는지 확인하십시오:

```python
%pip install --upgrade --quiet  quip-api
```


## 예시

### 개인 액세스 토큰

```python
<!--IMPORTS:[{"imported": "QuipLoader", "source": "langchain_community.document_loaders.quip", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.quip.QuipLoader.html", "title": "Quip"}]-->
from langchain_community.document_loaders.quip import QuipLoader

loader = QuipLoader(
    api_url="https://platform.quip.com", access_token="change_me", request_timeout=60
)
documents = loader.load(
    folder_ids={"123", "456"},
    thread_ids={"abc", "efg"},
    include_attachments=False,
    include_comments=False,
)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)