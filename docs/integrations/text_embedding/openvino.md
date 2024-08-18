---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/openvino.ipynb
description: OpenVINO는 AI 추론 최적화 및 배포를 위한 오픈 소스 툴킷으로, 다양한 하드웨어에서 성능을 향상시킵니다.
---

# OpenVINO
[OpenVINO™](https://github.com/openvinotoolkit/openvino)는 AI 추론을 최적화하고 배포하기 위한 오픈 소스 툴킷입니다. OpenVINO™ 런타임은 x86 및 ARM CPU, Intel GPU를 포함한 다양한 하드웨어 [장치](https://github.com/openvinotoolkit/openvino?tab=readme-ov-file#supported-hardware-matrix)를 지원합니다. 이는 컴퓨터 비전, 자동 음성 인식, 자연어 처리 및 기타 일반적인 작업에서 딥 러닝 성능을 향상시키는 데 도움을 줄 수 있습니다.

Hugging Face 임베딩 모델은 `OpenVINOEmbeddings` 클래스를 통해 OpenVINO에서 지원될 수 있습니다. Intel GPU가 있는 경우 `model_kwargs={"device": "GPU"}`를 지정하여 추론을 실행할 수 있습니다.

```python
%pip install --upgrade-strategy eager "optimum[openvino,nncf]" --quiet
```

```output
Note: you may need to restart the kernel to use updated packages.
```


```python
<!--IMPORTS:[{"imported": "OpenVINOEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.openvino.OpenVINOEmbeddings.html", "title": "OpenVINO"}]-->
from langchain_community.embeddings import OpenVINOEmbeddings
```


```python
model_name = "sentence-transformers/all-mpnet-base-v2"
model_kwargs = {"device": "CPU"}
encode_kwargs = {"mean_pooling": True, "normalize_embeddings": True}

ov_embeddings = OpenVINOEmbeddings(
    model_name_or_path=model_name,
    model_kwargs=model_kwargs,
    encode_kwargs=encode_kwargs,
)
```


```python
text = "This is a test document."
```


```python
query_result = ov_embeddings.embed_query(text)
```


```python
query_result[:3]
```


```output
[-0.048951778560876846, -0.03986183926463127, -0.02156277745962143]
```


```python
doc_result = ov_embeddings.embed_documents([text])
```


## IR 모델 내보내기
`OVModelForFeatureExtraction`을 사용하여 임베딩 모델을 OpenVINO IR 형식으로 내보내고 로컬 폴더에서 모델을 로드할 수 있습니다.

```python
from pathlib import Path

ov_model_dir = "all-mpnet-base-v2-ov"
if not Path(ov_model_dir).exists():
    ov_embeddings.save_model(ov_model_dir)
```


```python
ov_embeddings = OpenVINOEmbeddings(
    model_name_or_path=ov_model_dir,
    model_kwargs=model_kwargs,
    encode_kwargs=encode_kwargs,
)
```

```output
Compiling the model to CPU ...
```

## OpenVINO와 BGE
OpenVINO를 사용하여 `OpenVINOBgeEmbeddings` 클래스를 통해 BGE 임베딩 모델에 접근할 수도 있습니다.

```python
<!--IMPORTS:[{"imported": "OpenVINOBgeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.openvino.OpenVINOBgeEmbeddings.html", "title": "OpenVINO"}]-->
from langchain_community.embeddings import OpenVINOBgeEmbeddings

model_name = "BAAI/bge-small-en"
model_kwargs = {"device": "CPU"}
encode_kwargs = {"normalize_embeddings": True}
ov_embeddings = OpenVINOBgeEmbeddings(
    model_name_or_path=model_name,
    model_kwargs=model_kwargs,
    encode_kwargs=encode_kwargs,
)
```


```python
embedding = ov_embeddings.embed_query("hi this is harrison")
len(embedding)
```


```output
384
```


자세한 내용은 다음을 참조하십시오:

* [OpenVINO LLM 가이드](https://docs.openvino.ai/2024/learn-openvino/llm_inference_guide.html).
* [OpenVINO 문서](https://docs.openvino.ai/2024/home.html).
* [OpenVINO 시작 가이드](https://www.intel.com/content/www/us/en/content-details/819067/openvino-get-started-guide.html).
* [LangChain과 함께하는 RAG 노트북](https://github.com/openvinotoolkit/openvino_notebooks/tree/latest/notebooks/llm-rag-langchain).

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)