---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/microsoft_onedrive.ipynb
description: 이 문서는 Microsoft OneDrive에서 문서를 로드하는 방법에 대해 설명하며, 지원되는 파일 형식은 docx, doc
  및 pdf입니다.
---

# Microsoft OneDrive

> [Microsoft OneDrive](https://en.wikipedia.org/wiki/OneDrive) (이전 이름 `SkyDrive`)는 Microsoft에서 운영하는 파일 호스팅 서비스입니다.

이 노트북에서는 `OneDrive`에서 문서를 로드하는 방법을 다룹니다. 현재 docx, doc 및 pdf 파일만 지원됩니다.

## 필수 조건
1. [Microsoft identity platform](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app) 지침에 따라 애플리케이션을 등록합니다.
2. 등록이 완료되면 Azure 포털에서 앱 등록의 개요 창이 표시됩니다. 여기에서 애플리케이션(클라이언트) ID를 확인할 수 있습니다. `client ID`라고도 하며, 이 값은 Microsoft identity platform에서 애플리케이션을 고유하게 식별합니다.
3. **항목 1**에서 따라야 할 단계 중에 리디렉션 URI를 `http://localhost:8000/callback`으로 설정할 수 있습니다.
4. **항목 1**에서 따라야 할 단계 중에 애플리케이션 비밀(Application Secrets) 섹션에서 새 비밀번호(`client_secret`)를 생성합니다.
5. 이 [문서](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-expose-web-apis#add-a-scope)에서 지침에 따라 애플리케이션에 다음 `SCOPES`(`offline_access` 및 `Files.Read.All`)를 추가합니다.
6. [Graph Explorer Playground](https://developer.microsoft.com/en-us/graph/graph-explorer)를 방문하여 `OneDrive ID`를 얻습니다. 첫 번째 단계는 OneDrive 계정과 연결된 계정으로 로그인되어 있는지 확인하는 것입니다. 그런 다음 `https://graph.microsoft.com/v1.0/me/drive`에 요청을 보내면 응답으로 `id` 필드가 포함된 페이로드가 반환되어 OneDrive 계정의 ID를 포함합니다.
7. `pip install o365` 명령어를 사용하여 o365 패키지를 설치해야 합니다.
8. 단계가 끝나면 다음 값을 가져야 합니다: 
- `CLIENT_ID`
- `CLIENT_SECRET`
- `DRIVE_ID`

## 🧑 OneDrive에서 문서를 가져오는 방법

### 🔑 인증

기본적으로 `OneDriveLoader`는 `CLIENT_ID`와 `CLIENT_SECRET`의 값이 각각 `O365_CLIENT_ID` 및 `O365_CLIENT_SECRET`라는 환경 변수로 저장되어 있어야 한다고 예상합니다. 이러한 환경 변수를 애플리케이션의 루트에 있는 `.env` 파일을 통해 전달하거나 스크립트에서 다음 명령어를 사용할 수 있습니다.

```python
os.environ['O365_CLIENT_ID'] = "YOUR CLIENT ID"
os.environ['O365_CLIENT_SECRET'] = "YOUR CLIENT SECRET"
```


이 로더는 [*사용자 대신*](https://learn.microsoft.com/en-us/graph/auth-v2-user?context=graph%2Fapi%2F1.0&view=graph-rest-1.0) 인증을 사용합니다. 이는 사용자 동의가 필요한 2단계 인증입니다. 로더를 인스턴스화하면 사용자가 필요한 권한에 대한 동의를 제공하기 위해 방문해야 하는 URL을 출력합니다. 사용자는 이 URL을 방문하여 애플리케이션에 동의를 제공해야 합니다. 그런 다음 사용자는 결과 페이지의 URL을 복사하여 콘솔에 붙여넣어야 합니다. 로그인 시도가 성공하면 메서드는 True를 반환합니다.

```python
<!--IMPORTS:[{"imported": "OneDriveLoader", "source": "langchain_community.document_loaders.onedrive", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.onedrive.OneDriveLoader.html", "title": "Microsoft OneDrive"}]-->
from langchain_community.document_loaders.onedrive import OneDriveLoader

loader = OneDriveLoader(drive_id="YOUR DRIVE ID")
```


인증이 완료되면 로더는 `~/.credentials/` 폴더에 토큰(`o365_token.txt`)을 저장합니다. 이 토큰은 이전에 설명한 복사/붙여넣기 단계를 거치지 않고도 나중에 인증하는 데 사용할 수 있습니다. 이 토큰을 인증에 사용하려면 로더의 인스턴스화 시 `auth_with_token` 매개변수를 True로 변경해야 합니다.

```python
<!--IMPORTS:[{"imported": "OneDriveLoader", "source": "langchain_community.document_loaders.onedrive", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.onedrive.OneDriveLoader.html", "title": "Microsoft OneDrive"}]-->
from langchain_community.document_loaders.onedrive import OneDriveLoader

loader = OneDriveLoader(drive_id="YOUR DRIVE ID", auth_with_token=True)
```


### 🗂️ 문서 로더

#### 📑 OneDrive 디렉토리에서 문서 로드하기

`OneDriveLoader`는 OneDrive 내의 특정 폴더에서 문서를 로드할 수 있습니다. 예를 들어, OneDrive의 `Documents/clients` 폴더에 저장된 모든 문서를 로드하고 싶습니다.

```python
<!--IMPORTS:[{"imported": "OneDriveLoader", "source": "langchain_community.document_loaders.onedrive", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.onedrive.OneDriveLoader.html", "title": "Microsoft OneDrive"}]-->
from langchain_community.document_loaders.onedrive import OneDriveLoader

loader = OneDriveLoader(drive_id="YOUR DRIVE ID", folder_path="Documents/clients", auth_with_token=True)
documents = loader.load()
```


#### 📑 문서 ID 목록에서 문서 로드하기

또 다른 가능성은 로드하려는 각 문서에 대한 `object_id` 목록을 제공하는 것입니다. 이를 위해 관심 있는 모든 문서 ID를 찾기 위해 [Microsoft Graph API](https://developer.microsoft.com/en-us/graph/graph-explorer)에 쿼리해야 합니다. 이 [링크](https://learn.microsoft.com/en-us/graph/api/resources/onedrive?view=graph-rest-1.0#commonly-accessed-resources)는 문서 ID를 검색하는 데 유용한 엔드포인트 목록을 제공합니다.

예를 들어, Documents 폴더의 루트에 저장된 모든 객체에 대한 정보를 검색하려면 다음에 요청을 해야 합니다: `https://graph.microsoft.com/v1.0/drives/{YOUR DRIVE ID}/root/children`. 관심 있는 ID 목록을 확보한 후에는 다음 매개변수로 로더를 인스턴스화할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "OneDriveLoader", "source": "langchain_community.document_loaders.onedrive", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.onedrive.OneDriveLoader.html", "title": "Microsoft OneDrive"}]-->
from langchain_community.document_loaders.onedrive import OneDriveLoader

loader = OneDriveLoader(drive_id="YOUR DRIVE ID", object_ids=["ID_1", "ID_2"], auth_with_token=True)
documents = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)