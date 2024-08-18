---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/thirdai_neuraldb.ipynb
description: NeuralDB는 ThirdAI에서 개발한 CPU 친화적이고 세밀하게 조정 가능한 검색 엔진입니다. 다양한 초기화 방법과 문서
  검색 기능을 제공합니다.
---

# **NeuralDB**
NeuralDB는 ThirdAI에서 개발한 CPU 친화적이고 세밀하게 조정 가능한 검색 엔진입니다.

### **초기화**
초기화 방법은 두 가지가 있습니다:
- 처음부터: 기본 모델
- 체크포인트에서: 이전에 저장된 모델 로드

다음의 모든 초기화 방법에 대해 `thirdai_key` 매개변수는 `THIRDAI_KEY` 환경 변수가 설정되어 있으면 생략할 수 있습니다.

ThirdAI API 키는 https://www.thirdai.com/try-bolt/ 에서 얻을 수 있습니다.

```python
<!--IMPORTS:[{"imported": "NeuralDBRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.thirdai_neuraldb.NeuralDBRetriever.html", "title": "**NeuralDB**"}]-->
from langchain_community.retrievers import NeuralDBRetriever

# From scratch
retriever = NeuralDBRetriever.from_scratch(thirdai_key="your-thirdai-key")

# From checkpoint
retriever = NeuralDBRetriever.from_checkpoint(
    # Path to a NeuralDB checkpoint. For example, if you call
    # retriever.save("/path/to/checkpoint.ndb") in one script, then you can
    # call NeuralDBRetriever.from_checkpoint("/path/to/checkpoint.ndb") in
    # another script to load the saved model.
    checkpoint="/path/to/checkpoint.ndb",
    thirdai_key="your-thirdai-key",
)
```


### **문서 소스 삽입**

```python
retriever.insert(
    # If you have PDF, DOCX, or CSV files, you can directly pass the paths to the documents
    sources=["/path/to/doc.pdf", "/path/to/doc.docx", "/path/to/doc.csv"],
    # When True this means that the underlying model in the NeuralDB will
    # undergo unsupervised pretraining on the inserted files. Defaults to True.
    train=True,
    # Much faster insertion with a slight drop in performance. Defaults to True.
    fast_mode=True,
)

from thirdai import neural_db as ndb

retriever.insert(
    # If you have files in other formats, or prefer to configure how
    # your files are parsed, then you can pass in NeuralDB document objects
    # like this.
    sources=[
        ndb.PDF(
            "/path/to/doc.pdf",
            version="v2",
            chunk_size=100,
            metadata={"published": 2022},
        ),
        ndb.Unstructured("/path/to/deck.pptx"),
    ]
)
```


### **문서 검색**
검색기를 쿼리하려면 표준 LangChain 검색기 메서드 `get_relevant_documents`를 사용할 수 있으며, 이 메서드는 LangChain 문서 객체의 목록을 반환합니다. 각 문서 객체는 인덱싱된 파일에서 텍스트 조각을 나타냅니다. 예를 들어, 인덱싱된 PDF 파일 중 하나의 단락을 포함할 수 있습니다. 텍스트 외에도 문서의 메타데이터 필드는 문서의 ID, 이 문서의 출처(어떤 파일에서 왔는지), 문서의 점수와 같은 정보를 포함합니다.

```python
# This returns a list of LangChain Document objects
documents = retriever.invoke("query", top_k=10)
```


### **세밀 조정**
NeuralDBRetriever는 사용자 행동 및 도메인 특정 지식에 맞게 세밀하게 조정할 수 있습니다. 두 가지 방법으로 세밀 조정할 수 있습니다:
1. 연관: 검색기는 소스 구문을 대상 구문과 연관시킵니다. 검색기가 소스 구문을 볼 때, 대상 구문과 관련된 결과도 고려합니다.
2. 업보팅: 검색기는 특정 쿼리에 대해 문서의 점수를 높입니다. 이는 검색기를 사용자 행동에 맞게 세밀하게 조정할 때 유용합니다. 예를 들어, 사용자가 "자동차는 어떻게 제조되나요"를 검색하고 ID가 52인 반환된 문서를 좋아하는 경우, "자동차는 어떻게 제조되나요" 쿼리에 대해 ID가 52인 문서를 업보팅할 수 있습니다.

```python
retriever.associate(source="source phrase", target="target phrase")
retriever.associate_batch(
    [
        ("source phrase 1", "target phrase 1"),
        ("source phrase 2", "target phrase 2"),
    ]
)

retriever.upvote(query="how is a car manufactured", document_id=52)
retriever.upvote_batch(
    [
        ("query 1", 52),
        ("query 2", 20),
    ]
)
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)