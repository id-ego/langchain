---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/laser.ipynb
description: LASER는 Meta AI 연구팀이 개발한 다국어 문장 임베딩 라이브러리로, 147개 언어를 지원합니다. LangChain과
  함께 사용할 수 있습니다.
---

# LASER 언어 비독립 문장 표현 임베딩 by Meta AI

> [LASER](https://github.com/facebookresearch/LASER/)는 Meta AI 연구 팀이 개발한 파이썬 라이브러리로, 2024년 2월 25일 기준으로 147개 이상의 언어에 대한 다국어 문장 임베딩을 생성하는 데 사용됩니다.
> - 지원되는 언어 목록은 https://github.com/facebookresearch/flores/blob/main/flores200/README.md#languages-in-flores-200 에서 확인할 수 있습니다.

## 의존성

LangChain과 함께 LaserEmbed를 사용하려면 `laser_encoders` 파이썬 패키지를 설치하십시오.

```python
%pip install laser_encoders
```


## 임포트

```python
<!--IMPORTS:[{"imported": "LaserEmbeddings", "source": "langchain_community.embeddings.laser", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.laser.LaserEmbeddings.html", "title": "LASER Language-Agnostic SEntence Representations Embeddings by Meta AI"}]-->
from langchain_community.embeddings.laser import LaserEmbeddings
```


## Laser 인스턴스화

### 매개변수
- `lang: Optional[str]`
  > 비어 있으면 다국어 LASER 인코더 모델("laser2")을 기본값으로 사용합니다.
지원되는 언어 및 lang_codes 목록은 [여기](https://github.com/facebookresearch/flores/blob/main/flores200/README.md#languages-in-flores-200)와 [여기](https://github.com/facebookresearch/LASER/blob/main/laser_encoders/language_list.py)에서 확인할 수 있습니다.

```python
# Ex Instantiationz
embeddings = LaserEmbeddings(lang="eng_Latn")
```


## 사용법

### 문서 임베딩 생성

```python
document_embeddings = embeddings.embed_documents(
    ["This is a sentence", "This is some other sentence"]
)
```


### 쿼리 임베딩 생성

```python
query_embeddings = embeddings.embed_query("This is a query")
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)