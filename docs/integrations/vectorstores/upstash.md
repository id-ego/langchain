---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/upstash/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/upstash.ipynb
---

# Upstash Vector

> [Upstash Vector](https://upstash.com/docs/vector/overall/whatisvector) is a serverless vector database designed for working with vector embeddings.
> 
> The vector langchain integration is a wrapper around the [upstash-vector](https://github.com/upstash/vector-py) package.
> 
> The python package uses the [vector rest api](https://upstash.com/docs/vector/api/get-started) behind the scenes.

## Installation

Create a free vector database from [upstash console](https://console.upstash.com/vector) with the desired dimensions and distance metric.

You can then create an `UpstashVectorStore` instance by:

- Providing the environment variables `UPSTASH_VECTOR_URL` and `UPSTASH_VECTOR_TOKEN`
- Giving them as parameters to the constructor
- Passing an Upstash Vector `Index` instance to the constructor

Also, an `Embeddings` instance is required to turn given texts into embeddings. Here we use `OpenAIEmbeddings` as an example

```python
%pip install langchain-openai langchain langchain-community upstash-vector
```

```python
<!--IMPORTS:[{"imported": "UpstashVectorStore", "source": "langchain_community.vectorstores.upstash", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.upstash.UpstashVectorStore.html", "title": "Upstash Vector"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Upstash Vector"}]-->
import os

from langchain_community.vectorstores.upstash import UpstashVectorStore
from langchain_openai import OpenAIEmbeddings

os.environ["OPENAI_API_KEY"] = "<YOUR_OPENAI_KEY>"
os.environ["UPSTASH_VECTOR_REST_URL"] = "<YOUR_UPSTASH_VECTOR_URL>"
os.environ["UPSTASH_VECTOR_REST_TOKEN"] = "<YOUR_UPSTASH_VECTOR_TOKEN>"

# Create an embeddings instance
embeddings = OpenAIEmbeddings()

# Create a vector store instance
store = UpstashVectorStore(embedding=embeddings)
```

An alternative way of creating `UpstashVectorStore` is to [create an Upstash Vector index by selecting a model](https://upstash.com/docs/vector/features/embeddingmodels#using-a-model) and passing `embedding=True`. In this configuration, documents or queries will be sent to Upstash as text and embedded there.

```python
store = UpstashVectorStore(embedding=True)
```

If you are interested in trying out this approach, you can update the initialization of `store` like above and run the rest of the tutorial.

## Load documents

Load an example text file and split it into chunks which can be turned into vector embeddings.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Upstash Vector"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Upstash Vector"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

docs[:3]
```

```output
[Document(metadata={'source': '../../how_to/state_of_the_union.txt'}, page_content='Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  \n\nLast year COVID-19 kept us apart. This year we are finally together again. \n\nTonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. \n\nWith a duty to one another to the American people to the Constitution. \n\nAnd with an unwavering resolve that freedom will always triumph over tyranny. \n\nSix days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways. But he badly miscalculated. \n\nHe thought he could roll into Ukraine and the world would roll over. Instead he met a wall of strength he never imagined. \n\nHe met the Ukrainian people. \n\nFrom President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world.'),
 Document(metadata={'source': '../../how_to/state_of_the_union.txt'}, page_content='Groups of citizens blocking tanks with their bodies. Everyone from students to retirees teachers turned soldiers defending their homeland. \n\nIn this struggle as President Zelenskyy said in his speech to the European Parliament “Light will win over darkness.” The Ukrainian Ambassador to the United States is here tonight. \n\nLet each of us here tonight in this Chamber send an unmistakable signal to Ukraine and to the world. \n\nPlease rise if you are able and show that, Yes, we the United States of America stand with the Ukrainian people. \n\nThroughout our history we’ve learned this lesson when dictators do not pay a price for their aggression they cause more chaos.   \n\nThey keep moving.   \n\nAnd the costs and the threats to America and the world keep rising.   \n\nThat’s why the NATO Alliance was created to secure peace and stability in Europe after World War 2. \n\nThe United States is a member along with 29 other nations. \n\nIt matters. American diplomacy matters. American resolve matters.'),
 Document(metadata={'source': '../../how_to/state_of_the_union.txt'}, page_content='Putin’s latest attack on Ukraine was premeditated and unprovoked. \n\nHe rejected repeated efforts at diplomacy. \n\nHe thought the West and NATO wouldn’t respond. And he thought he could divide us at home. Putin was wrong. We were ready.  Here is what we did.   \n\nWe prepared extensively and carefully. \n\nWe spent months building a coalition of other freedom-loving nations from Europe and the Americas to Asia and Africa to confront Putin. \n\nI spent countless hours unifying our European allies. We shared with the world in advance what we knew Putin was planning and precisely how he would try to falsely justify his aggression.  \n\nWe countered Russia’s lies with truth.   \n\nAnd now that he has acted the free world is holding him accountable. \n\nAlong with twenty-seven members of the European Union including France, Germany, Italy, as well as countries like the United Kingdom, Canada, Japan, Korea, Australia, New Zealand, and many others, even Switzerland.')]
```

## Inserting documents

The vectorstore embeds text chunks using the embedding object and batch inserts them into the database. This returns an id array of the inserted vectors.

```python
inserted_vectors = store.add_documents(docs)

inserted_vectors[:5]
```

```output
['247aa3ae-9be9-43e2-98e4-48f94f920749',
 'c4dfc886-0a2d-497c-b2b7-d923a5cb3832',
 '0350761d-ca68-414e-b8db-7eca78cb0d18',
 '902fe5eb-8543-486a-bd5f-79858a7a8af1',
 '28875612-c672-4de4-b40a-3b658c72036a']
```

## Querying

The database can be queried using a vector or a text prompt.
If a text prompt is used, it's first converted into embedding and then queried.

The `k` parameter specifies how many results to return from the query.

```python
result = store.similarity_search("technology", k=5)
result
```

```output
[Document(metadata={'source': '../../how_to/state_of_the_union.txt'}, page_content='If you travel 20 miles east of Columbus, Ohio, you’ll find 1,000 empty acres of land. \n\nIt won’t look like much, but if you stop and look closely, you’ll see a “Field of dreams,” the ground on which America’s future will be built. \n\nThis is where Intel, the American company that helped build Silicon Valley, is going to build its $20 billion semiconductor “mega site”. \n\nUp to eight state-of-the-art factories in one place. 10,000 new good-paying jobs. \n\nSome of the most sophisticated manufacturing in the world to make computer chips the size of a fingertip that power the world and our everyday lives. \n\nSmartphones. The Internet. Technology we have yet to invent. \n\nBut that’s just the beginning. \n\nIntel’s CEO, Pat Gelsinger, who is here tonight, told me they are ready to increase their investment from  \n$20 billion to $100 billion. \n\nThat would be one of the biggest investments in manufacturing in American history. \n\nAnd all they’re waiting for is for you to pass this bill.'),
 Document(metadata={'source': '../../how_to/state_of_the_union.txt'}, page_content='So let’s not wait any longer. Send it to my desk. I’ll sign it.  \n\nAnd we will really take off. \n\nAnd Intel is not alone. \n\nThere’s something happening in America. \n\nJust look around and you’ll see an amazing story. \n\nThe rebirth of the pride that comes from stamping products “Made In America.” The revitalization of American manufacturing.   \n\nCompanies are choosing to build new factories here, when just a few years ago, they would have built them overseas. \n\nThat’s what is happening. Ford is investing $11 billion to build electric vehicles, creating 11,000 jobs across the country. \n\nGM is making the largest investment in its history—$7 billion to build electric vehicles, creating 4,000 jobs in Michigan. \n\nAll told, we created 369,000 new manufacturing jobs in America just last year. \n\nPowered by people I’ve met like JoJo Burgess, from generations of union steelworkers from Pittsburgh, who’s here with us tonight.'),
 Document(metadata={'source': '../../how_to/state_of_the_union.txt'}, page_content='When we use taxpayer dollars to rebuild America – we are going to Buy American: buy American products to support American jobs. \n\nThe federal government spends about $600 Billion a year to keep the country safe and secure. \n\nThere’s been a law on the books for almost a century \nto make sure taxpayers’ dollars support American jobs and businesses. \n\nEvery Administration says they’ll do it, but we are actually doing it. \n\nWe will buy American to make sure everything from the deck of an aircraft carrier to the steel on highway guardrails are made in America. \n\nBut to compete for the best jobs of the future, we also need to level the playing field with China and other competitors. \n\nThat’s why it is so important to pass the Bipartisan Innovation Act sitting in Congress that will make record investments in emerging technologies and American manufacturing. \n\nLet me give you one example of why it’s so important to pass it.'),
 Document(metadata={'source': '../../how_to/state_of_the_union.txt'}, page_content='Last month, I announced our plan to supercharge  \nthe Cancer Moonshot that President Obama asked me to lead six years ago. \n\nOur goal is to cut the cancer death rate by at least 50% over the next 25 years, turn more cancers from death sentences into treatable diseases.  \n\nMore support for patients and families. \n\nTo get there, I call on Congress to fund ARPA-H, the Advanced Research Projects Agency for Health. \n\nIt’s based on DARPA—the Defense Department project that led to the Internet, GPS, and so much more.  \n\nARPA-H will have a singular purpose—to drive breakthroughs in cancer, Alzheimer’s, diabetes, and more. \n\nA unity agenda for the nation. \n\nWe can do this. \n\nMy fellow Americans—tonight , we have gathered in a sacred space—the citadel of our democracy. \n\nIn this Capitol, generation after generation, Americans have debated great questions amid great strife, and have done great things. \n\nWe have fought for freedom, expanded liberty, defeated totalitarianism and terror.'),
 Document(metadata={'source': '../../how_to/state_of_the_union.txt'}, page_content='And based on the projections, more of the country will reach that point across the next couple of weeks. \n\nThanks to the progress we have made this past year, COVID-19 need no longer control our lives.  \n\nI know some are talking about “living with COVID-19”. Tonight – I say that we will never just accept living with COVID-19. \n\nWe will continue to combat the virus as we do other diseases. And because this is a virus that mutates and spreads, we will stay on guard. \n\nHere are four common sense steps as we move forward safely.  \n\nFirst, stay protected with vaccines and treatments. We know how incredibly effective vaccines are. If you’re vaccinated and boosted you have the highest degree of protection. \n\nWe will never give up on vaccinating more Americans. Now, I know parents with kids under 5 are eager to see a vaccine authorized for their children. \n\nThe scientists are working hard to get that done and we’ll be ready with plenty of vaccines when they do.')]
```

## Querying with score

The score of the query can be included for every result. 

> The score returned in the query requests is a normalized value between 0 and 1, where 1 indicates the highest similarity and 0 the lowest regardless of the similarity function used. For more information look at the [docs](https://upstash.com/docs/vector/overall/features#vector-similarity-functions).

```python
result = store.similarity_search_with_score("technology", k=5)

for doc, score in result:
    print(f"{doc.metadata} - {score}")
```
```output
{'source': '../../how_to/state_of_the_union.txt'} - 0.8968438
{'source': '../../how_to/state_of_the_union.txt'} - 0.8895128
{'source': '../../how_to/state_of_the_union.txt'} - 0.88626665
{'source': '../../how_to/state_of_the_union.txt'} - 0.88538057
{'source': '../../how_to/state_of_the_union.txt'} - 0.88432854
```
## Namespaces

Namespaces can be used to separate different types of documents. This can increase the efficiency of the queries since the search space is reduced. When no namespace is provided, the default namespace is used.

```python
store_books = UpstashVectorStore(embedding=embeddings, namespace="books")
```

```python
store_books.add_texts(
    [
        "A timeless tale set in the Jazz Age, this novel delves into the lives of affluent socialites, their pursuits of wealth, love, and the elusive American Dream. Amidst extravagant parties and glittering opulence, the story unravels the complexities of desire, ambition, and the consequences of obsession.",
        "Set in a small Southern town during the 1930s, this novel explores themes of racial injustice, moral growth, and empathy through the eyes of a young girl. It follows her father, a principled lawyer, as he defends a black man accused of assaulting a white woman, confronting deep-seated prejudices and challenging societal norms along the way.",
        "A chilling portrayal of a totalitarian regime, this dystopian novel offers a bleak vision of a future world dominated by surveillance, propaganda, and thought control. Through the eyes of a disillusioned protagonist, it explores the dangers of totalitarianism and the erosion of individual freedom in a society ruled by fear and oppression.",
        "Set in the English countryside during the early 19th century, this novel follows the lives of the Bennet sisters as they navigate the intricate social hierarchy of their time. Focusing on themes of marriage, class, and societal expectations, the story offers a witty and insightful commentary on the complexities of romantic relationships and the pursuit of happiness.",
        "Narrated by a disillusioned teenager, this novel follows his journey of self-discovery and rebellion against the phoniness of the adult world. Through a series of encounters and reflections, it explores themes of alienation, identity, and the search for authenticity in a society marked by conformity and hypocrisy.",
        "In a society where emotion is suppressed and individuality is forbidden, one man dares to defy the oppressive regime. Through acts of rebellion and forbidden love, he discovers the power of human connection and the importance of free will.",
        "Set in a future world devastated by environmental collapse, this novel follows a group of survivors as they struggle to survive in a harsh, unforgiving landscape. Amidst scarcity and desperation, they must confront moral dilemmas and question the nature of humanity itself.",
    ],
    [
        {"title": "The Great Gatsby", "author": "F. Scott Fitzgerald", "year": 1925},
        {"title": "To Kill a Mockingbird", "author": "Harper Lee", "year": 1960},
        {"title": "1984", "author": "George Orwell", "year": 1949},
        {"title": "Pride and Prejudice", "author": "Jane Austen", "year": 1813},
        {"title": "The Catcher in the Rye", "author": "J.D. Salinger", "year": 1951},
        {"title": "Brave New World", "author": "Aldous Huxley", "year": 1932},
        {"title": "The Road", "author": "Cormac McCarthy", "year": 2006},
    ],
)
```

```output
['928a5f12-900f-40b7-9406-3861741cc9d6',
 '4908670e-0b9c-455b-96b8-e0f83bc59204',
 '7083ff98-d900-4435-a67c-d9690fc555ba',
 'b910f9b1-2be0-4e0a-8b6c-93ba9b367df5',
 '7c40e950-4d2b-4293-9fb8-623a49e72607',
 '25a70e79-4905-42af-8b08-09f13bd48512',
 '695e2bcf-23d9-44d4-af26-a7b554c0c375']
```

```python
result = store_books.similarity_search("dystopia", k=3)
result
```

```output
[Document(metadata={'title': '1984', 'author': 'George Orwell', 'year': 1949}, page_content='A chilling portrayal of a totalitarian regime, this dystopian novel offers a bleak vision of a future world dominated by surveillance, propaganda, and thought control. Through the eyes of a disillusioned protagonist, it explores the dangers of totalitarianism and the erosion of individual freedom in a society ruled by fear and oppression.'),
 Document(metadata={'title': 'The Road', 'author': 'Cormac McCarthy', 'year': 2006}, page_content='Set in a future world devastated by environmental collapse, this novel follows a group of survivors as they struggle to survive in a harsh, unforgiving landscape. Amidst scarcity and desperation, they must confront moral dilemmas and question the nature of humanity itself.'),
 Document(metadata={'title': 'Brave New World', 'author': 'Aldous Huxley', 'year': 1932}, page_content='In a society where emotion is suppressed and individuality is forbidden, one man dares to defy the oppressive regime. Through acts of rebellion and forbidden love, he discovers the power of human connection and the importance of free will.')]
```

## Metadata Filtering

Metadata can be used to filter the results of a query. You can refer to the [docs](https://upstash.com/docs/vector/features/filtering) to see more complex ways of filtering.

```python
result = store_books.similarity_search("dystopia", k=3, filter="year < 2000")
result
```

```output
[Document(metadata={'title': '1984', 'author': 'George Orwell', 'year': 1949}, page_content='A chilling portrayal of a totalitarian regime, this dystopian novel offers a bleak vision of a future world dominated by surveillance, propaganda, and thought control. Through the eyes of a disillusioned protagonist, it explores the dangers of totalitarianism and the erosion of individual freedom in a society ruled by fear and oppression.'),
 Document(metadata={'title': 'Brave New World', 'author': 'Aldous Huxley', 'year': 1932}, page_content='In a society where emotion is suppressed and individuality is forbidden, one man dares to defy the oppressive regime. Through acts of rebellion and forbidden love, he discovers the power of human connection and the importance of free will.'),
 Document(metadata={'title': 'The Catcher in the Rye', 'author': 'J.D. Salinger', 'year': 1951}, page_content='Narrated by a disillusioned teenager, this novel follows his journey of self-discovery and rebellion against the phoniness of the adult world. Through a series of encounters and reflections, it explores themes of alienation, identity, and the search for authenticity in a society marked by conformity and hypocrisy.')]
```

## Getting info about vector database

You can get information about your database like the distance metric dimension using the info function.

> When an insert happens, the database an indexing takes place. While this is happening new vectors can not be queried. `pendingVectorCount` represents the number of vector that are currently being indexed. 

```python
store.info()
```

```output
InfoResult(vector_count=49, pending_vector_count=0, index_size=2978163, dimension=1536, similarity_function='COSINE', namespaces={'': NamespaceInfo(vector_count=42, pending_vector_count=0), 'books': NamespaceInfo(vector_count=7, pending_vector_count=0)})
```

## Deleting vectors

Vectors can be deleted by their ids

```python
store.delete(inserted_vectors)
```

## Clearing the vector database

This will clear the vector database

```python
store.delete(delete_all=True)
store_books.delete(delete_all=True)
```

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)