---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/microsoft_sharepoint.ipynb
description: Microsoft SharePoint는 비즈니스 팀의 협업을 지원하는 웹 기반 시스템으로, 문서 라이브러리에서 문서를 로드하는
  방법을 다룹니다.
---

# Microsoft SharePoint

> [Microsoft SharePoint](https://en.wikipedia.org/wiki/SharePoint)는 Microsoft에서 개발한 비즈니스 팀이 함께 작업할 수 있도록 워크플로우 애플리케이션, “리스트” 데이터베이스 및 기타 웹 파트와 보안 기능을 사용하는 웹 기반 협업 시스템입니다.

이 노트북은 [SharePoint 문서 라이브러리](https://support.microsoft.com/en-us/office/what-is-a-document-library-3b5976dd-65cf-4c9e-bf5a-713c10ca2872)에서 문서를 로드하는 방법을 다룹니다. 현재 docx, doc 및 pdf 파일만 지원됩니다.

## 필수 조건
1. [Microsoft ID 플랫폼](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app) 지침에 따라 애플리케이션을 등록합니다.
2. 등록이 완료되면 Azure 포털에 애플리케이션 등록 개요 창이 표시됩니다. 여기에서 애플리케이션(클라이언트) ID를 확인할 수 있습니다. `client ID`라고도 하는 이 값은 Microsoft ID 플랫폼에서 애플리케이션을 고유하게 식별합니다.
3. **항목 1**에서 따르는 단계 동안 리디렉션 URI를 `https://login.microsoftonline.com/common/oauth2/nativeclient`로 설정할 수 있습니다.
4. **항목 1**에서 따르는 단계 동안 애플리케이션 비밀 섹션에서 새 비밀번호(`client_secret`)를 생성합니다.
5. 이 [문서](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-expose-web-apis#add-a-scope)의 지침에 따라 애플리케이션에 `SCOPES`(`offline_access` 및 `Sites.Read.All`)를 추가합니다.
6. **문서 라이브러리**에서 파일을 검색하려면 해당 ID가 필요합니다. 이를 얻으려면 `Tenant Name`, `Collection ID`, 및 `Subsite ID` 값을 알아야 합니다.
7. `Tenant Name`을 찾으려면 이 [문서](https://learn.microsoft.com/en-us/azure/active-directory-b2c/tenant-management-read-tenant-name)의 지침을 따르세요. 이를 얻으면 값에서 `.onmicrosoft.com`을 제거하고 나머지를 `Tenant Name`으로 사용합니다.
8. `Collection ID`와 `Subsite ID`를 얻으려면 **SharePoint** `site-name`이 필요합니다. `SharePoint` 사이트 URL은 다음 형식을 가집니다: `https://<tenant-name>.sharepoint.com/sites/<site-name>` 이 URL의 마지막 부분이 `site-name`입니다.
9. 사이트 `Collection ID`를 얻으려면 브라우저에서 이 URL을 클릭하세요: `https://<tenant>.sharepoint.com/sites/<site-name>/_api/site/id` 그리고 `Edm.Guid` 속성의 값을 복사합니다.
10. `Subsite ID`(또는 웹 ID)를 얻으려면: `https://<tenant>.sharepoint.com/sites/<site-name>/_api/web/id`를 사용하고 `Edm.Guid` 속성의 값을 복사합니다.
11. `SharePoint 사이트 ID`는 다음 형식을 가집니다: `<tenant-name>.sharepoint.com,<Collection ID>,<subsite ID>` 이 값을 다음 단계에서 사용할 수 있도록 보관할 수 있습니다.
12. [Graph Explorer Playground](https://developer.microsoft.com/en-us/graph/graph-explorer)를 방문하여 `Document Library ID`를 얻습니다. 첫 번째 단계는 **SharePoint** 사이트와 연결된 계정으로 로그인하는 것입니다. 그런 다음 `https://graph.microsoft.com/v1.0/sites/<SharePoint site ID>/drive`에 요청을 보내면 응답으로 `Document Library ID`를 포함하는 `id` 필드가 있는 페이로드가 반환됩니다.

## 🧑 SharePoint 문서 라이브러리에서 문서를 가져오는 지침

### 🔑 인증

기본적으로 `SharePointLoader`는 `CLIENT_ID`와 `CLIENT_SECRET`의 값이 각각 `O365_CLIENT_ID` 및 `O365_CLIENT_SECRET`라는 환경 변수로 저장되어야 한다고 예상합니다. 이러한 환경 변수를 애플리케이션의 루트에 있는 `.env` 파일을 통해 전달하거나 스크립트에서 다음 명령을 사용하여 전달할 수 있습니다.

```python
os.environ['O365_CLIENT_ID'] = "YOUR CLIENT ID"
os.environ['O365_CLIENT_SECRET'] = "YOUR CLIENT SECRET"
```


이 로더는 [*사용자를 대신하여*](https://learn.microsoft.com/en-us/graph/auth-v2-user?context=graph%2Fapi%2F1.0&view=graph-rest-1.0)라는 인증을 사용합니다. 이는 사용자 동의가 필요한 2단계 인증입니다. 로더를 인스턴스화하면 사용자가 필요한 권한에 대해 앱에 동의를 제공하기 위해 방문해야 하는 URL을 출력합니다. 사용자는 이 URL을 방문하여 애플리케이션에 동의를 제공해야 합니다. 그런 다음 사용자는 결과 페이지 URL을 복사하여 콘솔에 붙여넣어야 합니다. 이 메서드는 로그인 시도가 성공적이면 True를 반환합니다.

```python
<!--IMPORTS:[{"imported": "SharePointLoader", "source": "langchain_community.document_loaders.sharepoint", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.sharepoint.SharePointLoader.html", "title": "Microsoft SharePoint"}]-->
from langchain_community.document_loaders.sharepoint import SharePointLoader

loader = SharePointLoader(document_library_id="YOUR DOCUMENT LIBRARY ID")
```


인증이 완료되면 로더는 `~/.credentials/` 폴더에 토큰(`o365_token.txt`)을 저장합니다. 이 토큰은 이전에 설명한 복사/붙여넣기 단계 없이 나중에 인증하는 데 사용할 수 있습니다. 인증을 위해 이 토큰을 사용하려면 로더의 인스턴스화에서 `auth_with_token` 매개변수를 True로 변경해야 합니다.

```python
<!--IMPORTS:[{"imported": "SharePointLoader", "source": "langchain_community.document_loaders.sharepoint", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.sharepoint.SharePointLoader.html", "title": "Microsoft SharePoint"}]-->
from langchain_community.document_loaders.sharepoint import SharePointLoader

loader = SharePointLoader(document_library_id="YOUR DOCUMENT LIBRARY ID", auth_with_token=True)
```


### 🗂️ 문서 로더

#### 📑 문서 라이브러리 디렉토리에서 문서 로드하기

`SharePointLoader`는 문서 라이브러리 내의 특정 폴더에서 문서를 로드할 수 있습니다. 예를 들어, 문서 라이브러리 내의 `Documents/marketing` 폴더에 저장된 모든 문서를 로드하고 싶다면 다음과 같이 할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "SharePointLoader", "source": "langchain_community.document_loaders.sharepoint", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.sharepoint.SharePointLoader.html", "title": "Microsoft SharePoint"}]-->
from langchain_community.document_loaders.sharepoint import SharePointLoader

loader = SharePointLoader(document_library_id="YOUR DOCUMENT LIBRARY ID", folder_path="Documents/marketing", auth_with_token=True)
documents = loader.load()
```


`Resource not found for the segment` 오류가 발생하면 폴더 경로 대신 `folder_id`를 사용해 보세요. 이는 [Microsoft Graph API](https://developer.microsoft.com/en-us/graph/graph-explorer)에서 얻을 수 있습니다.

```python
loader = SharePointLoader(document_library_id="YOUR DOCUMENT LIBRARY ID", auth_with_token=True
                          folder_id="<folder-id>")
documents = loader.load()
```


루트 디렉토리에서 문서를 로드하려면 `folder_id`, `folder_path` 및 `documents_ids`를 생략하면 로더가 루트 디렉토리를 로드합니다.
```python
# loads documents from root directory
loader = SharePointLoader(document_library_id="YOUR DOCUMENT LIBRARY ID", auth_with_token=True)
documents = loader.load()
```


`recursive=True`와 결합하면 SharePoint 전체에서 모든 문서를 간단히 로드할 수 있습니다:
```python
# loads documents from root directory
loader = SharePointLoader(document_library_id="YOUR DOCUMENT LIBRARY ID",
                          recursive=True,
                          auth_with_token=True)
documents = loader.load()
```


#### 📑 문서 ID 목록에서 문서 로드하기

또 다른 가능성은 로드하려는 각 문서에 대한 `object_id` 목록을 제공하는 것입니다. 이를 위해 관심 있는 모든 문서 ID를 찾기 위해 [Microsoft Graph API](https://developer.microsoft.com/en-us/graph/graph-explorer)에 쿼리해야 합니다. 이 [링크](https://learn.microsoft.com/en-us/graph/api/resources/onedrive?view=graph-rest-1.0#commonly-accessed-resources)는 문서 ID를 검색하는 데 유용한 엔드포인트 목록을 제공합니다.

예를 들어, `data/finance/` 폴더에 저장된 모든 객체에 대한 정보를 검색하려면 다음 요청을 해야 합니다: `https://graph.microsoft.com/v1.0/drives/<document-library-id>/root:/data/finance:/children`. 관심 있는 ID 목록을 얻은 후 다음 매개변수로 로더를 인스턴스화할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "SharePointLoader", "source": "langchain_community.document_loaders.sharepoint", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.sharepoint.SharePointLoader.html", "title": "Microsoft SharePoint"}]-->
from langchain_community.document_loaders.sharepoint import SharePointLoader

loader = SharePointLoader(document_library_id="YOUR DOCUMENT LIBRARY ID", object_ids=["ID_1", "ID_2"], auth_with_token=True)
documents = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)