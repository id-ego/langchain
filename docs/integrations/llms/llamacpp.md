---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/llamacpp.ipynb
description: '`llama-cpp-python`을 LangChain 내에서 실행하는 방법을 다루며, GGUF 모델 파일로의 변환 및 설치
  방법을 설명합니다.'
---

# Llama.cpp

[llama-cpp-python](https://github.com/abetlen/llama-cpp-python)는 [llama.cpp](https://github.com/ggerganov/llama.cpp)에 대한 Python 바인딩입니다.

이것은 [Hugging Face](https://huggingface.co/TheBloke)에서 접근할 수 있는 [많은 LLMs](https://github.com/ggerganov/llama.cpp#description) 모델에 대한 추론을 지원합니다.

이 노트북은 LangChain 내에서 `llama-cpp-python`을 실행하는 방법을 설명합니다.

**참고: 새로운 버전의 `llama-cpp-python`은 GGUF 모델 파일을 사용합니다 (자세한 내용은 [여기](https://github.com/abetlen/llama-cpp-python/pull/633) 참조).**

이는 주요 변경 사항입니다.

기존 GGML 모델을 GGUF로 변환하려면 [llama.cpp](https://github.com/ggerganov/llama.cpp)에서 다음을 실행할 수 있습니다:

```
python ./convert-llama-ggmlv3-to-gguf.py --eps 1e-5 --input models/openorca-platypus2-13b.ggmlv3.q4_0.bin --output models/openorca-platypus2-13b.gguf.q4_0.bin
```


## 설치

llama-cpp 패키지를 설치하는 방법에는 여러 가지 옵션이 있습니다:
- CPU 사용
- CPU + GPU (여러 BLAS 백엔드 중 하나 사용)
- Metal GPU (Apple Silicon Chip이 있는 MacOS)

### CPU 전용 설치

```python
%pip install --upgrade --quiet  llama-cpp-python
```


### OpenBLAS / cuBLAS / CLBlast로 설치

`llama.cpp`는 더 빠른 처리를 위해 여러 BLAS 백엔드를 지원합니다. `FORCE_CMAKE=1` 환경 변수를 사용하여 cmake 사용을 강제하고 원하는 BLAS 백엔드에 대한 pip 패키지를 설치합니다 ([출처](https://github.com/abetlen/llama-cpp-python#installation-with-openblas--cublas--clblast)).

cuBLAS 백엔드를 사용한 예시 설치:

```python
!CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install llama-cpp-python
```


**중요**: 이미 CPU 전용 버전의 패키지를 설치한 경우, 처음부터 다시 설치해야 합니다. 다음 명령을 고려하십시오:

```python
!CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install --upgrade --force-reinstall llama-cpp-python --no-cache-dir
```


### Metal로 설치

`llama.cpp`는 Apple 실리콘을 최적화하여 ARM NEON, Accelerate 및 Metal 프레임워크를 통해 지원합니다. `FORCE_CMAKE=1` 환경 변수를 사용하여 cmake 사용을 강제하고 Metal 지원을 위한 pip 패키지를 설치합니다 ([출처](https://github.com/abetlen/llama-cpp-python/blob/main/docs/install/macos.md)).

Metal 지원을 사용한 예시 설치:

```python
!CMAKE_ARGS="-DLLAMA_METAL=on" FORCE_CMAKE=1 pip install llama-cpp-python
```


**중요**: 이미 CPU 전용 버전의 패키지를 설치한 경우, 처음부터 다시 설치해야 합니다: 다음 명령을 고려하십시오:

```python
!CMAKE_ARGS="-DLLAMA_METAL=on" FORCE_CMAKE=1 pip install --upgrade --force-reinstall llama-cpp-python --no-cache-dir
```


### Windows로 설치

소스에서 컴파일하여 `llama-cpp-python` 라이브러리를 설치하는 것이 안정적입니다. 저장소 자체의 대부분의 지침을 따를 수 있지만, 유용할 수 있는 Windows 전용 지침이 있습니다.

`llama-cpp-python`을 설치하기 위한 요구 사항:

- git
- python
- cmake
- Visual Studio Community (다음 설정으로 설치해야 합니다)
  - C++를 사용한 데스크탑 개발
  - Python 개발
  - C++를 사용한 리눅스 임베디드 개발

1. `llama.cpp` 하위 모듈을 가져오기 위해 git 저장소를 재귀적으로 클론합니다.

```
git clone --recursive -j8 https://github.com/abetlen/llama-cpp-python.git
```


2. 명령 프롬프트를 열고 다음 환경 변수를 설정합니다.

```
set FORCE_CMAKE=1
set CMAKE_ARGS=-DLLAMA_CUBLAS=OFF
```

NVIDIA GPU가 있는 경우 `DLLAMA_CUBLAS`가 `ON`으로 설정되어 있는지 확인하십시오.

#### 컴파일 및 설치

이제 `llama-cpp-python` 디렉토리로 `cd`하여 패키지를 설치할 수 있습니다.

```
python -m pip install -e .
```


**중요**: 이미 CPU 전용 버전의 패키지를 설치한 경우, 처음부터 다시 설치해야 합니다: 다음 명령을 고려하십시오:

```python
!python -m pip install -e . --force-reinstall --no-cache-dir
```


## 사용법

모든 필요한 모델 파일을 [설치하는 모든 지침](https://github.com/ggerganov/llama.cpp)을 따르고 있는지 확인하십시오.

LLM을 로컬에서 실행할 것이므로 `API_TOKEN`이 필요하지 않습니다.

어떤 모델이 원하는 머신에서 사용하기에 적합한지 이해하는 것이 중요합니다.

[TheBloke의](https://huggingface.co/TheBloke) Hugging Face 모델에는 다양한 양자화 크기 및 방법으로 모델을 실행하는 데 필요한 RAM을 노출하는 `Provided files` 섹션이 있습니다 (예: [Llama2-7B-Chat-GGUF](https://huggingface.co/TheBloke/Llama-2-7b-Chat-GGUF#provided-files)).

이 [github 이슈](https://github.com/facebookresearch/llama/issues/425)도 귀하의 머신에 적합한 모델을 찾는 데 관련이 있습니다.

```python
<!--IMPORTS:[{"imported": "LlamaCpp", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.llamacpp.LlamaCpp.html", "title": "Llama.cpp"}, {"imported": "CallbackManager", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManager.html", "title": "Llama.cpp"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "Llama.cpp"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Llama.cpp"}]-->
from langchain_community.llms import LlamaCpp
from langchain_core.callbacks import CallbackManager, StreamingStdOutCallbackHandler
from langchain_core.prompts import PromptTemplate
```


**모델에 맞는 템플릿을 사용하는 것을 고려하십시오! 올바른 프롬프트 템플릿을 얻기 위해 Hugging Face 등의 모델 페이지를 확인하십시오.**

```python
template = """Question: {question}

Answer: Let's work this out in a step by step way to be sure we have the right answer."""

prompt = PromptTemplate.from_template(template)
```


```python
# Callbacks support token-wise streaming
callback_manager = CallbackManager([StreamingStdOutCallbackHandler()])
```


### CPU

LLaMA 2 7B 모델을 사용하는 예시

```python
# Make sure the model path is correct for your system!
llm = LlamaCpp(
    model_path="/Users/rlm/Desktop/Code/llama.cpp/models/openorca-platypus2-13b.gguf.q4_0.bin",
    temperature=0.75,
    max_tokens=2000,
    top_p=1,
    callback_manager=callback_manager,
    verbose=True,  # Verbose is required to pass to the callback manager
)
```


```python
question = """
Question: A rap battle between Stephen Colbert and John Oliver
"""
llm.invoke(question)
```

```output

Stephen Colbert:
Yo, John, I heard you've been talkin' smack about me on your show.
Let me tell you somethin', pal, I'm the king of late-night TV
My satire is sharp as a razor, it cuts deeper than a knife
While you're just a british bloke tryin' to be funny with your accent and your wit.
John Oliver:
Oh Stephen, don't be ridiculous, you may have the ratings but I got the real talk.
My show is the one that people actually watch and listen to, not just for the laughs but for the facts.
While you're busy talkin' trash, I'm out here bringing the truth to light.
Stephen Colbert:
Truth? Ha! You think your show is about truth? Please, it's all just a joke to you.
You're just a fancy-pants british guy tryin' to be funny with your news and your jokes.
While I'm the one who's really makin' a difference, with my sat
``````output

llama_print_timings:        load time =   358.60 ms
llama_print_timings:      sample time =   172.55 ms /   256 runs   (    0.67 ms per token,  1483.59 tokens per second)
llama_print_timings: prompt eval time =   613.36 ms /    16 tokens (   38.33 ms per token,    26.09 tokens per second)
llama_print_timings:        eval time = 10151.17 ms /   255 runs   (   39.81 ms per token,    25.12 tokens per second)
llama_print_timings:       total time = 11332.41 ms
```


```output
"\nStephen Colbert:\nYo, John, I heard you've been talkin' smack about me on your show.\nLet me tell you somethin', pal, I'm the king of late-night TV\nMy satire is sharp as a razor, it cuts deeper than a knife\nWhile you're just a british bloke tryin' to be funny with your accent and your wit.\nJohn Oliver:\nOh Stephen, don't be ridiculous, you may have the ratings but I got the real talk.\nMy show is the one that people actually watch and listen to, not just for the laughs but for the facts.\nWhile you're busy talkin' trash, I'm out here bringing the truth to light.\nStephen Colbert:\nTruth? Ha! You think your show is about truth? Please, it's all just a joke to you.\nYou're just a fancy-pants british guy tryin' to be funny with your news and your jokes.\nWhile I'm the one who's really makin' a difference, with my sat"
```


LLaMA v1 모델을 사용하는 예시

```python
# Make sure the model path is correct for your system!
llm = LlamaCpp(
    model_path="./ggml-model-q4_0.bin", callback_manager=callback_manager, verbose=True
)
```


```python
llm_chain = prompt | llm
```


```python
question = "What NFL team won the Super Bowl in the year Justin Bieber was born?"
llm_chain.invoke({"question": question})
```

```output


1. First, find out when Justin Bieber was born.
2. We know that Justin Bieber was born on March 1, 1994.
3. Next, we need to look up when the Super Bowl was played in that year.
4. The Super Bowl was played on January 28, 1995.
5. Finally, we can use this information to answer the question. The NFL team that won the Super Bowl in the year Justin Bieber was born is the San Francisco 49ers.
``````output

llama_print_timings:        load time =   434.15 ms
llama_print_timings:      sample time =    41.81 ms /   121 runs   (    0.35 ms per token)
llama_print_timings: prompt eval time =  2523.78 ms /    48 tokens (   52.58 ms per token)
llama_print_timings:        eval time = 23971.57 ms /   121 runs   (  198.11 ms per token)
llama_print_timings:       total time = 28945.95 ms
```


```output
'\n\n1. First, find out when Justin Bieber was born.\n2. We know that Justin Bieber was born on March 1, 1994.\n3. Next, we need to look up when the Super Bowl was played in that year.\n4. The Super Bowl was played on January 28, 1995.\n5. Finally, we can use this information to answer the question. The NFL team that won the Super Bowl in the year Justin Bieber was born is the San Francisco 49ers.'
```


### GPU

BLAS 백엔드로 설치가 올바르게 이루어졌다면, 모델 속성에서 `BLAS = 1` 지시자를 볼 수 있습니다.

GPU와 함께 사용할 때 가장 중요한 두 가지 매개변수는 다음과 같습니다:

- `n_gpu_layers` - 모델의 몇 개 레이어가 GPU로 오프로드되는지를 결정합니다.
- `n_batch` - 몇 개의 토큰이 병렬로 처리되는지를 결정합니다.

이 매개변수를 올바르게 설정하면 평가 속도가 크게 향상됩니다 (자세한 내용은 [래퍼 코드](https://github.com/langchain-ai/langchain/blob/master/libs/community/langchain_community/llms/llamacpp.py) 참조).

```python
n_gpu_layers = -1  # The number of layers to put on the GPU. The rest will be on the CPU. If you don't know how many layers there are, you can use -1 to move all to GPU.
n_batch = 512  # Should be between 1 and n_ctx, consider the amount of VRAM in your GPU.

# Make sure the model path is correct for your system!
llm = LlamaCpp(
    model_path="/Users/rlm/Desktop/Code/llama.cpp/models/openorca-platypus2-13b.gguf.q4_0.bin",
    n_gpu_layers=n_gpu_layers,
    n_batch=n_batch,
    callback_manager=callback_manager,
    verbose=True,  # Verbose is required to pass to the callback manager
)
```


```python
llm_chain = prompt | llm
question = "What NFL team won the Super Bowl in the year Justin Bieber was born?"
llm_chain.invoke({"question": question})
```

```output


1. Identify Justin Bieber's birth date: Justin Bieber was born on March 1, 1994.

2. Find the Super Bowl winner of that year: The NFL season of 1993 with the Super Bowl being played in January or of 1994.

3. Determine which team won the game: The Dallas Cowboys faced the Buffalo Bills in Super Bowl XXVII on January 31, 1993 (as the year is mis-labelled due to a error). The Dallas Cowboys won this matchup.

So, Justin Bieber was born when the Dallas Cowboys were the reigning NFL Super Bowl.
``````output

llama_print_timings:        load time =   427.63 ms
llama_print_timings:      sample time =   115.85 ms /   164 runs   (    0.71 ms per token,  1415.67 tokens per second)
llama_print_timings: prompt eval time =   427.53 ms /    45 tokens (    9.50 ms per token,   105.26 tokens per second)
llama_print_timings:        eval time =  4526.53 ms /   163 runs   (   27.77 ms per token,    36.01 tokens per second)
llama_print_timings:       total time =  5293.77 ms
```


```output
"\n\n1. Identify Justin Bieber's birth date: Justin Bieber was born on March 1, 1994.\n\n2. Find the Super Bowl winner of that year: The NFL season of 1993 with the Super Bowl being played in January or of 1994.\n\n3. Determine which team won the game: The Dallas Cowboys faced the Buffalo Bills in Super Bowl XXVII on January 31, 1993 (as the year is mis-labelled due to a error). The Dallas Cowboys won this matchup.\n\nSo, Justin Bieber was born when the Dallas Cowboys were the reigning NFL Super Bowl."
```


### Metal

Metal로 설치가 올바르게 이루어졌다면, 모델 속성에서 `NEON = 1` 지시자를 볼 수 있습니다.

가장 중요한 두 가지 GPU 매개변수는 다음과 같습니다:

- `n_gpu_layers` - 모델의 몇 개 레이어가 Metal GPU로 오프로드되는지를 결정합니다.
- `n_batch` - 몇 개의 토큰이 병렬로 처리되는지를 결정하며, 기본값은 8이며 더 큰 숫자로 설정합니다.
- `f16_kv` - 어떤 이유로 Metal은 `True`만 지원하며, 그렇지 않으면 `Asserting on type 0 GGML_ASSERT: .../ggml-metal.m:706: false && "not implemented"`와 같은 오류가 발생합니다.

이 매개변수를 올바르게 설정하면 평가 속도가 크게 향상됩니다 (자세한 내용은 [래퍼 코드](https://github.com/langchain-ai/langchain/blob/master/libs/community/langchain_community/llms/llamacpp.py) 참조).

```python
n_gpu_layers = 1  # The number of layers to put on the GPU. The rest will be on the CPU. If you don't know how many layers there are, you can use -1 to move all to GPU.
n_batch = 512  # Should be between 1 and n_ctx, consider the amount of RAM of your Apple Silicon Chip.
# Make sure the model path is correct for your system!
llm = LlamaCpp(
    model_path="/Users/rlm/Desktop/Code/llama.cpp/models/openorca-platypus2-13b.gguf.q4_0.bin",
    n_gpu_layers=n_gpu_layers,
    n_batch=n_batch,
    f16_kv=True,  # MUST set to True, otherwise you will run into problem after a couple of calls
    callback_manager=callback_manager,
    verbose=True,  # Verbose is required to pass to the callback manager
)
```


콘솔 로그는 Metal이 올바르게 활성화되었음을 나타내는 다음 로그를 보여줍니다.

```
ggml_metal_init: allocating
ggml_metal_init: using MPS
...
```


프로세스의 GPU 사용량을 모니터링하여 `Activity Monitor`를 확인할 수도 있으며, `n_gpu_layers=1`을 활성화한 후 CPU 사용량이 급격히 감소합니다.

LLM에 대한 첫 번째 호출에서는 Metal GPU에서 모델 컴파일로 인해 성능이 느릴 수 있습니다.

### 문법

우리는 [문법](https://github.com/ggerganov/llama.cpp/blob/master/grammars/README.md)을 사용하여 모델 출력을 제약하고 정의된 규칙에 따라 샘플 토큰을 생성할 수 있습니다.

이 개념을 설명하기 위해, 아래 예제에서 사용할 [샘플 문법 파일](https://github.com/langchain-ai/langchain/tree/master/libs/langchain/langchain/llms/grammars)을 포함했습니다.

gbnf 문법 파일을 만드는 것은 시간이 많이 걸릴 수 있지만, 출력 스키마가 중요한 사용 사례가 있는 경우 도움이 될 수 있는 두 가지 도구가 있습니다:
- TypeScript 인터페이스 정의를 gbnf 파일로 변환하는 [온라인 문법 생성기 앱](https://grammar.intrinsiclabs.ai/).
- json 스키마를 gbnf 파일로 변환하는 [Python 스크립트](https://github.com/ggerganov/llama.cpp/blob/master/examples/json-schema-to-grammar.py). 예를 들어 `pydantic` 객체를 생성하고 `.schema_json()` 메서드를 사용하여 JSON 스키마를 생성한 다음 이 스크립트를 사용하여 gbnf 파일로 변환할 수 있습니다.

첫 번째 예제에서는 지정된 `json.gbnf` 파일의 경로를 제공하여 JSON을 생성합니다:

```python
n_gpu_layers = 1  # The number of layers to put on the GPU. The rest will be on the CPU. If you don't know how many layers there are, you can use -1 to move all to GPU.
n_batch = 512  # Should be between 1 and n_ctx, consider the amount of RAM of your Apple Silicon Chip.
# Make sure the model path is correct for your system!
llm = LlamaCpp(
    model_path="/Users/rlm/Desktop/Code/llama.cpp/models/openorca-platypus2-13b.gguf.q4_0.bin",
    n_gpu_layers=n_gpu_layers,
    n_batch=n_batch,
    f16_kv=True,  # MUST set to True, otherwise you will run into problem after a couple of calls
    callback_manager=callback_manager,
    verbose=True,  # Verbose is required to pass to the callback manager
    grammar_path="/Users/rlm/Desktop/Code/langchain-main/langchain/libs/langchain/langchain/llms/grammars/json.gbnf",
)
```


```python
%%capture captured --no-stdout
result = llm.invoke("Describe a person in JSON format:")
```

```output
{
  "name": "John Doe",
  "age": 34,
  "": {
    "title": "Software Developer",
    "company": "Google"
  },
  "interests": [
    "Sports",
    "Music",
    "Cooking"
  ],
  "address": {
    "street_number": 123,
    "street_name": "Oak Street",
    "city": "Mountain View",
    "state": "California",
    "postal_code": 94040
  }}
``````output

llama_print_timings:        load time =   357.51 ms
llama_print_timings:      sample time =  1213.30 ms /   144 runs   (    8.43 ms per token,   118.68 tokens per second)
llama_print_timings: prompt eval time =   356.78 ms /     9 tokens (   39.64 ms per token,    25.23 tokens per second)
llama_print_timings:        eval time =  3947.16 ms /   143 runs   (   27.60 ms per token,    36.23 tokens per second)
llama_print_timings:       total time =  5846.21 ms
```

`list.gbnf`를 제공하여 목록을 반환할 수도 있습니다:

```python
n_gpu_layers = 1
n_batch = 512
llm = LlamaCpp(
    model_path="/Users/rlm/Desktop/Code/llama.cpp/models/openorca-platypus2-13b.gguf.q4_0.bin",
    n_gpu_layers=n_gpu_layers,
    n_batch=n_batch,
    f16_kv=True,  # MUST set to True, otherwise you will run into problem after a couple of calls
    callback_manager=callback_manager,
    verbose=True,
    grammar_path="/Users/rlm/Desktop/Code/langchain-main/langchain/libs/langchain/langchain/llms/grammars/list.gbnf",
)
```


```python
%%capture captured --no-stdout
result = llm.invoke("List of top-3 my favourite books:")
```

```output
["The Catcher in the Rye", "Wuthering Heights", "Anna Karenina"]
``````output

llama_print_timings:        load time =   322.34 ms
llama_print_timings:      sample time =   232.60 ms /    26 runs   (    8.95 ms per token,   111.78 tokens per second)
llama_print_timings: prompt eval time =   321.90 ms /    11 tokens (   29.26 ms per token,    34.17 tokens per second)
llama_print_timings:        eval time =   680.82 ms /    25 runs   (   27.23 ms per token,    36.72 tokens per second)
llama_print_timings:       total time =  1295.27 ms
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)