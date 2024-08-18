---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/activeloop_deeplake.ipynb
description: Activeloop Deep Lake는 텍스트, 이미지, 오디오 등 다양한 데이터를 저장하고 하이브리드 검색을 지원하는 멀티모달
  벡터 저장소입니다.
---

# Activeloop Deep Lake

> [Activeloop Deep Lake](https://docs.activeloop.ai/)는 텍스트, Json, 이미지, 오디오, 비디오 등 포함하여 임베딩과 그 메타데이터를 저장하는 다중 모달 벡터 저장소입니다. 데이터를 로컬, 클라우드 또는 Activeloop 저장소에 저장합니다. 임베딩과 그 속성을 포함한 하이브리드 검색을 수행합니다.

이 노트북은 `Activeloop Deep Lake`와 관련된 기본 기능을 보여줍니다. `Deep Lake`는 임베딩을 저장할 수 있지만, 모든 유형의 데이터를 저장할 수 있습니다. 버전 관리, 쿼리 엔진 및 딥 러닝 프레임워크에 대한 스트리밍 데이터 로더가 있는 서버리스 데이터 레이크입니다.

자세한 내용은 Deep Lake [문서](https://docs.activeloop.ai) 또는 [API 참조](https://docs.deeplake.ai)를 참조하십시오.

## 설정

```python
%pip install --upgrade --quiet  langchain-openai langchain-community 'deeplake[enterprise]' tiktoken
```


## Activeloop에서 제공하는 예제

[LangChain과의 통합](https://docs.activeloop.ai/tutorials/vector-store/deep-lake-vector-store-in-langchain).

## 로컬 Deep Lake

```python
<!--IMPORTS:[{"imported": "DeepLake", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.deeplake.DeepLake.html", "title": "Activeloop Deep Lake"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Activeloop Deep Lake"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Activeloop Deep Lake"}]-->
from langchain_community.vectorstores import DeepLake
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
activeloop_token = getpass.getpass("activeloop token:")
embeddings = OpenAIEmbeddings()
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Activeloop Deep Lake"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


### 로컬 데이터셋 생성

`./deeplake/`에 로컬 데이터셋을 생성한 후 유사성 검색을 실행합니다. Deeplake+LangChain 통합은 내부적으로 Deep Lake 데이터셋을 사용하므로 `dataset`과 `vector store`는 서로 바꿔 사용할 수 있습니다. 자신의 클라우드 또는 Deep Lake 저장소에 데이터셋을 생성하려면 [경로를 적절히 조정하십시오](https://docs.activeloop.ai/storage-and-credentials/storage-options).

```python
db = DeepLake(dataset_path="./my_deeplake/", embedding=embeddings, overwrite=True)
db.add_documents(docs)
# or shorter
# db = DeepLake.from_documents(docs, dataset_path="./my_deeplake/", embedding=embeddings, overwrite=True)
```


### 데이터셋 쿼리

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)
```

```output

``````output
Dataset(path='./my_deeplake/', tensors=['embedding', 'id', 'metadata', 'text'])

  tensor      htype      shape      dtype  compression
  -------    -------    -------    -------  ------- 
 embedding  embedding  (42, 1536)  float32   None   
    id        text      (42, 1)      str     None   
 metadata     json      (42, 1)      str     None   
   text       text      (42, 1)      str     None
``````output

```

데이터셋 요약 출력을 항상 비활성화하려면 VectorStore 초기화 시 verbose=False를 지정할 수 있습니다.

```python
print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

나중에 임베딩을 재계산하지 않고 데이터셋을 다시 로드할 수 있습니다.

```python
db = DeepLake(dataset_path="./my_deeplake/", embedding=embeddings, read_only=True)
docs = db.similarity_search(query)
```

```output
Deep Lake Dataset in ./my_deeplake/ already exists, loading from the storage
```

현재 Deep Lake는 단일 작성자 및 다수의 독자입니다. `read_only=True`로 설정하면 작성자 잠금을 피할 수 있습니다.

### 검색 질문/답변

```python
<!--IMPORTS:[{"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "Activeloop Deep Lake"}]-->
from langchain.chains import RetrievalQA
from langchain_openai import OpenAIChat

qa = RetrievalQA.from_chain_type(
    llm=OpenAIChat(model="gpt-3.5-turbo"),
    chain_type="stuff",
    retriever=db.as_retriever(),
)
```

```output
/home/ubuntu/langchain_activeloop/langchain/libs/langchain/langchain/llms/openai.py:786: UserWarning: You are trying to use a chat model. This way of initializing it is no longer supported. Instead, please use: `from langchain_openai import ChatOpenAI`
  warnings.warn(
```


```python
query = "What did the president say about Ketanji Brown Jackson"
qa.run(query)
```


```output
'The president said that Ketanji Brown Jackson is a former top litigator in private practice and a former federal public defender. She comes from a family of public school educators and police officers. She is a consensus builder and has received a broad range of support since being nominated.'
```


### 메타데이터에서 속성 기반 필터링

문서가 생성된 연도를 포함하는 메타데이터를 가진 또 다른 벡터 저장소를 생성해 보겠습니다.

```python
import random

for d in docs:
    d.metadata["year"] = random.randint(2012, 2014)

db = DeepLake.from_documents(
    docs, embeddings, dataset_path="./my_deeplake/", overwrite=True
)
```

```output

``````output
Dataset(path='./my_deeplake/', tensors=['embedding', 'id', 'metadata', 'text'])

  tensor      htype      shape     dtype  compression
  -------    -------    -------   -------  ------- 
 embedding  embedding  (4, 1536)  float32   None   
    id        text      (4, 1)      str     None   
 metadata     json      (4, 1)      str     None   
   text       text      (4, 1)      str     None
``````output

```


```python
db.similarity_search(
    "What did the president say about Ketanji Brown Jackson",
    filter={"metadata": {"year": 2013}},
)
```

```output
100%|██████████| 4/4 [00:00<00:00, 2936.16it/s]
```


```output
[Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2013}),
 Document(page_content='A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. \n\nAnd if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. \n\nWe can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  \n\nWe’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  \n\nWe’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. \n\nWe’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2013}),
 Document(page_content='Tonight, I’m announcing a crackdown on these companies overcharging American businesses and consumers. \n\nAnd as Wall Street firms take over more nursing homes, quality in those homes has gone down and costs have gone up.  \n\nThat ends on my watch. \n\nMedicare is going to set higher standards for nursing homes and make sure your loved ones get the care they deserve and expect. \n\nWe’ll also cut costs and keep the economy going strong by giving workers a fair shot, provide more training and apprenticeships, hire them based on their skills not degrees. \n\nLet’s pass the Paycheck Fairness Act and paid leave.  \n\nRaise the minimum wage to $15 an hour and extend the Child Tax Credit, so no one has to raise a family in poverty. \n\nLet’s increase Pell Grants and increase our historic support of HBCUs, and invest in what Jill—our First Lady who teaches full-time—calls America’s best-kept secret: community colleges.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2013})]
```


### 거리 함수 선택
거리 함수 `L2`는 유클리드, `L1`은 핵, `Max`는 l-무한 거리, `cos`는 코사인 유사도, `dot`는 내적입니다.

```python
db.similarity_search(
    "What did the president say about Ketanji Brown Jackson?", distance_metric="cos"
)
```


```output
[Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2013}),
 Document(page_content='A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. \n\nAnd if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. \n\nWe can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  \n\nWe’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  \n\nWe’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. \n\nWe’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2013}),
 Document(page_content='Tonight, I’m announcing a crackdown on these companies overcharging American businesses and consumers. \n\nAnd as Wall Street firms take over more nursing homes, quality in those homes has gone down and costs have gone up.  \n\nThat ends on my watch. \n\nMedicare is going to set higher standards for nursing homes and make sure your loved ones get the care they deserve and expect. \n\nWe’ll also cut costs and keep the economy going strong by giving workers a fair shot, provide more training and apprenticeships, hire them based on their skills not degrees. \n\nLet’s pass the Paycheck Fairness Act and paid leave.  \n\nRaise the minimum wage to $15 an hour and extend the Child Tax Credit, so no one has to raise a family in poverty. \n\nLet’s increase Pell Grants and increase our historic support of HBCUs, and invest in what Jill—our First Lady who teaches full-time—calls America’s best-kept secret: community colleges.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2013}),
 Document(page_content='And for our LGBTQ+ Americans, let’s finally get the bipartisan Equality Act to my desk. The onslaught of state laws targeting transgender Americans and their families is wrong. \n\nAs I said last year, especially to our younger transgender Americans, I will always have your back as your President, so you can be yourself and reach your God-given potential. \n\nWhile it often appears that we never agree, that isn’t true. I signed 80 bipartisan bills into law last year. From preventing government shutdowns to protecting Asian-Americans from still-too-common hate crimes to reforming military justice. \n\nAnd soon, we’ll strengthen the Violence Against Women Act that I first wrote three decades ago. It is important for us to show the nation that we can come together and do big things. \n\nSo tonight I’m offering a Unity Agenda for the Nation. Four big things we can do together.  \n\nFirst, beat the opioid epidemic.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2012})]
```


### 최대 한계 관련성
최대 한계 관련성을 사용합니다.

```python
db.max_marginal_relevance_search(
    "What did the president say about Ketanji Brown Jackson?"
)
```


```output
[Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2013}),
 Document(page_content='Tonight, I’m announcing a crackdown on these companies overcharging American businesses and consumers. \n\nAnd as Wall Street firms take over more nursing homes, quality in those homes has gone down and costs have gone up.  \n\nThat ends on my watch. \n\nMedicare is going to set higher standards for nursing homes and make sure your loved ones get the care they deserve and expect. \n\nWe’ll also cut costs and keep the economy going strong by giving workers a fair shot, provide more training and apprenticeships, hire them based on their skills not degrees. \n\nLet’s pass the Paycheck Fairness Act and paid leave.  \n\nRaise the minimum wage to $15 an hour and extend the Child Tax Credit, so no one has to raise a family in poverty. \n\nLet’s increase Pell Grants and increase our historic support of HBCUs, and invest in what Jill—our First Lady who teaches full-time—calls America’s best-kept secret: community colleges.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2013}),
 Document(page_content='A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. \n\nAnd if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. \n\nWe can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  \n\nWe’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  \n\nWe’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. \n\nWe’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2013}),
 Document(page_content='And for our LGBTQ+ Americans, let’s finally get the bipartisan Equality Act to my desk. The onslaught of state laws targeting transgender Americans and their families is wrong. \n\nAs I said last year, especially to our younger transgender Americans, I will always have your back as your President, so you can be yourself and reach your God-given potential. \n\nWhile it often appears that we never agree, that isn’t true. I signed 80 bipartisan bills into law last year. From preventing government shutdowns to protecting Asian-Americans from still-too-common hate crimes to reforming military justice. \n\nAnd soon, we’ll strengthen the Violence Against Women Act that I first wrote three decades ago. It is important for us to show the nation that we can come together and do big things. \n\nSo tonight I’m offering a Unity Agenda for the Nation. Four big things we can do together.  \n\nFirst, beat the opioid epidemic.', metadata={'source': '../../how_to/state_of_the_union.txt', 'year': 2012})]
```


### 데이터셋 삭제

```python
db.delete_dataset()
```

```output

```

삭제가 실패할 경우 강제 삭제할 수도 있습니다.

```python
DeepLake.force_delete_by_path("./my_deeplake")
```

```output

```

## 클라우드(Activeloop, AWS, GCS 등) 또는 메모리의 Deep Lake 데이터셋
기본적으로 Deep Lake 데이터셋은 로컬에 저장됩니다. 메모리, Deep Lake 관리 DB 또는 기타 객체 저장소에 저장하려면 벡터 저장소를 생성할 때 [해당 경로와 자격 증명을 제공할 수 있습니다](https://docs.activeloop.ai/storage-and-credentials/storage-options). 일부 경로는 Activeloop에 등록하고 [여기에서](https://app.activeloop.ai/) API 토큰을 생성해야 합니다.

```python
os.environ["ACTIVELOOP_TOKEN"] = activeloop_token
```


```python
# Embed and store the texts
username = "<USERNAME_OR_ORG>"  # your username on app.activeloop.ai
dataset_path = f"hub://{username}/langchain_testing_python"  # could be also ./local/path (much faster locally), s3://bucket/path/to/dataset, gcs://path/to/dataset, etc.

docs = text_splitter.split_documents(documents)

embedding = OpenAIEmbeddings()
db = DeepLake(dataset_path=dataset_path, embedding=embeddings, overwrite=True)
ids = db.add_documents(docs)
```

```output
Your Deep Lake dataset has been successfully created!
``````output

``````output
Dataset(path='hub://adilkhan/langchain_testing_python', tensors=['embedding', 'id', 'metadata', 'text'])

  tensor      htype      shape      dtype  compression
  -------    -------    -------    -------  ------- 
 embedding  embedding  (42, 1536)  float32   None   
    id        text      (42, 1)      str     None   
 metadata     json      (42, 1)      str     None   
   text       text      (42, 1)      str     None
``````output

```


```python
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)
print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

#### `tensor_db` 실행 옵션

Deep Lake의 관리 텐서 데이터베이스를 활용하려면 벡터 저장소 생성 시 런타임 매개변수를 {'tensor_db': True}로 지정해야 합니다. 이 구성은 클라이언트 측이 아닌 관리 텐서 데이터베이스에서 쿼리를 실행할 수 있게 합니다. 이 기능은 로컬 또는 메모리에 저장된 데이터셋에는 적용되지 않습니다. 관리 텐서 데이터베이스 외부에서 이미 벡터 저장소가 생성된 경우, 정해진 절차를 따라 관리 텐서 데이터베이스로 전송할 수 있습니다.

```python
# Embed and store the texts
username = "<USERNAME_OR_ORG>"  # your username on app.activeloop.ai
dataset_path = f"hub://{username}/langchain_testing"

docs = text_splitter.split_documents(documents)

embedding = OpenAIEmbeddings()
db = DeepLake(
    dataset_path=dataset_path,
    embedding=embeddings,
    overwrite=True,
    runtime={"tensor_db": True},
)
ids = db.add_documents(docs)
```

```output
Your Deep Lake dataset has been successfully created!
``````output
|
``````output
Dataset(path='hub://adilkhan/langchain_testing', tensors=['embedding', 'id', 'metadata', 'text'])

  tensor      htype      shape      dtype  compression
  -------    -------    -------    -------  ------- 
 embedding  embedding  (42, 1536)  float32   None   
    id        text      (42, 1)      str     None   
 metadata     json      (42, 1)      str     None   
   text       text      (42, 1)      str     None
``````output

```

### TQL 검색

또한, 유사성 검색 방법 내에서 쿼리 실행도 지원되며, 이때 쿼리는 Deep Lake의 텐서 쿼리 언어(TQL)를 사용하여 지정할 수 있습니다.

```python
search_id = db.vectorstore.dataset.id[0].numpy()
```


```python
search_id[0]
```


```output
'8a6ff326-3a85-11ee-b840-13905694aaaf'
```


```python
docs = db.similarity_search(
    query=None,
    tql=f"SELECT * WHERE id == '{search_id[0]}'",
)
```


```python
db.vectorstore.summary()
```

```output
Dataset(path='hub://adilkhan/langchain_testing', tensors=['embedding', 'id', 'metadata', 'text'])

  tensor      htype      shape      dtype  compression
  -------    -------    -------    -------  ------- 
 embedding  embedding  (42, 1536)  float32   None   
    id        text      (42, 1)      str     None   
 metadata     json      (42, 1)      str     None   
   text       text      (42, 1)      str     None
```

### AWS S3에서 벡터 저장소 생성

```python
dataset_path = "s3://BUCKET/langchain_test"  # could be also ./local/path (much faster locally), hub://bucket/path/to/dataset, gcs://path/to/dataset, etc.

embedding = OpenAIEmbeddings()
db = DeepLake.from_documents(
    docs,
    dataset_path=dataset_path,
    embedding=embeddings,
    overwrite=True,
    creds={
        "aws_access_key_id": os.environ["AWS_ACCESS_KEY_ID"],
        "aws_secret_access_key": os.environ["AWS_SECRET_ACCESS_KEY"],
        "aws_session_token": os.environ["AWS_SESSION_TOKEN"],  # Optional
    },
)
```

```output
s3://hub-2.0-datasets-n/langchain_test loaded successfully.
``````output
Evaluating ingest: 100%|██████████| 1/1 [00:10<00:00
\
``````output
Dataset(path='s3://hub-2.0-datasets-n/langchain_test', tensors=['embedding', 'ids', 'metadata', 'text'])

  tensor     htype     shape     dtype  compression
  -------   -------   -------   -------  ------- 
 embedding  generic  (4, 1536)  float32   None   
    ids      text     (4, 1)      str     None   
 metadata    json     (4, 1)      str     None   
   text      text     (4, 1)      str     None
``````output

```

## Deep Lake API
`db.vectorstore`에서 Deep Lake 데이터셋에 접근할 수 있습니다.

```python
# get structure of the dataset
db.vectorstore.summary()
```

```output
Dataset(path='hub://adilkhan/langchain_testing', tensors=['embedding', 'id', 'metadata', 'text'])

  tensor      htype      shape      dtype  compression
  -------    -------    -------    -------  ------- 
 embedding  embedding  (42, 1536)  float32   None   
    id        text      (42, 1)      str     None   
 metadata     json      (42, 1)      str     None   
   text       text      (42, 1)      str     None
```


```python
# get embeddings numpy array
embeds = db.vectorstore.dataset.embedding.numpy()
```


### 로컬 데이터셋을 클라우드로 전송
이미 생성된 데이터셋을 클라우드로 복사합니다. 클라우드에서 로컬로 전송할 수도 있습니다.

```python
import deeplake

username = "davitbun"  # your username on app.activeloop.ai
source = f"hub://{username}/langchain_testing"  # could be local, s3, gcs, etc.
destination = f"hub://{username}/langchain_test_copy"  # could be local, s3, gcs, etc.

deeplake.deepcopy(src=source, dest=destination, overwrite=True)
```

```output
Copying dataset: 100%|██████████| 56/56 [00:38<00:00
``````output
This dataset can be visualized in Jupyter Notebook by ds.visualize() or at https://app.activeloop.ai/davitbun/langchain_test_copy
Your Deep Lake dataset has been successfully created!
The dataset is private so make sure you are logged in!
```


```output
Dataset(path='hub://davitbun/langchain_test_copy', tensors=['embedding', 'ids', 'metadata', 'text'])
```


```python
db = DeepLake(dataset_path=destination, embedding=embeddings)
db.add_documents(docs)
```

```output

``````output
This dataset can be visualized in Jupyter Notebook by ds.visualize() or at https://app.activeloop.ai/davitbun/langchain_test_copy
``````output
/
``````output
hub://davitbun/langchain_test_copy loaded successfully.
``````output
Deep Lake Dataset in hub://davitbun/langchain_test_copy already exists, loading from the storage
``````output
Dataset(path='hub://davitbun/langchain_test_copy', tensors=['embedding', 'ids', 'metadata', 'text'])

  tensor     htype     shape     dtype  compression
  -------   -------   -------   -------  ------- 
 embedding  generic  (4, 1536)  float32   None   
    ids      text     (4, 1)      str     None   
 metadata    json     (4, 1)      str     None   
   text      text     (4, 1)      str     None
``````output
Evaluating ingest: 100%|██████████| 1/1 [00:31<00:00
-
``````output
Dataset(path='hub://davitbun/langchain_test_copy', tensors=['embedding', 'ids', 'metadata', 'text'])

  tensor     htype     shape     dtype  compression
  -------   -------   -------   -------  ------- 
 embedding  generic  (8, 1536)  float32   None   
    ids      text     (8, 1)      str     None   
 metadata    json     (8, 1)      str     None   
   text      text     (8, 1)      str     None
``````output

```


```output
['ad42f3fe-e188-11ed-b66d-41c5f7b85421',
 'ad42f3ff-e188-11ed-b66d-41c5f7b85421',
 'ad42f400-e188-11ed-b66d-41c5f7b85421',
 'ad42f401-e188-11ed-b66d-41c5f7b85421']
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)