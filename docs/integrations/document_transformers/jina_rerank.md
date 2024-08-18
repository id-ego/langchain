---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_transformers/jina_rerank.ipynb
description: 이 문서는 Jina Reranker를 사용하여 문서 압축 및 검색을 수행하는 방법을 보여줍니다. 다양한 코드 예제와 설정 방법이
  포함되어 있습니다.
---

# 지나 리랭커

이 노트북은 문서 압축 및 검색을 위해 지나 리랭커를 사용하는 방법을 보여줍니다.

```python
%pip install -qU langchain langchain-openai langchain-community langchain-text-splitters langchainhub

%pip install --upgrade --quiet  faiss

# OR  (depending on Python version)

%pip install --upgrade --quiet  faiss_cpu
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


## 기본 벡터 저장소 검색기 설정

간단한 벡터 저장소 검색기를 초기화하고 2023년 국정 연설을 (청크로) 저장하는 것으로 시작하겠습니다. 검색기가 많은 수(20)의 문서를 검색하도록 설정할 수 있습니다.

##### 지나 및 OpenAI API 키 설정

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()
os.environ["JINA_API_KEY"] = getpass.getpass()
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Jina Reranker"}, {"imported": "JinaEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.jina.JinaEmbeddings.html", "title": "Jina Reranker"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "Jina Reranker"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Jina Reranker"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.embeddings import JinaEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_text_splitters import RecursiveCharacterTextSplitter

documents = TextLoader(
    "../../how_to/state_of_the_union.txt",
).load()
text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=100)
texts = text_splitter.split_documents(documents)

embedding = JinaEmbeddings(model_name="jina-embeddings-v2-base-en")
retriever = FAISS.from_documents(texts, embedding).as_retriever(search_kwargs={"k": 20})

query = "What did the president say about Ketanji Brown Jackson"
docs = retriever.get_relevant_documents(query)
pretty_print_docs(docs)
```


## 지나 리랭커로 리랭킹 수행

이제 기본 검색기를 ContextualCompressionRetriever로 감싸고, 지나 리랭커를 압축기로 사용하겠습니다.

```python
<!--IMPORTS:[{"imported": "ContextualCompressionRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.contextual_compression.ContextualCompressionRetriever.html", "title": "Jina Reranker"}, {"imported": "JinaRerank", "source": "langchain_community.document_compressors", "docs": "https://api.python.langchain.com/en/latest/document_compressors/langchain_community.document_compressors.jina_rerank.JinaRerank.html", "title": "Jina Reranker"}]-->
from langchain.retrievers import ContextualCompressionRetriever
from langchain_community.document_compressors import JinaRerank

compressor = JinaRerank()
compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor, base_retriever=retriever
)

compressed_docs = compression_retriever.get_relevant_documents(
    "What did the president say about Ketanji Jackson Brown"
)
```


```python
pretty_print_docs(compressed_docs)
```


## QA 리랭킹과 지나 리랭커

```python
<!--IMPORTS:[{"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "Jina Reranker"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "Jina Reranker"}]-->
from langchain import hub
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

retrieval_qa_chat_prompt = hub.pull("langchain-ai/retrieval-qa-chat")
retrieval_qa_chat_prompt.pretty_print()
```

```output
================================[1m System Message [0m================================

Answer any use questions based solely on the context below:

<context>
[33;1m[1;3m{context}[0m
</context>

=============================[1m Messages Placeholder [0m=============================

[33;1m[1;3m{chat_history}[0m

================================[1m Human Message [0m=================================

[33;1m[1;3m{input}[0m
```


```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Jina Reranker"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
combine_docs_chain = create_stuff_documents_chain(llm, retrieval_qa_chat_prompt)
chain = create_retrieval_chain(compression_retriever, combine_docs_chain)
```


```python
chain.invoke({"input": query})
```