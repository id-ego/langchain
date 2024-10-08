---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/llamacpp/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/llamacpp.ipynb
---

# Llama.cpp

[llama-cpp-python](https://github.com/abetlen/llama-cpp-python) is a Python binding for [llama.cpp](https://github.com/ggerganov/llama.cpp).

It supports inference for [many LLMs](https://github.com/ggerganov/llama.cpp#description) models, which can be accessed on [Hugging Face](https://huggingface.co/TheBloke).

This notebook goes over how to run `llama-cpp-python` within LangChain.

**Note: new versions of `llama-cpp-python` use GGUF model files (see [here](https://github.com/abetlen/llama-cpp-python/pull/633)).**

This is a breaking change.

To convert existing GGML models to GGUF you can run the following in [llama.cpp](https://github.com/ggerganov/llama.cpp):

```
python ./convert-llama-ggmlv3-to-gguf.py --eps 1e-5 --input models/openorca-platypus2-13b.ggmlv3.q4_0.bin --output models/openorca-platypus2-13b.gguf.q4_0.bin
```

## Installation

There are different options on how to install the llama-cpp package: 
- CPU usage
- CPU + GPU (using one of many BLAS backends)
- Metal GPU (MacOS with Apple Silicon Chip) 

### CPU only installation

```python
%pip install --upgrade --quiet  llama-cpp-python
```

### Installation with OpenBLAS / cuBLAS / CLBlast

`llama.cpp` supports multiple BLAS backends for faster processing. Use the `FORCE_CMAKE=1` environment variable to force the use of cmake and install the pip package for the desired BLAS backend ([source](https://github.com/abetlen/llama-cpp-python#installation-with-openblas--cublas--clblast)).

Example installation with cuBLAS backend:

```python
!CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install llama-cpp-python
```

**IMPORTANT**: If you have already installed the CPU only version of the package, you need to reinstall it from scratch. Consider the following command: 

```python
!CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install --upgrade --force-reinstall llama-cpp-python --no-cache-dir
```

### Installation with Metal

`llama.cpp` supports Apple silicon first-class citizen - optimized via ARM NEON, Accelerate and Metal frameworks. Use the `FORCE_CMAKE=1` environment variable to force the use of cmake and install the pip package for the Metal support ([source](https://github.com/abetlen/llama-cpp-python/blob/main/docs/install/macos.md)).

Example installation with Metal Support:

```python
!CMAKE_ARGS="-DLLAMA_METAL=on" FORCE_CMAKE=1 pip install llama-cpp-python
```

**IMPORTANT**: If you have already installed a cpu only version of the package, you need to reinstall it from scratch: consider the following command: 

```python
!CMAKE_ARGS="-DLLAMA_METAL=on" FORCE_CMAKE=1 pip install --upgrade --force-reinstall llama-cpp-python --no-cache-dir
```

### Installation with Windows

It is stable to install the `llama-cpp-python` library by compiling from the source. You can follow most of the instructions in the repository itself but there are some windows specific instructions which might be useful.

Requirements to install the `llama-cpp-python`,

- git
- python
- cmake
- Visual Studio Community (make sure you install this with the following settings)
  - Desktop development with C++
  - Python development
  - Linux embedded development with C++

1. Clone git repository recursively to get `llama.cpp` submodule as well 

```
git clone --recursive -j8 https://github.com/abetlen/llama-cpp-python.git
```

2. Open up a command Prompt and set the following environment variables.

```
set FORCE_CMAKE=1
set CMAKE_ARGS=-DLLAMA_CUBLAS=OFF
```
If you have an NVIDIA GPU make sure `DLLAMA_CUBLAS` is set to `ON`

#### Compiling and installing

Now you can `cd` into the `llama-cpp-python` directory and install the package

```
python -m pip install -e .
```

**IMPORTANT**: If you have already installed a cpu only version of the package, you need to reinstall it from scratch: consider the following command: 

```python
!python -m pip install -e . --force-reinstall --no-cache-dir
```

## Usage

Make sure you are following all instructions to [install all necessary model files](https://github.com/ggerganov/llama.cpp).

You don't need an `API_TOKEN` as you will run the LLM locally.

It is worth understanding which models are suitable to be used on the desired machine.

[TheBloke's](https://huggingface.co/TheBloke) Hugging Face models have a `Provided files` section that exposes the RAM required to run models of different quantisation sizes and methods (eg: [Llama2-7B-Chat-GGUF](https://huggingface.co/TheBloke/Llama-2-7b-Chat-GGUF#provided-files)).

This [github issue](https://github.com/facebookresearch/llama/issues/425) is also relevant to find the right model for your machine.

```python
<!--IMPORTS:[{"imported": "LlamaCpp", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.llamacpp.LlamaCpp.html", "title": "Llama.cpp"}, {"imported": "CallbackManager", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManager.html", "title": "Llama.cpp"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "Llama.cpp"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Llama.cpp"}]-->
from langchain_community.llms import LlamaCpp
from langchain_core.callbacks import CallbackManager, StreamingStdOutCallbackHandler
from langchain_core.prompts import PromptTemplate
```

**Consider using a template that suits your model! Check the models page on Hugging Face etc. to get a correct prompting template.**

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

Example using a LLaMA 2 7B model

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

Example using a LLaMA v1 model

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

If the installation with BLAS backend was correct, you will see a `BLAS = 1` indicator in model properties.

Two of the most important parameters for use with GPU are:

- `n_gpu_layers` - determines how many layers of the model are offloaded to your GPU.
- `n_batch` - how many tokens are processed in parallel. 

Setting these parameters correctly will dramatically improve the evaluation speed (see [wrapper code](https://github.com/langchain-ai/langchain/blob/master/libs/community/langchain_community/llms/llamacpp.py) for more details).

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

If the installation with Metal was correct, you will see a `NEON = 1` indicator in model properties.

Two of the most important GPU parameters are:

- `n_gpu_layers` - determines how many layers of the model are offloaded to your Metal GPU.
- `n_batch` - how many tokens are processed in parallel, default is 8, set to bigger number.
- `f16_kv` - for some reason, Metal only support `True`, otherwise you will get error such as `Asserting on type 0 GGML_ASSERT: .../ggml-metal.m:706: false && "not implemented"`

Setting these parameters correctly will dramatically improve the evaluation speed (see [wrapper code](https://github.com/langchain-ai/langchain/blob/master/libs/community/langchain_community/llms/llamacpp.py) for more details).

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

The console log will show the following log to indicate Metal was enable properly.

```
ggml_metal_init: allocating
ggml_metal_init: using MPS
...
```

You also could check `Activity Monitor` by watching the GPU usage of the process, the CPU usage will drop dramatically after turn on `n_gpu_layers=1`. 

For the first call to the LLM, the performance may be slow due to the model compilation in Metal GPU.

### Grammars

We can use [grammars](https://github.com/ggerganov/llama.cpp/blob/master/grammars/README.md) to constrain model outputs and sample tokens based on the rules defined in them.

To demonstrate this concept, we've included [sample grammar files](https://github.com/langchain-ai/langchain/tree/master/libs/langchain/langchain/llms/grammars), that will be used in the examples below.

Creating gbnf grammar files can be time-consuming, but if you have a use-case where output schemas are important, there are two tools that can help:
- [Online grammar generator app](https://grammar.intrinsiclabs.ai/) that converts TypeScript interface definitions to gbnf file.
- [Python script](https://github.com/ggerganov/llama.cpp/blob/master/examples/json-schema-to-grammar.py) for converting json schema to gbnf file. You can for example create `pydantic` object, generate its JSON schema using `.schema_json()` method, and then use this script to convert it to gbnf file.

In the first example, supply the path to the specified `json.gbnf` file in order to produce JSON:

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
We can also supply `list.gbnf` to return a list:

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

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)