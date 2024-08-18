---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_transformers/cross_encoder_reranker.ipynb
description: 이 문서는 Hugging Face의 크로스 인코더 모델을 사용하여 리트리버에서 리랭커를 구현하는 방법을 설명합니다.
---

# 크로스 인코더 리랭커

이 노트북은 [Hugging Face 크로스 인코더 모델](https://huggingface.co/cross-encoder) 또는 크로스 인코더 기능을 구현하는 Hugging Face 모델([예: BAAI/bge-reranker-base](https://huggingface.co/BAAI/bge-reranker-base))을 사용하여 리랭커를 구현하는 방법을 보여줍니다. `SagemakerEndpointCrossEncoder`를 사용하면 Sagemaker에 로드된 이러한 HuggingFace 모델을 사용할 수 있습니다.

이는 [ContextualCompressionRetriever](/docs/how_to/contextual_compression)의 아이디어를 기반으로 합니다. 이 문서의 전체 구조는 [Cohere Reranker 문서](/docs/integrations/retrievers/cohere-reranker)에서 가져왔습니다.

크로스 인코더가 더 나은 검색을 위해 임베딩과 함께 리랭킹 메커니즘으로 사용될 수 있는 이유에 대한 자세한 내용은 [Hugging Face Cross-Encoders 문서](https://www.sbert.net/examples/applications/cross-encoder/README.html)를 참조하십시오.

```python
#!pip install faiss sentence_transformers

# OR  (depending on Python version)

#!pip install faiss-cpu sentence_transformers
```


```python
# Helper function for printing docs


def pretty_print_docs(docs):
    print(
        f"\n{'-' * 100}\n".join(
            [f"Document {i+1}:\n\n" + d.page_content for i, d in enumerate(docs)]
        )
    )
```


## 기본 벡터 저장소 리트리버 설정
간단한 벡터 저장소 리트리버를 초기화하고 2023년 국정 연설을 (청크로) 저장하는 것으로 시작합시다. 리트리버를 설정하여 많은 수(20)의 문서를 검색할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Cross Encoder Reranker"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "Cross Encoder Reranker"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "Cross Encoder Reranker"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Cross Encoder Reranker"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

documents = TextLoader("../../how_to/state_of_the_union.txt").load()
text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=100)
texts = text_splitter.split_documents(documents)
embeddingsModel = HuggingFaceEmbeddings(
    model_name="sentence-transformers/msmarco-distilbert-dot-v5"
)
retriever = FAISS.from_documents(texts, embeddingsModel).as_retriever(
    search_kwargs={"k": 20}
)

query = "What is the plan for the economy?"
docs = retriever.invoke(query)
pretty_print_docs(docs)
```


## CrossEncoderReranker로 리랭킹 수행
이제 기본 리트리버를 `ContextualCompressionRetriever`로 감쌉니다. `CrossEncoderReranker`는 반환된 결과를 리랭크하기 위해 `HuggingFaceCrossEncoder`를 사용합니다.

```python
<!--IMPORTS:[{"imported": "ContextualCompressionRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.contextual_compression.ContextualCompressionRetriever.html", "title": "Cross Encoder Reranker"}, {"imported": "CrossEncoderReranker", "source": "langchain.retrievers.document_compressors", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.document_compressors.cross_encoder_rerank.CrossEncoderReranker.html", "title": "Cross Encoder Reranker"}, {"imported": "HuggingFaceCrossEncoder", "source": "langchain_community.cross_encoders", "docs": "https://api.python.langchain.com/en/latest/cross_encoders/langchain_community.cross_encoders.huggingface.HuggingFaceCrossEncoder.html", "title": "Cross Encoder Reranker"}]-->
from langchain.retrievers import ContextualCompressionRetriever
from langchain.retrievers.document_compressors import CrossEncoderReranker
from langchain_community.cross_encoders import HuggingFaceCrossEncoder

model = HuggingFaceCrossEncoder(model_name="BAAI/bge-reranker-base")
compressor = CrossEncoderReranker(model=model, top_n=3)
compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor, base_retriever=retriever
)

compressed_docs = compression_retriever.invoke("What is the plan for the economy?")
pretty_print_docs(compressed_docs)
```

```output
Document 1:

More infrastructure and innovation in America. 

More goods moving faster and cheaper in America. 

More jobs where you can earn a good living in America. 

And instead of relying on foreign supply chains, let’s make it in America. 

Economists call it “increasing the productive capacity of our economy.” 

I call it building a better America. 

My plan to fight inflation will lower your costs and lower the deficit.
----------------------------------------------------------------------------------------------------
Document 2:

Second – cut energy costs for families an average of $500 a year by combatting climate change.  

Let’s provide investments and tax credits to weatherize your homes and businesses to be energy efficient and you get a tax credit; double America’s clean energy production in solar, wind, and so much more;  lower the price of electric vehicles, saving you another $80 a month because you’ll never have to pay at the gas pump again.
----------------------------------------------------------------------------------------------------
Document 3:

Look at cars. 

Last year, there weren’t enough semiconductors to make all the cars that people wanted to buy. 

And guess what, prices of automobiles went up. 

So—we have a choice. 

One way to fight inflation is to drive down wages and make Americans poorer.  

I have a better plan to fight inflation. 

Lower your costs, not your wages. 

Make more cars and semiconductors in America. 

More infrastructure and innovation in America. 

More goods moving faster and cheaper in America.
```


## Hugging Face 모델을 SageMaker 엔드포인트에 업로드

다음은 `SagemakerEndpointCrossEncoder`와 함께 작동하는 엔드포인트를 생성하기 위한 샘플 `inference.py`입니다. 단계별 안내에 대한 자세한 내용은 [이 기사](https://huggingface.co/blog/kchoe/deploy-any-huggingface-model-to-sagemaker)를 참조하십시오.

이 코드는 Hugging Face 모델을 즉시 다운로드하므로 `pytorch_model.bin`과 같은 모델 아티팩트를 `model.tar.gz`에 보관할 필요가 없습니다.

```python
import json
import logging
from typing import List

import torch
from sagemaker_inference import encoder
from transformers import AutoModelForSequenceClassification, AutoTokenizer

PAIRS = "pairs"
SCORES = "scores"


class CrossEncoder:
    def __init__(self) -> None:
        self.device = (
            torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
        )
        logging.info(f"Using device: {self.device}")
        model_name = "BAAI/bge-reranker-base"
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForSequenceClassification.from_pretrained(model_name)
        self.model = self.model.to(self.device)

    def __call__(self, pairs: List[List[str]]) -> List[float]:
        with torch.inference_mode():
            inputs = self.tokenizer(
                pairs,
                padding=True,
                truncation=True,
                return_tensors="pt",
                max_length=512,
            )
            inputs = inputs.to(self.device)
            scores = (
                self.model(**inputs, return_dict=True)
                .logits.view(
                    -1,
                )
                .float()
            )

        return scores.detach().cpu().tolist()


def model_fn(model_dir: str) -> CrossEncoder:
    try:
        return CrossEncoder()
    except Exception:
        logging.exception(f"Failed to load model from: {model_dir}")
        raise


def transform_fn(
    cross_encoder: CrossEncoder, input_data: bytes, content_type: str, accept: str
) -> bytes:
    payload = json.loads(input_data)
    model_output = cross_encoder(**payload)
    output = {SCORES: model_output}
    return encoder.encode(output, accept)
```