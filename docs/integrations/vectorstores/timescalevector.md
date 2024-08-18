---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/timescalevector.ipynb
description: 타임스케일 벡터는 AI 애플리케이션을 위한 PostgreSQL++ 벡터 데이터베이스로, 효율적인 벡터 저장 및 쿼리를 지원합니다.
---

# 타임스케일 벡터 (Postgres)

> [타임스케일 벡터](https://www.timescale.com/ai?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)는 AI 애플리케이션을 위한 `PostgreSQL++` 벡터 데이터베이스입니다.

이 노트북에서는 Postgres 벡터 데이터베이스 `타임스케일 벡터`를 사용하는 방법을 보여줍니다. (1) 의미 검색, (2) 시간 기반 벡터 검색, (3) 자기 쿼리, (4) 쿼리 속도를 높이기 위한 인덱스 생성 방법을 배웁니다.

## 타임스케일 벡터란?

`타임스케일 벡터`는 `PostgreSQL`에서 수백만 개의 벡터 임베딩을 효율적으로 저장하고 쿼리할 수 있게 해줍니다.
- `DiskANN`에서 영감을 받은 인덱싱 알고리즘을 통해 1억 개 이상의 벡터에 대해 더 빠르고 정확한 유사성 검색을 향상시킵니다.
- 자동 시간 기반 파티셔닝 및 인덱싱을 통해 빠른 시간 기반 벡터 검색을 가능하게 합니다.
- 벡터 임베딩 및 관계형 데이터를 쿼리하기 위한 친숙한 SQL 인터페이스를 제공합니다.

`타임스케일 벡터`는 POC에서 프로덕션까지 확장 가능한 AI를 위한 클라우드 `PostgreSQL`입니다:
- 관계형 메타데이터, 벡터 임베딩 및 시계열 데이터를 단일 데이터베이스에 저장할 수 있도록 운영을 간소화합니다.
- 스트리밍 백업 및 복제, 고가용성 및 행 수준 보안과 같은 엔터프라이즈급 기능을 갖춘 견고한 PostgreSQL 기반의 이점을 누립니다.
- 엔터프라이즈급 보안 및 규정 준수로 걱정 없는 경험을 제공합니다.

## 타임스케일 벡터에 접근하는 방법

`타임스케일 벡터`는 클라우드 PostgreSQL 플랫폼인 [타임스케일](https://www.timescale.com/ai?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)에서 사용할 수 있습니다. (현재 자가 호스팅 버전은 없습니다.)

LangChain 사용자는 타임스케일 벡터에 대해 90일 무료 체험을 제공합니다.
- 시작하려면 [가입](https://console.cloud.timescale.com/signup?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)하여 타임스케일에 새로운 데이터베이스를 만들고 이 노트북을 따르세요!
- 자세한 내용과 성능 벤치마크는 [타임스케일 벡터 설명 블로그](https://www.timescale.com/blog/how-we-made-postgresql-the-best-vector-database/?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)를 참조하세요.
- Python에서 타임스케일 벡터를 사용하는 방법에 대한 자세한 내용은 [설치 지침](https://github.com/timescale/python-vector)을 참조하세요.

## 설정

이 튜토리얼을 따르기 위해 준비하는 단계를 따르세요.

```python
# Pip install necessary packages
%pip install --upgrade --quiet  timescale-vector
%pip install --upgrade --quiet  langchain-openai langchain-community
%pip install --upgrade --quiet  tiktoken
```


이 예제에서는 `OpenAIEmbeddings`를 사용할 것이므로 OpenAI API 키를 로드하겠습니다.

```python
import os

# Run export OPENAI_API_KEY=sk-YOUR_OPENAI_API_KEY...
# Get openAI api key by reading local .env file
from dotenv import find_dotenv, load_dotenv

_ = load_dotenv(find_dotenv())
OPENAI_API_KEY = os.environ["OPENAI_API_KEY"]
```


```python
# Get the API key and save it as an environment variable
# import os
# import getpass
# os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")

```


```python
from typing import Tuple
```


다음으로 필요한 Python 라이브러리와 LangChain의 라이브러리를 가져옵니다. `timescale-vector` 라이브러리와 함께 TimescaleVector LangChain 벡터 저장소를 가져옵니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Timescale Vector (Postgres)"}, {"imported": "JSONLoader", "source": "langchain_community.document_loaders.json_loader", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.json_loader.JSONLoader.html", "title": "Timescale Vector (Postgres)"}, {"imported": "TimescaleVector", "source": "langchain_community.vectorstores.timescalevector", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.timescalevector.TimescaleVector.html", "title": "Timescale Vector (Postgres)"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Timescale Vector (Postgres)"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Timescale Vector (Postgres)"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Timescale Vector (Postgres)"}]-->
from datetime import datetime, timedelta

from langchain_community.document_loaders import TextLoader
from langchain_community.document_loaders.json_loader import JSONLoader
from langchain_community.vectorstores.timescalevector import TimescaleVector
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


## 1. 유클리드 거리로 유사성 검색 (기본)

먼저, 주어진 쿼리 문장과 가장 유사한 문장을 찾기 위해 국정 연설에 대한 유사성 검색 쿼리의 예를 살펴보겠습니다. 유사성 메트릭으로 [유클리드 거리](https://en.wikipedia.org/wiki/Euclidean_distance)를 사용할 것입니다.

```python
# Load the text and split it into chunks
loader = TextLoader("../../../extras/modules/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


다음으로, 타임스케일 데이터베이스의 서비스 URL을 로드합니다.

아직 가입하지 않았다면 [타임스케일에 가입하세요](https://console.cloud.timescale.com/signup?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral) 그리고 새로운 데이터베이스를 만드세요.

그런 다음 PostgreSQL 데이터베이스에 연결하려면 서비스 URI가 필요합니다. 이 URI는 새로운 데이터베이스를 만든 후 다운로드한 치트 시트나 `.env` 파일에서 찾을 수 있습니다.

URI는 다음과 같은 형식입니다: `postgres://tsdbadmin:<password>@<id>.tsdb.cloud.timescale.com:<port>/tsdb?sslmode=require`.

```python
# Timescale Vector needs the service url to your cloud database. You can see this as soon as you create the
# service in the cloud UI or in your credentials.sql file
SERVICE_URL = os.environ["TIMESCALE_SERVICE_URL"]

# Specify directly if testing
# SERVICE_URL = "postgres://tsdbadmin:<password>@<id>.tsdb.cloud.timescale.com:<port>/tsdb?sslmode=require"

# # You can get also it from an environment variables. We suggest using a .env file.
# import os
# SERVICE_URL = os.environ.get("TIMESCALE_SERVICE_URL", "")
```


다음으로 타임스케일 벡터 저장소를 생성합니다. 데이터가 저장될 테이블의 이름이 될 컬렉션 이름을 지정합니다.

참고: TimescaleVector의 새 인스턴스를 생성할 때, TimescaleVector 모듈은 컬렉션 이름으로 테이블을 생성하려고 합니다. 따라서 컬렉션 이름이 고유한지 확인하세요 (즉, 이미 존재하지 않아야 합니다).

```python
# The TimescaleVector Module will create a table with the name of the collection.
COLLECTION_NAME = "state_of_the_union_test"

# Create a Timescale Vector instance from the collection of documents
db = TimescaleVector.from_documents(
    embedding=embeddings,
    documents=docs,
    collection_name=COLLECTION_NAME,
    service_url=SERVICE_URL,
)
```


데이터를 로드했으므로 유사성 검색을 수행할 수 있습니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
docs_with_score = db.similarity_search_with_score(query)
```


```python
for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print(doc.page_content)
    print("-" * 80)
```

```output
--------------------------------------------------------------------------------
Score:  0.18443380687035138
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.18452197313308139
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.21720781018594182
A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. 

We can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  

We’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  

We’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. 

We’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.21724902288621384
A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. 

We can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  

We’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  

We’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. 

We’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.
--------------------------------------------------------------------------------
```

### 타임스케일 벡터를 검색기로 사용하기
타임스케일 벡터 저장소를 초기화한 후, 이를 [검색기](/docs/how_to#retrievers)로 사용할 수 있습니다.

```python
# Use TimescaleVector as a retriever
retriever = db.as_retriever()
```


```python
print(retriever)
```

```output
tags=['TimescaleVector', 'OpenAIEmbeddings'] metadata=None vectorstore=<langchain_community.vectorstores.timescalevector.TimescaleVector object at 0x10fc8d070> search_type='similarity' search_kwargs={}
```

타임스케일 벡터를 검색기로 사용하여 RetrievalQA 체인과 스터프 문서 체인을 사용하는 예제를 살펴보겠습니다.

이 예제에서는 위와 동일한 쿼리를 요청하겠지만, 이번에는 타임스케일 벡터에서 반환된 관련 문서를 LLM에 전달하여 질문에 대한 답변을 위한 컨텍스트로 사용할 것입니다.

먼저 스터프 체인을 생성하겠습니다:

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Timescale Vector (Postgres)"}, {"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "Timescale Vector (Postgres)"}]-->
# Initialize GPT3.5 model
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(temperature=0.1, model="gpt-3.5-turbo-16k")

# Initialize a RetrievalQA class from a stuff chain
from langchain.chains import RetrievalQA

qa_stuff = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
    verbose=True,
)
```


```python
query = "What did the president say about Ketanji Brown Jackson?"
response = qa_stuff.run(query)
```

```output


[1m> Entering new RetrievalQA chain...[0m

[1m> Finished chain.[0m
```


```python
print(response)
```

```output
The President said that he nominated Circuit Court of Appeals Judge Ketanji Brown Jackson, who is one of our nation's top legal minds and will continue Justice Breyer's legacy of excellence. He also mentioned that since her nomination, she has received a broad range of support from various groups, including the Fraternal Order of Police and former judges appointed by Democrats and Republicans.
```

## 2. 시간 기반 필터링으로 유사성 검색

타임스케일 벡터의 주요 사용 사례는 효율적인 시간 기반 벡터 검색입니다. 타임스케일 벡터는 벡터(및 관련 메타데이터)를 시간별로 자동으로 파티셔닝하여 이를 가능하게 합니다. 이를 통해 쿼리 벡터와 유사성 및 시간에 따라 벡터를 효율적으로 쿼리할 수 있습니다.

시간 기반 벡터 검색 기능은 다음과 같은 애플리케이션에 유용합니다:
- LLM 응답 기록 저장 및 검색 (예: 챗봇)
- 쿼리 벡터와 유사한 최신 임베딩 찾기 (예: 최근 뉴스).
- 관련 시간 범위로 유사성 검색 제한 (예: 지식 기반에 대한 시간 기반 질문하기)

타임스케일 벡터의 시간 기반 벡터 검색 기능을 사용하는 방법을 설명하기 위해, 타임스케일DB의 git 로그 기록에 대한 질문을 하겠습니다. 시간 기반 UUID를 사용하여 문서를 추가하는 방법과 시간 범위 필터로 유사성 검색을 실행하는 방법을 설명하겠습니다.

### git 로그 JSON에서 콘텐츠 및 메타데이터 추출
먼저 `timescale_commits`라는 PostgreSQL 데이터베이스의 새 컬렉션에 git 로그 데이터를 로드하겠습니다.

문서와 관련된 벡터 임베딩을 기반으로 UUID를 생성하는 도우미 함수를 정의하겠습니다. 이 함수를 사용하여 각 git 로그 항목에 대한 UUID를 생성합니다.

중요한 참고 사항: 문서 작업을 하고 있으며 시간 기반 검색을 위해 벡터와 관련된 현재 날짜와 시간을 원할 경우, 이 단계를 건너뛸 수 있습니다. 문서가 기본적으로 수집될 때 UUID가 자동으로 생성됩니다.

```python
from timescale_vector import client


# Function to take in a date string in the past and return a uuid v1
def create_uuid(date_string: str):
    if date_string is None:
        return None
    time_format = "%a %b %d %H:%M:%S %Y %z"
    datetime_obj = datetime.strptime(date_string, time_format)
    uuid = client.uuid_from_time(datetime_obj)
    return str(uuid)
```


다음으로, JSON 레코드에서 관련 메타데이터를 추출하는 메타데이터 함수를 정의하겠습니다. 이 함수를 JSONLoader에 전달합니다. 자세한 내용은 [JSON 문서 로더 문서](/docs/how_to/document_loader_json)를 참조하세요.

```python
# Helper function to split name and email given an author string consisting of Name Lastname <email>
def split_name(input_string: str) -> Tuple[str, str]:
    if input_string is None:
        return None, None
    start = input_string.find("<")
    end = input_string.find(">")
    name = input_string[:start].strip()
    email = input_string[start + 1 : end].strip()
    return name, email


# Helper function to transform a date string into a timestamp_tz string
def create_date(input_string: str) -> datetime:
    if input_string is None:
        return None
    # Define a dictionary to map month abbreviations to their numerical equivalents
    month_dict = {
        "Jan": "01",
        "Feb": "02",
        "Mar": "03",
        "Apr": "04",
        "May": "05",
        "Jun": "06",
        "Jul": "07",
        "Aug": "08",
        "Sep": "09",
        "Oct": "10",
        "Nov": "11",
        "Dec": "12",
    }

    # Split the input string into its components
    components = input_string.split()
    # Extract relevant information
    day = components[2]
    month = month_dict[components[1]]
    year = components[4]
    time = components[3]
    timezone_offset_minutes = int(components[5])  # Convert the offset to minutes
    timezone_hours = timezone_offset_minutes // 60  # Calculate the hours
    timezone_minutes = timezone_offset_minutes % 60  # Calculate the remaining minutes
    # Create a formatted string for the timestamptz in PostgreSQL format
    timestamp_tz_str = (
        f"{year}-{month}-{day} {time}+{timezone_hours:02}{timezone_minutes:02}"
    )
    return timestamp_tz_str


# Metadata extraction function to extract metadata from a JSON record
def extract_metadata(record: dict, metadata: dict) -> dict:
    record_name, record_email = split_name(record["author"])
    metadata["id"] = create_uuid(record["date"])
    metadata["date"] = create_date(record["date"])
    metadata["author_name"] = record_name
    metadata["author_email"] = record_email
    metadata["commit_hash"] = record["commit"]
    return metadata
```


다음으로 [샘플 데이터 세트](https://s3.amazonaws.com/assets.timescale.com/ai/ts_git_log.json)를 다운로드하여 이 노트북과 동일한 디렉토리에 배치해야 합니다.

다음 명령을 사용할 수 있습니다:

```python
# Download the file using curl and save it as commit_history.csv
# Note: Execute this command in your terminal, in the same directory as the notebook
!curl -O https://s3.amazonaws.com/assets.timescale.com/ai/ts_git_log.json
```


마지막으로 JSON 레코드를 구문 분석하기 위해 JSON 로더를 초기화할 수 있습니다. 간단함을 위해 빈 레코드는 제거합니다.

```python
# Define path to the JSON file relative to this notebook
# Change this to the path to your JSON file
FILE_PATH = "../../../../../ts_git_log.json"

# Load data from JSON file and extract metadata
loader = JSONLoader(
    file_path=FILE_PATH,
    jq_schema=".commit_history[]",
    text_content=False,
    metadata_func=extract_metadata,
)
documents = loader.load()

# Remove documents with None dates
documents = [doc for doc in documents if doc.metadata["date"] is not None]
```


```python
print(documents[0])
```

```output
page_content='{"commit": "44e41c12ab25e36c202f58e068ced262eadc8d16", "author": "Lakshmi Narayanan Sreethar<lakshmi@timescale.com>", "date": "Tue Sep 5 21:03:21 2023 +0530", "change summary": "Fix segfault in set_integer_now_func", "change details": "When an invalid function oid is passed to set_integer_now_func, it finds out that the function oid is invalid but before throwing the error, it calls ReleaseSysCache on an invalid tuple causing a segfault. Fixed that by removing the invalid call to ReleaseSysCache.  Fixes #6037 "}' metadata={'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/ts_git_log.json', 'seq_num': 1, 'id': '8b407680-4c01-11ee-96a6-b82284ddccc6', 'date': '2023-09-5 21:03:21+0850', 'author_name': 'Lakshmi Narayanan Sreethar', 'author_email': 'lakshmi@timescale.com', 'commit_hash': '44e41c12ab25e36c202f58e068ced262eadc8d16'}
```

### 문서 및 메타데이터를 타임스케일 벡터 저장소에 로드하기
이제 문서를 준비했으므로, 이를 처리하고 벡터 임베딩 표현과 함께 타임스케일 벡터 저장소에 로드하겠습니다.

이것은 데모이므로 처음 500개의 레코드만 로드합니다. 실제로는 원하는 만큼 많은 레코드를 로드할 수 있습니다.

```python
NUM_RECORDS = 500
documents = documents[:NUM_RECORDS]
```


그런 다음 CharacterTextSplitter를 사용하여 필요에 따라 문서를 더 작은 조각으로 나눕니다. 이 분할 과정은 각 문서의 메타데이터를 유지합니다.

```python
# Split the documents into chunks for embedding
text_splitter = CharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
)
docs = text_splitter.split_documents(documents)
```


다음으로, 사전 처리된 문서 컬렉션에서 타임스케일 벡터 인스턴스를 생성합니다.

먼저, PostgreSQL 데이터베이스의 테이블 이름이 될 컬렉션 이름을 정의합니다.

또한 `time_partition_interval` 인수에 전달할 시간 델타를 정의합니다. 이는 데이터를 시간별로 파티셔닝하는 간격으로 사용됩니다. 각 파티션은 지정된 시간 길이의 데이터를 포함합니다. 간단함을 위해 7일을 사용할 것이지만, 쿼리에서 최근 벡터를 자주 요청하는 경우 1일과 같은 더 작은 시간 델타를 사용할 수 있으며, 10년 이상의 기간에 걸쳐 벡터를 쿼리하는 경우 6개월 또는 1년과 같은 더 큰 시간 델타를 사용할 수 있습니다.

마지막으로, 타임스케일 벡터 인스턴스를 생성합니다. 사전 처리 단계에서 생성한 메타데이터의 `uuid` 필드를 `ids` 인수로 지정합니다. 이는 UUID의 시간 부분이 과거 날짜(즉, 커밋이 이루어진 날짜)를 반영하도록 하기 위함입니다. 그러나 문서와 관련된 현재 날짜와 시간을 원한다면 id 인수를 제거하면 UUID가 현재 날짜와 시간으로 자동 생성됩니다.

```python
# Define collection name
COLLECTION_NAME = "timescale_commits"
embeddings = OpenAIEmbeddings()

# Create a Timescale Vector instance from the collection of documents
db = TimescaleVector.from_documents(
    embedding=embeddings,
    ids=[doc.metadata["id"] for doc in docs],
    documents=docs,
    collection_name=COLLECTION_NAME,
    service_url=SERVICE_URL,
    time_partition_interval=timedelta(days=7),
)
```


### 시간 및 유사성으로 벡터 쿼리하기

이제 타임스케일 벡터에 문서를 로드했으므로, 시간 및 유사성으로 쿼리할 수 있습니다.

타임스케일 벡터는 시간 기반 필터링으로 유사성 검색을 수행하여 벡터를 쿼리하는 여러 방법을 제공합니다.

아래에서 각 방법을 살펴보겠습니다:

```python
# Time filter variables
start_dt = datetime(2023, 8, 1, 22, 10, 35)  # Start date = 1 August 2023, 22:10:35
end_dt = datetime(2023, 8, 30, 22, 10, 35)  # End date = 30 August 2023, 22:10:35
td = timedelta(days=7)  # Time delta = 7 days

query = "What's new with TimescaleDB functions?"
```


방법 1: 제공된 시작 날짜와 종료 날짜 내에서 필터링합니다.

```python
# Method 1: Query for vectors between start_date and end_date
docs_with_score = db.similarity_search_with_score(
    query, start_date=start_dt, end_date=end_dt
)

for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print("Date: ", doc.metadata["date"])
    print(doc.page_content)
    print("-" * 80)
```

```output
--------------------------------------------------------------------------------
Score:  0.17488396167755127
Date:  2023-08-29 18:13:24+0320
{"commit": " e4facda540286b0affba47ccc63959fefe2a7b26", "author": "Sven Klemm<sven@timescale.com>", "date": "Tue Aug 29 18:13:24 2023 +0200", "change summary": "Add compatibility layer for _timescaledb_internal functions", "change details": "With timescaledb 2.12 all the functions present in _timescaledb_internal were moved into the _timescaledb_functions schema to improve schema security. This patch adds a compatibility layer so external callers of these internal functions will not break and allow for more flexibility when migrating. "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.18102192878723145
Date:  2023-08-20 22:47:10+0320
{"commit": " 0a66bdb8d36a1879246bd652e4c28500c4b951ab", "author": "Sven Klemm<sven@timescale.com>", "date": "Sun Aug 20 22:47:10 2023 +0200", "change summary": "Move functions to _timescaledb_functions schema", "change details": "To increase schema security we do not want to mix our own internal objects with user objects. Since chunks are created in the _timescaledb_internal schema our internal functions should live in a different dedicated schema. This patch make the necessary adjustments for the following functions:  - to_unix_microseconds(timestamptz) - to_timestamp(bigint) - to_timestamp_without_timezone(bigint) - to_date(bigint) - to_interval(bigint) - interval_to_usec(interval) - time_to_internal(anyelement) - subtract_integer_from_now(regclass, bigint) "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.18150119891755445
Date:  2023-08-22 12:01:19+0320
{"commit": " cf04496e4b4237440274eb25e4e02472fc4e06fc", "author": "Sven Klemm<sven@timescale.com>", "date": "Tue Aug 22 12:01:19 2023 +0200", "change summary": "Move utility functions to _timescaledb_functions schema", "change details": "To increase schema security we do not want to mix our own internal objects with user objects. Since chunks are created in the _timescaledb_internal schema our internal functions should live in a different dedicated schema. This patch make the necessary adjustments for the following functions:  - generate_uuid() - get_git_commit() - get_os_info() - tsl_loaded() "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.18422493887617963
Date:  2023-08-9 15:26:03+0500
{"commit": " 44eab9cf9bef34274c88efd37a750eaa74cd8044", "author": "Konstantina Skovola<konstantina@timescale.com>", "date": "Wed Aug 9 15:26:03 2023 +0300", "change summary": "Release 2.11.2", "change details": "This release contains bug fixes since the 2.11.1 release. We recommend that you upgrade at the next available opportunity.  **Features** * #5923 Feature flags for TimescaleDB features  **Bugfixes** * #5680 Fix DISTINCT query with JOIN on multiple segmentby columns * #5774 Fixed two bugs in decompression sorted merge code * #5786 Ensure pg_config --cppflags are passed * #5906 Fix quoting owners in sql scripts. * #5912 Fix crash in 1-step integer policy creation  **Thanks** * @mrksngl for submitting a PR to fix extension upgrade scripts * @ericdevries for reporting an issue with DISTINCT queries using segmentby columns of compressed hypertable "}
--------------------------------------------------------------------------------
```

쿼리가 지정된 날짜 범위 내에서만 결과를 반환하는 것을 주목하세요.

방법 2: 제공된 시작 날짜와 이후의 시간 델타로 필터링합니다.

```python
# Method 2: Query for vectors between start_dt and a time delta td later
# Most relevant vectors between 1 August and 7 days later
docs_with_score = db.similarity_search_with_score(
    query, start_date=start_dt, time_delta=td
)

for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print("Date: ", doc.metadata["date"])
    print(doc.page_content)
    print("-" * 80)
```

```output
--------------------------------------------------------------------------------
Score:  0.18458807468414307
Date:  2023-08-3 14:30:23+0500
{"commit": " 7aeed663b9c0f337b530fd6cad47704a51a9b2ec", "author": "Dmitry Simonenko<dmitry@timescale.com>", "date": "Thu Aug 3 14:30:23 2023 +0300", "change summary": "Feature flags for TimescaleDB features", "change details": "This PR adds several GUCs which allow to enable/disable major timescaledb features:  - enable_hypertable_create - enable_hypertable_compression - enable_cagg_create - enable_policy_create "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.20492422580718994
Date:  2023-08-7 18:31:40+0320
{"commit": " 07762ea4cedefc88497f0d1f8712d1515cdc5b6e", "author": "Sven Klemm<sven@timescale.com>", "date": "Mon Aug 7 18:31:40 2023 +0200", "change summary": "Test timescaledb debian 12 packages in CI", "change details": ""}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.21106326580047607
Date:  2023-08-3 14:36:39+0500
{"commit": " 2863daf3df83c63ee36c0cf7b66c522da5b4e127", "author": "Dmitry Simonenko<dmitry@timescale.com>", "date": "Thu Aug 3 14:36:39 2023 +0300", "change summary": "Support CREATE INDEX ONLY ON main table", "change details": "This PR adds support for CREATE INDEX ONLY ON clause which allows to create index only on the main table excluding chunks.  Fix #5908 "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.21698051691055298
Date:  2023-08-2 20:24:14+0140
{"commit": " 3af0d282ea71d9a8f27159a6171e9516e62ec9cb", "author": "Lakshmi Narayanan Sreethar<lakshmi@timescale.com>", "date": "Wed Aug 2 20:24:14 2023 +0100", "change summary": "PG16: ExecInsertIndexTuples requires additional parameter", "change details": "PG16 adds a new boolean parameter to the ExecInsertIndexTuples function to denote if the index is a BRIN index, which is then used to determine if the index update can be skipped. The fix also removes the INDEX_ATTR_BITMAP_ALL enum value.  Adapt these changes by updating the compat function to accomodate the new parameter added to the ExecInsertIndexTuples function and using an alternative for the removed INDEX_ATTR_BITMAP_ALL enum value.  postgres/postgres@19d8e23 "}
--------------------------------------------------------------------------------
```

다시 한 번, 지정된 시간 필터 내에서 결과를 얻는 것을 주목하세요. 이전 쿼리와는 다릅니다.

방법 3: 제공된 종료 날짜와 이전의 시간 델타로 필터링합니다.

```python
# Method 3: Query for vectors between end_dt and a time delta td earlier
# Most relevant vectors between 30 August and 7 days earlier
docs_with_score = db.similarity_search_with_score(query, end_date=end_dt, time_delta=td)

for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print("Date: ", doc.metadata["date"])
    print(doc.page_content)
    print("-" * 80)
```

```output
--------------------------------------------------------------------------------
Score:  0.17488396167755127
Date:  2023-08-29 18:13:24+0320
{"commit": " e4facda540286b0affba47ccc63959fefe2a7b26", "author": "Sven Klemm<sven@timescale.com>", "date": "Tue Aug 29 18:13:24 2023 +0200", "change summary": "Add compatibility layer for _timescaledb_internal functions", "change details": "With timescaledb 2.12 all the functions present in _timescaledb_internal were moved into the _timescaledb_functions schema to improve schema security. This patch adds a compatibility layer so external callers of these internal functions will not break and allow for more flexibility when migrating. "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.18496227264404297
Date:  2023-08-29 10:49:47+0320
{"commit": " a9751ccd5eb030026d7b975d22753f5964972389", "author": "Sven Klemm<sven@timescale.com>", "date": "Tue Aug 29 10:49:47 2023 +0200", "change summary": "Move partitioning functions to _timescaledb_functions schema", "change details": "To increase schema security we do not want to mix our own internal objects with user objects. Since chunks are created in the _timescaledb_internal schema our internal functions should live in a different dedicated schema. This patch make the necessary adjustments for the following functions:  - get_partition_for_key(val anyelement) - get_partition_hash(val anyelement) "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.1871250867843628
Date:  2023-08-28 23:26:23+0320
{"commit": " b2a91494a11d8b82849b6f11f9ea6dc26ef8a8cb", "author": "Sven Klemm<sven@timescale.com>", "date": "Mon Aug 28 23:26:23 2023 +0200", "change summary": "Move ddl_internal functions to _timescaledb_functions schema", "change details": "To increase schema security we do not want to mix our own internal objects with user objects. Since chunks are created in the _timescaledb_internal schema our internal functions should live in a different dedicated schema. This patch make the necessary adjustments for the following functions:  - chunk_constraint_add_table_constraint(_timescaledb_catalog.chunk_constraint) - chunk_drop_replica(regclass,name) - chunk_index_clone(oid) - chunk_index_replace(oid,oid) - create_chunk_replica_table(regclass,name) - drop_stale_chunks(name,integer[]) - health() - hypertable_constraint_add_table_fk_constraint(name,name,name,integer) - process_ddl_event() - wait_subscription_sync(name,name,integer,numeric) "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.18867712088363497
Date:  2023-08-27 13:20:04+0320
{"commit": " e02b1f348eb4c48def00b7d5227238b4d9d41a4a", "author": "Sven Klemm<sven@timescale.com>", "date": "Sun Aug 27 13:20:04 2023 +0200", "change summary": "Simplify schema move update script", "change details": "Use dynamic sql to create the ALTER FUNCTION statements for those functions that may not exist in previous versions. "}
--------------------------------------------------------------------------------
```

방법 4: 쿼리에서 시작 날짜만 지정하여 주어진 날짜 이후의 모든 벡터를 필터링할 수 있습니다.

방법 5: 마찬가지로, 쿼리에서 종료 날짜만 지정하여 주어진 날짜 이전의 모든 벡터를 필터링할 수 있습니다.

```python
# Method 4: Query all vectors after start_date
docs_with_score = db.similarity_search_with_score(query, start_date=start_dt)

for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print("Date: ", doc.metadata["date"])
    print(doc.page_content)
    print("-" * 80)
```

```output
--------------------------------------------------------------------------------
Score:  0.17488396167755127
Date:  2023-08-29 18:13:24+0320
{"commit": " e4facda540286b0affba47ccc63959fefe2a7b26", "author": "Sven Klemm<sven@timescale.com>", "date": "Tue Aug 29 18:13:24 2023 +0200", "change summary": "Add compatibility layer for _timescaledb_internal functions", "change details": "With timescaledb 2.12 all the functions present in _timescaledb_internal were moved into the _timescaledb_functions schema to improve schema security. This patch adds a compatibility layer so external callers of these internal functions will not break and allow for more flexibility when migrating. "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.18102192878723145
Date:  2023-08-20 22:47:10+0320
{"commit": " 0a66bdb8d36a1879246bd652e4c28500c4b951ab", "author": "Sven Klemm<sven@timescale.com>", "date": "Sun Aug 20 22:47:10 2023 +0200", "change summary": "Move functions to _timescaledb_functions schema", "change details": "To increase schema security we do not want to mix our own internal objects with user objects. Since chunks are created in the _timescaledb_internal schema our internal functions should live in a different dedicated schema. This patch make the necessary adjustments for the following functions:  - to_unix_microseconds(timestamptz) - to_timestamp(bigint) - to_timestamp_without_timezone(bigint) - to_date(bigint) - to_interval(bigint) - interval_to_usec(interval) - time_to_internal(anyelement) - subtract_integer_from_now(regclass, bigint) "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.18150119891755445
Date:  2023-08-22 12:01:19+0320
{"commit": " cf04496e4b4237440274eb25e4e02472fc4e06fc", "author": "Sven Klemm<sven@timescale.com>", "date": "Tue Aug 22 12:01:19 2023 +0200", "change summary": "Move utility functions to _timescaledb_functions schema", "change details": "To increase schema security we do not want to mix our own internal objects with user objects. Since chunks are created in the _timescaledb_internal schema our internal functions should live in a different dedicated schema. This patch make the necessary adjustments for the following functions:  - generate_uuid() - get_git_commit() - get_os_info() - tsl_loaded() "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.18422493887617963
Date:  2023-08-9 15:26:03+0500
{"commit": " 44eab9cf9bef34274c88efd37a750eaa74cd8044", "author": "Konstantina Skovola<konstantina@timescale.com>", "date": "Wed Aug 9 15:26:03 2023 +0300", "change summary": "Release 2.11.2", "change details": "This release contains bug fixes since the 2.11.1 release. We recommend that you upgrade at the next available opportunity.  **Features** * #5923 Feature flags for TimescaleDB features  **Bugfixes** * #5680 Fix DISTINCT query with JOIN on multiple segmentby columns * #5774 Fixed two bugs in decompression sorted merge code * #5786 Ensure pg_config --cppflags are passed * #5906 Fix quoting owners in sql scripts. * #5912 Fix crash in 1-step integer policy creation  **Thanks** * @mrksngl for submitting a PR to fix extension upgrade scripts * @ericdevries for reporting an issue with DISTINCT queries using segmentby columns of compressed hypertable "}
--------------------------------------------------------------------------------
```


```python
# Method 5: Query all vectors before end_date
docs_with_score = db.similarity_search_with_score(query, end_date=end_dt)

for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print("Date: ", doc.metadata["date"])
    print(doc.page_content)
    print("-" * 80)
```

```output
--------------------------------------------------------------------------------
Score:  0.16723191738128662
Date:  2023-04-11 22:01:14+0320
{"commit": " 0595ff0888f2ffb8d313acb0bda9642578a9ade3", "author": "Sven Klemm<sven@timescale.com>", "date": "Tue Apr 11 22:01:14 2023 +0200", "change summary": "Move type support functions into _timescaledb_functions schema", "change details": ""}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.1706540584564209
Date:  2023-04-6 13:00:00+0320
{"commit": " 04f43335dea11e9c467ee558ad8edfc00c1a45ed", "author": "Sven Klemm<sven@timescale.com>", "date": "Thu Apr 6 13:00:00 2023 +0200", "change summary": "Move aggregate support function into _timescaledb_functions", "change details": "This patch moves the support functions for histogram, first and last into the _timescaledb_functions schema. Since we alter the schema of the existing functions in upgrade scripts and do not change the aggregates this should work completely transparently for any user objects using those aggregates. "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.17462033033370972
Date:  2023-03-31 08:22:57+0320
{"commit": " feef9206facc5c5f506661de4a81d96ef059b095", "author": "Sven Klemm<sven@timescale.com>", "date": "Fri Mar 31 08:22:57 2023 +0200", "change summary": "Add _timescaledb_functions schema", "change details": "Currently internal user objects like chunks and our functions live in the same schema making locking down that schema hard. This patch adds a new schema _timescaledb_functions that is meant to be the schema used for timescaledb internal functions to allow separation of code and chunks or other user objects. "}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.17488396167755127
Date:  2023-08-29 18:13:24+0320
{"commit": " e4facda540286b0affba47ccc63959fefe2a7b26", "author": "Sven Klemm<sven@timescale.com>", "date": "Tue Aug 29 18:13:24 2023 +0200", "change summary": "Add compatibility layer for _timescaledb_internal functions", "change details": "With timescaledb 2.12 all the functions present in _timescaledb_internal were moved into the _timescaledb_functions schema to improve schema security. This patch adds a compatibility layer so external callers of these internal functions will not break and allow for more flexibility when migrating. "}
--------------------------------------------------------------------------------
```

주요 요점은 위의 각 결과에서 지정된 시간 범위 내의 벡터만 반환된다는 것입니다. 이러한 쿼리는 관련 파티션만 검색하면 되므로 매우 효율적입니다.

이 기능을 질문 응답에도 사용할 수 있으며, 질문에 대한 답변을 위해 지정된 시간 범위 내에서 가장 관련성이 높은 벡터를 찾고자 할 때 유용합니다. 아래의 예제를 살펴보겠습니다. 타임스케일 벡터를 검색기로 사용합니다:

```python
# Set timescale vector as a retriever and specify start and end dates via kwargs
retriever = db.as_retriever(search_kwargs={"start_date": start_dt, "end_date": end_dt})
```


```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Timescale Vector (Postgres)"}, {"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "Timescale Vector (Postgres)"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(temperature=0.1, model="gpt-3.5-turbo-16k")

from langchain.chains import RetrievalQA

qa_stuff = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
    verbose=True,
)

query = (
    "What's new with the timescaledb functions? Tell me when these changes were made."
)
response = qa_stuff.run(query)
print(response)
```

```output


[1m> Entering new RetrievalQA chain...[0m

[1m> Finished chain.[0m
The following changes were made to the timescaledb functions:

1. "Add compatibility layer for _timescaledb_internal functions" - This change was made on Tue Aug 29 18:13:24 2023 +0200.
2. "Move functions to _timescaledb_functions schema" - This change was made on Sun Aug 20 22:47:10 2023 +0200.
3. "Move utility functions to _timescaledb_functions schema" - This change was made on Tue Aug 22 12:01:19 2023 +0200.
4. "Move partitioning functions to _timescaledb_functions schema" - This change was made on Tue Aug 29 10:49:47 2023 +0200.
```

LLM이 답변을 구성하는 데 사용하는 컨텍스트가 지정된 날짜 범위 내에서 검색된 문서에서만 온다는 점에 유의하세요.

이는 타임스케일 벡터를 사용하여 쿼리와 관련된 시간 범위 내에서 문서를 검색하여 검색 보강 생성을 향상시킬 수 있는 방법을 보여줍니다.

## 3. 쿼리 속도를 높이기 위한 ANN 검색 인덱스 사용

임베딩 열에 인덱스를 생성하여 유사성 쿼리 속도를 높일 수 있습니다. 데이터의 큰 부분을 수집한 후에만 이 작업을 수행해야 합니다.

타임스케일 벡터는 다음과 같은 인덱스를 지원합니다:
- 타임스케일 벡터 인덱스 (tsv): 빠른 유사성 검색을 위한 디스크-ann에서 영감을 받은 그래프 인덱스 (기본값).
- pgvector의 HNSW 인덱스: 빠른 유사성 검색을 위한 계층적 탐색 가능한 소세계 그래프 인덱스.
- pgvector의 IVFFLAT 인덱스: 빠른 유사성 검색을 위한 역파일 인덱스.

중요한 참고 사항: PostgreSQL에서는 각 테이블이 특정 열에 대해 하나의 인덱스만 가질 수 있습니다. 따라서 다양한 인덱스 유형의 성능을 테스트하려면 (1) 서로 다른 인덱스를 가진 여러 테이블을 생성하거나, (2) 동일한 테이블에 여러 벡터 열을 생성하고 각 열에 대해 서로 다른 인덱스를 생성하거나, (3) 동일한 열에 대해 인덱스를 삭제하고 다시 생성하여 결과를 비교할 수 있습니다.

```python
# Initialize an existing TimescaleVector store
COLLECTION_NAME = "timescale_commits"
embeddings = OpenAIEmbeddings()
db = TimescaleVector(
    collection_name=COLLECTION_NAME,
    service_url=SERVICE_URL,
    embedding_function=embeddings,
)
```


추가 인수 없이 `create_index()` 함수를 사용하면 기본적으로 timescale_vector_index가 생성됩니다.

```python
# create an index
# by default this will create a Timescale Vector (DiskANN) index
db.create_index()
```


인덱스의 매개변수를 지정할 수도 있습니다. 다양한 매개변수와 성능에 미치는 영향을 전체적으로 논의한 타임스케일 벡터 문서를 참조하세요.

참고: 스마트 기본값을 설정했기 때문에 매개변수를 지정할 필요는 없습니다. 그러나 특정 데이터 세트에 대해 더 나은 성능을 실험하고 싶다면 항상 자신의 매개변수를 지정할 수 있습니다.

```python
# drop the old index
db.drop_index()

# create an index
# Note: You don't need to specify m and ef_construction parameters as we set smart defaults.
db.create_index(index_type="tsv", max_alpha=1.0, num_neighbors=50)
```


타임스케일 벡터는 HNSW ANN 인덱싱 알고리즘과 ivfflat ANN 인덱싱 알고리즘도 지원합니다. 생성하고자 하는 인덱스를 `index_type` 인수에 지정하고, 선택적으로 인덱스의 매개변수를 지정하세요.

```python
# drop the old index
db.drop_index()

# Create an HNSW index
# Note: You don't need to specify m and ef_construction parameters as we set smart defaults.
db.create_index(index_type="hnsw", m=16, ef_construction=64)
```


```python
# drop the old index
db.drop_index()

# Create an IVFFLAT index
# Note: You don't need to specify num_lists and num_records parameters as we set smart defaults.
db.create_index(index_type="ivfflat", num_lists=20, num_records=1000)
```


일반적으로 기본 타임스케일 벡터 인덱스 또는 HNSW 인덱스를 사용하는 것을 권장합니다.

```python
# drop the old index
db.drop_index()
# Create a new timescale vector index
db.create_index()
```

## 4. 타임스케일 벡터를 이용한 자기 질의 검색기

타임스케일 벡터는 자기 질의 검색기 기능을 지원하여 스스로 쿼리할 수 있는 능력을 제공합니다. 쿼리 문장과 필터(단일 또는 복합)가 포함된 자연어 쿼리가 주어지면, 검색기는 쿼리 구성 LLM 체인을 사용하여 SQL 쿼리를 작성하고 이를 타임스케일 벡터의 PostgreSQL 데이터베이스에 적용합니다.

자기 질의에 대한 자세한 내용은 [문서 참조](/docs/how_to/self_query).

타임스케일 벡터로 자기 질의를 설명하기 위해 3부에서 사용한 동일한 gitlog 데이터셋을 사용할 것입니다.

```python
COLLECTION_NAME = "timescale_commits"
vectorstore = TimescaleVector(
    embedding_function=OpenAIEmbeddings(),
    collection_name=COLLECTION_NAME,
    service_url=SERVICE_URL,
)
```


다음으로 자기 질의 검색기를 생성하겠습니다. 이를 위해 문서가 지원하는 메타데이터 필드에 대한 정보를 미리 제공하고 문서 내용에 대한 간단한 설명이 필요합니다.

```python
<!--IMPORTS:[{"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "Timescale Vector (Postgres)"}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "Timescale Vector (Postgres)"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Timescale Vector (Postgres)"}]-->
from langchain.chains.query_constructor.base import AttributeInfo
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain_openai import OpenAI

# Give LLM info about the metadata fields
metadata_field_info = [
    AttributeInfo(
        name="id",
        description="A UUID v1 generated from the date of the commit",
        type="uuid",
    ),
    AttributeInfo(
        name="date",
        description="The date of the commit in timestamptz format",
        type="timestamptz",
    ),
    AttributeInfo(
        name="author_name",
        description="The name of the author of the commit",
        type="string",
    ),
    AttributeInfo(
        name="author_email",
        description="The email address of the author of the commit",
        type="string",
    ),
]
document_content_description = "The git log commit summary containing the commit hash, author, date of commit, change summary and change details"

# Instantiate the self-query retriever from an LLM
llm = OpenAI(temperature=0)
retriever = SelfQueryRetriever.from_llm(
    llm,
    vectorstore,
    document_content_description,
    metadata_field_info,
    enable_limit=True,
    verbose=True,
)
```


이제 gitlog 데이터셋에서 자기 질의 검색기를 테스트해 보겠습니다.

아래 쿼리를 실행하고 자연어로 쿼리, 필터가 있는 쿼리, 복합 필터가 있는 쿼리(AND, OR 필터)를 지정하는 방법을 주목하십시오. 자기 질의 검색기는 해당 쿼리를 SQL로 변환하고 타임스케일 벡터 PostgreSQL 벡터 저장소에서 검색을 수행합니다.

이것은 자기 질의 검색기의 힘을 보여줍니다. 이를 사용하여 사용자가 SQL을 직접 작성하지 않고도 벡터 저장소에서 복잡한 검색을 수행할 수 있습니다!

```python
# This example specifies a relevant query
retriever.invoke("What are improvements made to continuous aggregates?")
```

```output
/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/libs/langchain/langchain/chains/llm.py:275: UserWarning: The predict_and_parse method is deprecated, instead pass an output parser directly to LLMChain.
  warnings.warn(
``````output
query='improvements to continuous aggregates' filter=None limit=None
```


```output
[Document(page_content='{"commit": " 35c91204987ccb0161d745af1a39b7eb91bc65a5", "author": "Fabr\\u00edzio de Royes Mello<fabriziomello@gmail.com>", "date": "Thu Nov 24 13:19:36 2022 -0300", "change summary": "Add Hierarchical Continuous Aggregates validations", "change details": "Commit 3749953e introduce Hierarchical Continuous Aggregates (aka Continuous Aggregate on top of another Continuous Aggregate) but it lacks of some basic validations.  Validations added during the creation of a Hierarchical Continuous Aggregate:  * Forbid create a continuous aggregate with fixed-width bucket on top of   a continuous aggregate with variable-width bucket.  * Forbid incompatible bucket widths:   - should not be equal;   - bucket width of the new continuous aggregate should be greater than     the source continuous aggregate;   - bucket width of the new continuous aggregate should be multiple of     the source continuous aggregate. "}', metadata={'id': 'c98d1c00-6c13-11ed-9bbe-23925ce74d13', 'date': '2022-11-24 13:19:36+-500', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 446, 'author_name': 'Fabrízio de Royes Mello', 'commit_hash': ' 35c91204987ccb0161d745af1a39b7eb91bc65a5', 'author_email': 'fabriziomello@gmail.com'}),
 Document(page_content='{"commit": " 3749953e9704e45df8f621607989ada0714ce28d", "author": "Fabr\\u00edzio de Royes Mello<fabriziomello@gmail.com>", "date": "Wed Oct 5 18:45:40 2022 -0300", "change summary": "Hierarchical Continuous Aggregates", "change details": "Enable users create Hierarchical Continuous Aggregates (aka Continuous Aggregates on top of another Continuous Aggregates).  With this PR users can create levels of aggregation granularity in Continuous Aggregates making the refresh process even faster.  A problem with this feature can be in upper levels we can end up with the \\"average of averages\\". But to get the \\"real average\\" we can rely on \\"stats_aggs\\" TimescaleDB Toolkit function that calculate and store the partials that can be finalized with other toolkit functions like \\"average\\" and \\"sum\\".  Closes #1400 "}', metadata={'id': '0df31a00-44f7-11ed-9794-ebcc1227340f', 'date': '2022-10-5 18:45:40+-500', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 470, 'author_name': 'Fabrízio de Royes Mello', 'commit_hash': ' 3749953e9704e45df8f621607989ada0714ce28d', 'author_email': 'fabriziomello@gmail.com'}),
 Document(page_content='{"commit": " a6ff7ba6cc15b280a275e5acd315741ec9c86acc", "author": "Mats Kindahl<mats@timescale.com>", "date": "Tue Feb 28 12:04:17 2023 +0100", "change summary": "Rename columns in old-style continuous aggregates", "change details": "For continuous aggregates with the old-style partial aggregates renaming columns that are not in the group-by clause will generate an error when upgrading to a later version. The reason is that it is implicitly assumed that the name of the column is the same as for the direct view. This holds true for new-style continous aggregates, but is not always true for old-style continuous aggregates. In particular, columns that are not part of the `GROUP BY` clause can have an internally generated name.  This commit fixes that by extracting the name of the column from the partial view and use that when renaming the partial view column and the materialized table column. "}', metadata={'id': 'a49ace80-b757-11ed-8138-2390fd44ffd9', 'date': '2023-02-28 12:04:17+0140', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 294, 'author_name': 'Mats Kindahl', 'commit_hash': ' a6ff7ba6cc15b280a275e5acd315741ec9c86acc', 'author_email': 'mats@timescale.com'}),
 Document(page_content='{"commit": " 5bba74a2ec083728f8e93e09d03d102568fd72b5", "author": "Fabr\\u00edzio de Royes Mello<fabriziomello@gmail.com>", "date": "Mon Aug 7 19:49:47 2023 -0300", "change summary": "Relax strong table lock when refreshing a CAGG", "change details": "When refreshing a Continuous Aggregate we take a table lock on _timescaledb_catalog.continuous_aggs_invalidation_threshold when processing the invalidation logs (the first transaction of the refresh Continuous Aggregate procedure). It means that even two different Continuous Aggregates over two different hypertables will wait each other in the first phase of the refreshing procedure. Also it lead to problems when a pg_dump is running because it take an AccessShareLock on tables so Continuous Aggregate refresh execution will wait until the pg_dump finish.  Improved it by relaxing the strong table-level lock to a row-level lock so now the Continuous Aggregate refresh procedure can be executed in multiple sessions with less locks.  Fix #3554 "}', metadata={'id': 'b5583780-3574-11ee-a5ba-2e305874a58f', 'date': '2023-08-7 19:49:47+-500', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 27, 'author_name': 'Fabrízio de Royes Mello', 'commit_hash': ' 5bba74a2ec083728f8e93e09d03d102568fd72b5', 'author_email': 'fabriziomello@gmail.com'})]
```


```python
# This example specifies a filter
retriever.invoke("What commits did Sven Klemm add?")
```

```output
query=' ' filter=Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='author_name', value='Sven Klemm') limit=None
```


```output
[Document(page_content='{"commit": " e2e7ae304521b74ac6b3f157a207da047d44ab06", "author": "Sven Klemm<sven@timescale.com>", "date": "Fri Mar 3 11:22:06 2023 +0100", "change summary": "Don\'t run sanitizer test on individual PRs", "change details": "Sanitizer tests take a long time to run so we don\'t want to run them on individual PRs but instead run them nightly and on commits to master. "}', metadata={'id': '3f401b00-b9ad-11ed-b5ea-a3fd40b9ac16', 'date': '2023-03-3 11:22:06+0140', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 295, 'author_name': 'Sven Klemm', 'commit_hash': ' e2e7ae304521b74ac6b3f157a207da047d44ab06', 'author_email': 'sven@timescale.com'}),
 Document(page_content='{"commit": " d8f19e57a04d17593df5f2c694eae8775faddbc7", "author": "Sven Klemm<sven@timescale.com>", "date": "Wed Feb 1 08:34:20 2023 +0100", "change summary": "Bump version of setup-wsl github action", "change details": "The currently used version pulls in Node.js 12 which is deprecated on github.  https://github.blog/changelog/2022-09-22-github-actions-all-actions-will-begin-running-on-node16-instead-of-node12/ "}', metadata={'id': 'd70de600-a202-11ed-85d6-30b6df240f49', 'date': '2023-02-1 08:34:20+0140', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 350, 'author_name': 'Sven Klemm', 'commit_hash': ' d8f19e57a04d17593df5f2c694eae8775faddbc7', 'author_email': 'sven@timescale.com'}),
 Document(page_content='{"commit": " 83b13cf6f73a74656dde9cc6ec6cf76740cddd3c", "author": "Sven Klemm<sven@timescale.com>", "date": "Fri Nov 25 08:27:45 2022 +0100", "change summary": "Use packaged postgres for sqlsmith and coverity CI", "change details": "The sqlsmith and coverity workflows used the cache postgres build but could not produce a build by themselves and therefore relied on other workflows to produce the cached binaries. This patch changes those workflows to use normal postgres packages instead of custom built postgres to remove that dependency. "}', metadata={'id': 'a786ae80-6c92-11ed-bd6c-a57bd3348b97', 'date': '2022-11-25 08:27:45+0140', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 447, 'author_name': 'Sven Klemm', 'commit_hash': ' 83b13cf6f73a74656dde9cc6ec6cf76740cddd3c', 'author_email': 'sven@timescale.com'}),
 Document(page_content='{"commit": " b1314e63f2ff6151ab5becfb105afa3682286a4d", "author": "Sven Klemm<sven@timescale.com>", "date": "Thu Dec 22 12:03:35 2022 +0100", "change summary": "Fix RPM package test for PG15 on centos 7", "change details": "Installing PG15 on Centos 7 requires the EPEL repository to satisfy the dependencies. "}', metadata={'id': '477b1d80-81e8-11ed-9c8c-9b5abbd67c98', 'date': '2022-12-22 12:03:35+0140', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 408, 'author_name': 'Sven Klemm', 'commit_hash': ' b1314e63f2ff6151ab5becfb105afa3682286a4d', 'author_email': 'sven@timescale.com'})]
```


```python
# This example specifies a query and filter
retriever.invoke("What commits about timescaledb_functions did Sven Klemm add?")
```

```output
query='timescaledb_functions' filter=Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='author_name', value='Sven Klemm') limit=None
```


```output
[Document(page_content='{"commit": " 04f43335dea11e9c467ee558ad8edfc00c1a45ed", "author": "Sven Klemm<sven@timescale.com>", "date": "Thu Apr 6 13:00:00 2023 +0200", "change summary": "Move aggregate support function into _timescaledb_functions", "change details": "This patch moves the support functions for histogram, first and last into the _timescaledb_functions schema. Since we alter the schema of the existing functions in upgrade scripts and do not change the aggregates this should work completely transparently for any user objects using those aggregates. "}', metadata={'id': '2cb47800-d46a-11ed-8f0e-2b624245c561', 'date': '2023-04-6 13:00:00+0320', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 233, 'author_name': 'Sven Klemm', 'commit_hash': ' 04f43335dea11e9c467ee558ad8edfc00c1a45ed', 'author_email': 'sven@timescale.com'}),
 Document(page_content='{"commit": " feef9206facc5c5f506661de4a81d96ef059b095", "author": "Sven Klemm<sven@timescale.com>", "date": "Fri Mar 31 08:22:57 2023 +0200", "change summary": "Add _timescaledb_functions schema", "change details": "Currently internal user objects like chunks and our functions live in the same schema making locking down that schema hard. This patch adds a new schema _timescaledb_functions that is meant to be the schema used for timescaledb internal functions to allow separation of code and chunks or other user objects. "}', metadata={'id': '7a257680-cf8c-11ed-848c-a515e8687479', 'date': '2023-03-31 08:22:57+0320', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 239, 'author_name': 'Sven Klemm', 'commit_hash': ' feef9206facc5c5f506661de4a81d96ef059b095', 'author_email': 'sven@timescale.com'}),
 Document(page_content='{"commit": " 0a66bdb8d36a1879246bd652e4c28500c4b951ab", "author": "Sven Klemm<sven@timescale.com>", "date": "Sun Aug 20 22:47:10 2023 +0200", "change summary": "Move functions to _timescaledb_functions schema", "change details": "To increase schema security we do not want to mix our own internal objects with user objects. Since chunks are created in the _timescaledb_internal schema our internal functions should live in a different dedicated schema. This patch make the necessary adjustments for the following functions:  - to_unix_microseconds(timestamptz) - to_timestamp(bigint) - to_timestamp_without_timezone(bigint) - to_date(bigint) - to_interval(bigint) - interval_to_usec(interval) - time_to_internal(anyelement) - subtract_integer_from_now(regclass, bigint) "}', metadata={'id': 'bb99db00-3f9a-11ee-a8dc-0b9c1a5a37c4', 'date': '2023-08-20 22:47:10+0320', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 41, 'author_name': 'Sven Klemm', 'commit_hash': ' 0a66bdb8d36a1879246bd652e4c28500c4b951ab', 'author_email': 'sven@timescale.com'}),
 Document(page_content='{"commit": " 56ea8b4de93cefc38e002202d8ac96947dcbaa77", "author": "Sven Klemm<sven@timescale.com>", "date": "Thu Apr 13 13:16:14 2023 +0200", "change summary": "Move trigger functions to _timescaledb_functions schema", "change details": "To increase schema security we do not want to mix our own internal objects with user objects. Since chunks are created in the _timescaledb_internal schema our internal functions should live in a different dedicated schema. This patch make the necessary adjustments for our trigger functions. "}', metadata={'id': '9a255300-d9ec-11ed-988f-7086c8ca463a', 'date': '2023-04-13 13:16:14+0320', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 44, 'author_name': 'Sven Klemm', 'commit_hash': ' 56ea8b4de93cefc38e002202d8ac96947dcbaa77', 'author_email': 'sven@timescale.com'})]
```


```python
# This example specifies a time-based filter
retriever.invoke("What commits were added in July 2023?")
```

```output
query=' ' filter=Operation(operator=<Operator.AND: 'and'>, arguments=[Comparison(comparator=<Comparator.GTE: 'gte'>, attribute='date', value='2023-07-01T00:00:00Z'), Comparison(comparator=<Comparator.LTE: 'lte'>, attribute='date', value='2023-07-31T23:59:59Z')]) limit=None
```


```output
[Document(page_content='{"commit": " 5cf354e2469ee7e43248bed382a4b49fc7ccfecd", "author": "Markus Engel<engel@sero-systems.de>", "date": "Mon Jul 31 11:28:25 2023 +0200", "change summary": "Fix quoting owners in sql scripts.", "change details": "When referring to a role from a string type, it must be properly quoted using pg_catalog.quote_ident before it can be casted to regrole. Fixed this, especially in update scripts. "}', metadata={'id': '99590280-2f84-11ee-915b-5715b2447de4', 'date': '2023-07-31 11:28:25+0320', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 76, 'author_name': 'Markus Engel', 'commit_hash': ' 5cf354e2469ee7e43248bed382a4b49fc7ccfecd', 'author_email': 'engel@sero-systems.de'}),
 Document(page_content='{"commit": " 88aaf23ae37fe7f47252b87325eb570aa417c607", "author": "noctarius aka Christoph Engelbert<me@noctarius.com>", "date": "Wed Jul 12 14:53:40 2023 +0200", "change summary": "Allow Replica Identity (Alter Table) on CAGGs (#5868)", "change details": "This commit is a follow up of #5515, which added support for ALTER TABLE\\r ... REPLICA IDENTITY (FULL | INDEX) on hypertables.\\r \\r This commit allows the execution against materialized hypertables to\\r enable update / delete operations on continuous aggregates when logical\\r replication in enabled for them."}', metadata={'id': '1fcfa200-20b3-11ee-9a18-370561c7cb1a', 'date': '2023-07-12 14:53:40+0320', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 96, 'author_name': 'noctarius aka Christoph Engelbert', 'commit_hash': ' 88aaf23ae37fe7f47252b87325eb570aa417c607', 'author_email': 'me@noctarius.com'}),
 Document(page_content='{"commit": " d5268c36fbd23fa2a93c0371998286e8688247bb", "author": "Alexander Kuzmenkov<36882414+akuzm@users.noreply.github.com>", "date": "Fri Jul 28 13:35:05 2023 +0200", "change summary": "Fix SQLSmith workflow", "change details": "The build was failing because it was picking up the wrong version of Postgres. Remove it. "}', metadata={'id': 'cc0fba80-2d3a-11ee-ae7d-36dc25cad3b8', 'date': '2023-07-28 13:35:05+0320', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 82, 'author_name': 'Alexander Kuzmenkov', 'commit_hash': ' d5268c36fbd23fa2a93c0371998286e8688247bb', 'author_email': '36882414+akuzm@users.noreply.github.com'}),
 Document(page_content='{"commit": " 61c288ec5eb966a9b4d8ed90cd026ffc5e3543c9", "author": "Lakshmi Narayanan Sreethar<lakshmi@timescale.com>", "date": "Tue Jul 25 16:11:35 2023 +0530", "change summary": "Fix broken CI after PG12 removal", "change details": "The commit cdea343cc updated the gh_matrix_builder.py script but failed to import PG_LATEST variable into the script thus breaking the CI. Import that variable to fix the CI tests. "}', metadata={'id': 'd3835980-2ad7-11ee-b98d-c4e3092e076e', 'date': '2023-07-25 16:11:35+0850', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 84, 'author_name': 'Lakshmi Narayanan Sreethar', 'commit_hash': ' 61c288ec5eb966a9b4d8ed90cd026ffc5e3543c9', 'author_email': 'lakshmi@timescale.com'})]
```


```python
# This example specifies a query and a LIMIT value
retriever.invoke("What are two commits about hierarchical continuous aggregates?")
```

```output
query='hierarchical continuous aggregates' filter=None limit=2
```


```output
[Document(page_content='{"commit": " 35c91204987ccb0161d745af1a39b7eb91bc65a5", "author": "Fabr\\u00edzio de Royes Mello<fabriziomello@gmail.com>", "date": "Thu Nov 24 13:19:36 2022 -0300", "change summary": "Add Hierarchical Continuous Aggregates validations", "change details": "Commit 3749953e introduce Hierarchical Continuous Aggregates (aka Continuous Aggregate on top of another Continuous Aggregate) but it lacks of some basic validations.  Validations added during the creation of a Hierarchical Continuous Aggregate:  * Forbid create a continuous aggregate with fixed-width bucket on top of   a continuous aggregate with variable-width bucket.  * Forbid incompatible bucket widths:   - should not be equal;   - bucket width of the new continuous aggregate should be greater than     the source continuous aggregate;   - bucket width of the new continuous aggregate should be multiple of     the source continuous aggregate. "}', metadata={'id': 'c98d1c00-6c13-11ed-9bbe-23925ce74d13', 'date': '2022-11-24 13:19:36+-500', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 446, 'author_name': 'Fabrízio de Royes Mello', 'commit_hash': ' 35c91204987ccb0161d745af1a39b7eb91bc65a5', 'author_email': 'fabriziomello@gmail.com'}),
 Document(page_content='{"commit": " 3749953e9704e45df8f621607989ada0714ce28d", "author": "Fabr\\u00edzio de Royes Mello<fabriziomello@gmail.com>", "date": "Wed Oct 5 18:45:40 2022 -0300", "change summary": "Hierarchical Continuous Aggregates", "change details": "Enable users create Hierarchical Continuous Aggregates (aka Continuous Aggregates on top of another Continuous Aggregates).  With this PR users can create levels of aggregation granularity in Continuous Aggregates making the refresh process even faster.  A problem with this feature can be in upper levels we can end up with the \\"average of averages\\". But to get the \\"real average\\" we can rely on \\"stats_aggs\\" TimescaleDB Toolkit function that calculate and store the partials that can be finalized with other toolkit functions like \\"average\\" and \\"sum\\".  Closes #1400 "}', metadata={'id': '0df31a00-44f7-11ed-9794-ebcc1227340f', 'date': '2022-10-5 18:45:40+-500', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 470, 'author_name': 'Fabrízio de Royes Mello', 'commit_hash': ' 3749953e9704e45df8f621607989ada0714ce28d', 'author_email': 'fabriziomello@gmail.com'})]
```


## 5. 기존 타임스케일 벡터 저장소 작업하기

위의 예제에서는 문서 모음에서 벡터 저장소를 생성했습니다. 그러나 종종 기존 벡터 저장소에 데이터를 삽입하고 데이터를 쿼리하고 싶습니다. 기존 문서 모음을 초기화하고 문서를 추가하며 쿼리하는 방법을 살펴보겠습니다.

기존 타임스케일 벡터 저장소에서 작업하려면 쿼리할 테이블의 이름(`COLLECTION_NAME`)과 클라우드 PostgreSQL 데이터베이스의 URL(`SERVICE_URL`)을 알아야 합니다.

```python
# Initialize the existing
COLLECTION_NAME = "timescale_commits"
embeddings = OpenAIEmbeddings()
vectorstore = TimescaleVector(
    collection_name=COLLECTION_NAME,
    service_url=SERVICE_URL,
    embedding_function=embeddings,
)
```


테이블에 새 데이터를 로드하려면 `add_document()` 함수를 사용합니다. 이 함수는 문서 목록과 메타데이터 목록을 받습니다. 메타데이터는 각 문서에 대한 고유 ID를 포함해야 합니다.

문서가 현재 날짜 및 시간과 연결되기를 원한다면 ID 목록을 생성할 필요가 없습니다. 각 문서에 대해 UUID가 자동으로 생성됩니다.

문서가 과거 날짜 및 시간과 연결되기를 원한다면, 위의 2부에서 설명한 대로 `timecale-vector` 파이썬 라이브러리의 `uuid_from_time` 함수를 사용하여 ID 목록을 생성할 수 있습니다. 이 함수는 datetime 객체를 받아 해당 날짜와 시간이 인코딩된 UUID를 반환합니다.

```python
# Add documents to a collection in TimescaleVector
ids = vectorstore.add_documents([Document(page_content="foo")])
ids
```


```output
['a34f2b8a-53d7-11ee-8cc3-de1e4b2a0118']
```


```python
# Query the vectorstore for similar documents
docs_with_score = vectorstore.similarity_search_with_score("foo")
```


```python
docs_with_score[0]
```


```output
(Document(page_content='foo', metadata={}), 5.006789860928507e-06)
```


```python
docs_with_score[1]
```


```output
(Document(page_content='{"commit": " 00b566dfe478c11134bcf1e7bcf38943e7fafe8f", "author": "Fabr\\u00edzio de Royes Mello<fabriziomello@gmail.com>", "date": "Mon Mar 6 15:51:03 2023 -0300", "change summary": "Remove unused functions", "change details": "We don\'t use `ts_catalog_delete[_only]` functions anywhere and instead we rely on `ts_catalog_delete_tid[_only]` functions so removing it from our code base. "}', metadata={'id': 'd7f5c580-bc4f-11ed-9712-ffa0126a201a', 'date': '2023-03-6 15:51:03+-500', 'source': '/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/docs/docs/modules/ts_git_log.json', 'seq_num': 285, 'author_name': 'Fabrízio de Royes Mello', 'commit_hash': ' 00b566dfe478c11134bcf1e7bcf38943e7fafe8f', 'author_email': 'fabriziomello@gmail.com'}),
 0.23607668446580354)
```


### 데이터 삭제

UUID 또는 메타데이터 필터를 사용하여 데이터를 삭제할 수 있습니다.

```python
ids = vectorstore.add_documents([Document(page_content="Bar")])

vectorstore.delete(ids)
```


```output
True
```


메타데이터를 사용하여 삭제하는 것은 특정 소스에서 스크랩한 정보를 주기적으로 업데이트하거나 특정 날짜 또는 기타 메타데이터 속성을 업데이트하려는 경우 특히 유용합니다.

```python
vectorstore.add_documents(
    [Document(page_content="Hello World", metadata={"source": "www.example.com/hello"})]
)
vectorstore.add_documents(
    [Document(page_content="Adios", metadata={"source": "www.example.com/adios"})]
)

vectorstore.delete_by_metadata({"source": "www.example.com/adios"})

vectorstore.add_documents(
    [
        Document(
            page_content="Adios, but newer!",
            metadata={"source": "www.example.com/adios"},
        )
    ]
)
```


```output
['c6367004-53d7-11ee-8cc3-de1e4b2a0118']
```


### 벡터 저장소 덮어쓰기

기존 컬렉션이 있는 경우 `from_documents`를 수행하고 `pre_delete_collection`을 True로 설정하여 덮어씁니다.

```python
db = TimescaleVector.from_documents(
    documents=docs,
    embedding=embeddings,
    collection_name=COLLECTION_NAME,
    service_url=SERVICE_URL,
    pre_delete_collection=True,
)
```


```python
docs_with_score = db.similarity_search_with_score("foo")
```


```python
docs_with_score[0]
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)