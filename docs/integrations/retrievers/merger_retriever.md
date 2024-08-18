---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/merger_retriever.ipynb
description: '`Lord of the Retrievers (LOTR)`는 여러 검색기를 결합하여 쿼리에 대한 관련 문서 목록을 생성하고
  순위를 매기는 클래스입니다.'
---

# LOTR (병합 검색기)

> `검색기의 주인 (LOTR)` 또는 `병합 검색기 (MergerRetriever)`는 검색기 목록을 입력으로 받아 이들의 get_relevant_documents() 메서드 결과를 단일 목록으로 병합합니다. 병합된 결과는 쿼리와 관련된 문서 목록이며, 다양한 검색기에 의해 순위가 매겨집니다.

`병합 검색기 (MergerRetriever)` 클래스는 문서 검색의 정확성을 여러 가지 방법으로 향상시킬 수 있습니다. 첫째, 여러 검색기의 결과를 결합하여 결과의 편향 위험을 줄이는 데 도움을 줄 수 있습니다. 둘째, 다양한 검색기의 결과를 순위 매김하여 가장 관련성이 높은 문서가 먼저 반환되도록 할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ContextualCompressionRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.contextual_compression.ContextualCompressionRetriever.html", "title": "LOTR (Merger Retriever)"}, {"imported": "MergerRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.merger_retriever.MergerRetriever.html", "title": "LOTR (Merger Retriever)"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "LOTR (Merger Retriever)"}, {"imported": "EmbeddingsClusteringFilter", "source": "langchain_community.document_transformers", "docs": "https://api.python.langchain.com/en/latest/document_transformers/langchain_community.document_transformers.embeddings_redundant_filter.EmbeddingsClusteringFilter.html", "title": "LOTR (Merger Retriever)"}, {"imported": "EmbeddingsRedundantFilter", "source": "langchain_community.document_transformers", "docs": "https://api.python.langchain.com/en/latest/document_transformers/langchain_community.document_transformers.embeddings_redundant_filter.EmbeddingsRedundantFilter.html", "title": "LOTR (Merger Retriever)"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "LOTR (Merger Retriever)"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "LOTR (Merger Retriever)"}]-->
import os

import chromadb
from langchain.retrievers import (
    ContextualCompressionRetriever,
    DocumentCompressorPipeline,
    MergerRetriever,
)
from langchain_chroma import Chroma
from langchain_community.document_transformers import (
    EmbeddingsClusteringFilter,
    EmbeddingsRedundantFilter,
)
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_openai import OpenAIEmbeddings

# Get 3 diff embeddings.
all_mini = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
multi_qa_mini = HuggingFaceEmbeddings(model_name="multi-qa-MiniLM-L6-dot-v1")
filter_embeddings = OpenAIEmbeddings()

ABS_PATH = os.path.dirname(os.path.abspath(__file__))
DB_DIR = os.path.join(ABS_PATH, "db")

# Instantiate 2 diff chromadb indexes, each one with a diff embedding.
client_settings = chromadb.config.Settings(
    is_persistent=True,
    persist_directory=DB_DIR,
    anonymized_telemetry=False,
)
db_all = Chroma(
    collection_name="project_store_all",
    persist_directory=DB_DIR,
    client_settings=client_settings,
    embedding_function=all_mini,
)
db_multi_qa = Chroma(
    collection_name="project_store_multi",
    persist_directory=DB_DIR,
    client_settings=client_settings,
    embedding_function=multi_qa_mini,
)

# Define 2 diff retrievers with 2 diff embeddings and diff search type.
retriever_all = db_all.as_retriever(
    search_type="similarity", search_kwargs={"k": 5, "include_metadata": True}
)
retriever_multi_qa = db_multi_qa.as_retriever(
    search_type="mmr", search_kwargs={"k": 5, "include_metadata": True}
)

# The Lord of the Retrievers will hold the output of both retrievers and can be used as any other
# retriever on different types of chains.
lotr = MergerRetriever(retrievers=[retriever_all, retriever_multi_qa])
```


## 병합된 검색기에서 중복 결과 제거하기.

```python
# We can remove redundant results from both retrievers using yet another embedding.
# Using multiples embeddings in diff steps could help reduce biases.
filter = EmbeddingsRedundantFilter(embeddings=filter_embeddings)
pipeline = DocumentCompressorPipeline(transformers=[filter])
compression_retriever = ContextualCompressionRetriever(
    base_compressor=pipeline, base_retriever=lotr
)
```


## 병합된 검색기에서 문서의 대표 샘플 선택하기.

```python
# This filter will divide the documents vectors into clusters or "centers" of meaning.
# Then it will pick the closest document to that center for the final results.
# By default the result document will be ordered/grouped by clusters.
filter_ordered_cluster = EmbeddingsClusteringFilter(
    embeddings=filter_embeddings,
    num_clusters=10,
    num_closest=1,
)

# If you want the final document to be ordered by the original retriever scores
# you need to add the "sorted" parameter.
filter_ordered_by_retriever = EmbeddingsClusteringFilter(
    embeddings=filter_embeddings,
    num_clusters=10,
    num_closest=1,
    sorted=True,
)

pipeline = DocumentCompressorPipeline(transformers=[filter_ordered_by_retriever])
compression_retriever = ContextualCompressionRetriever(
    base_compressor=pipeline, base_retriever=lotr
)
```


## 성능 저하를 피하기 위해 결과 재정렬하기.
모델의 아키텍처와 관계없이, 10개 이상의 검색된 문서를 포함할 경우 상당한 성능 저하가 발생합니다.
간단히 말해: 모델이 긴 맥락 중간에 관련 정보를 액세스해야 할 때, 제공된 문서를 무시하는 경향이 있습니다.
참조: https://arxiv.org/abs//2307.03172

```python
<!--IMPORTS:[{"imported": "LongContextReorder", "source": "langchain_community.document_transformers", "docs": "https://api.python.langchain.com/en/latest/document_transformers/langchain_community.document_transformers.long_context_reorder.LongContextReorder.html", "title": "LOTR (Merger Retriever)"}]-->
# You can use an additional document transformer to reorder documents after removing redundancy.
from langchain_community.document_transformers import LongContextReorder

filter = EmbeddingsRedundantFilter(embeddings=filter_embeddings)
reordering = LongContextReorder()
pipeline = DocumentCompressorPipeline(transformers=[filter, reordering])
compression_retriever_reordered = ContextualCompressionRetriever(
    base_compressor=pipeline, base_retriever=lotr
)
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)