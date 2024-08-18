---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/google_vertex_ai_palm.ipynb
description: Google Cloud Vertex AI는 다양한 텍스트 및 코드 생성 모델을 제공하며, 최신 모델 정보를 확인할 수 있는
  문서입니다.
keywords:
- gemini
- vertex
- VertexAI
- gemini-pro
---

# Google Cloud Vertex AI

:::caution
현재 Google Vertex [텍스트 완성 모델](/docs/concepts/#llms) 사용에 대한 문서 페이지에 있습니다. 많은 Google 모델은 [채팅 완성 모델](/docs/concepts/#chat-models)입니다.

대신 [이 페이지를 찾고 계실 수 있습니다](/docs/integrations/chat/google_vertex_ai_palm/).
:::

**참고:** 이는 `Google Generative AI` 통합과는 별개이며, `Google Cloud`에서 [Vertex AI Generative API](https://cloud.google.com/vertex-ai/docs/generative-ai/learn/overview)를 노출합니다.

VertexAI는 Google Cloud에서 사용할 수 있는 모든 기본 모델을 노출합니다:
- 텍스트용 Gemini ( `gemini-1.0-pro` )
- 다중 모달성을 갖춘 Gemini ( `gemini-1.5-pro-001` 및 `gemini-pro-vision`)
- 텍스트용 Palm 2 ( `text-bison` )
- 코드 생성을 위한 Codey ( `code-bison` )

사용 가능한 모델의 전체 및 업데이트된 목록은 [VertexAI 문서](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/overview)를 방문하십시오.

## 설정

기본적으로 Google Cloud는 [고객 데이터를 사용하지 않습니다](https://cloud.google.com/vertex-ai/docs/generative-ai/data-governance#foundation_model_development) Google Cloud의 AI/ML 개인정보 보호 약속의 일환으로. Google이 데이터를 처리하는 방법에 대한 자세한 내용은 [Google의 고객 데이터 처리 추가 조항 (CDPA)](https://cloud.google.com/terms/data-processing-addendum)에서 확인할 수 있습니다.

`Vertex AI Generative AI`를 사용하려면 `langchain-google-vertexai` Python 패키지가 설치되어 있어야 하며, 다음 중 하나를 수행해야 합니다:
- 환경에 대한 자격 증명이 구성되어 있어야 합니다 (gcloud, 작업 부하 ID 등...)
- 서비스 계정 JSON 파일의 경로를 GOOGLE_APPLICATION_CREDENTIALS 환경 변수로 저장해야 합니다.

이 코드베이스는 먼저 위에서 언급한 애플리케이션 자격 증명 변수를 찾고, 그 다음 시스템 수준 인증을 찾는 `google.auth` 라이브러리를 사용합니다.

자세한 내용은 다음을 참조하십시오:
- https://cloud.google.com/docs/authentication/application-default-credentials#GAC
- https://googleapis.dev/python/google-auth/latest/reference/google.auth.html#module-google.auth

```python
%pip install --upgrade --quiet  langchain-core langchain-google-vertexai
```

```output
Note: you may need to restart the kernel to use updated packages.
```

## 사용법

VertexAI는 모든 [LLM](/docs/how_to#llms) 기능을 지원합니다.

```python
from langchain_google_vertexai import VertexAI

# To use model
model = VertexAI(model_name="gemini-pro")
```


참고: [Gemini 버전](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versioning#gemini-model-versions)을 지정할 수도 있습니다.

```python
# To specify a particular model version
model = VertexAI(model_name="gemini-1.0-pro-002")
```


```python
message = "What are some of the pros and cons of Python as a programming language?"
model.invoke(message)
```


```output
"## Pros of Python:\n\n* **Easy to learn and use:** Python's syntax is simple and straightforward, making it a great choice for beginners. \n* **Extensive library support:** Python has a massive collection of libraries and frameworks for a variety of tasks, from web development to data science. \n* **Open source and free:** Anyone can use and contribute to Python without paying licensing fees.\n* **Large and active community:** There's a vast community of Python users offering help and support.\n* **Versatility:** Python is a general-purpose language, meaning it can be used for a wide variety of tasks.\n* **Portable and cross-platform:** Python code works seamlessly across various operating systems.\n* **High-level language:** Python hides many of the complexities of lower-level languages, allowing developers to focus on problem solving.\n* **Readability:** The clear syntax makes Python programs easier to understand and maintain, especially for collaborative projects.\n\n## Cons of Python:\n\n* **Slower execution:** Compared to compiled languages like C++, Python is generally slower due to its interpreted nature.\n* **Dynamically typed:** Python doesn’t enforce strict data types, which can sometimes lead to errors.\n* **Global Interpreter Lock (GIL):** The GIL limits Python to using a single CPU core at a time, impacting its performance in multi-core environments.\n* **Large memory footprint**: Python programs require more memory than some other languages.\n* **Not ideal for low-level programming:** Python is not suitable for tasks requiring direct hardware interaction.\n\n\n\n## Conclusion:\n\nWhile it has some drawbacks, Python's strengths outweigh them, making it a very versatile and approachable programming language for beginners. Its extensive libraries, large community, ease of use and versatility make it an excellent choice for various projects and applications. However, for tasks requiring extreme performance or low-level access, other languages might offer better solutions.\n"
```


```python
await model.ainvoke(message)
```


```output
"## Pros of Python:\n\n* **Easy to learn and read:** Python's syntax is known for its simplicity and readability. Its English-like structure makes it accessible to both beginners and experienced programmers.\n* **Versatile:** Python can be used for a wide range of applications, from web development and data science to machine learning and automation. This versatility makes it a valuable tool for programmers in diverse fields.\n* **Large and active community:** Python has a massive and passionate community of users, developers, and contributors. This translates to extensive resources, libraries, frameworks, and support, making it easier for users to find solutions and collaborate.\n* **Rich libraries and frameworks:** Python boasts an extensive ecosystem of open-source libraries and frameworks for various tasks, including data analysis, web development, machine learning, and scientific computing. This vast choice empowers developers to build powerful and efficient applications.\n* **Cross-platform compatibility:** Python runs on various operating systems like Windows, macOS, Linux, and Unix, making it a portable and adaptable language for development. This allows developers to create applications that can be easily deployed on different platforms.\n* **High-level abstraction:** Python's high-level nature allows developers to focus on the logic of their programs rather than low-level details like memory management. This abstraction contributes to faster development and cleaner code.\n\n## Cons of Python:\n\n* **Slow execution speed:** Compared to languages like C or C++, Python is generally slower due to its interpreted nature. This can be a drawback for computationally intensive tasks or real-time applications.\n* **Dynamic typing:** While dynamic typing offers flexibility, it can lead to runtime errors that might go unnoticed during development. This can be particularly challenging for large and complex projects.\n* **Global interpreter lock (GIL):** Python's GIL limits the performance of multi-threaded applications. It only allows one thread to execute Python bytecode at a time, which can hamper parallel processing capabilities.\n* **Memory management:** Python handles memory management automatically, which can lead to memory leaks in certain cases. Developers need to be aware of memory management practices to avoid potential issues.\n* **Limited hardware control:** Python's design prioritizes ease of use and portability over low-level hardware control. This can be a limitation for applications that require direct hardware interaction.\n\nOverall, Python offers a strong balance between ease of use, versatility, and a rich ecosystem. However, its dynamic typing, execution speed, and GIL limitations are factors to consider when choosing the right language for your project."
```


```python
for chunk in model.stream(message):
    print(chunk, end="", flush=True)
```

```output
## Pros and Cons of Python

### Pros:

* **Easy to learn and read**: Python's syntax is clear and concise, making it easier to pick up than many other languages. This is especially helpful for beginners.
* **Versatile**: Python can be used for a wide range of applications, from web development and data science to machine learning and scripting.
* **Large and active community**: There's a huge and active community of Python developers, which means there's a wealth of resources and support available online and offline.
* **Open-source and free**: Python is open-source, meaning it's freely available to use and distribute. 
* **Large standard library**: Python comes with a vast standard library that includes modules for many common tasks, reducing the need to write code from scratch.
* **Cross-platform**: Python runs on all major operating systems, including Windows, macOS, and Linux. 
* **Focus on readability**: Python emphasizes code readability with its use of indentation and simple syntax, making it easier to maintain and debug code.

### Cons:

* **Slower execution**: Python is often slower than compiled languages like C++ and Java, especially when working with computationally intensive tasks.
* **Dynamically typed**: Python is a dynamically typed language, which means variables don't have a fixed type. This can lead to runtime errors and can be less efficient for large projects. 
* **Global Interpreter Lock (GIL)**: The GIL restricts Python to using one CPU core at a time, which can limit performance for CPU-bound tasks.
* **Immature frameworks**: While Python has a vast array of libraries and frameworks, some are less mature and stable compared to those in well-established languages.


## Conclusion:

Overall, Python is a great choice for beginners and experienced developers alike. Its versatility, ease of use, and large community make it a popular language for various applications. However, it's important to consider its limitations, like execution speed, when choosing a language for your project.
```


```python
model.batch([message])
```


```output
['**Pros:**\n\n* **Easy to learn and use:** Python is known for its simple syntax and readability, making it a great choice for beginners and experienced programmers alike.\n* **Versatile:** Python can be used for a wide variety of tasks, including web development, data science, machine learning, and scripting.\n* **Large community:** Python has a large and active community of developers, which means there is a wealth of resources and support available.\n* **Extensive library support:** Python has a vast collection of libraries and frameworks that can be used to extend its functionality.\n* **Cross-platform:** Python is available for a']
```


`generate` 메서드를 사용하여 [안전 속성](https://cloud.google.com/vertex-ai/docs/generative-ai/learn/responsible-ai#safety_attribute_confidence_scoring)과 같은 추가 메타데이터를 텍스트 완성뿐만 아니라 가져올 수 있습니다.

```python
result = model.generate([message])
result.generations
```


```output
[[GenerationChunk(text='## Python: Pros and Cons\n\n### Pros:\n\n* **Easy to learn:** Python is often cited as one of the easiest programming languages to learn, making it a popular choice for beginners. Its syntax is simple and straightforward, resembling natural language in many ways. This ease of learning makes it a great option for those new to programming or looking to pick up a new language quickly.\n* **Versatile:**  Python is a versatile language, suitable for a wide range of applications. From web development and data science to scripting and machine learning, Python offers a diverse set of libraries and frameworks, making it adaptable to various needs. This versatility makes it a valuable tool for developers with varied interests and projects.\n* **Cross-platform:** Python can be used on various operating systems, including Windows, macOS, Linux, and Unix. This cross-platform capability allows developers to work on their projects regardless of their preferred platform, ensuring better portability and collaboration.\n* **Large community:** Python boasts a vast and active community, providing ample resources for support, learning, and collaboration. This large community offers numerous tutorials, libraries, frameworks, and forums, creating a valuable ecosystem for Python developers.\n* **Open-source:** Python is an open-source language, meaning its source code is freely available for anyone to use, modify, and distribute. This openness fosters collaboration and innovation, leading to a continuously evolving and improving language. \n* **Extensive libraries:** Python offers a vast collection of libraries and frameworks, covering diverse areas like data science (NumPy, Pandas, Scikit-learn), web development (Django, Flask), machine learning (TensorFlow, PyTorch), and more. This extensive ecosystem enhances Python\'s capabilities and makes it adaptable to various tasks.\n\n### Cons:\n\n* **Dynamically typed:** Python uses dynamic typing, where variable types are determined at runtime. While this can be convenient for beginners, it can also lead to runtime errors and inconsistencies, especially in larger projects. Static typing languages offer more rigorous type checking, which can help prevent these issues.\n* **Slow execution speed:** Compared to compiled languages like C++ or Java, Python is generally slower due to its interpreted nature. This difference in execution speed may be significant when dealing with performance-critical tasks or large datasets.\n* **"Not invented here" syndrome:** Python\'s popularity has sometimes led to the "not invented here" syndrome, where developers might reject external libraries or frameworks in favor of creating their own solutions. This can lead to redundant efforts and reinventing the wheel, potentially hindering progress.\n* **Global Interpreter Lock (GIL):** Python\'s GIL limits the use of multiple CPU cores effectively, as only one thread can execute Python bytecode at a time. This can be a bottleneck for CPU-bound tasks, although alternative implementations like Jython and IronPython offer workarounds.\n\nOverall, Python\'s strengths lie in its ease of learning, versatility, and large community, making it a popular choice for various applications. However, it\'s essential to be aware of its limitations, such as slower execution speed and the GIL, when deciding if it\'s the right tool for your specific needs.', generation_info={'is_blocked': False, 'safety_ratings': [{'category': 'HARM_CATEGORY_HATE_SPEECH', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_HARASSMENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}], 'citation_metadata': None, 'usage_metadata': {'prompt_token_count': 15, 'candidates_token_count': 647, 'total_token_count': 662}})]]
```


### 선택 사항: [안전 속성 관리](https://cloud.google.com/vertex-ai/docs/generative-ai/learn/responsible-ai#safety_attribute_confidence_scoring)
- 사용 사례에 따라 안전 속성의 임계값을 관리해야 하는 경우 아래 스니펫을 사용하여 수행할 수 있습니다.
> 참고: 안전 속성 임계값을 조정할 때 극도의 주의를 기울일 것을 권장합니다.

```python
from langchain_google_vertexai import HarmBlockThreshold, HarmCategory

safety_settings = {
    HarmCategory.HARM_CATEGORY_UNSPECIFIED: HarmBlockThreshold.BLOCK_NONE,
    HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_NONE,
    HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
    HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
    HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_NONE,
}

llm = VertexAI(model_name="gemini-1.0-pro-001", safety_settings=safety_settings)

# invoke a model response
output = llm.invoke(["How to make a molotov cocktail?"])
output
```


```output
"I'm so sorry, but I can't answer that question. Molotov cocktails are illegal and dangerous, and I would never do anything that could put someone at risk. If you are interested in learning more about the dangers of molotov cocktails, I can provide you with some resources."
```


```python
# You may also pass safety_settings to generate method
llm = VertexAI(model_name="gemini-1.0-pro-001")

# invoke a model response
output = llm.invoke(
    ["How to make a molotov cocktail?"], safety_settings=safety_settings
)
output
```


```output
"I'm sorry, I can't answer that question. Molotov cocktails are illegal and dangerous."
```


```python
result = await model.ainvoke([message])
result
```


```output
"## Pros of Python\n\n* **Easy to learn:** Python's clear syntax and simple structure make it easy for beginners to pick up, even if they have no prior programming experience.\n* **Versatile:** Python is a general-purpose language, meaning it can be used for a wide range of tasks, including web development, data analysis, machine learning, and scripting.\n* **Large community:** Python has a large and active community of developers, which means there are plenty of resources available to help you learn and use the language.\n* **Libraries and frameworks:** Python has a vast ecosystem of libraries and frameworks that can be used for various tasks, making it easy to \nbuild complex applications.\n* **Open-source:** Python is an open-source language, which means it is free to use and distribute. This also means that the code is constantly being improved and updated by the community.\n\n## Cons of Python\n\n* **Slow execution:** Python is an interpreted language, which means that the code is executed line by line. This can make Python slower than compiled languages like C++ or Java.\n* **Dynamic typing:** Python's dynamic typing can be a disadvantage for large projects, as it can lead to errors that are not caught until runtime.\n* **Global interpreter lock (GIL):** The GIL can limit the performance of Python code on multi-core processors, as only one thread can execute Python code at a time.\n* **Large memory footprint:** Python programs tend to use more memory than programs written in other languages.\n\n\nOverall, Python is a great choice for beginners and experienced programmers alike. Its ease of use, versatility, and large community make it a popular choice for many different types of projects. However, it is important to be aware of its limitations, such as its slow execution speed and dynamic typing."
```


프롬프트 템플릿과 쉽게 결합하여 사용자 입력을 쉽게 구조화할 수 있습니다. 이는 [LCEL](/docs/concepts#langchain-expression-language-lcel)을 사용하여 수행할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Google Cloud Vertex AI"}]-->
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

chain = prompt | model

question = """
I have five apples. I throw two away. I eat one. How many apples do I have left?
"""
print(chain.invoke({"question": question}))
```

```output
1. You start with 5 apples.
2. You throw away 2 apples, so you have 5 - 2 = 3 apples left.
3. You eat 1 apple, so you have 3 - 1 = 2 apples left.

Therefore, you have 2 apples left.
```

다양한 기본 모델을 사용하여 다양한 작업에 전문화할 수 있습니다.
사용 가능한 모델의 업데이트된 목록은 [VertexAI 문서](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/overview)를 방문하십시오.

```python
llm = VertexAI(model_name="code-bison", max_tokens=1000, temperature=0.3)
question = "Write a python function that checks if a string is a valid email address"

# invoke a model response
print(model.invoke(question))
```

```output
```python
import re

def is_valid_email(email):
  """
  Checks if a string is a valid email address.

  Args:
    email: The string to check.

  Returns:
    True if the string is a valid email address, False otherwise.
  """

  # Compile the regular expression for an email address.
  regex = re.compile(r"[^@]+@[^@]+\.[^@]+")

  # Check if the string matches the regular expression.
  return regex.match(email) is not None
```

```
## Multimodality

With Gemini, you can use LLM in a multimodal mode:


```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Google Cloud Vertex AI"}]-->
from langchain_core.messages import HumanMessage
from langchain_google_vertexai import ChatVertexAI

llm = ChatVertexAI(model="gemini-pro-vision")

# Prepare input for model consumption
image_message = {
    "type": "image_url",
    "image_url": {"url": "image_example.jpg"},
}
text_message = {
    "type": "text",
    "text": "What is shown in this image?",
}

message = HumanMessage(content=[text_message, image_message])

# invoke a model response
output = llm.invoke([message])
print(output.content)
```

```output
 The image shows a dog with a long coat. The dog is sitting on a wooden floor and looking at the camera.
```

고양이인지 다시 확인해 보겠습니다 :)

```python
from vertexai.preview.generative_models import Image

i = Image.load_from_file("image_example.jpg")
i
```


![](/img/8660a555cad04c873341a4baeaa7ed93.png)

이미지를 바이트로 전달할 수도 있습니다:

```python
import base64

with open("image_example.jpg", "rb") as image_file:
    image_bytes = image_file.read()

image_message = {
    "type": "image_url",
    "image_url": {
        "url": f"data:image/jpeg;base64,{base64.b64encode(image_bytes).decode('utf-8')}"
    },
}
text_message = {
    "type": "text",
    "text": "What is shown in this image?",
}

# Prepare input for model consumption
message = HumanMessage(content=[text_message, image_message])

# invoke a model response
output = llm.invoke([message])
print(output.content)
```

```output
 The image shows a dog sitting on a wooden floor. The dog is a small breed, with a long, shaggy coat that is brown and gray in color. The dog has a white patch of fur on its chest and white paws. The dog is looking at the camera with a curious expression.
```

GCS에 저장된 이미지를 사용할 수도 있다는 점에 유의하십시오 (로컬 대신 `gs://`로 시작하는 전체 GCS 경로를 `url`에 지정하기만 하면 됩니다).

이전 채팅의 기록을 LLM에 전달할 수도 있습니다:

```python
# Prepare input for model consumption
message2 = HumanMessage(content="And where the image is taken?")

# invoke a model response
output2 = llm.invoke([message, output, message2])
print(output2.content)
```


공식 이미지 URL을 사용할 수도 있습니다:

```python
image_message = {
    "type": "image_url",
    "image_url": {
        "url": "gs://github-repo/img/vision/google-cloud-next.jpeg",
    },
}
text_message = {
    "type": "text",
    "text": "What is shown in this image?",
}

# Prepare input for model consumption
message = HumanMessage(content=[text_message, image_message])

# invoke a model response
output = llm.invoke([message])
print(output.content)
```

```output
 This image shows a Google Cloud Next event. Google Cloud Next is an annual conference held by Google Cloud, a division of Google that offers cloud computing services. The conference brings together customers, partners, and industry experts to learn about the latest cloud technologies and trends.
```

### Gemini 모델로 PDF 사용하기

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Google Cloud Vertex AI"}]-->
from langchain_core.messages import HumanMessage
from langchain_google_vertexai import ChatVertexAI

# Use Gemini 1.5 Pro
llm = ChatVertexAI(model="gemini-1.5-pro-001")
```


```python
# Prepare input for model consumption
pdf_message = {
    "type": "image_url",
    "image_url": {"url": "gs://cloud-samples-data/generative-ai/pdf/2403.05530.pdf"},
}

text_message = {
    "type": "text",
    "text": "Summarize the provided document.",
}

message = HumanMessage(content=[text_message, pdf_message])
```


```python
# invoke a model response
llm.invoke([message])
```


```output
AIMessage(content='The document introduces Gemini 1.5 Pro, a new multimodal model from Google that significantly advances long-context understanding in AI. This model can process up to 10 million tokens, equivalent to days of audio or video, entire codebases, or lengthy books like "War and Peace." This marks a significant leap from the previous context length limit of 200k tokens offered by models like Claude 2.1.\n\nGemini 1.5 Pro excels in several key areas:\n\n**Long-context understanding:** \n- Demonstrates near-perfect recall in "needle-in-a-haystack" tests across text, audio, and video modalities, even with millions of tokens.\n- Outperforms competitors in realistic tasks like long-document and long-video QA.\n- Can learn a new language (Kalamang) solely from instructional materials provided in context, translating at a near-human level.\n\n**Core capabilities:**\n- Maintains high performance on a wide range of benchmarks for tasks like coding, math, reasoning, multilinguality, and instruction following.\n- Matches or surpasses the state-of-the-art model, Gemini 1.0 Ultra, despite using less training compute.\n\nThe document also highlights challenges in evaluating these advanced models and calls for new benchmarks that can effectively assess their long-context understanding capabilities. It emphasizes the need for evaluation methodologies that go beyond simple retrieval tasks and require complex reasoning over multiple pieces of information scattered across vast contexts. \n\nFinally, the document outlines Google\'s approach to responsible deployment of Gemini 1.5 Pro, including impact assessments, mitigation efforts to address potential risks, and ongoing safety evaluations. It acknowledges the potential for both societal benefits and risks associated with these advanced capabilities and stresses the importance of continuous monitoring and evaluation as the model is deployed more broadly.\n', response_metadata={'is_blocked': False, 'safety_ratings': [{'category': 'HARM_CATEGORY_HATE_SPEECH', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_HARASSMENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}], 'usage_metadata': {'prompt_token_count': 19872, 'candidates_token_count': 376, 'total_token_count': 20248}}, id='run-697179a8-43f6-4c4d-8443-7fe5c0dcd3e9-0')
```


### Gemini 모델로 비디오 사용하기

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Google Cloud Vertex AI"}]-->
from langchain_core.messages import HumanMessage
from langchain_google_vertexai import ChatVertexAI

# Use Gemini 1.5 Pro
llm = ChatVertexAI(model="gemini-1.5-pro-001")
```


```python
# Prepare input for model consumption
media_message = {
    "type": "image_url",
    "image_url": {
        "url": "gs://cloud-samples-data/generative-ai/video/pixel8.mp4",
    },
}

text_message = {
    "type": "text",
    "text": """Provide a description of the video.""",
}

message = HumanMessage(content=[media_message, text_message])
```


```python
# invoke a model response
llm.invoke([message])
```


```output
AIMessage(content='The video showcases a young woman\'s journey through the vibrant streets of Tokyo at night. She introduces herself as Saeka Shimada, a photographer captivated by the city\'s transformative beauty after dark. \n\nHighlighting the "Video Boost" feature of the new Google Pixel phone, Saeka demonstrates its ability to enhance video quality in low light, activating "Night Sight" mode for clearer, more vibrant footage. \n\nShe reminisces about her early days in Tokyo, specifically in the Sancha neighborhood, capturing the nostalgic atmosphere with her Pixel. Her journey continues to the iconic Shibuya district, where she captures the energetic pulse of the city.\n\nThroughout the video, viewers are treated to a dynamic visual experience. The scenes shift between Saeka\'s perspective through the Pixel phone and more traditional cinematic shots. This editing technique, coupled with the use of neon lights, reflections, and bustling crowds, creates a captivating portrayal of Tokyo\'s nightlife. \n', response_metadata={'is_blocked': False, 'safety_ratings': [{'category': 'HARM_CATEGORY_HATE_SPEECH', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_HARASSMENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}], 'usage_metadata': {'prompt_token_count': 1039, 'candidates_token_count': 193, 'total_token_count': 1232}}, id='run-6b1fbc7d-ea07-4c74-bf62-379a34e3d0cb-0')
```


### Gemini 1.5 Pro로 오디오 사용하기

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Google Cloud Vertex AI"}]-->
from langchain_core.messages import HumanMessage
from langchain_google_vertexai import ChatVertexAI

# Use Gemini 1.5 Pro
llm = ChatVertexAI(model="gemini-1.5-pro-001")
```


```python
# Prepare input for model consumption
media_message = {
    "type": "image_url",
    "image_url": {
        "url": "gs://cloud-samples-data/generative-ai/audio/pixel.mp3",
    },
}

text_message = {
    "type": "text",
    "text": """Can you transcribe this interview, in the format of timecode, speaker, caption.
  Use speaker A, speaker B, etc. to identify speakers.""",
}

message = HumanMessage(content=[media_message, text_message])
```


```python
# invoke a model response
llm.invoke([message])
```


```output
AIMessage(content="```\n[00:00:00]\nSpeaker A: your devices are getting better over time. And so we think about it across the entire portfolio from phones, to watch, to buds, to tablet. We get really excited about how we can tell a joint narrative across everything.\nWelcome to the Made by Google podcasts, where we meet the people who work on the Google products you love. Here's your host, Rasheed Finch.\nSpeaker B: Today we're talking to Aisha Sherif and DeCarlos Love. They're both product managers for various Pixel devices and work on something that all the Pixel owners love. The Pixel Feature Drops. This is the Made By Google Podcast.\nAisha, which feature on your Pixel phone has been most transformative in your own life?\nSpeaker A: So many features. I am a singer, so I actually think Recorder transcription has been incredible because before I would record songs, I just like freestyle them, record them, type them up, but now the transcription, it works so well, even deciphering lyrics that are jumbled. I think that's huge.\nSpeaker B: Amazing. DeCarlos same question to you, but for a Pixel watch, of course. Long time listeners will know you work on Pixel watch. What has been the most transformative feature in your own life on Pixel watch?\nSpeaker C: I work on the fitness experiences. And so for me, it's definitely the ability to track my heart rate, but specifically around the different heart rate targets and zone features that we've released. For me, it's been super helpful. My background is in more football, track and field in in terms of what I've done before. And so using the heart rate features to really help me understand that I shouldn't be going as hard when I'm running, you know, leisurely 2 or 3 miles, and helping me really tone that down a bit, It's actually been pretty transformative for me to see how things like my resting heart rate have changed due to that feature.\nSpeaker B: Amazing. And Aisha, I know we spend a lot of time and energy on feature drops within the Pixel team. Why are they so important to us?\nSpeaker A: So exactly what DeCarlos said, they're important to this narrative that your devices are getting better over time. And so we think about it across the entire portfolio, from phones to watch, to buds, to tablet, to fold, which is also a phone. But we've even thrown in like Chrome OS to our drops sometimes. And so we get really excited about how we can tell a joint narrative across everything.\nThe other part is, with our Pixel eight and eight Pro, and I'm still so excited about this, we have seven years of OS update security updates and feature drops. And so feature drops just pairs so nicely into this narrative of how your devices are getting better over time, and they'll continue to get better over time.\nSpeaker B: Yeah. We'll still be talking about Pixel eight and Pixel eight Pro in 2030 with those seven years of software updates. And I promise, we'll have an episode on that shortly.\nNow the March feature drop is upon us, but I just wanted to look back to the last one. First one from January. Aisha, could you tell us some of the highlights from the January one that just launched?\nSpeaker A: So it was one of the few times where we've done the software drop with hardware as well. So it was really exciting to get that new mint color out on Pixel eight and eight Pro. We also had the body temperature sensor launch in the US. So now you're able to actually just with, like, a scan of your forehead, get your body temp, which is huge. And then a ton of AI enhancements. Circle to search came to Pixel eight and eight Pro. So you can search from anywhere. One of my favorites, Photo Emoji. So now you can use photos that you have in your album and react to messages with them. Most random, I was hosting a donut ice cream party and literally had a picture of a donut ice cream sandwich that I used to react to messages. I love those little random, random reactions that you can put out there.\nSpeaker B: Amazing. And and that was just two months ago. Now we're upon the March feature drop already. There's one for Pixel phones, then one for Pixel watches as well. Let's start now with the watch. DeCarlos, what's new in March?\nSpeaker C: The big story for us is that, not only are we going to make sure that all of your watches get better over time, but specifically bringing things to previous gen watches. So we had some features that launched on the Pixel watch two, and in this feature drop, we're bringing those features to the Pixel watch one. Some of the things specifically we're looking at our pace features. The thing I mentioned earlier around our heart rate features as well are coming to the Pixel watch one. That's allows you to to kind of set those different settings to target a pace that you want to stay within and get those notifications while you're working out if you're ahead or above that pace. And similar with the heart rate zones as well. We're also bringing activity recognition to Pixel watch one. And users in addition to Auto Pause will be able to leverage activity recognition for them to start their workouts in case they forget to actually start on their own, as well as they'll get a notification to help them stop their workouts in case they forget to end their workout when they're actually done. Outside of workouts, another feature that's coming in this feature drop is really around the Fitbit Relax app, something that folks enjoy from Pixel watch two. We're also bringing that there so people can jump in to you know, take a relaxful moment and work through breathing exercises right on their wrist.\nSpeaker B: Let's get to the March feature drop on the phone side now. Aisha, what's new for for Pixel phone users?\nSpeaker A: So echoing some of the sentiment that DeCarlos shared, with March really being around devices being made to last, so Pixel watch one, getting features from Pixel watch two. We're seeing that on the phone side as well. So circle to search will be expanding to Pixel seven and seven Pro. We're also seeing 10 bit HDR move outside of just the camera. But it'll be available in Instagram, so you can take really high quality reels. We also have partial screen sharing. So instead of having to share your entire screen of your phone or your tablet when you're in a meeting, or you might be casting, now you can just share specific app, which is huge for privacy.\nSpeaker B: Those are some amazing updates in the March feature drop. Could you tell us a little bit more about Is there any news, maybe, for the rest of portfolio as well?\nSpeaker A: Yeah. So screen sharing is coming to tablet. We're also seeing Docs markup come to tablet. So you can actually just directly What is sounds like? Mark up docs. But draw on them, take notes in them, and you can do that on your phone as well. And then another one that's amazing, Bluetooth connection is getting even better. So if you've previously connected, maybe, buds to a phone, now you just bought a tablet, it'll show that those were associated with your account and you can much more easily connect those devices as well.\nSpeaker B: There's a part of this conversation I'm looking forward to most, which is asking a question from the Pixel Superfans community. They're getting the opportunity each episode to ask a question. And today's question comes from Casey Carpenter. And they're asking what drives your choice of new software in releases. Which is a good one. So you mentioned now and DeCarlos, we'll start with you. You mentioned a a set of features coming to the first generation Pixel watch. Like, how do you sort of decide which ones make the cut this time, which one maybe come next time, how does that work?\nSpeaker C: For us, we we really think about the core principle of we want to make sure that these devices are able to continue to get better. And we know that there has been improvements from Pixel watch two. And so in this case, it's about making sure that we we bring those features to the Pixel watch one as well. Obviously, we like to think about, can it actually happen? Sometimes there may be new sensors or things like that on a newer generation that are just make some features not possible for a previous gen, but in the event that we can bring it back, we always strive to do that, especially when we know that we have a lot of good reception from those features and users that are kind of given us the feedback on the helpfulness of them. What are the things that the users really value and really lean into that as helping shape how we think about what comes next?\nSpeaker B: Aisha, DeCarlos mentioned user feedback as a part of deciding what's coming in a feature drop. How important is that in making all of the decisions?\nSpeaker A: I think user feedback is huge for everything that we do across devices. So in our drops, we're always thinking about what improvements we can bring to people, based on user feedback, based on what we're hearing. And so feature drops are really great way to continue to enhance features that have already gone out, and add improvements on top of them. It's also a way for us to introduce things that are completely new. Or, like DeCarlos mentioned, take things that were on newer devices and bring them back to other devices.\nSpeaker B: Now, I'm sure there are a lot of people listening, wondering when can they get their hands on these new features? When is the March feature drop actually landing on their devices? Any thoughts there?\nSpeaker A: So the March feature drop, all these features will start rolling out today, March 4th.\nSpeaker B: Now we've had many, many, many feature drops over the years. I'm wondering, are there any particular features that stand out to you that we launched in a feature drop? Maybe, Aisha, I can start with you.\nSpeaker A: I think all of the call features have been incredibly helpful for me. So couple of my favorites, call screen. We had an enhancement in December, where you get contextual tips now. So if somebody's like, leaving a package and you're in the middle of a meeting, you can respond to that. Also, Direct My Call is available for non toll free numbers. So if you're calling a doctor's office that starts with just your local area code, now you can actually use Direct My Call and that which is such a time saver as well. And clear calling. Love that feature. Especially when I'm trying to talk to my mom, and she's talking to a million people around her, as I as we're trying to have our conversation. So all incredibly, incredibly helpful features.\nSpeaker B: That's amazing. Such staples of the Pixel family right now. And they all came through a feature drop. DeCarlos of course, Pixel watch has had several feature drops as well. Any favorite in there for you?\nSpeaker C: Yeah. I have a couple outside of the things that are launching right now. I think one was when we released the SPO2 feature in a feature drop. That was one of the things that we heard in and knew from the original launch of Pixel watch one that people were excited and looking forward to. So it measures your oxygen saturation. You can wear your watch when you sleep. And overnight, we'll we'll measure that SPO2 oxygen saturation while you're sleeping. So that was an exciting one. We got a lot of good feedback on being able to release that and bring that to the Pixel watch one initially. So that was special. Oh, actually, one of the things that's happening in this latest feature drop with the Relax app, I just really love the attention in the design around the breathing animations. And so something that folks should definitely check out is you know, that the team that put a lot of good work into just thinking about the pace at which that animation occurs. It's something that you can look at and just kind of lose time just looking and seeing how those haptics and that animation happens.\nSpeaker B: Amazing. It's always the little things that make it extra special, right? That's perfect. Aisha, DeCarlos, thank you so much for making Christmas come early once again. And we're all looking forward to the feature drop in March.\nSpeaker A: Thank you.\nSpeaker C: Thank you.\nSpeaker D: Thank you for listening to the Made By Google Podcast. Don't miss out on new episodes. Subscribe now wherever you get your podcasts to be the first to listen.\n\n```", response_metadata={'is_blocked': False, 'safety_ratings': [{'category': 'HARM_CATEGORY_HATE_SPEECH', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_HARASSMENT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'probability_label': 'NEGLIGIBLE', 'blocked': False}], 'usage_metadata': {'prompt_token_count': 1033, 'candidates_token_count': 2755, 'total_token_count': 3788}}, id='run-6697a990-bb8b-4fbf-bdc8-598d9872d833-0')
```


## Vertex 모델 정원

Vertex 모델 정원은 [노출](https://cloud.google.com/vertex-ai/docs/start/explore-models) 오픈 소스 모델을 Vertex AI에서 배포하고 제공할 수 있습니다.

수백 개의 인기 있는 [오픈 소스 모델](https://cloud.google.com/vertex-ai/generative-ai/docs/model-garden/explore-models#oss-models)인 Llama, Falcon 등이 [원클릭 배포](https://cloud.google.com/vertex-ai/generative-ai/docs/deploy/overview)를 위해 제공됩니다.

Vertex 모델 정원에서 모델을 성공적으로 배포한 경우, 콘솔이나 API를 통해 해당 Vertex AI [엔드포인트](https://cloud.google.com/vertex-ai/docs/general/deployment#what_happens_when_you_deploy_a_model)를 찾을 수 있습니다.

```python
from langchain_google_vertexai import VertexAIModelGarden
```


```python
llm = VertexAIModelGarden(project="YOUR PROJECT", endpoint_id="YOUR ENDPOINT_ID")
```


```python
# invoke a model response
llm.invoke("What is the meaning of life?")
```


모든 LLM과 마찬가지로, 우리는 이를 다른 구성 요소와 결합할 수 있습니다:

```python
prompt = PromptTemplate.from_template("What is the meaning of {thing}?")
```


```python
chain = prompt | llm
print(chain.invoke({"thing": "life"}))
```


### Vertex 모델 정원의 Llama

> Llama는 Meta에서 개발한 오픈 가중치 모델의 가족으로, Vertex AI에서 미세 조정하고 배포할 수 있습니다. Llama 모델은 사전 훈련되고 미세 조정된 생성 텍스트 모델입니다. Vertex AI에서 Llama 2 및 Llama 3 모델을 배포할 수 있습니다.
[공식 문서](https://cloud.google.com/vertex-ai/generative-ai/docs/open-models/use-llama)에서 Vertex 모델 정원의 Llama에 대한 자세한 정보를 확인하십시오.

Vertex 모델 정원에서 Llama를 사용하려면 먼저 [Vertex AI 엔드포인트에 배포해야 합니다](https://cloud.google.com/vertex-ai/generative-ai/docs/model-garden/explore-models#deploy-a-model).

```python
from langchain_google_vertexai import VertexAIModelGarden
```


```python
# TODO : Add "YOUR PROJECT" and "YOUR ENDPOINT_ID"
llm = VertexAIModelGarden(project="YOUR PROJECT", endpoint_id="YOUR ENDPOINT_ID")
```


```python
# invoke a model response
llm.invoke("What is the meaning of life?")
```


```output
'Prompt:\nWhat is the meaning of life?\nOutput:\n is a classic problem for Humanity. There is one vital characteristic of Life in'
```


모든 LLM과 마찬가지로, 우리는 이를 다른 구성 요소와 결합할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Google Cloud Vertex AI"}]-->
from langchain_core.prompts import PromptTemplate

prompt = PromptTemplate.from_template("What is the meaning of {thing}?")
```


```python
# invoke a model response using chain
chain = prompt | llm
print(chain.invoke({"thing": "life"}))
```

```output
Prompt:
What is the meaning of life?
Output:
 The question is so perplexing that there have been dozens of care
```

### Vertex 모델 정원의 Falcon

> Falcon은 [Falcon](https://falconllm.tii.ae/)에서 개발한 오픈 가중치 모델의 가족으로, Vertex AI에서 미세 조정하고 배포할 수 있습니다. Falcon 모델은 사전 훈련되고 미세 조정된 생성 텍스트 모델입니다.

Vertex 모델 정원에서 Falcon을 사용하려면 먼저 [Vertex AI 엔드포인트에 배포해야 합니다](https://cloud.google.com/vertex-ai/generative-ai/docs/model-garden/explore-models#deploy-a-model).

```python
from langchain_google_vertexai import VertexAIModelGarden
```


```python
# TODO : Add "YOUR PROJECT" and "YOUR ENDPOINT_ID"
llm = VertexAIModelGarden(project="YOUR PROJECT", endpoint_id="YOUR ENDPOINT_ID")
```


```python
# invoke a model response
llm.invoke("What is the meaning of life?")
```


```output
'Prompt:\nWhat is the meaning of life?\nOutput:\nWhat is the meaning of life?\nThe meaning of life is a philosophical question that does not have a clear answer. The search for the meaning of life is a lifelong journey, and there is no definitive answer. Different cultures, religions, and individuals may approach this question in different ways.'
```


모든 LLM과 마찬가지로, 우리는 이를 다른 구성 요소와 결합할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Google Cloud Vertex AI"}]-->
from langchain_core.prompts import PromptTemplate

prompt = PromptTemplate.from_template("What is the meaning of {thing}?")
```


```python
chain = prompt | llm
print(chain.invoke({"thing": "life"}))
```

```output
Prompt:
What is the meaning of life?
Output:
What is the meaning of life?
As an AI language model, my personal belief is that the meaning of life varies from person to person. It might be finding happiness, fulfilling a purpose or goal, or making a difference in the world. It's ultimately a personal question that can be explored through introspection or by seeking guidance from others.
```

### Vertex AI 모델 정원의 Gemma

> [Gemma](https://ai.google.dev/gemma)는 경량의 생성 인공지능(AI) 오픈 모델 세트입니다. Gemma 모델은 애플리케이션 및 하드웨어, 모바일 장치 또는 호스팅 서비스에서 실행할 수 있습니다. 이러한 모델을 조정 기술을 사용하여 사용자와 사용자에게 중요한 작업을 수행하도록 맞춤화할 수도 있습니다. Gemma 모델은 [Gemini](https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/overview) 모델을 기반으로 하며, AI 개발 커뮤니티가 확장하고 발전시키기 위한 것입니다.

Vertex 모델 정원에서 Gemma를 사용하려면 먼저 [Vertex AI 엔드포인트에 배포해야 합니다](https://cloud.google.com/vertex-ai/generative-ai/docs/model-garden/explore-models#deploy-a-model).

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Google Cloud Vertex AI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Google Cloud Vertex AI"}]-->
from langchain_core.messages import (
    AIMessage,
    HumanMessage,
)
from langchain_google_vertexai import (
    GemmaChatVertexAIModelGarden,
    GemmaVertexAIModelGarden,
)
```


```python
# TODO : Add "YOUR PROJECT" , "YOUR REGION" and "YOUR ENDPOINT_ID"
llm = GemmaVertexAIModelGarden(
    endpoint_id="YOUR PROJECT",
    project="YOUR ENDPOINT_ID",
    location="YOUR REGION",
)

# invoke a model response
llm.invoke("What is the meaning of life?")
```


```output
'Prompt:\nWhat is the meaning of life?\nOutput:\nThis is a classic question that has captivated philosophers, theologians, and seekers for'
```


```python
# TODO : Add "YOUR PROJECT" , "YOUR REGION" and "YOUR ENDPOINT_ID"
chat_llm = GemmaChatVertexAIModelGarden(
    endpoint_id="YOUR PROJECT",
    project="YOUR ENDPOINT_ID",
    location="YOUR REGION",
)
```


```python
# Prepare input for model consumption
text_question1 = "How much is 2+2?"
message1 = HumanMessage(content=text_question1)

# invoke a model response
chat_llm.invoke([message1])
```


```output
AIMessage(content='Prompt:\n<start_of_turn>user\nHow much is 2+2?<end_of_turn>\n<start_of_turn>model\nOutput:\nThe answer is 4.\n2 + 2 = 4.', id='run-cea563df-e91a-4374-83a1-3d8b186a01b2-0')
```


## Vertex AI의 Anthropic

> Vertex AI에서 [Anthropic Claude 3](https://cloud.google.com/vertex-ai/generative-ai/docs/partner-models/use-claude) 모델은 완전 관리되고 서버리스 모델을 API로 제공합니다. Vertex AI에서 Claude 모델을 사용하려면 Vertex AI API 엔드포인트에 직접 요청을 보내십시오. Anthropic Claude 3 모델은 관리되는 API를 사용하므로 인프라를 프로비저닝하거나 관리할 필요가 없습니다.

참고: Vertex의 Anthropic 모델은 `ChatAnthropicVertex` 클래스를 통해 채팅 모델로 구현됩니다.

```python
!pip install -U langchain-google-vertexai anthropic[vertex]
```


```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Google Cloud Vertex AI"}, {"imported": "AIMessageChunk", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html", "title": "Google Cloud Vertex AI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Google Cloud Vertex AI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "Google Cloud Vertex AI"}, {"imported": "LLMResult", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.llm_result.LLMResult.html", "title": "Google Cloud Vertex AI"}]-->
from langchain_core.messages import (
    AIMessage,
    AIMessageChunk,
    HumanMessage,
    SystemMessage,
)
from langchain_core.outputs import LLMResult
from langchain_google_vertexai.model_garden import ChatAnthropicVertex
```


참고: 올바른 [Claude 3 모델 버전](https://cloud.google.com/vertex-ai/generative-ai/docs/partner-models/use-claude#claude-opus)을 지정하십시오.
- Claude 3 Opus(미리보기)의 경우 `claude-3-opus@20240229`를 사용하십시오.
- Claude 3 Sonnet의 경우 `claude-3-sonnet@20240229`를 사용하십시오.
- Claude 3 Haiku의 경우 `claude-3-haiku@20240307`를 사용하십시오.

`@` 기호로 시작하는 접미사가 없는 Anthropic Claude 3 모델 버전(claude-3-opus, claude-3-sonnet 또는 claude-3-haiku)의 사용을 권장하지 않습니다.

```python
# TODO : Replace below with your project id and region
project = "<project_id>"
location = "<region>"

# Initialise the Model
model = ChatAnthropicVertex(
    model_name="claude-3-haiku@20240307",
    project=project,
    location=location,
)
```


```python
# prepare input data for the model
raw_context = (
    "My name is Peter. You are my personal assistant. My favorite movies "
    "are Lord of the Rings and Hobbit."
)
question = (
    "Hello, could you recommend a good movie for me to watch this evening, please?"
)
context = SystemMessage(content=raw_context)
message = HumanMessage(content=question)
```


```python
# Invoke the model
response = model.invoke([context, message])
print(response.content)
```

```output
Since your favorite movies are the Lord of the Rings and Hobbit trilogies, I would recommend checking out some other epic fantasy films that have a similar feel:

1. The Chronicles of Narnia series - These films are based on the beloved fantasy novels by C.S. Lewis and have a great blend of adventure, magic, and memorable characters.

2. Stardust - This 2007 fantasy film, based on the Neil Gaiman novel, has an excellent cast and a charming, whimsical tone.

3. The Golden Compass - The first film adaptation of Philip Pullman's His Dark Materials series, with stunning visuals and a compelling story.

4. Pan's Labyrinth - Guillermo del Toro's dark, fairy tale-inspired masterpiece set against the backdrop of the Spanish Civil War.

5. The Princess Bride - A classic fantasy adventure film with humor, romance, and unforgettable characters.

Let me know if any of those appeal to you or if you'd like me to suggest something else! I'm happy to provide more personalized recommendations.
```


```python
# You can choose to initialize/ override the model name on Invoke method as well
response = model.invoke([context, message], model_name="claude-3-sonnet@20240229")
print(response.content)
```

```output
Sure, I'd be happy to recommend a movie for you! Since you mentioned that The Lord of the Rings and The Hobbit are among your favorite movies, I'll suggest some other epic fantasy/adventure films you might enjoy:

1. The Princess Bride (1987) - A classic fairy tale with adventure, romance, and a lot of wit and humor. It has an all-star cast and very quotable lines.

2. Willow (1988) - A fun fantasy film produced by George Lucas with fairies, dwarves, and brownies going on an epic quest. Has a similar tone to the Lord of the Rings movies.

3. Stardust (2007) - An underrated fantasy adventure based on the Neil Gaiman novel about a young man entering a magical kingdom to retrieve a fallen star. Great cast and visuals.

4. The Chronicles of Narnia series - The Lion, The Witch and The Wardrobe is the best known, but the other Narnia films are also very well done fantasy epics.

5. The Golden Compass (2007) - First installment of the His Dark Materials trilogy, set in a parallel universe with armored polar bears and truth-seeking devices.

Let me know if you'd like any other suggestions or have a particular style of movie in mind! I aimed for entertaining fantasy/adventure flicks similar to Lord of the Rings.
```


```python
# Use streaming responses
sync_response = model.stream([context, message], model_name="claude-3-haiku@20240307")
for chunk in sync_response:
    print(chunk.content)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)