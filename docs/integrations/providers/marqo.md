---
description: Marqo는 LangChain 내에서 텐서 검색 엔진을 활용하여 고속 검색과 비동기 데이터 업로드를 지원하는 혁신적인 솔루션입니다.
---

# Marqo

이 페이지는 LangChain 내에서 Marqo 생태계를 사용하는 방법을 다룹니다.

### **Marqo란 무엇인가요?**

Marqo는 메모리 내 HNSW 인덱스에 저장된 임베딩을 사용하여 최첨단 검색 속도를 달성하는 텐서 검색 엔진입니다. Marqo는 수억 개의 문서 인덱스에 수평 인덱스 샤딩으로 확장할 수 있으며 비동기 및 논블로킹 데이터 업로드 및 검색을 허용합니다. Marqo는 PyTorch, Huggingface, OpenAI 등에서 최신 머신 러닝 모델을 사용합니다. 미리 구성된 모델로 시작하거나 자신만의 모델을 가져올 수 있습니다. 내장된 ONNX 지원 및 변환은 CPU와 GPU 모두에서 더 빠른 추론과 더 높은 처리량을 가능하게 합니다.

Marqo는 자체 추론을 포함하므로 문서에 텍스트와 이미지가 혼합될 수 있으며, 다른 시스템의 데이터를 포함한 Marqo 인덱스를 LangChain 생태계로 가져올 때 임베딩의 호환성에 대해 걱정할 필요가 없습니다.

Marqo의 배포는 유연하며, 우리의 도커 이미지를 사용하여 직접 시작하거나 [관리형 클라우드 서비스에 대해 문의하세요!](https://www.marqo.ai/pricing)

우리의 도커 이미지를 사용하여 Marqo를 로컬에서 실행하려면, [시작하기 가이드를 참조하세요.](https://docs.marqo.ai/latest/)

## 설치 및 설정
- `pip install marqo`로 Python SDK를 설치하세요.

## 래퍼

### VectorStore

Marqo 인덱스를 감싸는 래퍼가 존재하여 벡터스토어 프레임워크 내에서 사용할 수 있습니다. Marqo는 임베딩 생성을 위한 다양한 모델 중에서 선택할 수 있게 해주며, 일부 전처리 구성을 노출합니다.

Marqo 벡터스토어는 문서에 이미지와 텍스트가 혼합된 기존 멀티모달 인덱스와도 작동할 수 있으며, 자세한 내용은 [우리 문서](https://docs.marqo.ai/latest/#multi-modal-and-cross-modal-search)를 참조하세요. 기존 멀티모달 인덱스로 Marqo 벡터스토어를 인스턴스화하면 langchain 벡터스토어의 `add_texts` 메서드를 통해 새로운 문서를 추가할 수 있는 기능이 비활성화됩니다.

이 벡터스토어를 가져오려면:
```python
<!--IMPORTS:[{"imported": "Marqo", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.marqo.Marqo.html", "title": "Marqo"}]-->
from langchain_community.vectorstores import Marqo
```


Marqo 래퍼와 그 고유한 기능에 대한 더 자세한 설명은 [이 노트북](/docs/integrations/vectorstores/marqo)을 참조하세요.