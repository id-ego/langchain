---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/infinity.ipynb
description: 이 문서는 MIT 라이센스를 가진 Embedding Server를 사용하여 Langchain과 함께 Embeddings를 생성하는
  방법을 설명합니다.
---

# 인피니티

`Infinity`는 MIT 라이센스가 부여된 임베딩 서버를 사용하여 `Embeddings`를 생성할 수 있게 해줍니다.

이 노트북은 [Infinity Github Project](https://github.com/michaelfeil/infinity)와 함께 Langchain을 사용하여 임베딩을 사용하는 방법을 설명합니다.

## 임포트

```python
<!--IMPORTS:[{"imported": "InfinityEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.infinity.InfinityEmbeddings.html", "title": "Infinity"}, {"imported": "InfinityEmbeddingsLocal", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.infinity_local.InfinityEmbeddingsLocal.html", "title": "Infinity"}]-->
from langchain_community.embeddings import InfinityEmbeddings, InfinityEmbeddingsLocal
```


# 옵션 1: Python에서 인피니티 사용하기

#### 선택 사항: 인피니티 설치

인피니티를 설치하려면 다음 명령어를 사용하세요. 자세한 내용은 [Github 문서](https://github.com/michaelfeil/infinity)를 확인하세요.
torch 및 onnx 종속성을 설치하세요.

```bash
pip install infinity_emb[torch,optimum]
```


```python
documents = [
    "Baguette is a dish.",
    "Paris is the capital of France.",
    "numpy is a lib for linear algebra",
    "You escaped what I've escaped - You'd be in Paris getting fucked up too",
]
query = "Where is Paris?"
```


```python
embeddings = InfinityEmbeddingsLocal(
    model="sentence-transformers/all-MiniLM-L6-v2",
    # revision
    revision=None,
    # best to keep at 32
    batch_size=32,
    # for AMD/Nvidia GPUs via torch
    device="cuda",
    # warm up model before execution
)


async def embed():
    # TODO: This function is just to showcase that your call can run async.

    # important: use engine inside of `async with` statement to start/stop the batching engine.
    async with embeddings:
        # avoid closing and starting the engine often.
        # rather keep it running.
        # you may call `await embeddings.__aenter__()` and `__aexit__()
        # if you are sure when to manually start/stop execution` in a more granular way

        documents_embedded = await embeddings.aembed_documents(documents)
        query_result = await embeddings.aembed_query(query)
        print("embeddings created successful")
    return documents_embedded, query_result
```

```output
/home/michael/langchain/libs/langchain/.venv/lib/python3.10/site-packages/tqdm/auto.py:21: TqdmWarning: IProgress not found. Please update jupyter and ipywidgets. See https://ipywidgets.readthedocs.io/en/stable/user_install.html
  from .autonotebook import tqdm as notebook_tqdm
The BetterTransformer implementation does not support padding during training, as the fused kernels do not support attention masks. Beware that passing padded batched data during training may result in unexpected outputs. Please refer to https://huggingface.co/docs/optimum/bettertransformer/overview for more details.
/home/michael/langchain/libs/langchain/.venv/lib/python3.10/site-packages/optimum/bettertransformer/models/encoder_models.py:301: UserWarning: The PyTorch API of nested tensors is in prototype stage and will change in the near future. (Triggered internally at ../aten/src/ATen/NestedTensorImpl.cpp:177.)
  hidden_states = torch._nested_tensor_from_mask(hidden_states, ~attention_mask)
```


```python
# run the async code however you would like
# if you are in a jupyter notebook, you can use the following
documents_embedded, query_result = await embed()
```


```python
# (demo) compute similarity
import numpy as np

scores = np.array(documents_embedded) @ np.array(query_result).T
dict(zip(documents, scores))
```


# 옵션 2: 서버 실행 및 API를 통한 연결

#### 선택 사항: 인피니티 인스턴스를 시작해야 합니다.

인피니티를 설치하려면 다음 명령어를 사용하세요. 자세한 내용은 [Github 문서](https://github.com/michaelfeil/infinity)를 확인하세요.
```bash
pip install infinity_emb[all]
```


# 인피니티 패키지 설치
%pip install --upgrade --quiet  infinity_emb[all]

서버를 시작하세요 - Jupyter Notebook 내부가 아닌 별도의 터미널에서 수행하는 것이 가장 좋습니다.

```bash
model=sentence-transformers/all-MiniLM-L6-v2
port=7797
infinity_emb --port $port --model-name-or-path $model
```


또는 대안으로 도커를 사용할 수 있습니다:
```bash
model=sentence-transformers/all-MiniLM-L6-v2
port=7797
docker run -it --gpus all -p $port:$port michaelf34/infinity:latest --model-name-or-path $model --port $port
```


## 인피니티 인스턴스를 사용하여 문서 임베드하기

```python
documents = [
    "Baguette is a dish.",
    "Paris is the capital of France.",
    "numpy is a lib for linear algebra",
    "You escaped what I've escaped - You'd be in Paris getting fucked up too",
]
query = "Where is Paris?"
```


```python
#
infinity_api_url = "http://localhost:7797/v1"
# model is currently not validated.
embeddings = InfinityEmbeddings(
    model="sentence-transformers/all-MiniLM-L6-v2", infinity_api_url=infinity_api_url
)
try:
    documents_embedded = embeddings.embed_documents(documents)
    query_result = embeddings.embed_query(query)
    print("embeddings created successful")
except Exception as ex:
    print(
        "Make sure the infinity instance is running. Verify by clicking on "
        f"{infinity_api_url.replace('v1','docs')} Exception: {ex}. "
    )
```

```output
Make sure the infinity instance is running. Verify by clicking on http://localhost:7797/docs Exception: HTTPConnectionPool(host='localhost', port=7797): Max retries exceeded with url: /v1/embeddings (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f91c35dbd30>: Failed to establish a new connection: [Errno 111] Connection refused')).
```


```python
# (demo) compute similarity
import numpy as np

scores = np.array(documents_embedded) @ np.array(query_result).T
dict(zip(documents, scores))
```


```output
{'Baguette is a dish.': 0.31344215908661155,
 'Paris is the capital of France.': 0.8148670296896388,
 'numpy is a lib for linear algebra': 0.004429399861302009,
 "You escaped what I've escaped - You'd be in Paris getting fucked up too": 0.5088476180154582}
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)