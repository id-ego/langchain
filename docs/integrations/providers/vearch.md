---
description: Vearch는 딥러닝 벡터의 효율적인 유사성 검색을 위한 확장 가능한 분산 시스템입니다. Python SDK를 통해 쉽게 설치하고
  사용할 수 있습니다.
---

# Vearch

[Vearch](https://github.com/vearch/vearch)는 딥 러닝 벡터의 효율적인 유사성 검색을 위한 확장 가능한 분산 시스템입니다.

# 설치 및 설정

Vearch Python SDK는 Vearch를 로컬에서 사용할 수 있게 해줍니다. Vearch Python SDK는 `pip install vearch`로 쉽게 설치할 수 있습니다.

# 벡터 저장소

Vearch는 벡터 저장소로도 사용할 수 있습니다. 자세한 내용은 [이 노트북](/docs/integrations/vectorstores/vearch)을 참조하세요.

```python
<!--IMPORTS:[{"imported": "Vearch", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vearch.Vearch.html", "title": "Vearch"}]-->
from langchain_community.vectorstores import Vearch
```