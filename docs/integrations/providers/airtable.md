---
description: Airtable은 스프레드시트와 데이터베이스의 기능을 결합한 클라우드 협업 서비스로, 다양한 데이터 유형을 지원합니다.
---

# Airtable

> [Airtable](https://en.wikipedia.org/wiki/Airtable)는 클라우드 협업 서비스입니다.
`Airtable`은 데이터베이스의 기능을 갖춘 스프레드시트-데이터베이스 하이브리드입니다.
Airtable 테이블의 필드는 스프레드시트의 셀과 유사하지만 '체크박스', '전화번호', '드롭다운 목록'과 같은 유형을 가지며 이미지와 같은 파일 첨부를 참조할 수 있습니다.

> 사용자는 데이터베이스를 생성하고, 열 유형을 설정하고, 레코드를 추가하고, 테이블을 서로 연결하고, 협업하고, 레코드를 정렬하며, 외부 웹사이트에 보기를 게시할 수 있습니다.

## 설치 및 설정

```bash
pip install pyairtable
```


* [API 키](https://support.airtable.com/docs/creating-and-using-api-keys-and-access-tokens)를 가져옵니다.
* [베이스의 ID](https://airtable.com/developers/web/api/introduction)를 가져옵니다.
* [테이블 URL에서 테이블 ID를 가져옵니다](https://www.highviewapps.com/kb/where-can-i-find-the-airtable-base-id-and-table-id/#:~:text=Both%20the%20Airtable%20Base%20ID,URL%20that%20begins%20with%20tbl).

## 문서 로더

```python
<!--IMPORTS:[{"imported": "AirtableLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.airtable.AirtableLoader.html", "title": "Airtable"}]-->
from langchain_community.document_loaders import AirtableLoader
```


[예제](https://docs/integrations/document_loaders/airtable)를 참조하세요.