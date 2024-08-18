---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/psychic.ipynb
description: 이 문서는 Psychic에서 문서를 로드하는 방법을 다루며, 필요한 준비 사항과 문서 변환 과정을 설명합니다.
---

# Psychic
이 노트북은 `Psychic`에서 문서를 로드하는 방법을 다룹니다. 자세한 내용은 [여기](/docs/integrations/providers/psychic)를 참조하세요.

## 필수 조건
1. [이 문서](/docs/integrations/providers/psychic)의 빠른 시작 섹션을 따르세요.
2. [Psychic 대시보드](https://dashboard.psychic.dev/)에 로그인하고 비밀 키를 가져옵니다.
3. 웹 앱에 프론트엔드 리액트 라이브러리를 설치하고 사용자가 연결을 인증하도록 합니다. 연결은 지정한 연결 ID를 사용하여 생성됩니다.

## 문서 로드하기

`PsychicLoader` 클래스를 사용하여 연결에서 문서를 로드합니다. 각 연결에는 커넥터 ID(연결된 SaaS 앱에 해당)와 연결 ID(프론트엔드 라이브러리에 전달한 ID)가 있습니다.

```python
# Uncomment this to install psychicapi if you don't already have it installed
!poetry run pip -q install psychicapi langchain-chroma
```

```output

[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m A new release of pip is available: [0m[31;49m23.0.1[0m[39;49m -> [0m[32;49m23.1.2[0m
[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m To update, run: [0m[32;49mpip install --upgrade pip[0m
```


```python
<!--IMPORTS:[{"imported": "PsychicLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.psychic.PsychicLoader.html", "title": "Psychic"}]-->
from langchain_community.document_loaders import PsychicLoader
from psychicapi import ConnectorId

# Create a document loader for google drive. We can also load from other connectors by setting the connector_id to the appropriate value e.g. ConnectorId.notion.value
# This loader uses our test credentials
google_drive_loader = PsychicLoader(
    api_key="7ddb61c1-8b6a-4d31-a58e-30d1c9ea480e",
    connector_id=ConnectorId.gdrive.value,
    connection_id="google-test",
)

documents = google_drive_loader.load()
```


## 문서를 임베딩으로 변환하기

이제 이러한 문서를 임베딩으로 변환하고 Chroma와 같은 벡터 데이터베이스에 저장할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "RetrievalQAWithSourcesChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.qa_with_sources.retrieval.RetrievalQAWithSourcesChain.html", "title": "Psychic"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Psychic"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Psychic"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Psychic"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Psychic"}]-->
from langchain.chains import RetrievalQAWithSourcesChain
from langchain_chroma import Chroma
from langchain_openai import OpenAI, OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
docsearch = Chroma.from_documents(texts, embeddings)
chain = RetrievalQAWithSourcesChain.from_chain_type(
    OpenAI(temperature=0), chain_type="stuff", retriever=docsearch.as_retriever()
)
chain({"question": "what is psychic?"}, return_only_outputs=True)
```


## 관련 자료

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)