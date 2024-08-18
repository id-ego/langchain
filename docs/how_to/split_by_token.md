---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/split_by_token.ipynb
description: 텍스트를 토큰으로 나누는 방법과 OpenAI의 tiktoken을 사용하여 토큰 수를 정확하게 측정하는 방법에 대해 설명합니다.
---

# 텍스트를 토큰으로 나누는 방법

언어 모델에는 토큰 한도가 있습니다. 토큰 한도를 초과해서는 안 됩니다. 텍스트를 청크로 나눌 때는 토큰 수를 세는 것이 좋습니다. 많은 토크나이저가 있습니다. 텍스트에서 토큰을 셀 때는 언어 모델에서 사용된 것과 동일한 토크나이저를 사용해야 합니다.

## tiktoken

:::note
[tiktoken](https://github.com/openai/tiktoken)은 `OpenAI`에서 만든 빠른 `BPE` 토크나이저입니다.
:::

`tiktoken`을 사용하여 사용된 토큰을 추정할 수 있습니다. OpenAI 모델에 대해 더 정확할 것입니다.

1. 텍스트가 나누어지는 방법: 전달된 문자에 따라.
2. 청크 크기가 측정되는 방법: `tiktoken` 토크나이저에 의해.

[CharacterTextSplitter](https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html), [RecursiveCharacterTextSplitter](https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html), 및 [TokenTextSplitter](https://api.python.langchain.com/en/latest/base/langchain_text_splitters.base.TokenTextSplitter.html)는 `tiktoken`과 직접 사용할 수 있습니다.

```python
%pip install --upgrade --quiet langchain-text-splitters tiktoken
```


```python
<!--IMPORTS:[{"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "How to split text by tokens "}]-->
from langchain_text_splitters import CharacterTextSplitter

# This is a long document we can split up.
with open("state_of_the_union.txt") as f:
    state_of_the_union = f.read()
```


[CharacterTextSplitter](https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html)로 나눈 후 `tiktoken`으로 청크를 병합하려면 `.from_tiktoken_encoder()` 메서드를 사용하세요. 이 메서드에서 나눈 청크는 `tiktoken` 토크나이저로 측정된 청크 크기보다 클 수 있습니다.

`.from_tiktoken_encoder()` 메서드는 `encoding_name`을 인수로 받거나 (예: `cl100k_base`), 또는 `model_name` (예: `gpt-4`)을 받을 수 있습니다. `chunk_size`, `chunk_overlap`, 및 `separators`와 같은 모든 추가 인수는 `CharacterTextSplitter`를 인스턴스화하는 데 사용됩니다:

```python
text_splitter = CharacterTextSplitter.from_tiktoken_encoder(
    encoding_name="cl100k_base", chunk_size=100, chunk_overlap=0
)
texts = text_splitter.split_text(state_of_the_union)
```


```python
print(texts[0])
```

```output
Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  

Last year COVID-19 kept us apart. This year we are finally together again. 

Tonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. 

With a duty to one another to the American people to the Constitution.
```

청크 크기에 대한 강력한 제약을 구현하려면 `RecursiveCharacterTextSplitter.from_tiktoken_encoder`를 사용할 수 있으며, 각 분할은 크기가 더 큰 경우 재귀적으로 나뉩니다:

```python
<!--IMPORTS:[{"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to split text by tokens "}]-->
from langchain_text_splitters import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter.from_tiktoken_encoder(
    model_name="gpt-4",
    chunk_size=100,
    chunk_overlap=0,
)
```


`tiktoken`과 직접 작동하는 `TokenTextSplitter` 분할기를 로드할 수도 있으며, 이는 각 분할이 청크 크기보다 작도록 보장합니다.

```python
<!--IMPORTS:[{"imported": "TokenTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/base/langchain_text_splitters.base.TokenTextSplitter.html", "title": "How to split text by tokens "}]-->
from langchain_text_splitters import TokenTextSplitter

text_splitter = TokenTextSplitter(chunk_size=10, chunk_overlap=0)

texts = text_splitter.split_text(state_of_the_union)
print(texts[0])
```

```output
Madam Speaker, Madam Vice President, our
```

일부 서면 언어(예: 중국어 및 일본어)는 2개 이상의 토큰으로 인코딩되는 문자를 가지고 있습니다. `TokenTextSplitter`를 직접 사용하면 두 청크 사이의 문자를 위한 토큰이 분할되어 잘못된 유니코드 문자가 발생할 수 있습니다. 유효한 유니코드 문자열을 포함하도록 청크를 보장하려면 `RecursiveCharacterTextSplitter.from_tiktoken_encoder` 또는 `CharacterTextSplitter.from_tiktoken_encoder`를 사용하세요.

## spaCy

:::note
[spaCy](https://spacy.io/)는 Python 및 Cython 프로그래밍 언어로 작성된 고급 자연어 처리를 위한 오픈 소스 소프트웨어 라이브러리입니다.
:::

LangChain은 [spaCy 토크나이저](https://spacy.io/api/tokenizer)를 기반으로 한 분할기를 구현합니다.

1. 텍스트가 나누어지는 방법: `spaCy` 토크나이저에 의해.
2. 청크 크기가 측정되는 방법: 문자 수에 의해.

```python
%pip install --upgrade --quiet  spacy
```


```python
# This is a long document we can split up.
with open("state_of_the_union.txt") as f:
    state_of_the_union = f.read()
```


```python
<!--IMPORTS:[{"imported": "SpacyTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/spacy/langchain_text_splitters.spacy.SpacyTextSplitter.html", "title": "How to split text by tokens "}]-->
from langchain_text_splitters import SpacyTextSplitter

text_splitter = SpacyTextSplitter(chunk_size=1000)

texts = text_splitter.split_text(state_of_the_union)
print(texts[0])
```

```output
Madam Speaker, Madam Vice President, our First Lady and Second Gentleman.

Members of Congress and the Cabinet.

Justices of the Supreme Court.

My fellow Americans.  



Last year COVID-19 kept us apart.

This year we are finally together again. 



Tonight, we meet as Democrats Republicans and Independents.

But most importantly as Americans. 



With a duty to one another to the American people to the Constitution. 



And with an unwavering resolve that freedom will always triumph over tyranny. 



Six days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways.

But he badly miscalculated. 



He thought he could roll into Ukraine and the world would roll over.

Instead he met a wall of strength he never imagined. 



He met the Ukrainian people. 



From President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world.
```

## SentenceTransformers

[SentenceTransformersTokenTextSplitter](https://api.python.langchain.com/en/latest/sentence_transformers/langchain_text_splitters.sentence_transformers.SentenceTransformersTokenTextSplitter.html)는 문장 변환기 모델과 함께 사용하기 위한 전문 텍스트 분할기입니다. 기본 동작은 사용하려는 문장 변환기 모델의 토큰 창에 맞게 텍스트를 청크로 나누는 것입니다.

문장을 나누고 문장 변환기 토크나이저에 따라 토큰 수를 제한하려면 `SentenceTransformersTokenTextSplitter`를 인스턴스화하세요. 선택적으로 다음을 지정할 수 있습니다:

- `chunk_overlap`: 토큰 겹침의 정수 수;
- `model_name`: 문장 변환기 모델 이름, 기본값은 `"sentence-transformers/all-mpnet-base-v2"`입니다;
- `tokens_per_chunk`: 청크당 원하는 토큰 수.

```python
<!--IMPORTS:[{"imported": "SentenceTransformersTokenTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/sentence_transformers/langchain_text_splitters.sentence_transformers.SentenceTransformersTokenTextSplitter.html", "title": "How to split text by tokens "}]-->
from langchain_text_splitters import SentenceTransformersTokenTextSplitter

splitter = SentenceTransformersTokenTextSplitter(chunk_overlap=0)
text = "Lorem "

count_start_and_stop_tokens = 2
text_token_count = splitter.count_tokens(text=text) - count_start_and_stop_tokens
print(text_token_count)
```

```output
2
```


```python
token_multiplier = splitter.maximum_tokens_per_chunk // text_token_count + 1

# `text_to_split` does not fit in a single chunk
text_to_split = text * token_multiplier

print(f"tokens in text to split: {splitter.count_tokens(text=text_to_split)}")
```

```output
tokens in text to split: 514
```


```python
text_chunks = splitter.split_text(text=text_to_split)

print(text_chunks[1])
```

```output
lorem
```

## NLTK

:::note
[자연어 툴킷](https://en.wikipedia.org/wiki/Natural_Language_Toolkit), 또는 더 일반적으로 [NLTK](https://www.nltk.org/)는 Python 프로그래밍 언어로 작성된 영어의 기호 및 통계적 자연어 처리(NLP)를 위한 라이브러리 및 프로그램 모음입니다.
:::

단순히 "\n\n"에서 나누는 대신, `NLTK`를 사용하여 [NLTK 토크나이저](https://www.nltk.org/api/nltk.tokenize.html)를 기반으로 나눌 수 있습니다.

1. 텍스트가 나누어지는 방법: `NLTK` 토크나이저에 의해.
2. 청크 크기가 측정되는 방법: 문자 수에 의해.

```python
# pip install nltk
```


```python
# This is a long document we can split up.
with open("state_of_the_union.txt") as f:
    state_of_the_union = f.read()
```


```python
<!--IMPORTS:[{"imported": "NLTKTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/nltk/langchain_text_splitters.nltk.NLTKTextSplitter.html", "title": "How to split text by tokens "}]-->
from langchain_text_splitters import NLTKTextSplitter

text_splitter = NLTKTextSplitter(chunk_size=1000)
```


```python
texts = text_splitter.split_text(state_of_the_union)
print(texts[0])
```

```output
Madam Speaker, Madam Vice President, our First Lady and Second Gentleman.

Members of Congress and the Cabinet.

Justices of the Supreme Court.

My fellow Americans.

Last year COVID-19 kept us apart.

This year we are finally together again.

Tonight, we meet as Democrats Republicans and Independents.

But most importantly as Americans.

With a duty to one another to the American people to the Constitution.

And with an unwavering resolve that freedom will always triumph over tyranny.

Six days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways.

But he badly miscalculated.

He thought he could roll into Ukraine and the world would roll over.

Instead he met a wall of strength he never imagined.

He met the Ukrainian people.

From President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world.

Groups of citizens blocking tanks with their bodies.
```

## KoNLPY

:::note
[KoNLPy: Python에서의 한국어 NLP](https://konlpy.org/en/latest/)는 한국어 자연어 처리를 위한 Python 패키지입니다.
:::

토큰 분할은 텍스트를 더 작고 관리 가능한 단위인 토큰으로 세분화하는 것을 포함합니다. 이러한 토큰은 종종 단어, 구, 기호 또는 추가 처리 및 분석에 중요한 다른 의미 있는 요소입니다. 영어와 같은 언어에서 토큰 분할은 일반적으로 공백 및 구두점으로 단어를 분리하는 것을 포함합니다. 토큰 분할의 효과는 주로 토크나이저가 언어 구조를 이해하는 데 달려 있으며, 의미 있는 토큰 생성을 보장합니다. 영어를 위해 설계된 토크나이저는 한국어와 같은 다른 언어의 고유한 의미 구조를 이해할 수 없기 때문에 한국어 처리에 효과적으로 사용될 수 없습니다.

### KoNLPY의 Kkma 분석기를 통한 한국어 토큰 분할
한국어 텍스트의 경우, KoNLPY에는 `Kkma` (Korean Knowledge Morpheme Analyzer)라는 형태소 분석기가 포함되어 있습니다. `Kkma`는 한국어 텍스트에 대한 자세한 형태소 분석을 제공합니다. 문장을 단어로, 단어를 각각의 형태소로 분해하며, 각 토큰의 품사를 식별합니다. 긴 텍스트를 처리하는 데 특히 유용한 개별 문장으로 텍스트 블록을 세분화할 수 있습니다.

### 사용 고려 사항
`Kkma`는 자세한 분석으로 유명하지만, 이 정밀도가 처리 속도에 영향을 미칠 수 있다는 점에 유의해야 합니다. 따라서 `Kkma`는 신속한 텍스트 처리보다 분석의 깊이가 우선시되는 응용 프로그램에 가장 적합합니다.

```python
# pip install konlpy
```


```python
# This is a long Korean document that we want to split up into its component sentences.
with open("./your_korean_doc.txt") as f:
    korean_document = f.read()
```


```python
<!--IMPORTS:[{"imported": "KonlpyTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/konlpy/langchain_text_splitters.konlpy.KonlpyTextSplitter.html", "title": "How to split text by tokens "}]-->
from langchain_text_splitters import KonlpyTextSplitter

text_splitter = KonlpyTextSplitter()
```


```python
texts = text_splitter.split_text(korean_document)
# The sentences are split with "\n\n" characters.
print(texts[0])
```

```output
춘향전 옛날에 남원에 이 도령이라는 벼슬아치 아들이 있었다.

그의 외모는 빛나는 달처럼 잘생겼고, 그의 학식과 기예는 남보다 뛰어났다.

한편, 이 마을에는 춘향이라는 절세 가인이 살고 있었다.

춘 향의 아름다움은 꽃과 같아 마을 사람들 로부터 많은 사랑을 받았다.

어느 봄날, 도령은 친구들과 놀러 나갔다가 춘 향을 만 나 첫 눈에 반하고 말았다.

두 사람은 서로 사랑하게 되었고, 이내 비밀스러운 사랑의 맹세를 나누었다.

하지만 좋은 날들은 오래가지 않았다.

도령의 아버지가 다른 곳으로 전근을 가게 되어 도령도 떠나 야만 했다.

이별의 아픔 속에서도, 두 사람은 재회를 기약하며 서로를 믿고 기다리기로 했다.

그러나 새로 부임한 관아의 사또가 춘 향의 아름다움에 욕심을 내 어 그녀에게 강요를 시작했다.

춘 향 은 도령에 대한 자신의 사랑을 지키기 위해, 사또의 요구를 단호히 거절했다.

이에 분노한 사또는 춘 향을 감옥에 가두고 혹독한 형벌을 내렸다.

이야기는 이 도령이 고위 관직에 오른 후, 춘 향을 구해 내는 것으로 끝난다.

두 사람은 오랜 시련 끝에 다시 만나게 되고, 그들의 사랑은 온 세상에 전해 지며 후세에까지 이어진다.

- 춘향전 (The Tale of Chunhyang)
```

## Hugging Face 토크나이저

[Hugging Face](https://huggingface.co/docs/tokenizers/index)에는 많은 토크나이저가 있습니다.

우리는 텍스트 길이를 토큰으로 계산하기 위해 Hugging Face 토크나이저인 [GPT2TokenizerFast](https://huggingface.co/Ransaka/gpt2-tokenizer-fast)를 사용합니다.

1. 텍스트가 나누어지는 방법: 전달된 문자에 따라.
2. 청크 크기가 측정되는 방법: `Hugging Face` 토크나이저에 의해 계산된 토큰 수에 의해.

```python
from transformers import GPT2TokenizerFast

tokenizer = GPT2TokenizerFast.from_pretrained("gpt2")
```


```python
<!--IMPORTS:[{"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "How to split text by tokens "}]-->
# This is a long document we can split up.
with open("state_of_the_union.txt") as f:
    state_of_the_union = f.read()
from langchain_text_splitters import CharacterTextSplitter
```


```python
text_splitter = CharacterTextSplitter.from_huggingface_tokenizer(
    tokenizer, chunk_size=100, chunk_overlap=0
)
texts = text_splitter.split_text(state_of_the_union)
```


```python
print(texts[0])
```

```output
Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  

Last year COVID-19 kept us apart. This year we are finally together again. 

Tonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. 

With a duty to one another to the American people to the Constitution.
```