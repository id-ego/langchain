---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/aerospike.ipynb
description: 이 문서는 Aerospike Vector Search(AVS)와 LangChain 통합 기능을 소개하며, 대규모 데이터셋에서의
  검색 방법을 설명합니다.
---

# Aerospike

[Aerospike Vector Search](https://aerospike.com/docs/vector) (AVS)는 Aerospike에 저장된 매우 큰 데이터 세트에서 검색을 가능하게 하는 Aerospike 데이터베이스의 확장입니다. 이 새로운 서비스는 Aerospike 외부에서 실행되며 이러한 검색을 수행하기 위해 인덱스를 구축합니다.

이 노트북은 LangChain Aerospike VectorStore 통합의 기능을 보여줍니다.

## AVS 설치

이 노트북을 사용하기 전에 실행 중인 AVS 인스턴스가 필요합니다. [사용 가능한 설치 방법](https://aerospike.com/docs/vector/install) 중 하나를 사용하세요.

완료되면 이 데모에서 나중에 사용할 AVS 인스턴스의 IP 주소와 포트를 저장하세요:

```python
PROXIMUS_HOST = "<avs-ip>"
PROXIMUS_PORT = 5000
```


## 종속성 설치
`sentence-transformers` 종속성은 큽니다. 이 단계는 완료하는 데 몇 분이 걸릴 수 있습니다.

```python
!pip install --upgrade --quiet aerospike-vector-search==0.6.1 langchain-community sentence-transformers langchain
```


## 인용구 데이터 세트 다운로드

약 100,000개의 인용구 데이터 세트를 다운로드하고 그 인용구의 하위 집합을 사용하여 의미 검색을 수행합니다.

```python
!wget https://github.com/aerospike/aerospike-vector-search-examples/raw/7dfab0fccca0852a511c6803aba46578729694b5/quote-semantic-search/container-volumes/quote-search/data/quotes.csv.tgz
```

```output
--2024-05-10 17:28:17--  https://github.com/aerospike/aerospike-vector-search-examples/raw/7dfab0fccca0852a511c6803aba46578729694b5/quote-semantic-search/container-volumes/quote-search/data/quotes.csv.tgz
Resolving github.com (github.com)... 140.82.116.4
Connecting to github.com (github.com)|140.82.116.4|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://raw.githubusercontent.com/aerospike/aerospike-vector-search-examples/7dfab0fccca0852a511c6803aba46578729694b5/quote-semantic-search/container-volumes/quote-search/data/quotes.csv.tgz [following]
--2024-05-10 17:28:17--  https://raw.githubusercontent.com/aerospike/aerospike-vector-search-examples/7dfab0fccca0852a511c6803aba46578729694b5/quote-semantic-search/container-volumes/quote-search/data/quotes.csv.tgz
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 185.199.110.133, 185.199.109.133, 185.199.111.133, ...
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|185.199.110.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 11597643 (11M) [application/octet-stream]
Saving to: ‘quotes.csv.tgz’

quotes.csv.tgz      100%[===================>]  11.06M  1.94MB/s    in 6.1s    

2024-05-10 17:28:23 (1.81 MB/s) - ‘quotes.csv.tgz’ saved [11597643/11597643]
```

## 인용구를 문서로 로드

`CSVLoader` 문서 로더를 사용하여 인용구 데이터 세트를 로드합니다. 이 경우 `lazy_load`는 인용구를 보다 효율적으로 수집하기 위해 반복자를 반환합니다. 이 예제에서는 5,000개의 인용구만 로드합니다.

```python
<!--IMPORTS:[{"imported": "CSVLoader", "source": "langchain_community.document_loaders.csv_loader", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.csv_loader.CSVLoader.html", "title": "Aerospike"}]-->
import itertools
import os
import tarfile

from langchain_community.document_loaders.csv_loader import CSVLoader

filename = "./quotes.csv"

if not os.path.exists(filename) and os.path.exists(filename + ".tgz"):
    # Untar the file
    with tarfile.open(filename + ".tgz", "r:gz") as tar:
        tar.extractall(path=os.path.dirname(filename))

NUM_QUOTES = 5000
documents = CSVLoader(filename, metadata_columns=["author", "category"]).lazy_load()
documents = list(
    itertools.islice(documents, NUM_QUOTES)
)  # Allows us to slice an iterator
```


```python
print(documents[0])
```

```output
page_content="quote: I'm selfish, impatient and a little insecure. I make mistakes, I am out of control and at times hard to handle. But if you can't handle me at my worst, then you sure as hell don't deserve me at my best." metadata={'source': './quotes.csv', 'row': 0, 'author': 'Marilyn Monroe', 'category': 'attributed-no-source, best, life, love, mistakes, out-of-control, truth, worst'}
```

## 임베더 생성

이 단계에서는 HuggingFaceEmbeddings와 "all-MiniLM-L6-v2" 문장 변환기 모델을 사용하여 문서를 임베드하여 벡터 검색을 수행할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "HuggingFaceEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "Aerospike"}]-->
from aerospike_vector_search.types import VectorDistanceMetric
from langchain_community.embeddings import HuggingFaceEmbeddings

MODEL_DIM = 384
MODEL_DISTANCE_CALC = VectorDistanceMetric.COSINE
embedder = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
```


```output
modules.json:   0%|          | 0.00/349 [00:00<?, ?B/s]
```


```output
config_sentence_transformers.json:   0%|          | 0.00/116 [00:00<?, ?B/s]
```


```output
README.md:   0%|          | 0.00/10.7k [00:00<?, ?B/s]
```


```output
sentence_bert_config.json:   0%|          | 0.00/53.0 [00:00<?, ?B/s]
```

```output
/opt/conda/lib/python3.11/site-packages/huggingface_hub/file_download.py:1132: FutureWarning: `resume_download` is deprecated and will be removed in version 1.0.0. Downloads always resume when possible. If you want to force a new download, use `force_download=True`.
  warnings.warn(
```

```output
config.json:   0%|          | 0.00/612 [00:00<?, ?B/s]
```

```output
/opt/conda/lib/python3.11/site-packages/huggingface_hub/file_download.py:1132: FutureWarning: `resume_download` is deprecated and will be removed in version 1.0.0. Downloads always resume when possible. If you want to force a new download, use `force_download=True`.
  warnings.warn(
```

```output
model.safetensors:   0%|          | 0.00/90.9M [00:00<?, ?B/s]
```


```output
tokenizer_config.json:   0%|          | 0.00/350 [00:00<?, ?B/s]
```


```output
vocab.txt:   0%|          | 0.00/232k [00:00<?, ?B/s]
```


```output
tokenizer.json:   0%|          | 0.00/466k [00:00<?, ?B/s]
```


```output
special_tokens_map.json:   0%|          | 0.00/112 [00:00<?, ?B/s]
```


```output
1_Pooling/config.json:   0%|          | 0.00/190 [00:00<?, ?B/s]
```


## Aerospike 인덱스 생성 및 문서 임베드

문서를 추가하기 전에 Aerospike 데이터베이스에 인덱스를 생성해야 합니다. 아래 예제에서는 예상 인덱스가 이미 존재하는지 확인하는 편리한 코드를 사용합니다.

```python
<!--IMPORTS:[{"imported": "Aerospike", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.aerospike.Aerospike.html", "title": "Aerospike"}]-->
from aerospike_vector_search import AdminClient, Client, HostPort
from aerospike_vector_search.types import VectorDistanceMetric
from langchain_community.vectorstores import Aerospike

# Here we are using the AVS host and port you configured earlier
seed = HostPort(host=PROXIMUS_HOST, port=PROXIMUS_PORT)

# The namespace of where to place our vectors. This should match the vector configured in your docstore.conf file.
NAMESPACE = "test"

# The name of our new index.
INDEX_NAME = "quote-miniLM-L6-v2"

# AVS needs to know which metadata key contains our vector when creating the index and inserting documents.
VECTOR_KEY = "vector"

client = Client(seeds=seed)
admin_client = AdminClient(
    seeds=seed,
)
index_exists = False

# Check if the index already exists. If not, create it
for index in admin_client.index_list():
    if index["id"]["namespace"] == NAMESPACE and index["id"]["name"] == INDEX_NAME:
        index_exists = True
        print(f"{INDEX_NAME} already exists. Skipping creation")
        break

if not index_exists:
    print(f"{INDEX_NAME} does not exist. Creating index")
    admin_client.index_create(
        namespace=NAMESPACE,
        name=INDEX_NAME,
        vector_field=VECTOR_KEY,
        vector_distance_metric=MODEL_DISTANCE_CALC,
        dimensions=MODEL_DIM,
        index_meta_data={
            "model": "miniLM-L6-v2",
            "date": "05/04/2024",
            "dim": str(MODEL_DIM),
            "distance": "cosine",
        },
    )

admin_client.close()

docstore = Aerospike.from_documents(
    documents,
    embedder,
    client=client,
    namespace=NAMESPACE,
    vector_key=VECTOR_KEY,
    index_name=INDEX_NAME,
    distance_strategy=MODEL_DISTANCE_CALC,
)
```

```output
quote-miniLM-L6-v2 does not exist. Creating index
```

## 문서 검색
이제 벡터를 임베드했으므로 인용구에 대해 벡터 검색을 사용할 수 있습니다.

```python
query = "A quote about the beauty of the cosmos"
docs = docstore.similarity_search(
    query, k=5, index_name=INDEX_NAME, metadata_keys=["_id", "author"]
)


def print_documents(docs):
    for i, doc in enumerate(docs):
        print("~~~~ Document", i, "~~~~")
        print("auto-generated id:", doc.metadata["_id"])
        print("author: ", doc.metadata["author"])
        print(doc.page_content)
        print("~~~~~~~~~~~~~~~~~~~~\n")


print_documents(docs)
```

```output
~~~~ Document 0 ~~~~
auto-generated id: f53589dd-e3e0-4f55-8214-766ca8dc082f
author:  Carl Sagan, Cosmos
quote: The Cosmos is all that is or was or ever will be. Our feeblest contemplations of the Cosmos stir us -- there is a tingling in the spine, a catch in the voice, a faint sensation, as if a distant memory, of falling from a height. We know we are approaching the greatest of mysteries.
~~~~~~~~~~~~~~~~~~~~

~~~~ Document 1 ~~~~
auto-generated id: dde3e5d1-30b7-47b4-aab7-e319d14e1810
author:  Elizabeth Gilbert
quote: The love that moves the sun and the other stars.
~~~~~~~~~~~~~~~~~~~~

~~~~ Document 2 ~~~~
auto-generated id: fd56575b-2091-45e7-91c1-9efff2fe5359
author:  Renee Ahdieh, The Rose & the Dagger
quote: From the stars, to the stars.
~~~~~~~~~~~~~~~~~~~~

~~~~ Document 3 ~~~~
auto-generated id: 8567ed4e-885b-44a7-b993-e0caf422b3c9
author:  Dante Alighieri, Paradiso
quote: Love, that moves the sun and the other stars
~~~~~~~~~~~~~~~~~~~~

~~~~ Document 4 ~~~~
auto-generated id: f868c25e-c54d-48cd-a5a8-14bf402f9ea8
author:  Thich Nhat Hanh, Teachings on Love
quote: Through my love for you, I want to express my love for the whole cosmos, the whole of humanity, and all beings. By living with you, I want to learn to love everyone and all species. If I succeed in loving you, I will be able to love everyone and all species on Earth... This is the real message of love.
~~~~~~~~~~~~~~~~~~~~
```

## 텍스트로 추가 인용구 임베딩

`add_texts`를 사용하여 추가 인용구를 추가할 수 있습니다.

```python
docstore = Aerospike(
    client,
    embedder,
    NAMESPACE,
    index_name=INDEX_NAME,
    vector_key=VECTOR_KEY,
    distance_strategy=MODEL_DISTANCE_CALC,
)

ids = docstore.add_texts(
    [
        "quote: Rebellions are built on hope.",
        "quote: Logic is the beginning of wisdom, not the end.",
        "quote: If wishes were fishes, we’d all cast nets.",
    ],
    metadatas=[
        {"author": "Jyn Erso, Rogue One"},
        {"author": "Spock, Star Trek"},
        {"author": "Frank Herbert, Dune"},
    ],
)

print("New IDs")
print(ids)
```

```output
New IDs
['972846bd-87ae-493b-8ba3-a3d023c03948', '8171122e-cbda-4eb7-a711-6625b120893b', '53b54409-ac19-4d90-b518-d7c40bf5ee5d']
```

## 최대 한계 관련성 검색을 사용한 문서 검색

최대 한계 관련성 검색을 사용하여 쿼리와 유사하지만 서로 다르도록 벡터를 찾을 수 있습니다. 이 예제에서는 `as_retriever`를 사용하여 검색기 객체를 생성하지만 `docstore.max_marginal_relevance_search`를 직접 호출하여도 쉽게 수행할 수 있습니다. `lambda_mult` 검색 인수는 쿼리 응답의 다양성을 결정합니다. 0은 최대 다양성에 해당하고 1은 최소 다양성에 해당합니다.

```python
query = "A quote about our favorite four-legged pets"
retriever = docstore.as_retriever(
    search_type="mmr", search_kwargs={"fetch_k": 20, "lambda_mult": 0.7}
)
matched_docs = retriever.invoke(query)

print_documents(matched_docs)
```

```output
~~~~ Document 0 ~~~~
auto-generated id: 67d5b23f-b2d2-4872-80ad-5834ea08aa64
author:  John Grogan, Marley and Me: Life and Love With the World's Worst Dog
quote: Such short little lives our pets have to spend with us, and they spend most of it waiting for us to come home each day. It is amazing how much love and laughter they bring into our lives and even how much closer we become with each other because of them.
~~~~~~~~~~~~~~~~~~~~

~~~~ Document 1 ~~~~
auto-generated id: a9b28eb0-a21c-45bf-9e60-ab2b80e988d8
author:  John Grogan, Marley and Me: Life and Love With the World's Worst Dog
quote: Dogs are great. Bad dogs, if you can really call them that, are perhaps the greatest of them all.
~~~~~~~~~~~~~~~~~~~~

~~~~ Document 2 ~~~~
auto-generated id: ee7434c8-2551-4651-8a22-58514980fb4a
author:  Colleen Houck, Tiger's Curse
quote: He then put both hands on the door on either side of my head and leaned in close, pinning me against it. I trembled like a downy rabbit caught in the clutches of a wolf. The wolf came closer. He bent his head and began nuzzling my cheek. The problem was…I wanted the wolf to devour me.
~~~~~~~~~~~~~~~~~~~~

~~~~ Document 3 ~~~~
auto-generated id: 9170804c-a155-473b-ab93-8a561dd48f91
author:  Ray Bradbury
quote: Stuff your eyes with wonder," he said, "live as if you'd drop dead in ten seconds. See the world. It's more fantastic than any dream made or paid for in factories. Ask no guarantees, ask for no security, there never was such an animal. And if there were, it would be related to the great sloth which hangs upside down in a tree all day every day, sleeping its life away. To hell with that," he said, "shake the tree and knock the great sloth down on his ass.
~~~~~~~~~~~~~~~~~~~~
```

## 관련성 임계값으로 문서 검색

또 다른 유용한 기능은 관련성 임계값을 가진 유사성 검색입니다. 일반적으로 우리는 쿼리와 가장 유사하지만 어느 정도 근접 범위 내에 있는 결과만 원합니다. 관련성 1은 가장 유사하고 관련성 0은 가장 비유사합니다.

```python
query = "A quote about stormy weather"
retriever = docstore.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={
        "score_threshold": 0.4
    },  # A greater value returns items with more relevance
)
matched_docs = retriever.invoke(query)

print_documents(matched_docs)
```

```output
~~~~ Document 0 ~~~~
auto-generated id: 2c1d6ee1-b742-45ea-bed6-24a1f655c849
author:  Roy T. Bennett, The Light in the Heart
quote: Never lose hope. Storms make people stronger and never last forever.
~~~~~~~~~~~~~~~~~~~~

~~~~ Document 1 ~~~~
auto-generated id: 5962c2cf-ffb5-4e03-9257-bdd630b5c7e9
author:  Roy T. Bennett, The Light in the Heart
quote: Difficulties and adversities viciously force all their might on us and cause us to fall apart, but they are necessary elements of individual growth and reveal our true potential. We have got to endure and overcome them, and move forward. Never lose hope. Storms make people stronger and never last forever.
~~~~~~~~~~~~~~~~~~~~

~~~~ Document 2 ~~~~
auto-generated id: 3bbcc4ca-de89-4196-9a46-190a50bf6c47
author:  Vincent van Gogh, The Letters of Vincent van Gogh
quote: There is peace even in the storm
~~~~~~~~~~~~~~~~~~~~

~~~~ Document 3 ~~~~
auto-generated id: 37d8cf02-fc2f-429d-b2b6-260a05286108
author:  Edwin Morgan, A Book of Lives
quote: Valentine WeatherKiss me with rain on your eyelashes,come on, let us sway together,under the trees, and to hell with thunder.
~~~~~~~~~~~~~~~~~~~~
```

## 정리

리소스를 해제하고 스레드를 정리하기 위해 클라이언트를 닫아야 합니다.

```python
client.close()
```


## 준비 완료. 검색 시작!

이제 Aerospike Vector Search의 LangChain 통합에 대한 이해가 깊어졌으므로 Aerospike 데이터베이스와 LangChain 생태계를 손끝에서 활용할 수 있습니다. 행복한 빌딩 되세요!

## 관련 문서

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)