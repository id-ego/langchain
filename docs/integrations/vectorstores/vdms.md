---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/vdms.ipynb
description: 인텔의 VDMS는 시각적 메타데이터를 그래프로 저장하여 대규모 시각 데이터에 효율적으로 접근할 수 있는 저장 솔루션입니다.
---

# 인텔의 비주얼 데이터 관리 시스템 (VDMS)

> 인텔의 [VDMS](https://github.com/IntelLabs/vdms)는 그래프로 저장된 비주얼 메타데이터를 통해 관련 비주얼 데이터 검색을 목표로 하여 클라우드 규모에 도달하는 효율적인 대용량 "비주얼" 데이터 접근을 위한 저장 솔루션입니다. VDMS는 MIT 라이선스 하에 배포됩니다.

VDMS는 다음을 지원합니다:
* K 최근접 이웃 검색
* 유클리드 거리 (L2) 및 내적 (IP)
* 인덱싱 및 거리 계산을 위한 라이브러리: TileDBDense, TileDBSparse, FaissFlat (기본값), FaissIVFFlat, Flinng
* 텍스트, 이미지 및 비디오에 대한 임베딩
* 벡터 및 메타데이터 검색

VDMS는 서버 및 클라이언트 구성 요소를 가지고 있습니다. 서버를 설정하려면 [설치 지침](https://github.com/IntelLabs/vdms/blob/master/INSTALL.md)을 참조하거나 [도커 이미지](https://hub.docker.com/r/intellabs/vdms)를 사용하세요.

이 노트북은 도커 이미지를 사용하여 VDMS를 벡터 저장소로 사용하는 방법을 보여줍니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

시작하려면 VDMS 클라이언트 및 Sentence Transformers에 대한 Python 패키지를 설치하세요:

```python
# Pip install necessary package
%pip install --upgrade --quiet pip vdms sentence-transformers langchain-huggingface > /dev/null
```

```output
Note: you may need to restart the kernel to use updated packages.
```

## VDMS 서버 시작
여기에서 포트 55555로 VDMS 서버를 시작합니다.

```python
!docker run --rm -d -p 55555:55555 --name vdms_vs_test_nb intellabs/vdms:latest
```

```output
b26917ffac236673ef1d035ab9c91fe999e29c9eb24aa6c7103d7baa6bf2f72d
```

## 기본 예제 (도커 컨테이너 사용)

이 기본 예제에서는 VDMS에 문서를 추가하고 이를 벡터 데이터베이스로 사용하는 방법을 보여줍니다.

VDMS 서버를 도커 컨테이너에서 별도로 실행하여 LangChain과 함께 사용할 수 있으며, LangChain은 VDMS Python 클라이언트를 통해 서버에 연결됩니다.

VDMS는 여러 문서 컬렉션을 처리할 수 있지만, LangChain 인터페이스는 하나의 컬렉션을 기대하므로 컬렉션의 이름을 지정해야 합니다. LangChain에서 사용하는 기본 컬렉션 이름은 "langchain"입니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders.text", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Intel's Visual Data Management System (VDMS)"}, {"imported": "VDMS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vdms.VDMS.html", "title": "Intel's Visual Data Management System (VDMS)"}, {"imported": "VDMS_Client", "source": "langchain_community.vectorstores.vdms", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vdms.VDMS_Client.html", "title": "Intel's Visual Data Management System (VDMS)"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "Intel's Visual Data Management System (VDMS)"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters.character", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Intel's Visual Data Management System (VDMS)"}]-->
import time
import warnings

warnings.filterwarnings("ignore")

from langchain_community.document_loaders.text import TextLoader
from langchain_community.vectorstores import VDMS
from langchain_community.vectorstores.vdms import VDMS_Client
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters.character import CharacterTextSplitter

time.sleep(2)
DELIMITER = "-" * 50

# Connect to VDMS Vector Store
vdms_client = VDMS_Client(host="localhost", port=55555)
```


결과를 인쇄하기 위한 몇 가지 도우미 함수입니다.

```python
def print_document_details(doc):
    print(f"Content:\n\t{doc.page_content}\n")
    print("Metadata:")
    for key, value in doc.metadata.items():
        if value != "Missing property":
            print(f"\t{key}:\t{value}")


def print_results(similarity_results, score=True):
    print(f"{DELIMITER}\n")
    if score:
        for doc, score in similarity_results:
            print(f"Score:\t{score}\n")
            print_document_details(doc)
            print(f"{DELIMITER}\n")
    else:
        for doc in similarity_results:
            print_document_details(doc)
            print(f"{DELIMITER}\n")


def print_response(list_of_entities):
    for ent in list_of_entities:
        for key, value in ent.items():
            if value != "Missing property":
                print(f"\n{key}:\n\t{value}")
        print(f"{DELIMITER}\n")
```


### 문서 로드 및 임베딩 함수 얻기
여기에서는 최근의 국정 연설을 로드하고 문서를 청크로 나눕니다.

LangChain 벡터 저장소는 문서를 관리하기 위해 문자열/키워드 `id`를 사용합니다. 기본적으로 `id`는 uuid이지만, 여기에서는 이를 문자열로 캐스팅한 정수로 정의합니다. 추가 메타데이터도 문서와 함께 제공되며, 이 예제에서는 임베딩 함수로 HuggingFaceEmbeddings를 사용합니다.

```python
# load the document and split it into chunks
document_path = "../../how_to/state_of_the_union.txt"
raw_documents = TextLoader(document_path).load()

# split it into chunks
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(raw_documents)
ids = []
for doc_idx, doc in enumerate(docs):
    ids.append(str(doc_idx + 1))
    docs[doc_idx].metadata["id"] = str(doc_idx + 1)
    docs[doc_idx].metadata["page_number"] = int(doc_idx + 1)
    docs[doc_idx].metadata["president_included"] = (
        "president" in doc.page_content.lower()
    )
print(f"# Documents: {len(docs)}")


# create the open-source embedding function
embedding = HuggingFaceEmbeddings()
print(
    f"# Embedding Dimensions: {len(embedding.embed_query('This is a test document.'))}"
)
```

```output
# Documents: 42
# Embedding Dimensions: 768
```

### Faiss Flat 및 유클리드 거리 (기본값)를 사용한 유사성 검색

이 섹션에서는 FAISS IndexFlat 인덱싱 (기본값) 및 유클리드 거리 (기본값)를 거리 메트릭으로 사용하여 VDMS에 문서를 추가합니다. 우리는 쿼리 `Ketanji Brown Jackson에 대해 대통령이 뭐라고 했는가`와 관련된 세 개의 문서 (`k=3`)를 검색합니다.

```python
# add data
collection_name = "my_collection_faiss_L2"
db_FaissFlat = VDMS.from_documents(
    docs,
    client=vdms_client,
    ids=ids,
    collection_name=collection_name,
    embedding=embedding,
)

# Query (No metadata filtering)
k = 3
query = "What did the president say about Ketanji Brown Jackson"
returned_docs = db_FaissFlat.similarity_search(query, k=k, filter=None)
print_results(returned_docs, score=False)
```

```output
--------------------------------------------------

Content:
	Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.

Metadata:
	id:	32
	page_number:	32
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Content:
	As Frances Haugen, who is here with us tonight, has shown, we must hold social media platforms accountable for the national experiment they’re conducting on our children for profit. 

It’s time to strengthen privacy protections, ban targeted advertising to children, demand tech companies stop collecting personal data on our children. 

And let’s get all Americans the mental health services they need. More people they can turn to for help, and full parity between physical and mental health care. 

Third, support our veterans. 

Veterans are the best of us. 

I’ve always believed that we have a sacred obligation to equip all those we send to war and care for them and their families when they come home. 

My administration is providing assistance with job training and housing, and now helping lower-income veterans get VA care debt-free.  

Our troops in Iraq and Afghanistan faced many dangers.

Metadata:
	id:	37
	page_number:	37
	president_included:	False
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Content:
	A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. 

We can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  

We’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  

We’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. 

We’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.

Metadata:
	id:	33
	page_number:	33
	president_included:	False
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------
```


```python
# Query (with filtering)
k = 3
constraints = {"page_number": [">", 30], "president_included": ["==", True]}
query = "What did the president say about Ketanji Brown Jackson"
returned_docs = db_FaissFlat.similarity_search(query, k=k, filter=constraints)
print_results(returned_docs, score=False)
```

```output
--------------------------------------------------

Content:
	Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.

Metadata:
	id:	32
	page_number:	32
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Content:
	And for our LGBTQ+ Americans, let’s finally get the bipartisan Equality Act to my desk. The onslaught of state laws targeting transgender Americans and their families is wrong. 

As I said last year, especially to our younger transgender Americans, I will always have your back as your President, so you can be yourself and reach your God-given potential. 

While it often appears that we never agree, that isn’t true. I signed 80 bipartisan bills into law last year. From preventing government shutdowns to protecting Asian-Americans from still-too-common hate crimes to reforming military justice. 

And soon, we’ll strengthen the Violence Against Women Act that I first wrote three decades ago. It is important for us to show the nation that we can come together and do big things. 

So tonight I’m offering a Unity Agenda for the Nation. Four big things we can do together.  

First, beat the opioid epidemic.

Metadata:
	id:	35
	page_number:	35
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Content:
	Last month, I announced our plan to supercharge  
the Cancer Moonshot that President Obama asked me to lead six years ago. 

Our goal is to cut the cancer death rate by at least 50% over the next 25 years, turn more cancers from death sentences into treatable diseases.  

More support for patients and families. 

To get there, I call on Congress to fund ARPA-H, the Advanced Research Projects Agency for Health. 

It’s based on DARPA—the Defense Department project that led to the Internet, GPS, and so much more.  

ARPA-H will have a singular purpose—to drive breakthroughs in cancer, Alzheimer’s, diabetes, and more. 

A unity agenda for the nation. 

We can do this. 

My fellow Americans—tonight , we have gathered in a sacred space—the citadel of our democracy. 

In this Capitol, generation after generation, Americans have debated great questions amid great strife, and have done great things. 

We have fought for freedom, expanded liberty, defeated totalitarianism and terror.

Metadata:
	id:	40
	page_number:	40
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------
```

### Faiss IVFFlat 및 내적 (IP) 거리 사용한 유사성 검색

이 섹션에서는 Faiss IndexIVFFlat 인덱싱 및 IP를 거리 메트릭으로 사용하여 VDMS에 문서를 추가합니다. 우리는 쿼리 `Ketanji Brown Jackson에 대해 대통령이 뭐라고 했는가`와 관련된 세 개의 문서 (`k=3`)를 검색하고 문서와 함께 점수도 반환합니다.

```python
db_FaissIVFFlat = VDMS.from_documents(
    docs,
    client=vdms_client,
    ids=ids,
    collection_name="my_collection_FaissIVFFlat_IP",
    embedding=embedding,
    engine="FaissIVFFlat",
    distance_strategy="IP",
)
# Query
k = 3
query = "What did the president say about Ketanji Brown Jackson"
docs_with_score = db_FaissIVFFlat.similarity_search_with_score(query, k=k, filter=None)
print_results(docs_with_score)
```

```output
--------------------------------------------------

Score:	1.2032090425

Content:
	Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.

Metadata:
	id:	32
	page_number:	32
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Score:	1.4952471256

Content:
	As Frances Haugen, who is here with us tonight, has shown, we must hold social media platforms accountable for the national experiment they’re conducting on our children for profit. 

It’s time to strengthen privacy protections, ban targeted advertising to children, demand tech companies stop collecting personal data on our children. 

And let’s get all Americans the mental health services they need. More people they can turn to for help, and full parity between physical and mental health care. 

Third, support our veterans. 

Veterans are the best of us. 

I’ve always believed that we have a sacred obligation to equip all those we send to war and care for them and their families when they come home. 

My administration is providing assistance with job training and housing, and now helping lower-income veterans get VA care debt-free.  

Our troops in Iraq and Afghanistan faced many dangers.

Metadata:
	id:	37
	page_number:	37
	president_included:	False
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Score:	1.5008399487

Content:
	A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. 

We can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  

We’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  

We’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. 

We’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.

Metadata:
	id:	33
	page_number:	33
	president_included:	False
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------
```

### FLINNG 및 IP 거리 사용한 유사성 검색

이 섹션에서는 근접 이웃 그룹을 식별하기 위한 필터 (FLINNG) 인덱싱 및 IP를 거리 메트릭으로 사용하여 VDMS에 문서를 추가합니다. 우리는 쿼리 `Ketanji Brown Jackson에 대해 대통령이 뭐라고 했는가`와 관련된 세 개의 문서 (`k=3`)를 검색하고 문서와 함께 점수도 반환합니다.

```python
db_Flinng = VDMS.from_documents(
    docs,
    client=vdms_client,
    ids=ids,
    collection_name="my_collection_Flinng_IP",
    embedding=embedding,
    engine="Flinng",
    distance_strategy="IP",
)
# Query
k = 3
query = "What did the president say about Ketanji Brown Jackson"
docs_with_score = db_Flinng.similarity_search_with_score(query, k=k, filter=None)
print_results(docs_with_score)
```

```output
--------------------------------------------------

Score:	1.2032090425

Content:
	Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.

Metadata:
	id:	32
	page_number:	32
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Score:	1.4952471256

Content:
	As Frances Haugen, who is here with us tonight, has shown, we must hold social media platforms accountable for the national experiment they’re conducting on our children for profit. 

It’s time to strengthen privacy protections, ban targeted advertising to children, demand tech companies stop collecting personal data on our children. 

And let’s get all Americans the mental health services they need. More people they can turn to for help, and full parity between physical and mental health care. 

Third, support our veterans. 

Veterans are the best of us. 

I’ve always believed that we have a sacred obligation to equip all those we send to war and care for them and their families when they come home. 

My administration is providing assistance with job training and housing, and now helping lower-income veterans get VA care debt-free.  

Our troops in Iraq and Afghanistan faced many dangers.

Metadata:
	id:	37
	page_number:	37
	president_included:	False
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Score:	1.5008399487

Content:
	A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. 

We can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  

We’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  

We’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. 

We’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.

Metadata:
	id:	33
	page_number:	33
	president_included:	False
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------
```

### TileDBDense 및 유클리드 거리 사용한 유사성 검색

이 섹션에서는 TileDB Dense 인덱싱 및 L2를 거리 메트릭으로 사용하여 VDMS에 문서를 추가합니다. 우리는 쿼리 `Ketanji Brown Jackson에 대해 대통령이 뭐라고 했는가`와 관련된 세 개의 문서 (`k=3`)를 검색하고 문서와 함께 점수도 반환합니다.

```python
db_tiledbD = VDMS.from_documents(
    docs,
    client=vdms_client,
    ids=ids,
    collection_name="my_collection_tiledbD_L2",
    embedding=embedding,
    engine="TileDBDense",
    distance_strategy="L2",
)

k = 3
query = "What did the president say about Ketanji Brown Jackson"
docs_with_score = db_tiledbD.similarity_search_with_score(query, k=k, filter=None)
print_results(docs_with_score)
```

```output
--------------------------------------------------

Score:	1.2032090425

Content:
	Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.

Metadata:
	id:	32
	page_number:	32
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Score:	1.4952471256

Content:
	As Frances Haugen, who is here with us tonight, has shown, we must hold social media platforms accountable for the national experiment they’re conducting on our children for profit. 

It’s time to strengthen privacy protections, ban targeted advertising to children, demand tech companies stop collecting personal data on our children. 

And let’s get all Americans the mental health services they need. More people they can turn to for help, and full parity between physical and mental health care. 

Third, support our veterans. 

Veterans are the best of us. 

I’ve always believed that we have a sacred obligation to equip all those we send to war and care for them and their families when they come home. 

My administration is providing assistance with job training and housing, and now helping lower-income veterans get VA care debt-free.  

Our troops in Iraq and Afghanistan faced many dangers.

Metadata:
	id:	37
	page_number:	37
	president_included:	False
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Score:	1.5008399487

Content:
	A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. 

We can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  

We’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  

We’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. 

We’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.

Metadata:
	id:	33
	page_number:	33
	president_included:	False
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------
```

### 업데이트 및 삭제

실제 애플리케이션을 구축하는 과정에서 데이터 추가를 넘어 데이터 업데이트 및 삭제도 원할 것입니다.

여기에서는 이를 수행하는 방법을 보여주는 기본 예제가 있습니다. 먼저, 쿼리와 가장 관련이 높은 문서의 메타데이터를 날짜를 추가하여 업데이트합니다.

```python
from datetime import datetime

doc = db_FaissFlat.similarity_search(query)[0]
print(f"Original metadata: \n\t{doc.metadata}")

# Update the metadata for a document by adding last datetime document read
datetime_str = datetime(2024, 5, 1, 14, 30, 0).isoformat()
doc.metadata["last_date_read"] = {"_date": datetime_str}
print(f"new metadata: \n\t{doc.metadata}")
print(f"{DELIMITER}\n")

# Update document in VDMS
id_to_update = doc.metadata["id"]
db_FaissFlat.update_document(collection_name, id_to_update, doc)
response, response_array = db_FaissFlat.get(
    collection_name,
    constraints={
        "id": ["==", id_to_update],
        "last_date_read": [">=", {"_date": "2024-05-01T00:00:00"}],
    },
)

# Display Results
print(f"UPDATED ENTRY (id={id_to_update}):")
print_response([response[0]["FindDescriptor"]["entities"][0]])
```

```output
Original metadata: 
	{'id': '32', 'page_number': 32, 'president_included': True, 'source': '../../how_to/state_of_the_union.txt'}
new metadata: 
	{'id': '32', 'page_number': 32, 'president_included': True, 'source': '../../how_to/state_of_the_union.txt', 'last_date_read': {'_date': '2024-05-01T14:30:00'}}
--------------------------------------------------

UPDATED ENTRY (id=32):

content:
	Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.

id:
	32

last_date_read:
	2024-05-01T14:30:00+00:00

page_number:
	32

president_included:
	True

source:
	../../how_to/state_of_the_union.txt
--------------------------------------------------
```

다음으로 ID (id=42)를 사용하여 마지막 문서를 삭제합니다.

```python
print("Documents before deletion: ", db_FaissFlat.count(collection_name))

id_to_remove = ids[-1]
db_FaissFlat.delete(collection_name=collection_name, ids=[id_to_remove])
print(
    f"Documents after deletion (id={id_to_remove}): {db_FaissFlat.count(collection_name)}"
)
```

```output
Documents before deletion:  42
Documents after deletion (id=42): 41
```

## 기타 정보
VDMS는 다양한 유형의 비주얼 데이터 및 작업을 지원합니다. 일부 기능은 LangChain 인터페이스에 통합되어 있지만, VDMS는 지속적인 개발 중이므로 추가 워크플로 개선이 추가될 것입니다.

LangChain에 통합된 추가 기능은 아래와 같습니다.

### 벡터에 의한 유사성 검색
문자열 쿼리로 검색하는 대신 임베딩/벡터로 검색할 수 있습니다.

```python
embedding_vector = embedding.embed_query(query)
returned_docs = db_FaissFlat.similarity_search_by_vector(embedding_vector)

# Print Results
print_document_details(returned_docs[0])
```

```output
Content:
	Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.

Metadata:
	id:	32
	last_date_read:	2024-05-01T14:30:00+00:00
	page_number:	32
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
```

### 메타데이터 필터링

작업하기 전에 컬렉션을 좁히는 것이 유용할 수 있습니다.

예를 들어, get 메서드를 사용하여 메타데이터로 컬렉션을 필터링할 수 있습니다. 사전을 사용하여 메타데이터를 필터링합니다. 여기에서는 `id = 2`인 문서를 검색하고 이를 벡터 저장소에서 제거합니다.

```python
response, response_array = db_FaissFlat.get(
    collection_name,
    limit=1,
    include=["metadata", "embeddings"],
    constraints={"id": ["==", "2"]},
)

# Delete id=2
db_FaissFlat.delete(collection_name=collection_name, ids=["2"])

print("Deleted entry:")
print_response([response[0]["FindDescriptor"]["entities"][0]])
```

```output
Deleted entry:

blob:
	True

content:
	Groups of citizens blocking tanks with their bodies. Everyone from students to retirees teachers turned soldiers defending their homeland. 

In this struggle as President Zelenskyy said in his speech to the European Parliament “Light will win over darkness.” The Ukrainian Ambassador to the United States is here tonight. 

Let each of us here tonight in this Chamber send an unmistakable signal to Ukraine and to the world. 

Please rise if you are able and show that, Yes, we the United States of America stand with the Ukrainian people. 

Throughout our history we’ve learned this lesson when dictators do not pay a price for their aggression they cause more chaos.   

They keep moving.   

And the costs and the threats to America and the world keep rising.   

That’s why the NATO Alliance was created to secure peace and stability in Europe after World War 2. 

The United States is a member along with 29 other nations. 

It matters. American diplomacy matters. American resolve matters.

id:
	2

page_number:
	2

president_included:
	True

source:
	../../how_to/state_of_the_union.txt
--------------------------------------------------
```

### 검색기 옵션

이 섹션에서는 VDMS를 검색기로 사용하는 다양한 옵션을 다룹니다.

#### 유사성 검색

여기에서는 검색기 객체에서 유사성 검색을 사용합니다.

```python
retriever = db_FaissFlat.as_retriever()
relevant_docs = retriever.invoke(query)[0]

print_document_details(relevant_docs)
```

```output
Content:
	Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.

Metadata:
	id:	32
	last_date_read:	2024-05-01T14:30:00+00:00
	page_number:	32
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
```

#### 최대 한계 관련성 검색 (MMR)

검색기 객체에서 유사성 검색을 사용하는 것 외에도 `mmr`을 사용할 수 있습니다.

```python
retriever = db_FaissFlat.as_retriever(search_type="mmr")
relevant_docs = retriever.invoke(query)[0]

print_document_details(relevant_docs)
```

```output
Content:
	Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.

Metadata:
	id:	32
	last_date_read:	2024-05-01T14:30:00+00:00
	page_number:	32
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
```

MMR을 직접 사용할 수도 있습니다.

```python
mmr_resp = db_FaissFlat.max_marginal_relevance_search_with_score(query, k=2, fetch_k=10)
print_results(mmr_resp)
```

```output
--------------------------------------------------

Score:	1.2032091618

Content:
	Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.

Metadata:
	id:	32
	last_date_read:	2024-05-01T14:30:00+00:00
	page_number:	32
	president_included:	True
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------

Score:	1.50705266

Content:
	But cancer from prolonged exposure to burn pits ravaged Heath’s lungs and body. 

Danielle says Heath was a fighter to the very end. 

He didn’t know how to stop fighting, and neither did she. 

Through her pain she found purpose to demand we do better. 

Tonight, Danielle—we are. 

The VA is pioneering new ways of linking toxic exposures to diseases, already helping more veterans get benefits. 

And tonight, I’m announcing we’re expanding eligibility to veterans suffering from nine respiratory cancers. 

I’m also calling on Congress: pass a law to make sure veterans devastated by toxic exposures in Iraq and Afghanistan finally get the benefits and comprehensive health care they deserve. 

And fourth, let’s end cancer as we know it. 

This is personal to me and Jill, to Kamala, and to so many of you. 

Cancer is the #2 cause of death in America–second only to heart disease.

Metadata:
	id:	39
	page_number:	39
	president_included:	False
	source:	../../how_to/state_of_the_union.txt
--------------------------------------------------
```

### 컬렉션 삭제
이전에는 `id`를 기반으로 문서를 제거했습니다. 여기에서는 ID가 제공되지 않았으므로 모든 문서가 제거됩니다.

```python
print("Documents before deletion: ", db_FaissFlat.count(collection_name))

db_FaissFlat.delete(collection_name=collection_name)

print("Documents after deletion: ", db_FaissFlat.count(collection_name))
```

```output
Documents before deletion:  40
Documents after deletion:  0
```

## VDMS 서버 중지

```python
!docker kill vdms_vs_test_nb
```

```output
huggingface/tokenizers: The current process just got forked, after parallelism has already been used. Disabling parallelism to avoid deadlocks...
To disable this warning, you can either:
	- Avoid using `tokenizers` before the fork if possible
	- Explicitly set the environment variable TOKENIZERS_PARALLELISM=(true | false)
``````output
vdms_vs_test_nb
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)