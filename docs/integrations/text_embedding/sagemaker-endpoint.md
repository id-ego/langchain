---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/sagemaker-endpoint.ipynb
description: SageMaker에서 Hugging Face 모델을 호스팅하고 배치 요청을 처리하는 방법에 대한 안내 및 코드 수정 사항을
  제공합니다.
---

# SageMaker

`SageMaker Endpoints Embeddings` 클래스를 로드해 보겠습니다. 이 클래스는 SageMaker에서 예를 들어, 자신의 Hugging Face 모델을 호스팅하는 경우 사용할 수 있습니다.

이 방법에 대한 지침은 [여기](https://www.philschmid.de/custom-inference-huggingface-sagemaker)를 참조하십시오.

**참고**: 배치 요청을 처리하려면, 사용자 정의 `inference.py` 스크립트 내의 `predict_fn()` 함수에서 반환 라인을 조정해야 합니다:

다음에서 변경:

`return {"vectors": sentence_embeddings[0].tolist()}`

다음으로:

`return {"vectors": sentence_embeddings.tolist()}`.

```python
!pip3 install langchain boto3
```


```python
<!--IMPORTS:[{"imported": "SagemakerEndpointEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.sagemaker_endpoint.SagemakerEndpointEmbeddings.html", "title": "SageMaker"}, {"imported": "EmbeddingsContentHandler", "source": "langchain_community.embeddings.sagemaker_endpoint", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.sagemaker_endpoint.EmbeddingsContentHandler.html", "title": "SageMaker"}]-->
import json
from typing import Dict, List

from langchain_community.embeddings import SagemakerEndpointEmbeddings
from langchain_community.embeddings.sagemaker_endpoint import EmbeddingsContentHandler


class ContentHandler(EmbeddingsContentHandler):
    content_type = "application/json"
    accepts = "application/json"

    def transform_input(self, inputs: list[str], model_kwargs: Dict) -> bytes:
        """
        Transforms the input into bytes that can be consumed by SageMaker endpoint.
        Args:
            inputs: List of input strings.
            model_kwargs: Additional keyword arguments to be passed to the endpoint.
        Returns:
            The transformed bytes input.
        """
        # Example: inference.py expects a JSON string with a "inputs" key:
        input_str = json.dumps({"inputs": inputs, **model_kwargs})
        return input_str.encode("utf-8")

    def transform_output(self, output: bytes) -> List[List[float]]:
        """
        Transforms the bytes output from the endpoint into a list of embeddings.
        Args:
            output: The bytes output from SageMaker endpoint.
        Returns:
            The transformed output - list of embeddings
        Note:
            The length of the outer list is the number of input strings.
            The length of the inner lists is the embedding dimension.
        """
        # Example: inference.py returns a JSON string with the list of
        # embeddings in a "vectors" key:
        response_json = json.loads(output.read().decode("utf-8"))
        return response_json["vectors"]


content_handler = ContentHandler()


embeddings = SagemakerEndpointEmbeddings(
    # credentials_profile_name="credentials-profile-name",
    endpoint_name="huggingface-pytorch-inference-2023-03-21-16-14-03-834",
    region_name="us-east-1",
    content_handler=content_handler,
)


# client = boto3.client(
#     "sagemaker-runtime",
#     region_name="us-west-2"
# )
# embeddings = SagemakerEndpointEmbeddings(
#     endpoint_name="huggingface-pytorch-inference-2023-03-21-16-14-03-834",
#     client=client
#     content_handler=content_handler,
# )
```


```python
query_result = embeddings.embed_query("foo")
```


```python
doc_results = embeddings.embed_documents(["foo"])
```


```python
doc_results
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)