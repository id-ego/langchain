---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/blackboard.ipynb
description: 블랙보드 학습 관리 시스템에 대한 개요와 데이터 로딩 방법을 설명하는 문서입니다. 특정 블랙보드 과정과의 호환성에 대한 정보도
  포함되어 있습니다.
---

# 블랙보드

> [블랙보드 학습](https://en.wikipedia.org/wiki/Blackboard_Learn) (이전에는 블랙보드 학습 관리 시스템) 은 블랙보드 주식회사에서 개발한 웹 기반 가상 학습 환경 및 학습 관리 시스템입니다. 이 소프트웨어는 과정 관리, 사용자 정의 가능한 개방형 아키텍처 및 학생 정보 시스템 및 인증 프로토콜과의 통합을 허용하는 확장 가능한 디자인을 특징으로 합니다. 로컬 서버에 설치하거나 `Blackboard ASP Solutions`에서 호스팅하거나 Amazon Web Services에서 호스팅되는 서비스형 소프트웨어로 제공될 수 있습니다. 그 주요 목적은 전통적으로 대면으로 제공되는 과정에 온라인 요소를 추가하고 대면 회의가 거의 없거나 전혀 없는 완전 온라인 과정을 개발하는 것을 포함한다고 명시되어 있습니다.

이 문서는 [블랙보드 학습](https://www.anthology.com/products/teaching-and-learning/learning-effectiveness/blackboard-learn) 인스턴스에서 데이터를 로드하는 방법을 다룹니다.

이 로더는 모든 `블랙보드` 과정과 호환되지 않습니다. 새로운 `블랙보드` 인터페이스를 사용하는 과정과만 호환됩니다. 이 로더를 사용하려면 BbRouter 쿠키가 필요합니다. 이 쿠키는 과정에 로그인한 후 브라우저의 개발자 도구에서 BbRouter 쿠키의 값을 복사하여 얻을 수 있습니다.

```python
<!--IMPORTS:[{"imported": "BlackboardLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.blackboard.BlackboardLoader.html", "title": "Blackboard"}]-->
from langchain_community.document_loaders import BlackboardLoader

loader = BlackboardLoader(
    blackboard_course_url="https://blackboard.example.com/webapps/blackboard/execute/announcement?method=search&context=course_entry&course_id=_123456_1",
    bbrouter="expires:12345...",
    load_all_recursively=True,
)
documents = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)