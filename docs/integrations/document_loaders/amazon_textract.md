---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/amazon_textract.ipynb
description: Amazon Textract는 스캔한 문서에서 텍스트와 데이터를 자동으로 추출하는 기계 학습 서비스입니다.
---

# 아마존 텍스트랙트

> [아마존 텍스트랙트](https://docs.aws.amazon.com/managedservices/latest/userguide/textract.html)는 스캔한 문서에서 텍스트, 손글씨 및 데이터를 자동으로 추출하는 머신 러닝(ML) 서비스입니다.
> 
> 단순한 광학 문자 인식(OCR)을 넘어 양식 및 표에서 데이터를 식별, 이해 및 추출합니다. 오늘날 많은 기업들이 PDF, 이미지, 표 및 양식과 같은 스캔한 문서에서 데이터를 수동으로 추출하거나 수동 구성(양식이 변경될 때마다 업데이트해야 하는 경우가 많음)이 필요한 간단한 OCR 소프트웨어를 사용하고 있습니다. 이러한 수동적이고 비용이 많이 드는 프로세스를 극복하기 위해 `텍스트랙트`는 ML을 사용하여 모든 유형의 문서를 읽고 처리하며, 수동 노력 없이 텍스트, 손글씨, 표 및 기타 데이터를 정확하게 추출합니다.

이 샘플은 `아마존 텍스트랙트`를 문서 로더로 사용하여 LangChain과 결합하는 방법을 보여줍니다.

`텍스트랙트`는 `PDF`, `TIF`, `PNG` 및 `JPEG` 형식을 지원합니다.

`텍스트랙트`는 이러한 [문서 크기, 언어 및 문자](https://docs.aws.amazon.com/textract/latest/dg/limits-document.html)를 지원합니다.

```python
%pip install --upgrade --quiet  boto3 langchain-openai tiktoken python-dotenv
```


```python
%pip install --upgrade --quiet  "amazon-textract-caller>=0.2.0"
```


## 샘플 1

첫 번째 예제는 로컬 파일을 사용하며, 내부적으로 아마존 텍스트랙트 동기 API [DetectDocumentText](https://docs.aws.amazon.com/textract/latest/dg/API_DetectDocumentText.html)로 전송됩니다.

로컬 파일이나 HTTP://와 같은 URL 엔드포인트는 텍스트랙트를 위한 단일 페이지 문서로 제한됩니다.
다중 페이지 문서는 S3에 저장해야 합니다. 이 샘플 파일은 JPEG입니다.

```python
<!--IMPORTS:[{"imported": "AmazonTextractPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.AmazonTextractPDFLoader.html", "title": "Amazon Textract "}]-->
from langchain_community.document_loaders import AmazonTextractPDFLoader

loader = AmazonTextractPDFLoader("example_data/alejandro_rosalez_sample-small.jpeg")
documents = loader.load()
```


파일에서 출력

```python
documents
```


```output
[Document(page_content='Patient Information First Name: ALEJANDRO Last Name: ROSALEZ Date of Birth: 10/10/1982 Sex: M Marital Status: MARRIED Email Address: Address: 123 ANY STREET City: ANYTOWN State: CA Zip Code: 12345 Phone: 646-555-0111 Emergency Contact 1: First Name: CARLOS Last Name: SALAZAR Phone: 212-555-0150 Relationship to Patient: BROTHER Emergency Contact 2: First Name: JANE Last Name: DOE Phone: 650-555-0123 Relationship FRIEND to Patient: Did you feel fever or feverish lately? Yes No Are you having shortness of breath? Yes No Do you have a cough? Yes No Did you experience loss of taste or smell? Yes No Where you in contact with any confirmed COVID-19 positive patients? Yes No Did you travel in the past 14 days to any regions affected by COVID-19? Yes No Patient Information First Name: ALEJANDRO Last Name: ROSALEZ Date of Birth: 10/10/1982 Sex: M Marital Status: MARRIED Email Address: Address: 123 ANY STREET City: ANYTOWN State: CA Zip Code: 12345 Phone: 646-555-0111 Emergency Contact 1: First Name: CARLOS Last Name: SALAZAR Phone: 212-555-0150 Relationship to Patient: BROTHER Emergency Contact 2: First Name: JANE Last Name: DOE Phone: 650-555-0123 Relationship FRIEND to Patient: Did you feel fever or feverish lately? Yes No Are you having shortness of breath? Yes No Do you have a cough? Yes No Did you experience loss of taste or smell? Yes No Where you in contact with any confirmed COVID-19 positive patients? Yes No Did you travel in the past 14 days to any regions affected by COVID-19? Yes No ', metadata={'source': 'example_data/alejandro_rosalez_sample-small.jpeg', 'page': 1})]
```


## 샘플 2
다음 샘플은 HTTPS 엔드포인트에서 파일을 로드합니다.
아마존 텍스트랙트는 모든 다중 페이지 문서가 S3에 저장되어야 하므로 단일 페이지여야 합니다.

```python
<!--IMPORTS:[{"imported": "AmazonTextractPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.AmazonTextractPDFLoader.html", "title": "Amazon Textract "}]-->
from langchain_community.document_loaders import AmazonTextractPDFLoader

loader = AmazonTextractPDFLoader(
    "https://amazon-textract-public-content.s3.us-east-2.amazonaws.com/langchain/alejandro_rosalez_sample_1.jpg"
)
documents = loader.load()
```


```python
documents
```


```output
[Document(page_content='Patient Information First Name: ALEJANDRO Last Name: ROSALEZ Date of Birth: 10/10/1982 Sex: M Marital Status: MARRIED Email Address: Address: 123 ANY STREET City: ANYTOWN State: CA Zip Code: 12345 Phone: 646-555-0111 Emergency Contact 1: First Name: CARLOS Last Name: SALAZAR Phone: 212-555-0150 Relationship to Patient: BROTHER Emergency Contact 2: First Name: JANE Last Name: DOE Phone: 650-555-0123 Relationship FRIEND to Patient: Did you feel fever or feverish lately? Yes No Are you having shortness of breath? Yes No Do you have a cough? Yes No Did you experience loss of taste or smell? Yes No Where you in contact with any confirmed COVID-19 positive patients? Yes No Did you travel in the past 14 days to any regions affected by COVID-19? Yes No Patient Information First Name: ALEJANDRO Last Name: ROSALEZ Date of Birth: 10/10/1982 Sex: M Marital Status: MARRIED Email Address: Address: 123 ANY STREET City: ANYTOWN State: CA Zip Code: 12345 Phone: 646-555-0111 Emergency Contact 1: First Name: CARLOS Last Name: SALAZAR Phone: 212-555-0150 Relationship to Patient: BROTHER Emergency Contact 2: First Name: JANE Last Name: DOE Phone: 650-555-0123 Relationship FRIEND to Patient: Did you feel fever or feverish lately? Yes No Are you having shortness of breath? Yes No Do you have a cough? Yes No Did you experience loss of taste or smell? Yes No Where you in contact with any confirmed COVID-19 positive patients? Yes No Did you travel in the past 14 days to any regions affected by COVID-19? Yes No ', metadata={'source': 'example_data/alejandro_rosalez_sample-small.jpeg', 'page': 1})]
```


## 샘플 3

다중 페이지 문서를 처리하려면 문서가 S3에 있어야 합니다. 샘플 문서는 us-east-2의 버킷에 있으며, 텍스트랙트는 성공적으로 호출되기 위해 동일한 지역에서 호출되어야 하므로 클라이언트에서 region_name을 설정하고 이를 로더에 전달하여 텍스트랙트가 us-east-2에서 호출되도록 합니다. 또한 us-east-2에서 노트북을 실행하거나 다른 환경에서 실행할 때 해당 지역 이름으로 boto3 텍스트랙트 클라이언트를 전달할 수 있습니다.

```python
import boto3

textract_client = boto3.client("textract", region_name="us-east-2")

file_path = "s3://amazon-textract-public-content/langchain/layout-parser-paper.pdf"
loader = AmazonTextractPDFLoader(file_path, client=textract_client)
documents = loader.load()
```


응답을 검증하기 위해 페이지 수를 가져옵니다(전체 응답을 인쇄하면 상당히 길어질 것입니다...). 우리는 16페이지를 예상합니다.

```python
len(documents)
```


```output
16
```


## 샘플 4

아마존 텍스트랙트 PDF 로더에 `linearization_config`라는 추가 매개변수를 전달할 수 있는 옵션이 있으며, 이는 텍스트 출력이 텍스트랙트 실행 후 파서에 의해 어떻게 선형화될지를 결정합니다.

```python
<!--IMPORTS:[{"imported": "AmazonTextractPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.AmazonTextractPDFLoader.html", "title": "Amazon Textract "}]-->
from langchain_community.document_loaders import AmazonTextractPDFLoader
from textractor.data.text_linearization_config import TextLinearizationConfig

loader = AmazonTextractPDFLoader(
    "s3://amazon-textract-public-content/langchain/layout-parser-paper.pdf",
    linearization_config=TextLinearizationConfig(
        hide_header_layout=True,
        hide_footer_layout=True,
        hide_figure_layout=True,
    ),
)
documents = loader.load()
```


## LangChain 체인에서 AmazonTextractPDFLoader 사용하기 (예: OpenAI)

AmazonTextractPDFLoader는 다른 로더와 동일한 방식으로 체인에서 사용할 수 있습니다.
텍스트랙트 자체에는 이 샘플의 QA 체인과 유사한 기능을 제공하는 [쿼리 기능](https://docs.aws.amazon.com/textract/latest/dg/API_Query.html)이 있으며, 확인해 볼 가치가 있습니다.

```python
# You can store your OPENAI_API_KEY in a .env file as well
# import os
# from dotenv import load_dotenv

# load_dotenv()
```


```python
# Or set the OpenAI key in the environment directly
import os

os.environ["OPENAI_API_KEY"] = "your-OpenAI-API-key"
```


```python
<!--IMPORTS:[{"imported": "load_qa_chain", "source": "langchain.chains.question_answering", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.question_answering.chain.load_qa_chain.html", "title": "Amazon Textract "}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Amazon Textract "}]-->
from langchain.chains.question_answering import load_qa_chain
from langchain_openai import OpenAI

chain = load_qa_chain(llm=OpenAI(), chain_type="map_reduce")
query = ["Who are the autors?"]

chain.run(input_documents=documents, question=query)
```


```output
' The authors are Zejiang Shen, Ruochen Zhang, Melissa Dell, Benjamin Charles Germain Lee, Jacob Carlson, Weining Li, Gardner, M., Grus, J., Neumann, M., Tafjord, O., Dasigi, P., Liu, N., Peters, M., Schmitz, M., Zettlemoyer, L., Lukasz Garncarek, Powalski, R., Stanislawek, T., Topolski, B., Halama, P., Gralinski, F., Graves, A., Fernández, S., Gomez, F., Schmidhuber, J., Harley, A.W., Ufkes, A., Derpanis, K.G., He, K., Gkioxari, G., Dollár, P., Girshick, R., He, K., Zhang, X., Ren, S., Sun, J., Kay, A., Lamiroy, B., Lopresti, D., Mears, J., Jakeway, E., Ferriter, M., Adams, C., Yarasavage, N., Thomas, D., Zwaard, K., Li, M., Cui, L., Huang,'
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)