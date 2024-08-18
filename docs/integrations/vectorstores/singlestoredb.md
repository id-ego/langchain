---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/singlestoredb.ipynb
description: SingleStoreDB는 클라우드 및 온프레미스 환경에서 뛰어난 성능을 제공하는 분산 SQL 데이터베이스 솔루션입니다. 벡터
  저장 및 연산 지원이 특징입니다.
---

# SingleStoreDB
> [SingleStoreDB](https://singlestore.com/)는 클라우드([cloud](https://www.singlestore.com/cloud/)) 및 온프레미스 환경 모두에서 뛰어난 성능을 발휘하도록 설계된 강력하고 고성능의 분산 SQL 데이터베이스 솔루션입니다. 다재다능한 기능 세트를 자랑하며, 원활한 배포 옵션을 제공하면서 비할 데 없는 성능을 제공합니다.

SingleStoreDB의 두드러진 특징은 벡터 저장 및 작업에 대한 고급 지원으로, 텍스트 유사성 매칭과 같은 복잡한 AI 기능이 필요한 애플리케이션에 이상적인 선택입니다. [dot_product](https://docs.singlestore.com/managed-service/en/reference/sql-reference/vector-functions/dot_product.html) 및 [euclidean_distance](https://docs.singlestore.com/managed-service/en/reference/sql-reference/vector-functions/euclidean_distance.html)와 같은 내장 벡터 기능을 통해 SingleStoreDB는 개발자가 정교한 알고리즘을 효율적으로 구현할 수 있도록 합니다.

SingleStoreDB 내에서 벡터 데이터를 활용하고자 하는 개발자를 위해, [벡터 데이터 작업](https://docs.singlestore.com/managed-service/en/developer-resources/functional-extensions/working-with-vector-data.html)에 대한 포괄적인 튜토리얼이 제공됩니다. 이 튜토리얼은 SingleStoreDB 내의 벡터 저장소를 탐구하며, 벡터 유사성을 기반으로 검색을 용이하게 하는 능력을 보여줍니다. 벡터 인덱스를 활용하여 쿼리를 놀라운 속도로 실행할 수 있어 관련 데이터를 신속하게 검색할 수 있습니다.

또한, SingleStoreDB의 벡터 저장소는 [Lucene 기반의 전체 텍스트 인덱싱](https://docs.singlestore.com/cloud/developer-resources/functional-extensions/working-with-full-text-search/)과 원활하게 통합되어 강력한 텍스트 유사성 검색을 가능하게 합니다. 사용자는 문서 메타데이터 객체의 선택된 필드를 기반으로 검색 결과를 필터링하여 쿼리의 정확성을 높일 수 있습니다.

SingleStoreDB의 차별점은 벡터 및 전체 텍스트 검색을 다양한 방식으로 결합할 수 있는 능력으로, 유연성과 다재다능함을 제공합니다. 텍스트 또는 벡터 유사성에 따라 사전 필터링을 하거나 가장 관련성이 높은 데이터를 선택하거나, 최종 유사성 점수를 계산하기 위해 가중 합계 접근 방식을 사용하는 등 개발자는 여러 옵션을 사용할 수 있습니다.

본질적으로, SingleStoreDB는 벡터 데이터를 관리하고 쿼리하는 포괄적인 솔루션을 제공하며, AI 기반 애플리케이션을 위한 비할 데 없는 성능과 유연성을 제공합니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

```python
# Establishing a connection to the database is facilitated through the singlestoredb Python connector.
# Please ensure that this connector is installed in your working environment.
%pip install --upgrade --quiet  singlestoredb
```


```python
import getpass
import os

# We want to use OpenAIEmbeddings so we have to get the OpenAI API Key.
os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


```python
<!--IMPORTS:[{"imported": "SingleStoreDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.singlestoredb.SingleStoreDB.html", "title": "SingleStoreDB"}, {"imported": "DistanceStrategy", "source": "langchain_community.vectorstores.utils", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.utils.DistanceStrategy.html", "title": "SingleStoreDB"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "SingleStoreDB"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "SingleStoreDB"}]-->
from langchain_community.vectorstores import SingleStoreDB
from langchain_community.vectorstores.utils import DistanceStrategy
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
```


```python
# loading docs
# we will use some artificial data for this example
docs = [
    Document(
        page_content="""In the parched desert, a sudden rainstorm brought relief,
            as the droplets danced upon the thirsty earth, rejuvenating the landscape
            with the sweet scent of petrichor.""",
        metadata={"category": "rain"},
    ),
    Document(
        page_content="""Amidst the bustling cityscape, the rain fell relentlessly,
            creating a symphony of pitter-patter on the pavement, while umbrellas
            bloomed like colorful flowers in a sea of gray.""",
        metadata={"category": "rain"},
    ),
    Document(
        page_content="""High in the mountains, the rain transformed into a delicate
            mist, enveloping the peaks in a mystical veil, where each droplet seemed to
            whisper secrets to the ancient rocks below.""",
        metadata={"category": "rain"},
    ),
    Document(
        page_content="""Blanketing the countryside in a soft, pristine layer, the
            snowfall painted a serene tableau, muffling the world in a tranquil hush
            as delicate flakes settled upon the branches of trees like nature's own 
            lacework.""",
        metadata={"category": "snow"},
    ),
    Document(
        page_content="""In the urban landscape, snow descended, transforming
            bustling streets into a winter wonderland, where the laughter of
            children echoed amidst the flurry of snowballs and the twinkle of
            holiday lights.""",
        metadata={"category": "snow"},
    ),
    Document(
        page_content="""Atop the rugged peaks, snow fell with an unyielding
            intensity, sculpting the landscape into a pristine alpine paradise,
            where the frozen crystals shimmered under the moonlight, casting a
            spell of enchantment over the wilderness below.""",
        metadata={"category": "snow"},
    ),
]

embeddings = OpenAIEmbeddings()
```


데이터베이스에 대한 [연결](https://singlestoredb-python.labs.singlestore.com/generated/singlestoredb.connect.html)을 설정하는 방법에는 여러 가지가 있습니다. 환경 변수를 설정하거나 `SingleStoreDB 생성자`에 명명된 매개변수를 전달할 수 있습니다. 또는 이러한 매개변수를 `from_documents` 및 `from_texts` 메서드에 제공할 수 있습니다.

```python
# Setup connection url as environment variable
os.environ["SINGLESTOREDB_URL"] = "root:pass@localhost:3306/db"

# Load documents to the store
docsearch = SingleStoreDB.from_documents(
    docs,
    embeddings,
    table_name="notebook",  # use table with a custom name
)
```


```python
query = "trees in the snow"
docs = docsearch.similarity_search(query)  # Find documents that correspond to the query
print(docs[0].page_content)
```


SingleStoreDB는 사용자가 메타데이터 필드를 기반으로 검색 결과를 향상시키고 정제할 수 있도록 하여 검색 기능을 향상시킵니다. 이 기능은 개발자와 데이터 분석가가 쿼리를 세밀하게 조정할 수 있도록 하여 검색 결과가 요구 사항에 정확하게 맞춰지도록 합니다. 특정 메타데이터 속성을 사용하여 검색 결과를 필터링함으로써 사용자는 쿼리의 범위를 좁히고 관련 데이터 하위 집합에만 집중할 수 있습니다.

```python
query = "trees branches"
docs = docsearch.similarity_search(
    query, filter={"category": "snow"}
)  # Find documents that correspond to the query and has category "snow"
print(docs[0].page_content)
```


SingleStore DB 버전 8.5 이상에서 [ANN 벡터 인덱스](https://docs.singlestore.com/cloud/reference/sql-reference/vector-functions/vector-indexing/)를 활용하여 검색 효율성을 향상시킵니다. 벡터 저장소 객체 생성 시 `use_vector_index=True`를 설정하여 이 기능을 활성화할 수 있습니다. 또한, 벡터의 차원이 기본 OpenAI 임베딩 크기인 1536과 다를 경우, `vector_size` 매개변수를 적절히 지정해야 합니다.

SingleStoreDB는 각기 다른 사용 사례 및 사용자 선호에 맞춰 세심하게 설계된 다양한 검색 전략을 제공합니다. 기본 `VECTOR_ONLY` 전략은 벡터 간의 유사성 점수를 직접 계산하기 위해 `dot_product` 또는 `euclidean_distance`와 같은 벡터 작업을 활용하며, `TEXT_ONLY`는 텍스트 중심 애플리케이션에 특히 유리한 Lucene 기반의 전체 텍스트 검색을 사용합니다. 균형 잡힌 접근 방식을 원하는 사용자를 위해 `FILTER_BY_TEXT`는 텍스트 유사성을 기반으로 결과를 먼저 정제한 후 벡터 비교를 수행하고, `FILTER_BY_VECTOR`는 벡터 유사성을 우선시하여 결과를 필터링한 후 텍스트 유사성을 평가하여 최적의 일치를 찾습니다. 특히, `FILTER_BY_TEXT` 및 `FILTER_BY_VECTOR`는 작동을 위해 전체 텍스트 인덱스가 필요합니다. 또한, `WEIGHTED_SUM`은 벡터 및 텍스트 유사성을 가중치를 두어 최종 유사성 점수를 계산하는 정교한 전략으로, 오직 dot_product 거리 계산만을 사용하며 전체 텍스트 인덱스도 필요합니다. 이러한 다재다능한 전략은 사용자가 고유한 요구에 맞춰 검색을 세밀하게 조정할 수 있도록 하여 효율적이고 정확한 데이터 검색 및 분석을 촉진합니다. 또한, `FILTER_BY_TEXT`, `FILTER_BY_VECTOR`, `WEIGHTED_SUM` 전략으로 대표되는 SingleStoreDB의 하이브리드 접근 방식은 벡터 및 텍스트 기반 검색을 원활하게 결합하여 효율성과 정확성을 극대화하여 사용자가 다양한 애플리케이션에 대해 플랫폼의 기능을 최대한 활용할 수 있도록 합니다.

```python
docsearch = SingleStoreDB.from_documents(
    docs,
    embeddings,
    distance_strategy=DistanceStrategy.DOT_PRODUCT,  # Use dot product for similarity search
    use_vector_index=True,  # Use vector index for faster search
    use_full_text_search=True,  # Use full text index
)

vectorResults = docsearch.similarity_search(
    "rainstorm in parched desert, rain",
    k=1,
    search_strategy=SingleStoreDB.SearchStrategy.VECTOR_ONLY,
    filter={"category": "rain"},
)
print(vectorResults[0].page_content)

textResults = docsearch.similarity_search(
    "rainstorm in parched desert, rain",
    k=1,
    search_strategy=SingleStoreDB.SearchStrategy.TEXT_ONLY,
)
print(textResults[0].page_content)

filteredByTextResults = docsearch.similarity_search(
    "rainstorm in parched desert, rain",
    k=1,
    search_strategy=SingleStoreDB.SearchStrategy.FILTER_BY_TEXT,
    filter_threshold=0.1,
)
print(filteredByTextResults[0].page_content)

filteredByVectorResults = docsearch.similarity_search(
    "rainstorm in parched desert, rain",
    k=1,
    search_strategy=SingleStoreDB.SearchStrategy.FILTER_BY_VECTOR,
    filter_threshold=0.1,
)
print(filteredByVectorResults[0].page_content)

weightedSumResults = docsearch.similarity_search(
    "rainstorm in parched desert, rain",
    k=1,
    search_strategy=SingleStoreDB.SearchStrategy.WEIGHTED_SUM,
    text_weight=0.2,
    vector_weight=0.8,
)
print(weightedSumResults[0].page_content)
```


## 다중 모드 예제: CLIP 및 OpenClip 임베딩 활용

다중 모드 데이터 분석의 영역에서 이미지 및 텍스트와 같은 다양한 정보 유형의 통합이 점점 더 중요해지고 있습니다. 이러한 통합을 촉진하는 강력한 도구 중 하나는 [CLIP](https://openai.com/research/clip)로, 이미지를 텍스트와 함께 공유된 의미 공간에 임베딩할 수 있는 최첨단 모델입니다. 이를 통해 CLIP는 유사성 검색을 통해 다양한 모드에서 관련 콘텐츠를 검색할 수 있게 합니다.

예를 들어, 다중 모드 데이터를 효과적으로 분석하는 애플리케이션 시나리오를 고려해 보겠습니다. 이 예에서는 CLIP의 프레임워크를 활용하는 [OpenClip 다중 모드 임베딩](/docs/integrations/text_embedding/open_clip)의 기능을 활용합니다. OpenClip을 사용하면 텍스트 설명을 해당 이미지와 함께 원활하게 임베딩할 수 있어 포괄적인 분석 및 검색 작업을 수행할 수 있습니다. 텍스트 쿼리를 기반으로 시각적으로 유사한 이미지를 식별하거나 특정 시각적 콘텐츠와 관련된 텍스트 구문을 찾는 등 OpenClip은 사용자가 다중 모드 데이터에서 통찰력을 탐색하고 추출할 수 있도록 remarkable한 효율성과 정확성을 제공합니다.

```python
%pip install -U langchain openai singlestoredb langchain-experimental # (newest versions required for multi-modal)
```


```python
<!--IMPORTS:[{"imported": "SingleStoreDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.singlestoredb.SingleStoreDB.html", "title": "SingleStoreDB"}, {"imported": "OpenCLIPEmbeddings", "source": "langchain_experimental.open_clip", "docs": "https://api.python.langchain.com/en/latest/open_clip/langchain_experimental.open_clip.open_clip.OpenCLIPEmbeddings.html", "title": "SingleStoreDB"}]-->
import os

from langchain_community.vectorstores import SingleStoreDB
from langchain_experimental.open_clip import OpenCLIPEmbeddings

os.environ["SINGLESTOREDB_URL"] = "root:pass@localhost:3306/db"

TEST_IMAGES_DIR = "../../modules/images"

docsearch = SingleStoreDB(OpenCLIPEmbeddings())

image_uris = sorted(
    [
        os.path.join(TEST_IMAGES_DIR, image_name)
        for image_name in os.listdir(TEST_IMAGES_DIR)
        if image_name.endswith(".jpg")
    ]
)

# Add images
docsearch.add_images(uris=image_uris)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)