---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/contextual_compression.ipynb
description: 문서 검색 시 관련 정보를 압축하여 제공하는 방법을 설명하며, Contextual Compression Retriever의
  사용법을 안내합니다.
---

# 검색을 위한 맥락 압축 방법

검색의 한 가지 도전 과제는 일반적으로 문서 저장 시스템에 데이터를 삽입할 때 특정 쿼리를 알 수 없다는 것입니다. 이는 쿼리와 가장 관련성이 높은 정보가 많은 무관한 텍스트가 포함된 문서에 묻힐 수 있음을 의미합니다. 전체 문서를 애플리케이션을 통해 전달하면 더 비싼 LLM 호출과 더 나쁜 응답으로 이어질 수 있습니다.

맥락 압축은 이를 해결하기 위해 고안되었습니다. 아이디어는 간단합니다: 검색된 문서를 즉시 있는 그대로 반환하는 대신, 주어진 쿼리의 맥락을 사용하여 압축하여 관련 정보만 반환할 수 있습니다. 여기서 "압축"은 개별 문서의 내용을 압축하고 문서를 통째로 필터링하는 것을 모두 포함합니다.

Contextual Compression Retriever를 사용하려면 다음이 필요합니다:

- 기본 검색기
- 문서 압축기

Contextual Compression Retriever는 쿼리를 기본 검색기로 전달하고, 초기 문서를 가져와 문서 압축기를 통해 전달합니다. 문서 압축기는 문서 목록을 받아 문서의 내용을 줄이거나 문서를 아예 삭제하여 목록을 단축합니다.

## 시작하기

```python
# Helper function for printing docs


def pretty_print_docs(docs):
    print(
        f"\n{'-' * 100}\n".join(
            [f"Document {i+1}:\n\n" + d.page_content for i, d in enumerate(docs)]
        )
    )
```


## 기본 벡터 저장소 검색기 사용하기
간단한 벡터 저장소 검색기를 초기화하고 2023년 국정 연설을 (조각으로) 저장하는 것부터 시작하겠습니다. 예시 질문을 주면 검색기가 하나 또는 두 개의 관련 문서와 몇 개의 무관한 문서를 반환하는 것을 볼 수 있습니다. 심지어 관련 문서에도 많은 무관한 정보가 포함되어 있습니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "How to do retrieval with contextual compression"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to do retrieval with contextual compression"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to do retrieval with contextual compression"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "How to do retrieval with contextual compression"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

documents = TextLoader("state_of_the_union.txt").load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_documents(documents)
retriever = FAISS.from_documents(texts, OpenAIEmbeddings()).as_retriever()

docs = retriever.invoke("What did the president say about Ketanji Brown Jackson")
pretty_print_docs(docs)
```

```output
Document 1:

Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
----------------------------------------------------------------------------------------------------
Document 2:

A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. 

We can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  

We’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  

We’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. 

We’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.
----------------------------------------------------------------------------------------------------
Document 3:

And for our LGBTQ+ Americans, let’s finally get the bipartisan Equality Act to my desk. The onslaught of state laws targeting transgender Americans and their families is wrong. 

As I said last year, especially to our younger transgender Americans, I will always have your back as your President, so you can be yourself and reach your God-given potential. 

While it often appears that we never agree, that isn’t true. I signed 80 bipartisan bills into law last year. From preventing government shutdowns to protecting Asian-Americans from still-too-common hate crimes to reforming military justice. 

And soon, we’ll strengthen the Violence Against Women Act that I first wrote three decades ago. It is important for us to show the nation that we can come together and do big things. 

So tonight I’m offering a Unity Agenda for the Nation. Four big things we can do together.  

First, beat the opioid epidemic.
----------------------------------------------------------------------------------------------------
Document 4:

Tonight, I’m announcing a crackdown on these companies overcharging American businesses and consumers. 

And as Wall Street firms take over more nursing homes, quality in those homes has gone down and costs have gone up.  

That ends on my watch. 

Medicare is going to set higher standards for nursing homes and make sure your loved ones get the care they deserve and expect. 

We’ll also cut costs and keep the economy going strong by giving workers a fair shot, provide more training and apprenticeships, hire them based on their skills not degrees. 

Let’s pass the Paycheck Fairness Act and paid leave.  

Raise the minimum wage to $15 an hour and extend the Child Tax Credit, so no one has to raise a family in poverty. 

Let’s increase Pell Grants and increase our historic support of HBCUs, and invest in what Jill—our First Lady who teaches full-time—calls America’s best-kept secret: community colleges.
```

## `LLMChainExtractor`로 맥락 압축 추가하기
이제 기본 검색기를 `ContextualCompressionRetriever`로 감싸겠습니다. 초기 반환된 문서들을 반복하고 각 문서에서 쿼리와 관련된 내용만 추출하는 `LLMChainExtractor`를 추가할 것입니다.

```python
<!--IMPORTS:[{"imported": "ContextualCompressionRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.contextual_compression.ContextualCompressionRetriever.html", "title": "How to do retrieval with contextual compression"}, {"imported": "LLMChainExtractor", "source": "langchain.retrievers.document_compressors", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.document_compressors.chain_extract.LLMChainExtractor.html", "title": "How to do retrieval with contextual compression"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "How to do retrieval with contextual compression"}]-->
from langchain.retrievers import ContextualCompressionRetriever
from langchain.retrievers.document_compressors import LLMChainExtractor
from langchain_openai import OpenAI

llm = OpenAI(temperature=0)
compressor = LLMChainExtractor.from_llm(llm)
compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor, base_retriever=retriever
)

compressed_docs = compression_retriever.invoke(
    "What did the president say about Ketanji Jackson Brown"
)
pretty_print_docs(compressed_docs)
```

```output
Document 1:

I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson.
```

## 더 많은 내장 압축기: 필터
### `LLMChainFilter`
`LLMChainFilter`는 약간 더 간단하지만 더 강력한 압축기로, LLM 체인을 사용하여 초기 검색된 문서 중 어떤 것을 필터링할지, 어떤 것을 반환할지를 결정합니다. 문서 내용을 조작하지 않습니다.

```python
<!--IMPORTS:[{"imported": "LLMChainFilter", "source": "langchain.retrievers.document_compressors", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.document_compressors.chain_filter.LLMChainFilter.html", "title": "How to do retrieval with contextual compression"}]-->
from langchain.retrievers.document_compressors import LLMChainFilter

_filter = LLMChainFilter.from_llm(llm)
compression_retriever = ContextualCompressionRetriever(
    base_compressor=_filter, base_retriever=retriever
)

compressed_docs = compression_retriever.invoke(
    "What did the president say about Ketanji Jackson Brown"
)
pretty_print_docs(compressed_docs)
```

```output
Document 1:

Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

### `LLMListwiseRerank`

[LLMListwiseRerank](https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.document_compressors.listwise_rerank.LLMListwiseRerank.html)는 [제로샷 리스트 문서 재순위](https://arxiv.org/pdf/2305.02156)를 사용하며, `LLMChainFilter`와 유사하게 작동하는 강력하지만 더 비싼 옵션입니다. 더 강력한 LLM을 사용하는 것이 권장됩니다.

`LLMListwiseRerank`는 [with_structured_output](/docs/integrations/chat/) 메서드가 구현된 모델이 필요합니다.

```python
<!--IMPORTS:[{"imported": "LLMListwiseRerank", "source": "langchain.retrievers.document_compressors", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.document_compressors.listwise_rerank.LLMListwiseRerank.html", "title": "How to do retrieval with contextual compression"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to do retrieval with contextual compression"}]-->
from langchain.retrievers.document_compressors import LLMListwiseRerank
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)

_filter = LLMListwiseRerank.from_llm(llm, top_n=1)
compression_retriever = ContextualCompressionRetriever(
    base_compressor=_filter, base_retriever=retriever
)

compressed_docs = compression_retriever.invoke(
    "What did the president say about Ketanji Jackson Brown"
)
pretty_print_docs(compressed_docs)
```

```output
Document 1:

Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

### `EmbeddingsFilter`

각 검색된 문서에 대해 추가 LLM 호출을 하는 것은 비싸고 느립니다. `EmbeddingsFilter`는 문서와 쿼리를 임베딩하고 쿼리와 충분히 유사한 임베딩을 가진 문서만 반환함으로써 더 저렴하고 빠른 옵션을 제공합니다.

```python
<!--IMPORTS:[{"imported": "EmbeddingsFilter", "source": "langchain.retrievers.document_compressors", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.document_compressors.embeddings_filter.EmbeddingsFilter.html", "title": "How to do retrieval with contextual compression"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to do retrieval with contextual compression"}]-->
from langchain.retrievers.document_compressors import EmbeddingsFilter
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()
embeddings_filter = EmbeddingsFilter(embeddings=embeddings, similarity_threshold=0.76)
compression_retriever = ContextualCompressionRetriever(
    base_compressor=embeddings_filter, base_retriever=retriever
)

compressed_docs = compression_retriever.invoke(
    "What did the president say about Ketanji Jackson Brown"
)
pretty_print_docs(compressed_docs)
```

```output
Document 1:

Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
----------------------------------------------------------------------------------------------------
Document 2:

A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. 

We can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  

We’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  

We’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. 

We’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.
```

## 압축기와 문서 변환기를 함께 연결하기
`DocumentCompressorPipeline`을 사용하면 여러 압축기를 순차적으로 쉽게 결합할 수 있습니다. 압축기와 함께 `BaseDocumentTransformer`를 파이프라인에 추가할 수 있으며, 이는 맥락 압축을 수행하지 않고 단순히 문서 집합에 대한 변환을 수행합니다. 예를 들어 `TextSplitter`는 문서를 더 작은 조각으로 나누는 문서 변환기로 사용할 수 있으며, `EmbeddingsRedundantFilter`는 문서 간의 임베딩 유사성을 기반으로 중복 문서를 필터링하는 데 사용할 수 있습니다.

아래에서는 먼저 문서를 더 작은 조각으로 나눈 후, 중복 문서를 제거하고, 쿼리와의 관련성을 기반으로 필터링하여 압축기 파이프라인을 생성합니다.

```python
<!--IMPORTS:[{"imported": "DocumentCompressorPipeline", "source": "langchain.retrievers.document_compressors", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.document_compressors.base.DocumentCompressorPipeline.html", "title": "How to do retrieval with contextual compression"}, {"imported": "EmbeddingsRedundantFilter", "source": "langchain_community.document_transformers", "docs": "https://api.python.langchain.com/en/latest/document_transformers/langchain_community.document_transformers.embeddings_redundant_filter.EmbeddingsRedundantFilter.html", "title": "How to do retrieval with contextual compression"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "How to do retrieval with contextual compression"}]-->
from langchain.retrievers.document_compressors import DocumentCompressorPipeline
from langchain_community.document_transformers import EmbeddingsRedundantFilter
from langchain_text_splitters import CharacterTextSplitter

splitter = CharacterTextSplitter(chunk_size=300, chunk_overlap=0, separator=". ")
redundant_filter = EmbeddingsRedundantFilter(embeddings=embeddings)
relevant_filter = EmbeddingsFilter(embeddings=embeddings, similarity_threshold=0.76)
pipeline_compressor = DocumentCompressorPipeline(
    transformers=[splitter, redundant_filter, relevant_filter]
)
```


```python
compression_retriever = ContextualCompressionRetriever(
    base_compressor=pipeline_compressor, base_retriever=retriever
)

compressed_docs = compression_retriever.invoke(
    "What did the president say about Ketanji Jackson Brown"
)
pretty_print_docs(compressed_docs)
```

```output
Document 1:

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson
----------------------------------------------------------------------------------------------------
Document 2:

As I said last year, especially to our younger transgender Americans, I will always have your back as your President, so you can be yourself and reach your God-given potential. 

While it often appears that we never agree, that isn’t true. I signed 80 bipartisan bills into law last year
----------------------------------------------------------------------------------------------------
Document 3:

A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder
----------------------------------------------------------------------------------------------------
Document 4:

Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. 

We can do both
```