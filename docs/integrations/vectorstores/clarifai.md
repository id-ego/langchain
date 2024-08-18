---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/clarifai.ipynb
description: Clarifai는 데이터 탐색, 라벨링, 모델 훈련 및 추론을 포함한 AI 플랫폼으로, 벡터 데이터베이스 기능을 제공합니다.
---

# Clarifai

> [Clarifai](https://www.clarifai.com/)는 데이터 탐색, 데이터 레이블링, 모델 훈련, 평가 및 추론에 이르는 전체 AI 라이프사이클을 제공하는 AI 플랫폼입니다. Clarifai 애플리케이션은 입력을 업로드한 후 벡터 데이터베이스로 사용할 수 있습니다.

이 노트북은 `Clarifai` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다. 텍스트 의미 검색 기능을 보여주는 예제가 나와 있습니다. Clarifai는 이미지, 비디오 프레임 및 지역화된 검색(자세한 내용은 [Rank](https://docs.clarifai.com/api-guide/search/rank) 참조) 및 속성 검색(자세한 내용은 [Filter](https://docs.clarifai.com/api-guide/search/filter) 참조)과 함께 의미 검색도 지원합니다.

Clarifai를 사용하려면 계정과 개인 액세스 토큰(PAT) 키가 있어야 합니다. [여기에서 확인](https://clarifai.com/settings/security)하여 PAT를 얻거나 생성하세요.

# Dependencies

```python
# Install required dependencies
%pip install --upgrade --quiet  clarifai langchain-community
```


# Imports
여기에서는 개인 액세스 토큰을 설정할 것입니다. 플랫폼의 설정/보안에서 PAT를 찾을 수 있습니다.

```python
# Please login and get your API key from  https://clarifai.com/settings/security
from getpass import getpass

CLARIFAI_PAT = getpass()
```

```output
 ········
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Clarifai"}, {"imported": "Clarifai", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.clarifai.Clarifai.html", "title": "Clarifai"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Clarifai"}]-->
# Import the required modules
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import Clarifai
from langchain_text_splitters import CharacterTextSplitter
```


# Setup
텍스트 데이터가 업로드될 사용자 ID와 애플리케이션 ID를 설정합니다. 참고: 해당 애플리케이션을 생성할 때 텍스트 문서를 인덱싱하기 위한 적절한 기본 워크플로우(예: 언어 이해 워크플로우)를 선택해야 합니다.

먼저 [Clarifai](https://clarifai.com/login)에서 계정을 생성한 후 애플리케이션을 생성해야 합니다.

```python
USER_ID = "USERNAME_ID"
APP_ID = "APPLICATION_ID"
NUMBER_OF_DOCS = 2
```


## From Texts
텍스트 목록에서 Clarifai 벡터 저장소를 생성합니다. 이 섹션은 각 텍스트와 해당 메타데이터를 Clarifai 애플리케이션에 업로드합니다. 그런 다음 Clarifai 애플리케이션을 사용하여 관련 텍스트를 찾기 위한 의미 검색을 수행할 수 있습니다.

```python
texts = [
    "I really enjoy spending time with you",
    "I hate spending time with my dog",
    "I want to go for a run",
    "I went to the movies yesterday",
    "I love playing soccer with my friends",
]

metadatas = [
    {"id": i, "text": text, "source": "book 1", "category": ["books", "modern"]}
    for i, text in enumerate(texts)
]
```


대안으로 입력에 사용자 정의 ID를 제공할 수 있는 옵션이 있습니다.

```python
idlist = ["text1", "text2", "text3", "text4", "text5"]
metadatas = [
    {"id": idlist[i], "text": text, "source": "book 1", "category": ["books", "modern"]}
    for i, text in enumerate(texts)
]
```


```python
# There is an option to initialize clarifai vector store with pat as argument!
clarifai_vector_db = Clarifai(
    user_id=USER_ID,
    app_id=APP_ID,
    number_of_docs=NUMBER_OF_DOCS,
)
```


Clarifai 앱에 데이터를 업로드합니다.

```python
# upload with metadata and custom input ids.
response = clarifai_vector_db.add_texts(texts=texts, ids=idlist, metadatas=metadatas)

# upload without metadata (Not recommended)- Since you will not be able to perform Search operation with respect to metadata.
# custom input_id (optional)
response = clarifai_vector_db.add_texts(texts=texts)
```


Clarifai 벡터 DB 저장소를 생성하고 모든 입력을 앱에 직접 수집할 수 있습니다.

```python
clarifai_vector_db = Clarifai.from_texts(
    user_id=USER_ID,
    app_id=APP_ID,
    texts=texts,
    metadatas=metadatas,
)
```


유사성 검색 기능을 사용하여 유사한 텍스트를 검색합니다.

```python
docs = clarifai_vector_db.similarity_search("I would like to see you")
docs
```


```output
[Document(page_content='I really enjoy spending time with you', metadata={'text': 'I really enjoy spending time with you', 'id': 'text1', 'source': 'book 1', 'category': ['books', 'modern']})]
```


추가로 메타데이터로 검색 결과를 필터링할 수 있습니다.

```python
# There is lots powerful filtering you can do within an app by leveraging metadata filters.
# This one will limit the similarity query to only the texts that have key of "source" matching value of "book 1"
book1_similar_docs = clarifai_vector_db.similarity_search(
    "I would love to see you", filter={"source": "book 1"}
)

# you can also use lists in the input's metadata and then select things that match an item in the list. This is useful for categories like below:
book_category_similar_docs = clarifai_vector_db.similarity_search(
    "I would love to see you", filter={"category": ["books"]}
)
```


## From Documents
문서 목록에서 Clarifai 벡터 저장소를 생성합니다. 이 섹션은 각 문서와 해당 메타데이터를 Clarifai 애플리케이션에 업로드합니다. 그런 다음 Clarifai 애플리케이션을 사용하여 관련 문서를 찾기 위한 의미 검색을 수행할 수 있습니다.

```python
loader = TextLoader("your_local_file_path.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)
```


```python
USER_ID = "USERNAME_ID"
APP_ID = "APPLICATION_ID"
NUMBER_OF_DOCS = 4
```


Clarifai 벡터 DB 클래스를 생성하고 모든 문서를 Clarifai 앱에 수집합니다.

```python
clarifai_vector_db = Clarifai.from_documents(
    user_id=USER_ID,
    app_id=APP_ID,
    documents=docs,
    number_of_docs=NUMBER_OF_DOCS,
)
```


```python
docs = clarifai_vector_db.similarity_search("Texts related to population")
docs
```


## From existing App
Clarifai 내에서는 API 또는 UI를 통해 애플리케이션(본질적으로 프로젝트)에 데이터를 추가하기 위한 훌륭한 도구가 있습니다. 대부분의 사용자는 LangChain과 상호작용하기 전에 이미 그렇게 했을 것입니다. 따라서 이 예제는 기존 앱의 데이터를 사용하여 검색을 수행합니다. 우리의 [API 문서](https://docs.clarifai.com/api-guide/data/create-get-update-delete) 및 [UI 문서](https://docs.clarifai.com/portal-guide/data)를 확인하세요. Clarifai 애플리케이션을 사용하여 관련 문서를 찾기 위한 의미 검색을 수행할 수 있습니다.

```python
USER_ID = "USERNAME_ID"
APP_ID = "APPLICATION_ID"
NUMBER_OF_DOCS = 4
```


```python
clarifai_vector_db = Clarifai(
    user_id=USER_ID,
    app_id=APP_ID,
    number_of_docs=NUMBER_OF_DOCS,
)
```


```python
docs = clarifai_vector_db.similarity_search(
    "Texts related to ammuniction and president wilson"
)
```


```python
docs[0].page_content
```


```output
"President Wilson, generally acclaimed as the leader of the world's democracies,\nphrased for civilization the arguments against autocracy in the great peace conference\nafter the war. The President headed the American delegation to that conclave of world\nre-construction. With him as delegates to the conference were Robert Lansing, Secretary\nof State; Henry White, former Ambassador to France and Italy; Edward M. House and\nGeneral Tasker H. Bliss.\nRepresenting American Labor at the International Labor conference held in Paris\nsimultaneously with the Peace Conference were Samuel Gompers, president of the\nAmerican Federation of Labor; William Green, secretary-treasurer of the United Mine\nWorkers of America; John R. Alpine, president of the Plumbers' Union; James Duncan,\npresident of the International Association of Granite Cutters; Frank Duffy, president of\nthe United Brotherhood of Carpenters and Joiners, and Frank Morrison, secretary of the\nAmerican Federation of Labor.\nEstimating the share of each Allied nation in the great victory, mankind will\nconclude that the heaviest cost in proportion to prewar population and treasure was paid\nby the nations that first felt the shock of war, Belgium, Serbia, Poland and France. All\nfour were the battle-grounds of huge armies, oscillating in a bloody frenzy over once\nfertile fields and once prosperous towns.\nBelgium, with a population of 8,000,000, had a casualty list of more than 350,000;\nFrance, with its casualties of 4,000,000 out of a population (including its colonies) of\n90,000,000, is really the martyr nation of the world. Her gallant poilus showed the world\nhow cheerfully men may die in defense of home and liberty. Huge Russia, including\nhapless Poland, had a casualty list of 7,000,000 out of its entire population of\n180,000,000. The United States out of a population of 110,000,000 had a casualty list of\n236,117 for nineteen months of war; of these 53,169 were killed or died of disease;\n179,625 were wounded; and 3,323 prisoners or missing."
```


## Related

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)