---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/image_captions.ipynb
description: 이 문서는 Salesforce BLIP 이미지 캡셔닝 모델을 사용하여 이미지 캡션의 쿼리 가능한 인덱스를 생성하는 방법을 설명합니다.
---

# 이미지 캡션

기본적으로 로더는 사전 훈련된 [Salesforce BLIP 이미지 캡셔닝 모델](https://huggingface.co/Salesforce/blip-image-captioning-base)을 사용합니다.

이 노트북은 `ImageCaptionLoader`를 사용하여 이미지 캡션의 쿼리 가능한 인덱스를 생성하는 방법을 보여줍니다.

```python
%pip install -qU transformers langchain_openai langchain_chroma

import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()
```


### Wikimedia에서 이미지 URL 목록 준비

```python
<!--IMPORTS:[{"imported": "ImageCaptionLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.image_captions.ImageCaptionLoader.html", "title": "Image captions"}]-->
from langchain_community.document_loaders import ImageCaptionLoader

list_image_urls = [
    "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Ara_ararauna_Luc_Viatour.jpg/1554px-Ara_ararauna_Luc_Viatour.jpg",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/1928_Model_A_Ford.jpg/640px-1928_Model_A_Ford.jpg",
]
```


### 로더 생성

```python
loader = ImageCaptionLoader(images=list_image_urls)
list_docs = loader.load()
list_docs
```


```output
[Document(metadata={'image_path': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Ara_ararauna_Luc_Viatour.jpg/1554px-Ara_ararauna_Luc_Viatour.jpg'}, page_content='an image of a bird flying in the air [SEP]'),
 Document(metadata={'image_path': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/1928_Model_A_Ford.jpg/640px-1928_Model_A_Ford.jpg'}, page_content='an image of a vintage car parked on the street [SEP]')]
```


```python
import requests
from PIL import Image

Image.open(requests.get(list_image_urls[0], stream=True).raw).convert("RGB")
```


![](/img/97a10733d1122a4ca1078261b2cd8e77.png)

### 인덱스 생성

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Image captions"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Image captions"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Image captions"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(list_docs)
vectorstore = Chroma.from_documents(documents=splits, embedding=OpenAIEmbeddings())

retriever = vectorstore.as_retriever(k=2)
```


### 쿼리

```python
<!--IMPORTS:[{"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "Image captions"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "Image captions"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Image captions"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Image captions"}]-->
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-4o", temperature=0)

system_prompt = (
    "You are an assistant for question-answering tasks. "
    "Use the following pieces of retrieved context to answer "
    "the question. If you don't know the answer, say that you "
    "don't know. Use three sentences maximum and keep the "
    "answer concise."
    "\n\n"
    "{context}"
)

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        ("human", "{input}"),
    ]
)


question_answer_chain = create_stuff_documents_chain(model, prompt)
rag_chain = create_retrieval_chain(retriever, question_answer_chain)

response = rag_chain.invoke({"input": "What animals are in the images?"})

print(response["answer"])
```

```output
The images include a bird.
```


```python
response = rag_chain.invoke({"input": "What kind of images are there?"})

print(response["answer"])
```

```output
There are images of a bird flying in the air and a vintage car parked on the street.
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)