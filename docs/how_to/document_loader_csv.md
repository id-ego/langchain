---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/document_loader_csv.ipynb
description: CSV 파일을 로드하는 방법과 LangChain의 CSV 로더를 사용하여 CSV 데이터를 Document 객체로 변환하는 방법을
  설명합니다.
---

# CSV 파일 로드 방법

[쉼표로 구분된 값(CSV)](https://en.wikipedia.org/wiki/Comma-separated_values) 파일은 값을 구분하기 위해 쉼표를 사용하는 구분된 텍스트 파일입니다. 파일의 각 줄은 데이터 레코드입니다. 각 레코드는 쉼표로 구분된 하나 이상의 필드로 구성됩니다.

LangChain은 CSV 파일을 [문서](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html#langchain_core.documents.base.Document) 객체의 시퀀스로 로드하는 [CSV 로더](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.csv_loader.CSVLoader.html)를 구현합니다. CSV 파일의 각 행은 하나의 문서로 변환됩니다.

```python
<!--IMPORTS:[{"imported": "CSVLoader", "source": "langchain_community.document_loaders.csv_loader", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.csv_loader.CSVLoader.html", "title": "How to load CSVs"}]-->
from langchain_community.document_loaders.csv_loader import CSVLoader

file_path = (
    "../../../docs/integrations/document_loaders/example_data/mlb_teams_2012.csv"
)

loader = CSVLoader(file_path=file_path)
data = loader.load()

for record in data[:2]:
    print(record)
```

```output
page_content='Team: Nationals\n"Payroll (millions)": 81.34\n"Wins": 98' metadata={'source': '../../../docs/integrations/document_loaders/example_data/mlb_teams_2012.csv', 'row': 0}
page_content='Team: Reds\n"Payroll (millions)": 82.20\n"Wins": 97' metadata={'source': '../../../docs/integrations/document_loaders/example_data/mlb_teams_2012.csv', 'row': 1}
```

## CSV 구문 분석 및 로드 사용자 정의

`CSVLoader`는 Python의 `csv.DictReader`에 전달되는 인수를 사용자 정의할 수 있는 `csv_args` 키워드를 허용합니다. 지원되는 csv 인수에 대한 자세한 내용은 [csv 모듈](https://docs.python.org/3/library/csv.html) 문서를 참조하십시오.

```python
loader = CSVLoader(
    file_path=file_path,
    csv_args={
        "delimiter": ",",
        "quotechar": '"',
        "fieldnames": ["MLB Team", "Payroll in millions", "Wins"],
    },
)

data = loader.load()
for record in data[:2]:
    print(record)
```

```output
page_content='MLB Team: Team\nPayroll in millions: "Payroll (millions)"\nWins: "Wins"' metadata={'source': '../../../docs/integrations/document_loaders/example_data/mlb_teams_2012.csv', 'row': 0}
page_content='MLB Team: Nationals\nPayroll in millions: 81.34\nWins: 98' metadata={'source': '../../../docs/integrations/document_loaders/example_data/mlb_teams_2012.csv', 'row': 1}
```

## 문서 소스를 식별할 열 지정

[문서](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html#langchain_core.documents.base.Document) 메타데이터의 `"source"` 키는 CSV의 열을 사용하여 설정할 수 있습니다. 각 행에서 생성된 문서의 소스를 지정하려면 `source_column` 인수를 사용하십시오. 그렇지 않으면 `file_path`가 CSV 파일에서 생성된 모든 문서의 소스로 사용됩니다.

이는 소스를 사용하여 질문에 답하는 체인에 대해 CSV 파일에서 로드된 문서를 사용할 때 유용합니다.

```python
loader = CSVLoader(file_path=file_path, source_column="Team")

data = loader.load()
for record in data[:2]:
    print(record)
```

```output
page_content='Team: Nationals\n"Payroll (millions)": 81.34\n"Wins": 98' metadata={'source': 'Nationals', 'row': 0}
page_content='Team: Reds\n"Payroll (millions)": 82.20\n"Wins": 97' metadata={'source': 'Reds', 'row': 1}
```

## 문자열에서 로드

Python의 `tempfile`는 CSV 문자열을 직접 다룰 때 사용할 수 있습니다.

```python
import tempfile
from io import StringIO

string_data = """
"Team", "Payroll (millions)", "Wins"
"Nationals",     81.34, 98
"Reds",          82.20, 97
"Yankees",      197.96, 95
"Giants",       117.62, 94
""".strip()


with tempfile.NamedTemporaryFile(delete=False, mode="w+") as temp_file:
    temp_file.write(string_data)
    temp_file_path = temp_file.name

loader = CSVLoader(file_path=temp_file_path)
loader.load()
for record in data[:2]:
    print(record)
```

```output
page_content='Team: Nationals\n"Payroll (millions)": 81.34\n"Wins": 98' metadata={'source': 'Nationals', 'row': 0}
page_content='Team: Reds\n"Payroll (millions)": 82.20\n"Wins": 97' metadata={'source': 'Reds', 'row': 1}
```