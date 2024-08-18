---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/notiondb.ipynb
description: Notion 데이터베이스에서 콘텐츠를 로드하는 `NotionDBLoader` 클래스에 대한 설명과 설정 방법을 제공합니다.
---

# Notion DB 2/2

> [Notion](https://www.notion.so/)은 칸반 보드, 작업, 위키 및 데이터베이스를 통합한 수정된 Markdown 지원 협업 플랫폼입니다. 이는 노트 작성, 지식 및 데이터 관리, 프로젝트 및 작업 관리를 위한 올인원 작업 공간입니다.

`NotionDBLoader`는 `Notion` 데이터베이스에서 콘텐츠를 로드하기 위한 Python 클래스입니다. 데이터베이스에서 페이지를 검색하고, 그 콘텐츠를 읽고, Document 객체의 목록을 반환합니다.

## 요구 사항

- `Notion` 데이터베이스
- Notion 통합 토큰

## 설정

### 1. Notion 테이블 데이터베이스 생성
Notion에서 새 테이블 데이터베이스를 생성합니다. 데이터베이스에 어떤 열이든 추가할 수 있으며, 이들은 메타데이터로 처리됩니다. 예를 들어 다음과 같은 열을 추가할 수 있습니다:

- 제목: 제목을 기본 속성으로 설정합니다.
- 카테고리: 페이지와 관련된 카테고리를 저장하기 위한 다중 선택 속성입니다.
- 키워드: 페이지와 관련된 키워드를 저장하기 위한 다중 선택 속성입니다.

데이터베이스의 각 페이지 본문에 콘텐츠를 추가합니다. NotionDBLoader는 이러한 페이지에서 콘텐츠와 메타데이터를 추출합니다.

## 2. Notion 통합 생성
Notion 통합을 생성하려면 다음 단계를 따르세요:

1. [Notion Developers](https://www.notion.com/my-integrations) 페이지를 방문하고 Notion 계정으로 로그인합니다.
2. "+ 새 통합" 버튼을 클릭합니다.
3. 통합에 이름을 지정하고 데이터베이스가 위치한 작업 공간을 선택합니다.
4. 필요한 기능을 선택합니다. 이 확장은 콘텐츠 읽기 기능만 필요합니다.
5. "제출" 버튼을 클릭하여 통합을 생성합니다.
통합이 생성되면 `통합 토큰 (API 키)`가 제공됩니다. 이 토큰을 복사하고 안전하게 보관하세요. NotionDBLoader를 사용하려면 필요합니다.

### 3. 통합을 데이터베이스에 연결
통합을 데이터베이스에 연결하려면 다음 단계를 따르세요:

1. Notion에서 데이터베이스를 엽니다.
2. 데이터베이스 보기의 오른쪽 상단 모서리에 있는 세 점 메뉴 아이콘을 클릭합니다.
3. "+ 새 통합" 버튼을 클릭합니다.
4. 통합을 찾습니다. 이름을 검색 상자에 입력해야 할 수도 있습니다.
5. "연결" 버튼을 클릭하여 통합을 데이터베이스에 연결합니다.

### 4. 데이터베이스 ID 가져오기
데이터베이스 ID를 가져오려면 다음 단계를 따르세요:

1. Notion에서 데이터베이스를 엽니다.
2. 데이터베이스 보기의 오른쪽 상단 모서리에 있는 세 점 메뉴 아이콘을 클릭합니다.
3. 메뉴에서 "링크 복사"를 선택하여 데이터베이스 URL을 클립보드에 복사합니다.
4. 데이터베이스 ID는 URL에 있는 긴 알파벳 숫자 문자열입니다. 일반적으로 다음과 같이 보입니다: https://www.notion.so/username/8935f9d140a04f95a872520c4f123456?v=.... 이 예에서 데이터베이스 ID는 8935f9d140a04f95a872520c4f123456입니다.

데이터베이스가 제대로 설정되고 통합 토큰과 데이터베이스 ID를 손에 쥐고 나면, 이제 NotionDBLoader 코드를 사용하여 Notion 데이터베이스에서 콘텐츠와 메타데이터를 로드할 수 있습니다.

## 사용법
NotionDBLoader는 langchain 패키지의 문서 로더의 일부입니다. 다음과 같이 사용할 수 있습니다:

```python
from getpass import getpass

NOTION_TOKEN = getpass()
DATABASE_ID = getpass()
```

```output
········
········
```


```python
<!--IMPORTS:[{"imported": "NotionDBLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.notiondb.NotionDBLoader.html", "title": "Notion DB 2/2"}]-->
from langchain_community.document_loaders import NotionDBLoader
```


```python
loader = NotionDBLoader(
    integration_token=NOTION_TOKEN,
    database_id=DATABASE_ID,
    request_timeout_sec=30,  # optional, defaults to 10
)
```


```python
docs = loader.load()
```


```python
print(docs)
```

```output

```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)