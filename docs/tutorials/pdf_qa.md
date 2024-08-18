---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/pdf_qa.ipynb
description: PDF 파일에 대한 질문에 답변할 수 있는 시스템을 구축하는 방법을 안내합니다. 문서 로더와 RAG 파이프라인을 활용합니다.
keywords:
- pdf
- document loader
---

# PDF 수집 및 질문/답변 시스템 구축

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [문서 로더](/docs/concepts/#document-loaders)
- [채팅 모델](/docs/concepts/#chat-models)
- [임베딩](/docs/concepts/#embedding-models)
- [벡터 저장소](/docs/concepts/#vector-stores)
- [검색 증강 생성](/docs/tutorials/rag/)

:::

PDF 파일은 종종 다른 출처에서 사용할 수 없는 중요한 비구조적 데이터를 포함하고 있습니다. 이들은 상당히 길 수 있으며, 일반 텍스트 파일과 달리 언어 모델의 프롬프트에 직접 입력할 수 없습니다.

이 튜토리얼에서는 PDF 파일에 대한 질문에 답할 수 있는 시스템을 생성합니다. 더 구체적으로, [문서 로더](/docs/concepts/#document-loaders)를 사용하여 LLM에서 사용할 수 있는 형식으로 텍스트를 로드한 다음, 출처 자료에서 인용을 포함하여 질문에 답하기 위해 검색 증강 생성(RAG) 파이프라인을 구축합니다.

이 튜토리얼은 [RAG](/docs/tutorials/rag/) 튜토리얼에서 더 깊이 다룬 몇 가지 개념을 간단히 설명할 것이므로, 아직 보지 않았다면 먼저 그 내용을 살펴보는 것이 좋습니다.

자, 시작해봅시다!

## 문서 로드하기

먼저, 로드할 PDF를 선택해야 합니다. 우리는 [Nike의 연례 공공 SEC 보고서](https://s1.q4cdn.com/806093406/files/doc_downloads/2023/414759-1-_5_Nike-NPS-Combo_Form-10-K_WR.pdf)의 문서를 사용할 것입니다. 이 문서는 100페이지가 넘으며, 긴 설명 텍스트와 혼합된 중요한 데이터를 포함하고 있습니다. 그러나 원하는 PDF를 자유롭게 사용하실 수 있습니다.

PDF를 선택한 후, 다음 단계는 LLM이 더 쉽게 처리할 수 있는 형식으로 로드하는 것입니다. LLM은 일반적으로 텍스트 입력을 요구하기 때문입니다. LangChain에는 이 목적을 위해 사용할 수 있는 몇 가지 [내장 문서 로더](/docs/how_to/document_loader_pdf/)가 있습니다. 아래에서는 파일 경로에서 읽는 [`pypdf`](https://pypi.org/project/pypdf/) 패키지로 구동되는 로더를 사용할 것입니다:

```python
%pip install -qU pypdf langchain_community
```


```python
<!--IMPORTS:[{"imported": "PyPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFLoader.html", "title": "Build a PDF ingestion and Question/Answering system"}]-->
from langchain_community.document_loaders import PyPDFLoader

file_path = "../example_data/nke-10k-2023.pdf"
loader = PyPDFLoader(file_path)

docs = loader.load()

print(len(docs))
```

```output
107
```


```python
print(docs[0].page_content[0:100])
print(docs[0].metadata)
```

```output
Table of Contents
UNITED STATES
SECURITIES AND EXCHANGE COMMISSION
Washington, D.C. 20549
FORM 10-K

{'source': '../example_data/nke-10k-2023.pdf', 'page': 0}
```

방금 무슨 일이 있었나요?

- 로더는 지정된 경로의 PDF를 메모리로 읽어옵니다.
- 그런 다음 `pypdf` 패키지를 사용하여 텍스트 데이터를 추출합니다.
- 마지막으로, PDF의 각 페이지에 대한 LangChain [문서](/docs/concepts/#documents)를 생성하며, 페이지의 내용과 텍스트가 문서의 어디에서 왔는지에 대한 메타데이터를 포함합니다.

LangChain에는 다른 데이터 소스를 위한 [많은 다른 문서 로더](/docs/integrations/document_loaders/)가 있으며, [사용자 정의 문서 로더](/docs/how_to/document_loader_custom/)를 생성할 수도 있습니다.

## RAG를 통한 질문 답변

다음으로, 로드한 문서를 나중에 검색할 수 있도록 준비합니다. [텍스트 분할기](/docs/concepts/#text-splitters)를 사용하여 로드한 문서를 LLM의 컨텍스트 창에 더 쉽게 맞출 수 있는 작은 문서로 분할한 다음, 이를 [벡터 저장소](/docs/concepts/#vector-stores)에 로드합니다. 그런 다음 RAG 체인에서 사용할 수 있도록 벡터 저장소에서 [검색기](/docs/concepts/#retrievers)를 생성할 수 있습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" openaiParams={`model="gpt-4o"`} />

```python
%pip install langchain_chroma langchain_openai
```


```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Build a PDF ingestion and Question/Answering system"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Build a PDF ingestion and Question/Answering system"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Build a PDF ingestion and Question/Answering system"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(docs)
vectorstore = Chroma.from_documents(documents=splits, embedding=OpenAIEmbeddings())

retriever = vectorstore.as_retriever()
```


마지막으로, 최종 `rag_chain`을 구성하기 위해 몇 가지 내장 도우미를 사용할 것입니다:

```python
<!--IMPORTS:[{"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "Build a PDF ingestion and Question/Answering system"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "Build a PDF ingestion and Question/Answering system"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Build a PDF ingestion and Question/Answering system"}]-->
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate

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


question_answer_chain = create_stuff_documents_chain(llm, prompt)
rag_chain = create_retrieval_chain(retriever, question_answer_chain)

results = rag_chain.invoke({"input": "What was Nike's revenue in 2023?"})

results
```


```output
{'input': "What was Nike's revenue in 2023?",
 'context': [Document(page_content='Table of Contents\nFISCAL 2023 NIKE BRAND REVENUE HIGHLIGHTS\nThe following tables present NIKE Brand revenues disaggregated by reportable operating segment, distribution channel and major product line:\nFISCAL 2023 COMPARED TO FISCAL 2022\n•NIKE, Inc. Revenues were $51.2 billion in fiscal 2023, which increased 10% and 16% compared to fiscal 2022 on a reported and currency-neutral basis, respectively.\nThe increase was due to higher revenues in North America, Europe, Middle East & Africa ("EMEA"), APLA and Greater China, which contributed approximately 7, 6,\n2 and 1 percentage points to NIKE, Inc. Revenues, respectively.\n•NIKE Brand revenues, which represented over 90% of NIKE, Inc. Revenues, increased 10% and 16% on a reported and currency-neutral basis, respectively. This\nincrease was primarily due to higher revenues in Men\'s, the Jordan Brand, Women\'s and Kids\' which grew 17%, 35%,11% and 10%, respectively, on a wholesale\nequivalent basis.', metadata={'page': 35, 'source': '../example_data/nke-10k-2023.pdf'}),
  Document(page_content='Enterprise Resource Planning Platform, data and analytics, demand sensing, insight gathering, and other areas to create an end-to-end technology foundation, which we\nbelieve will further accelerate our digital transformation. We believe this unified approach will accelerate growth and unlock more efficiency for our business, while driving\nspeed and responsiveness as we serve consumers globally.\nFINANCIAL HIGHLIGHTS\n•In fiscal 2023, NIKE, Inc. achieved record Revenues of $51.2 billion, which increased 10% and 16% on a reported and currency-neutral basis, respectively\n•NIKE Direct revenues grew 14% from $18.7 billion in fiscal 2022 to $21.3 billion in fiscal 2023, and represented approximately 44% of total NIKE Brand revenues for\nfiscal 2023\n•Gross margin for the fiscal year decreased 250 basis points to 43.5% primarily driven by higher product costs, higher markdowns and unfavorable changes in foreign\ncurrency exchange rates, partially offset by strategic pricing actions', metadata={'page': 30, 'source': '../example_data/nke-10k-2023.pdf'}),
  Document(page_content="Table of Contents\nNORTH AMERICA\n(Dollars in millions) FISCAL 2023FISCAL 2022 % CHANGE% CHANGE\nEXCLUDING\nCURRENCY\nCHANGESFISCAL 2021 % CHANGE% CHANGE\nEXCLUDING\nCURRENCY\nCHANGES\nRevenues by:\nFootwear $ 14,897 $ 12,228 22 % 22 %$ 11,644 5 % 5 %\nApparel 5,947 5,492 8 % 9 % 5,028 9 % 9 %\nEquipment 764 633 21 % 21 % 507 25 % 25 %\nTOTAL REVENUES $ 21,608 $ 18,353 18 % 18 %$ 17,179 7 % 7 %\nRevenues by:    \nSales to Wholesale Customers $ 11,273 $ 9,621 17 % 18 %$ 10,186 -6 % -6 %\nSales through NIKE Direct 10,335 8,732 18 % 18 % 6,993 25 % 25 %\nTOTAL REVENUES $ 21,608 $ 18,353 18 % 18 %$ 17,179 7 % 7 %\nEARNINGS BEFORE INTEREST AND TAXES $ 5,454 $ 5,114 7 % $ 5,089 0 %\nFISCAL 2023 COMPARED TO FISCAL 2022\n•North America revenues increased 18% on a currency-neutral basis, primarily due to higher revenues in Men's and the Jordan Brand. NIKE Direct revenues\nincreased 18%, driven by strong digital sales growth of 23%, comparable store sales growth of 9% and the addition of new stores.", metadata={'page': 39, 'source': '../example_data/nke-10k-2023.pdf'}),
  Document(page_content="Table of Contents\nEUROPE, MIDDLE EAST & AFRICA\n(Dollars in millions) FISCAL 2023FISCAL 2022 % CHANGE% CHANGE\nEXCLUDING\nCURRENCY\nCHANGESFISCAL 2021 % CHANGE% CHANGE\nEXCLUDING\nCURRENCY\nCHANGES\nRevenues by:\nFootwear $ 8,260 $ 7,388 12 % 25 %$ 6,970 6 % 9 %\nApparel 4,566 4,527 1 % 14 % 3,996 13 % 16 %\nEquipment 592 564 5 % 18 % 490 15 % 17 %\nTOTAL REVENUES $ 13,418 $ 12,479 8 % 21 %$ 11,456 9 % 12 %\nRevenues by:    \nSales to Wholesale Customers $ 8,522 $ 8,377 2 % 15 %$ 7,812 7 % 10 %\nSales through NIKE Direct 4,896 4,102 19 % 33 % 3,644 13 % 15 %\nTOTAL REVENUES $ 13,418 $ 12,479 8 % 21 %$ 11,456 9 % 12 %\nEARNINGS BEFORE INTEREST AND TAXES $ 3,531 $ 3,293 7 % $ 2,435 35 % \nFISCAL 2023 COMPARED TO FISCAL 2022\n•EMEA revenues increased 21% on a currency-neutral basis, due to higher revenues in Men's, the Jordan Brand, Women's and Kids'. NIKE Direct revenues\nincreased 33%, driven primarily by strong digital sales growth of 43% and comparable store sales growth of 22%.", metadata={'page': 40, 'source': '../example_data/nke-10k-2023.pdf'})],
 'answer': 'According to the financial highlights, Nike, Inc. achieved record revenues of $51.2 billion in fiscal 2023, which increased 10% on a reported basis and 16% on a currency-neutral basis compared to fiscal 2022.'}
```


결과 사전의 `answer` 키에서 최종 답변을 얻고, LLM이 답변을 생성하는 데 사용한 `context`를 확인할 수 있습니다.

`context` 아래의 값을 더 살펴보면, 각 문서가 섭취된 페이지 내용의 조각을 포함하고 있음을 알 수 있습니다. 유용하게도, 이러한 문서는 처음 로드했을 때의 원래 메타데이터를 보존합니다:

```python
print(results["context"][0].page_content)
```

```output
Table of Contents
FISCAL 2023 NIKE BRAND REVENUE HIGHLIGHTS
The following tables present NIKE Brand revenues disaggregated by reportable operating segment, distribution channel and major product line:
FISCAL 2023 COMPARED TO FISCAL 2022
•NIKE, Inc. Revenues were $51.2 billion in fiscal 2023, which increased 10% and 16% compared to fiscal 2022 on a reported and currency-neutral basis, respectively.
The increase was due to higher revenues in North America, Europe, Middle East & Africa ("EMEA"), APLA and Greater China, which contributed approximately 7, 6,
2 and 1 percentage points to NIKE, Inc. Revenues, respectively.
•NIKE Brand revenues, which represented over 90% of NIKE, Inc. Revenues, increased 10% and 16% on a reported and currency-neutral basis, respectively. This
increase was primarily due to higher revenues in Men's, the Jordan Brand, Women's and Kids' which grew 17%, 35%,11% and 10%, respectively, on a wholesale
equivalent basis.
```


```python
print(results["context"][0].metadata)
```

```output
{'page': 35, 'source': '../example_data/nke-10k-2023.pdf'}
```

이 특정 조각은 원래 PDF의 35페이지에서 왔습니다. 이 데이터를 사용하여 답변이 PDF의 어느 페이지에서 왔는지 보여줄 수 있으며, 사용자가 답변이 출처 자료에 기반하고 있음을 빠르게 확인할 수 있도록 합니다.

:::info
RAG에 대한 더 깊은 탐구를 원하신다면 [이 더 집중된 튜토리얼](/docs/tutorials/rag/)이나 [우리의 사용 방법 가이드](/docs/how_to/#qa-with-rag)를 참조하세요.
:::

## 다음 단계

이제 문서 로더를 사용하여 PDF 파일에서 문서를 로드하는 방법과 RAG를 위해 로드된 데이터를 준비하는 몇 가지 기술을 살펴보았습니다.

문서 로더에 대한 더 많은 정보는 다음을 확인하세요:

- [개념 가이드의 항목](/docs/concepts/#document-loaders)
- [관련 사용 방법 가이드](/docs/how_to/#document-loaders)
- [사용 가능한 통합](/docs/integrations/document_loaders/)
- [사용자 정의 문서 로더를 만드는 방법](/docs/how_to/document_loader_custom/)

RAG에 대한 더 많은 정보는 다음을 참조하세요:

- [검색 증강 생성(RAG) 앱 구축](/docs/tutorials/rag/)
- [관련 사용 방법 가이드](/docs/how_to/#qa-with-rag)