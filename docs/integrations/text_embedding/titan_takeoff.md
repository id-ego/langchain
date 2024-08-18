---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/titan_takeoff.ipynb
description: TitanML은 NLP 모델을 더 작고 저렴하며 빠르게 구축하고 배포할 수 있도록 돕는 플랫폼입니다. Titan Takeoff로
  LLM을 쉽게 배포하세요.
---

# 타이탄 이륙

`TitanML`은 훈련, 압축 및 추론 최적화 플랫폼을 통해 기업이 더 나은, 더 작고, 더 저렴하며, 더 빠른 NLP 모델을 구축하고 배포할 수 있도록 돕습니다.

우리의 추론 서버인 [타이탄 이륙](https://docs.titanml.co/docs/intro)은 단일 명령으로 하드웨어에서 LLM을 로컬로 배포할 수 있게 해줍니다. 대부분의 임베딩 모델은 기본적으로 지원되며, 특정 모델에 문제가 발생하면 hello@titanml.co로 알려주십시오.

## 사용 예시
타이탄 이륙 서버를 사용하기 시작하는 데 도움이 되는 몇 가지 유용한 예시입니다. 이러한 명령을 실행하기 전에 이륙 서버가 백그라운드에서 시작되었는지 확인해야 합니다. 자세한 내용은 [이륙 시작을 위한 문서 페이지](https://docs.titanml.co/docs/Docs/launching/)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "TitanTakeoffEmbed", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.titan_takeoff.TitanTakeoffEmbed.html", "title": "Titan Takeoff"}]-->
import time

from langchain_community.embeddings import TitanTakeoffEmbed
```


### 예시 1
기본 사용법은 이륙이 기본 포트(예: localhost:3000)에서 실행되고 있다고 가정합니다.

```python
embed = TitanTakeoffEmbed()
output = embed.embed_query(
    "What is the weather in London in August?", consumer_group="embed"
)
print(output)
```


### 예시 2
TitanTakeoffEmbed Python Wrapper를 사용하여 리더를 시작합니다. 이륙을 처음 실행하여 리더를 생성하지 않았거나 다른 리더를 추가하고 싶다면 TitanTakeoffEmbed 객체를 초기화할 때 그렇게 할 수 있습니다. 시작할 모델의 목록을 `models` 매개변수로 전달하기만 하면 됩니다.

`embed.query_documents`를 사용하여 여러 문서를 한 번에 임베딩할 수 있습니다. 예상 입력은 `embed_query` 메서드에 대해 기대되는 단일 문자열이 아닌 문자열 목록입니다.

```python
# Model config for the embedding model, where you can specify the following parameters:
#   model_name (str): The name of the model to use
#   device: (str): The device to use for inference, cuda or cpu
#   consumer_group (str): The consumer group to place the reader into
embedding_model = {
    "model_name": "BAAI/bge-large-en-v1.5",
    "device": "cpu",
    "consumer_group": "embed",
}
embed = TitanTakeoffEmbed(models=[embedding_model])

# The model needs time to spin up, length of time need will depend on the size of model and your network connection speed
time.sleep(60)

prompt = "What is the capital of France?"
# We specified "embed" consumer group so need to send request to the same consumer group so it hits our embedding model and not others
output = embed.embed_query(prompt, consumer_group="embed")
print(output)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)