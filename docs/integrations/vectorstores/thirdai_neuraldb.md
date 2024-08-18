---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/thirdai_neuraldb.ipynb
description: ThirdAI NeuralDB는 CPU 친화적이고 세밀하게 조정 가능한 벡터 저장소로, 간편한 초기화 및 유사성 검색 기능을
  제공합니다.
---

# ThirdAI NeuralDB

> [NeuralDB](https://www.thirdai.com/neuraldb-enterprise/)는 [ThirdAI](https://www.thirdai.com/)에서 개발한 CPU 친화적이고 세밀하게 조정 가능한 벡터 저장소입니다.

## 초기화

초기화 방법은 두 가지가 있습니다:
- 처음부터: 기본 모델
- 체크포인트에서: 이전에 저장된 모델 로드

다음의 모든 초기화 방법에 대해, `THIRDAI_KEY` 환경 변수가 설정되어 있으면 `thirdai_key` 매개변수를 생략할 수 있습니다.

ThirdAI API 키는 https://www.thirdai.com/try-bolt/에서 얻을 수 있습니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

```python
<!--IMPORTS:[{"imported": "NeuralDBVectorStore", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.thirdai_neuraldb.NeuralDBVectorStore.html", "title": "ThirdAI NeuralDB"}]-->
from langchain_community.vectorstores import NeuralDBVectorStore

# From scratch
vectorstore = NeuralDBVectorStore.from_scratch(thirdai_key="your-thirdai-key")

# From checkpoint
vectorstore = NeuralDBVectorStore.from_checkpoint(
    # Path to a NeuralDB checkpoint. For example, if you call
    # vectorstore.save("/path/to/checkpoint.ndb") in one script, then you can
    # call NeuralDBVectorStore.from_checkpoint("/path/to/checkpoint.ndb") in
    # another script to load the saved model.
    checkpoint="/path/to/checkpoint.ndb",
    thirdai_key="your-thirdai-key",
)
```


## 문서 소스 삽입

```python
vectorstore.insert(
    # If you have PDF, DOCX, or CSV files, you can directly pass the paths to the documents
    sources=["/path/to/doc.pdf", "/path/to/doc.docx", "/path/to/doc.csv"],
    # When True this means that the underlying model in the NeuralDB will
    # undergo unsupervised pretraining on the inserted files. Defaults to True.
    train=True,
    # Much faster insertion with a slight drop in performance. Defaults to True.
    fast_mode=True,
)

from thirdai import neural_db as ndb

vectorstore.insert(
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


## 유사성 검색

벡터 저장소를 쿼리하려면 표준 LangChain 벡터 저장소 메서드인 `similarity_search`를 사용할 수 있으며, 이는 LangChain 문서 객체의 목록을 반환합니다. 각 문서 객체는 인덱싱된 파일에서 텍스트의 조각을 나타냅니다. 예를 들어, 인덱싱된 PDF 파일 중 하나의 단락을 포함할 수 있습니다. 텍스트 외에도 문서의 메타데이터 필드는 문서의 ID, 이 문서의 출처(어떤 파일에서 왔는지) 및 문서의 점수와 같은 정보를 포함합니다.

```python
# This returns a list of LangChain Document objects
documents = vectorstore.similarity_search("query", k=10)
```


## 세밀 조정

NeuralDBVectorStore는 사용자 행동 및 도메인 특정 지식에 맞게 세밀하게 조정할 수 있습니다. 두 가지 방법으로 세밀 조정할 수 있습니다:
1. 연관: 벡터 저장소가 소스 문구를 대상 문구와 연관시킵니다. 벡터 저장소가 소스 문구를 볼 때, 대상 문구와 관련된 결과도 고려합니다.
2. 업보팅: 벡터 저장소가 특정 쿼리에 대해 문서의 점수를 높입니다. 이는 사용자의 행동에 맞게 벡터 저장소를 세밀 조정할 때 유용합니다. 예를 들어, 사용자가 "자동차는 어떻게 제조되나요"를 검색하고 ID가 52인 반환된 문서를 좋아하면, "자동차는 어떻게 제조되나요" 쿼리에 대해 ID가 52인 문서를 업보팅할 수 있습니다.

```python
vectorstore.associate(source="source phrase", target="target phrase")
vectorstore.associate_batch(
    [
        ("source phrase 1", "target phrase 1"),
        ("source phrase 2", "target phrase 2"),
    ]
)

vectorstore.upvote(query="how is a car manufactured", document_id=52)
vectorstore.upvote_batch(
    [
        ("query 1", 52),
        ("query 2", 20),
    ]
)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)