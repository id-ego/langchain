---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/source_code.ipynb
description: 이 문서는 언어 파싱을 사용하여 소스 코드 파일을 로드하는 방법을 다루며, 함수와 클래스별로 문서를 분리하여 정확도를 향상시킵니다.
---

# 소스 코드

이 노트북은 언어 파싱을 사용하여 소스 코드 파일을 로드하는 방법을 다룹니다: 코드의 각 최상위 함수와 클래스는 별도의 문서로 로드됩니다. 이미 로드된 함수와 클래스 외부의 나머지 최상위 코드는 별도의 문서로 로드됩니다.

이 접근 방식은 소스 코드에 대한 QA 모델의 정확성을 향상시킬 수 있습니다.

코드 파싱을 지원하는 언어는 다음과 같습니다:

- C (*)
- C++ (*)
- C# (*)
- COBOL
- Elixir
- Go (*)
- Java (*)
- JavaScript (패키지 `esprima` 필요)
- Kotlin (*)
- Lua (*)
- Perl (*)
- Python
- Ruby (*)
- Rust (*)
- Scala (*)
- TypeScript (*)

(*)로 표시된 항목은 `tree_sitter` 및 `tree_sitter_languages` 패키지가 필요합니다. `tree_sitter`를 사용하여 추가 언어 지원을 추가하는 것은 간단하지만, 현재 LangChain을 수정해야 합니다.

파싱에 사용되는 언어는 구성할 수 있으며, 구문 기반 분할을 활성화하는 데 필요한 최소 줄 수와 함께 설정할 수 있습니다.

언어가 명시적으로 지정되지 않은 경우, `LanguageParser`는 파일 이름 확장자로부터 언어를 유추합니다.

```python
%pip install -qU esprima esprima tree_sitter tree_sitter_languages
```


```python
<!--IMPORTS:[{"imported": "GenericLoader", "source": "langchain_community.document_loaders.generic", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.generic.GenericLoader.html", "title": "Source Code"}, {"imported": "LanguageParser", "source": "langchain_community.document_loaders.parsers", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.parsers.language.language_parser.LanguageParser.html", "title": "Source Code"}, {"imported": "Language", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/base/langchain_text_splitters.base.Language.html", "title": "Source Code"}]-->
import warnings

warnings.filterwarnings("ignore")
from pprint import pprint

from langchain_community.document_loaders.generic import GenericLoader
from langchain_community.document_loaders.parsers import LanguageParser
from langchain_text_splitters import Language
```


```python
loader = GenericLoader.from_filesystem(
    "./example_data/source_code",
    glob="*",
    suffixes=[".py", ".js"],
    parser=LanguageParser(),
)
docs = loader.load()
```


```python
len(docs)
```


```output
6
```


```python
for document in docs:
    pprint(document.metadata)
```

```output
{'content_type': 'functions_classes',
 'language': <Language.PYTHON: 'python'>,
 'source': 'example_data/source_code/example.py'}
{'content_type': 'functions_classes',
 'language': <Language.PYTHON: 'python'>,
 'source': 'example_data/source_code/example.py'}
{'content_type': 'simplified_code',
 'language': <Language.PYTHON: 'python'>,
 'source': 'example_data/source_code/example.py'}
{'content_type': 'functions_classes',
 'language': <Language.JS: 'js'>,
 'source': 'example_data/source_code/example.js'}
{'content_type': 'functions_classes',
 'language': <Language.JS: 'js'>,
 'source': 'example_data/source_code/example.js'}
{'content_type': 'simplified_code',
 'language': <Language.JS: 'js'>,
 'source': 'example_data/source_code/example.js'}
```


```python
print("\n\n--8<--\n\n".join([document.page_content for document in docs]))
```

```output
class MyClass:
    def __init__(self, name):
        self.name = name

    def greet(self):
        print(f"Hello, {self.name}!")

--8<--

def main():
    name = input("Enter your name: ")
    obj = MyClass(name)
    obj.greet()

--8<--

# Code for: class MyClass:


# Code for: def main():


if __name__ == "__main__":
    main()

--8<--

class MyClass {
  constructor(name) {
    this.name = name;
  }

  greet() {
    console.log(`Hello, ${this.name}!`);
  }
}

--8<--

function main() {
  const name = prompt("Enter your name:");
  const obj = new MyClass(name);
  obj.greet();
}

--8<--

// Code for: class MyClass {

// Code for: function main() {

main();
```

파서는 작은 파일에 대해 비활성화할 수 있습니다.

매개변수 `parser_threshold`는 소스 코드 파일이 파서를 사용하여 분할되기 위해 필요한 최소 줄 수를 나타냅니다.

```python
loader = GenericLoader.from_filesystem(
    "./example_data/source_code",
    glob="*",
    suffixes=[".py"],
    parser=LanguageParser(language=Language.PYTHON, parser_threshold=1000),
)
docs = loader.load()
```


```python
len(docs)
```


```output
1
```


```python
print(docs[0].page_content)
```

```output
class MyClass:
    def __init__(self, name):
        self.name = name

    def greet(self):
        print(f"Hello, {self.name}!")


def main():
    name = input("Enter your name: ")
    obj = MyClass(name)
    obj.greet()


if __name__ == "__main__":
    main()
```

## 분할

너무 큰 함수, 클래스 또는 스크립트에 대해 추가 분할이 필요할 수 있습니다.

```python
loader = GenericLoader.from_filesystem(
    "./example_data/source_code",
    glob="*",
    suffixes=[".js"],
    parser=LanguageParser(language=Language.JS),
)
docs = loader.load()
```


```python
<!--IMPORTS:[{"imported": "Language", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/base/langchain_text_splitters.base.Language.html", "title": "Source Code"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Source Code"}]-->
from langchain_text_splitters import (
    Language,
    RecursiveCharacterTextSplitter,
)
```


```python
js_splitter = RecursiveCharacterTextSplitter.from_language(
    language=Language.JS, chunk_size=60, chunk_overlap=0
)
```


```python
result = js_splitter.split_documents(docs)
```


```python
len(result)
```


```output
7
```


```python
print("\n\n--8<--\n\n".join([document.page_content for document in result]))
```

```output
class MyClass {
  constructor(name) {
    this.name = name;

--8<--

}

--8<--

greet() {
    console.log(`Hello, ${this.name}!`);
  }
}

--8<--

function main() {
  const name = prompt("Enter your name:");

--8<--

const obj = new MyClass(name);
  obj.greet();
}

--8<--

// Code for: class MyClass {

// Code for: function main() {

--8<--

main();
```

## Tree-sitter 템플릿을 사용하여 언어 추가하기

Tree-Sitter 템플릿을 사용하여 언어 지원을 확장하는 것은 몇 가지 필수 단계를 포함합니다:

1. **새 언어 파일 만들기**:
   - 지정된 디렉토리(langchain/libs/community/langchain_community/document_loaders/parsers/language)에 새 파일을 만듭니다.
   - 이 파일을 **`cpp.py`**와 같은 기존 언어 파일의 구조와 파싱 논리를 기반으로 모델링합니다.
   - 또한 langchain 디렉토리(langchain/libs/langchain/langchain/document_loaders/parsers/language)에 파일을 만들어야 합니다.
2. **언어 세부 사항 파싱**:
   - **`cpp.py`** 파일에서 사용된 구조를 모방하고, 통합할 언어에 맞게 조정합니다.
   - 주요 변경 사항은 파싱할 언어의 구문 및 구조에 맞게 청크 쿼리 배열을 조정하는 것입니다.
3. **언어 파서 테스트**:
   - 철저한 검증을 위해 새 언어에 특정한 테스트 파일을 생성합니다. 지정된 디렉토리(langchain/libs/community/tests/unit_tests/document_loaders/parsers/language)에 **`test_language.py`**를 만듭니다.
   - **`test_cpp.py`**에서 설정한 예를 따라 새 언어의 파싱된 요소에 대한 기본 테스트를 설정합니다.
4. **파서 및 텍스트 분할기에 통합**:
   - **`language_parser.py`** 파일 내에 새 언어를 통합합니다. LANGUAGE_EXTENSIONS와 LANGUAGE_SEGMENTERS를 업데이트하고, LanguageParser가 추가된 언어를 인식하고 처리할 수 있도록 docstring을 업데이트합니다.
   - 또한, 올바른 파싱을 위해 **`text_splitter.py`**의 Language 클래스에 언어가 포함되어 있는지 확인합니다.

이 단계를 따르고 포괄적인 테스트 및 통합을 보장함으로써 Tree-Sitter 템플릿을 사용하여 언어 지원을 성공적으로 확장할 수 있습니다.

행운을 빕니다!

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)