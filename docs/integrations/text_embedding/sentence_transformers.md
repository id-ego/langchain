---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/sentence_transformers.ipynb
description: Hugging Face의 sentence-transformers를 사용하여 최첨단 문장, 텍스트 및 이미지 임베딩을 생성하는
  방법을 안내합니다.
---

# 허깅 페이스의 문장 변환기

> [허깅 페이스 문장 변환기](https://huggingface.co/sentence-transformers)는 최첨단 문장, 텍스트 및 이미지 임베딩을 위한 파이썬 프레임워크입니다. 
`HuggingFaceEmbeddings` 클래스에서 이러한 임베딩 모델을 사용할 수 있습니다.

:::caution

로컬에서 문장 변환기를 실행하는 것은 운영 체제 및 기타 전역 요인의 영향을 받을 수 있습니다. 경험이 있는 사용자에게만 권장됩니다.

:::

## 설정

`langchain_huggingface` 패키지를 의존성으로 설치해야 합니다:

```python
%pip install -qU langchain-huggingface
```


## 사용법

```python
<!--IMPORTS:[{"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "Sentence Transformers on Hugging Face"}]-->
from langchain_huggingface import HuggingFaceEmbeddings

embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")

text = "This is a test document."
query_result = embeddings.embed_query(text)

# show only the first 100 characters of the stringified vector
print(str(query_result)[:100] + "...")
```

```output
[-0.038338568061590195, 0.12346471101045609, -0.028642969205975533, 0.05365273356437683, 0.008845377...
```


```python
doc_result = embeddings.embed_documents([text, "This is not a test document."])
print(str(doc_result)[:100] + "...")
```

```output
[[-0.038338497281074524, 0.12346471846103668, -0.028642890974879265, 0.05365274101495743, 0.00884535...
```


## 문제 해결

`accelerate` 패키지를 찾을 수 없거나 가져오기를 실패하는 문제가 발생하는 경우, 설치/업그레이드가 도움이 될 수 있습니다:

```python
%pip install -qU accelerate
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)