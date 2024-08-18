---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/llamacpp.ipynb
description: '`llama.cpp`는 Python 바인딩을 제공하여 텍스트 완성, OpenAI 호환 웹 서버 및 다양한 모델을 지원하는
  라이브러리입니다.'
---

# Llama.cpp

> [llama.cpp python](https://github.com/abetlen/llama-cpp-python) 라이브러리는 `@ggerganov`의 [llama.cpp](https://github.com/ggerganov/llama.cpp)에 대한 간단한 Python 바인딩입니다.
> 
> 이 패키지는 다음을 제공합니다:
> 
> - ctypes 인터페이스를 통한 C API에 대한 저수준 접근.
> - 텍스트 완성을 위한 고수준 Python API
>   - `OpenAI`-유사 API
>   - `LangChain` 호환성
>   - `LlamaIndex` 호환성
> - OpenAI 호환 웹 서버
>   - 로컬 Copilot 대체
>   - 함수 호출 지원
>   - 비전 API 지원
>   - 여러 모델

```python
%pip install --upgrade --quiet  llama-cpp-python
```


```python
<!--IMPORTS:[{"imported": "LlamaCppEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.llamacpp.LlamaCppEmbeddings.html", "title": "Llama.cpp"}]-->
from langchain_community.embeddings import LlamaCppEmbeddings
```


```python
llama = LlamaCppEmbeddings(model_path="/path/to/model/ggml-model-q4_0.bin")
```


```python
text = "This is a test document."
```


```python
query_result = llama.embed_query(text)
```


```python
doc_result = llama.embed_documents([text])
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)