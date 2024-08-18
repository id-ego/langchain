---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/scann.ipynb
description: ScaNN은 대규모 벡터 유사성 검색을 위한 효율적인 방법으로, 검색 공간 가지치기 및 양자화를 지원합니다.
---

# ScaNN

ScaNN (Scalable Nearest Neighbors)는 대규모에서 효율적인 벡터 유사성 검색을 위한 방법입니다.

ScaNN은 최대 내적 검색을 위한 검색 공간 가지치기 및 양자화를 포함하며, 유클리드 거리와 같은 다른 거리 함수도 지원합니다. 이 구현은 AVX2 지원이 있는 x86 프로세서에 최적화되어 있습니다. 자세한 내용은 [Google Research github](https://github.com/google-research/google-research/tree/master/scann)를 참조하세요.

이 통합을 사용하려면 `langchain-community`를 `pip install -qU langchain-community`로 설치해야 합니다.

## 설치
pip를 통해 ScaNN을 설치합니다. 또는 [ScaNN 웹사이트](https://github.com/google-research/google-research/tree/master/scann#building-from-source)의 지침을 따라 소스에서 설치할 수 있습니다.

```python
%pip install --upgrade --quiet  scann
```


## 검색 데모

아래에서는 Huggingface Embeddings와 함께 ScaNN을 사용하는 방법을 보여줍니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "ScaNN"}, {"imported": "ScaNN", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.scann.ScaNN.html", "title": "ScaNN"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "ScaNN"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "ScaNN"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import ScaNN
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)


embeddings = HuggingFaceEmbeddings()

db = ScaNN.from_documents(docs, embeddings)
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)

docs[0]
```


## RetrievalQA 데모

다음으로, Google PaLM API와 함께 ScaNN을 사용하는 방법을 보여줍니다.

API 키는 https://developers.generativeai.google/tutorials/setup 에서 얻을 수 있습니다.

```python
<!--IMPORTS:[{"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "ScaNN"}, {"imported": "ChatGooglePalm", "source": "langchain_community.chat_models.google_palm", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.google_palm.ChatGooglePalm.html", "title": "ScaNN"}]-->
from langchain.chains import RetrievalQA
from langchain_community.chat_models.google_palm import ChatGooglePalm

palm_client = ChatGooglePalm(google_api_key="YOUR_GOOGLE_PALM_API_KEY")

qa = RetrievalQA.from_chain_type(
    llm=palm_client,
    chain_type="stuff",
    retriever=db.as_retriever(search_kwargs={"k": 10}),
)
```


```python
print(qa.run("What did the president say about Ketanji Brown Jackson?"))
```

```output
The president said that Ketanji Brown Jackson is one of our nation's top legal minds, who will continue Justice Breyer's legacy of excellence.
```


```python
print(qa.run("What did the president say about Michael Phelps?"))
```

```output
The president did not mention Michael Phelps in his speech.
```

## 로컬 검색 인덱스 저장 및 로드

```python
db.save_local("/tmp/db", "state_of_union")
restored_db = ScaNN.load_local("/tmp/db", embeddings, index_name="state_of_union")
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)