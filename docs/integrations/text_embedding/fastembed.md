---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/fastembed.ipynb
description: FastEmbed는 Qdrant에서 제공하는 경량의 빠른 파이썬 라이브러리로, 임베딩 생성을 위한 효율적인 솔루션입니다.
---

# FastEmbed by Qdrant

> [FastEmbed](https://qdrant.github.io/fastembed/)는 [Qdrant](https://qdrant.tech)에서 제공하는 경량의 빠른 파이썬 라이브러리로, 임베딩 생성을 위해 만들어졌습니다.
> 
> - 양자화된 모델 가중치
> - ONNX 런타임, PyTorch 의존성 없음
> - CPU 우선 설계
> - 대규모 데이터셋 인코딩을 위한 데이터 병렬 처리.

## Dependencies

LangChain과 함께 FastEmbed를 사용하려면 `fastembed` 파이썬 패키지를 설치하세요.

```python
%pip install --upgrade --quiet  fastembed
```


## Imports

```python
<!--IMPORTS:[{"imported": "FastEmbedEmbeddings", "source": "langchain_community.embeddings.fastembed", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fastembed.FastEmbedEmbeddings.html", "title": "FastEmbed by Qdrant"}]-->
from langchain_community.embeddings.fastembed import FastEmbedEmbeddings
```


## Instantiating FastEmbed

### Parameters
- `model_name: str` (기본값: "BAAI/bge-small-en-v1.5")
  > 사용할 FastEmbedding 모델의 이름입니다. 지원되는 모델 목록은 [여기](https://qdrant.github.io/fastembed/examples/Supported_Models/)에서 확인할 수 있습니다.
- `max_length: int` (기본값: 512)
  > 최대 토큰 수입니다. 512를 초과하는 값에 대한 동작은 알 수 없습니다.
- `cache_dir: Optional[str]` (기본값: None)
  > 캐시 디렉토리의 경로입니다. 기본값은 상위 디렉토리의 `local_cache`입니다.
- `threads: Optional[int]` (기본값: None)
  > 단일 onnxruntime 세션이 사용할 수 있는 스레드 수입니다.
- `doc_embed_type: Literal["default", "passage"]` (기본값: "default")
  > "default": FastEmbed의 기본 임베딩 방법을 사용합니다.
  
  > "passage": 임베딩 전에 텍스트에 "passage"를 접두사로 추가합니다.
- `batch_size: int` (기본값: 256)
  > 인코딩을 위한 배치 크기입니다. 더 높은 값은 더 많은 메모리를 사용하지만 더 빠릅니다.
- `parallel: Optional[int]` (기본값: None)
  
  > `>1`인 경우 데이터 병렬 인코딩이 사용되며, 대규모 데이터셋의 오프라인 인코딩에 권장됩니다.
  `0`인 경우 모든 사용 가능한 코어를 사용합니다.
  `None`인 경우 데이터 병렬 처리를 사용하지 않고 기본 onnxruntime 스레딩을 대신 사용합니다.

```python
embeddings = FastEmbedEmbeddings()
```


## Usage

### Generating document embeddings

```python
document_embeddings = embeddings.embed_documents(
    ["This is a document", "This is some other document"]
)
```


### Generating query embeddings

```python
query_embeddings = embeddings.embed_query("This is a query")
```


## Related

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)