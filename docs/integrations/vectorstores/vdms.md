---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/vdms/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/vdms.ipynb
---

# Intel's Visual Data Management System (VDMS)

>Intel's [VDMS](https://github.com/IntelLabs/vdms) is a storage solution for efficient access of big-”visual”-data that aims to achieve cloud scale by searching for relevant visual data via visual metadata stored as a graph and enabling machine friendly enhancements to visual data for faster access. VDMS is licensed under MIT.

VDMS supports:
* K nearest neighbor search
* Euclidean distance (L2) and inner product (IP)
* Libraries for indexing and computing distances: TileDBDense, TileDBSparse, FaissFlat (Default), FaissIVFFlat, Flinng
* Embeddings for text, images, and video
* Vector and metadata searches

VDMS has server and client components. To setup the server, see the [installation instructions](https://github.com/IntelLabs/vdms/blob/master/INSTALL.md) or use the [docker image](https://hub.docker.com/r/intellabs/vdms).

This notebook shows how to use VDMS as a vector store using the docker image.

You'll need to install `langchain-community` with `pip install -qU langchain-community` to use this integration

To begin, install the Python packages for the VDMS client and Sentence Transformers:


```python
# Pip install necessary package
%pip install --upgrade --quiet pip vdms sentence-transformers langchain-huggingface > /dev/null
```
```output
Note: you may need to restart the kernel to use updated packages.
```
## Start VDMS Server
Here we start the VDMS server with port 55555.


```python
!docker run --rm -d -p 55555:55555 --name vdms_vs_test_nb intellabs/vdms:latest
```
```output
b26917ffac236673ef1d035ab9c91fe999e29c9eb24aa6c7103d7baa6bf2f72d
```
## Basic Example (using the Docker Container)

In this basic example, we demonstrate adding documents into VDMS and using it as a vector database.

You can run the VDMS Server in a Docker container separately to use with LangChain which connects to the server via the VDMS Python Client. 

VDMS has the ability to handle multiple collections of documents, but the LangChain interface expects one, so we need to specify the name of the collection . The default collection name used by LangChain is "langchain".



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

Here are some helper functions for printing results.


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

### Load Document and Obtain Embedding Function
Here we load the most recent State of the Union Address and split the document into chunks. 

LangChain vector stores use a string/keyword `id` for bookkeeping documents. By default, `id` is a uuid but here we're defining it as an integer cast as a string. Additional metadata is also provided with the documents and the HuggingFaceEmbeddings are used for this example as the embedding function.


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
### Similarity Search using Faiss Flat and Euclidean Distance (Default)

In this section, we add the documents to VDMS using FAISS IndexFlat indexing (default) and Euclidena distance (default) as the distance metric for simiarity search. We search for three documents (`k=3`) related to the query `What did the president say about Ketanji Brown Jackson`.


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
### Similarity Search using Faiss IVFFlat and Inner Product (IP) Distance

In this section, we add the documents to VDMS using Faiss IndexIVFFlat indexing and IP as the distance metric for similarity search. We search for three documents (`k=3`) related to the query `What did the president say about Ketanji Brown Jackson` and also return the score along with the document.



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
### Similarity Search using FLINNG and IP Distance

In this section, we add the documents to VDMS using Filters to Identify Near-Neighbor Groups (FLINNG) indexing and IP as the distance metric for similarity search. We search for three documents (`k=3`) related to the query `What did the president say about Ketanji Brown Jackson` and also return the score along with the document.


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
### Similarity Search using TileDBDense and Euclidean Distance

In this section, we add the documents to VDMS using TileDB Dense indexing and L2 as the distance metric for similarity search. We search for three documents (`k=3`) related to the query `What did the president say about Ketanji Brown Jackson` and also return the score along with the document.




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
### Update and Delete

While building toward a real application, you want to go beyond adding data, and also update and delete data.

Here is a basic example showing how to do so.  First, we will update the metadata for the document most relevant to the query by adding a date. 


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
Next we will delete the last document by ID (id=42).


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
## Other Information
VDMS supports various types of visual data and operations. Some of the capabilities are integrated in the LangChain interface but additional workflow improvements will be added as VDMS is under continuous development.

Addtional capabilities integrated into LangChain are below.

### Similarity search by vector
Instead of searching by string query, you can also search by embedding/vector.


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
### Filtering on metadata

It can be helpful to narrow down the collection before working with it.

For example, collections can be filtered on metadata using the get method. A dictionary is used to filter metadata. Here we retrieve the document where `id = 2` and remove it from the vector store.


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
### Retriever options

This section goes over different options for how to use VDMS as a retriever.


#### Simiarity Search

Here we use similarity search in the retriever object.



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
#### Maximal Marginal Relevance Search (MMR)

In addition to using similarity search in the retriever object, you can also use `mmr`.


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
We can also use MMR directly.


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
### Delete collection
Previously, we removed documents based on its `id`. Here, all documents are removed since no ID is provided.


```python
print("Documents before deletion: ", db_FaissFlat.count(collection_name))

db_FaissFlat.delete(collection_name=collection_name)

print("Documents after deletion: ", db_FaissFlat.count(collection_name))
```
```output
Documents before deletion:  40
Documents after deletion:  0
```
## Stop VDMS Server


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

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)