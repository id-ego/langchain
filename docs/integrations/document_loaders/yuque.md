---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/yuque.ipynb
description: 이 문서는 팀 협업을 위한 클라우드 기반 지식 관리 도구인 Yuque에서 문서를 로드하는 방법을 다룹니다.
---

# Yuque

> [Yuque](https://www.yuque.com/)는 문서화에서 팀 협업을 위한 전문 클라우드 기반 지식 베이스입니다.

이 노트북은 `Yuque`에서 문서를 로드하는 방법을 다룹니다.

개인 설정 페이지의 [개인 설정](https://www.yuque.com/settings/tokens)에서 개인 아바타를 클릭하여 개인 액세스 토큰을 얻을 수 있습니다.

```python
<!--IMPORTS:[{"imported": "YuqueLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.yuque.YuqueLoader.html", "title": "Yuque"}]-->
from langchain_community.document_loaders import YuqueLoader
```


```python
loader = YuqueLoader(access_token="<your_personal_access_token>")
```


```python
docs = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)