---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/dspy.ipynb
description: DSPy는 LLM을 위한 프레임워크로, 프로그램의 선언적 단계를 자동으로 컴파일하여 고품질 프롬프트를 생성합니다.
---

# DSPy

[DSPy](https://github.com/stanfordnlp/dspy)는 LLM을 위한 환상적인 프레임워크로, 프로그램의 선언적 단계를 수행하는 방법을 LMs에게 가르치는 자동 컴파일러를 도입합니다. 구체적으로, DSPy 컴파일러는 내부적으로 프로그램을 추적한 다음 대형 LMs를 위한 고품질 프롬프트를 작성하거나 소형 LMs를 위한 자동 미세 조정을 훈련시켜 작업의 단계를 가르칩니다.

[Omar Khattab](https://twitter.com/lateinteraction) 덕분에 통합이 이루어졌습니다! 이는 약간의 수정으로 모든 LCEL 체인과 함께 작동합니다.

이 짧은 튜토리얼은 이 개념 증명 기능이 어떻게 작동하는지를 보여줍니다. *이것은 아직 DSPy나 LangChain의 전체 기능을 제공하지 않지만, 수요가 많으면 확장할 것입니다.*

참고: 이것은 Omar가 DSPy를 위해 작성한 원래 예제에서 약간 수정된 것입니다. DSPy 측에서 LangChain \<\> DSPy에 관심이 있다면, 그것을 확인하는 것을 추천합니다. [여기](https://github.com/stanfordnlp/dspy/blob/main/examples/tweets/compiling_langchain.ipynb)에서 찾을 수 있습니다.

예제를 살펴보겠습니다. 이 예제에서는 간단한 RAG 파이프라인을 만들 것입니다. DSPy를 사용하여 프로그램을 "컴파일"하고 최적화된 프롬프트를 학습할 것입니다.

## 종속성 설치

!pip install -U dspy-ai  
!pip install -U openai jinja2  
!pip install -U langchain langchain-community langchain-openai langchain-core  

## 설정

OpenAI를 사용할 것이므로 API 키를 설정해야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()
```


이제 검색기를 설정할 수 있습니다. 검색기에는 DSPy를 통해 ColBERT 검색기를 사용할 것이며, 이는 모든 검색기와 함께 작동합니다.

```python
import dspy

colbertv2 = dspy.ColBERTv2(url="http://20.102.90.50:2017/wiki17_abstracts")
```


```python
<!--IMPORTS:[{"imported": "set_llm_cache", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_llm_cache.html", "title": "DSPy"}, {"imported": "SQLiteCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.SQLiteCache.html", "title": "DSPy"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "DSPy"}]-->
from langchain.globals import set_llm_cache
from langchain_community.cache import SQLiteCache
from langchain_openai import OpenAI

set_llm_cache(SQLiteCache(database_path="cache.db"))

llm = OpenAI(model_name="gpt-3.5-turbo-instruct", temperature=0)


def retrieve(inputs):
    return [doc["text"] for doc in colbertv2(inputs["question"], k=5)]
```


```python
colbertv2("cycling")
```


```output
[{'text': 'Cycling | Cycling, also called bicycling or biking, is the use of bicycles for transport, recreation, exercise or sport. Persons engaged in cycling are referred to as "cyclists", "bikers", or less commonly, as "bicyclists". Apart from two-wheeled bicycles, "cycling" also includes the riding of unicycles, tricycles, quadracycles, recumbent and similar human-powered vehicles (HPVs).',
  'pid': 2201868,
  'rank': 1,
  'score': 27.078739166259766,
  'prob': 0.3544841299722533,
  'long_text': 'Cycling | Cycling, also called bicycling or biking, is the use of bicycles for transport, recreation, exercise or sport. Persons engaged in cycling are referred to as "cyclists", "bikers", or less commonly, as "bicyclists". Apart from two-wheeled bicycles, "cycling" also includes the riding of unicycles, tricycles, quadracycles, recumbent and similar human-powered vehicles (HPVs).'},
 {'text': 'Cycling (ice hockey) | In ice hockey, cycling is an offensive strategy that moves the puck along the boards in the offensive zone to create a scoring chance by making defenders tired or moving them out of position.',
  'pid': 312153,
  'rank': 2,
  'score': 26.109302520751953,
  'prob': 0.13445464524590262,
  'long_text': 'Cycling (ice hockey) | In ice hockey, cycling is an offensive strategy that moves the puck along the boards in the offensive zone to create a scoring chance by making defenders tired or moving them out of position.'},
 {'text': 'Bicycle | A bicycle, also called a cycle or bike, is a human-powered, pedal-driven, single-track vehicle, having two wheels attached to a frame, one behind the other. A is called a cyclist, or bicyclist.',
  'pid': 2197695,
  'rank': 3,
  'score': 25.849220275878906,
  'prob': 0.10366294133944996,
  'long_text': 'Bicycle | A bicycle, also called a cycle or bike, is a human-powered, pedal-driven, single-track vehicle, having two wheels attached to a frame, one behind the other. A is called a cyclist, or bicyclist.'},
 {'text': 'USA Cycling | USA Cycling or USAC, based in Colorado Springs, Colorado, is the national governing body for bicycle racing in the United States. It covers the disciplines of road, track, mountain bike, cyclo-cross, and BMX across all ages and ability levels. In 2015, USAC had a membership of 61,631 individual members.',
  'pid': 3821927,
  'rank': 4,
  'score': 25.61395263671875,
  'prob': 0.08193096873942958,
  'long_text': 'USA Cycling | USA Cycling or USAC, based in Colorado Springs, Colorado, is the national governing body for bicycle racing in the United States. It covers the disciplines of road, track, mountain bike, cyclo-cross, and BMX across all ages and ability levels. In 2015, USAC had a membership of 61,631 individual members.'},
 {'text': 'Vehicular cycling | Vehicular cycling (also known as bicycle driving) is the practice of riding bicycles on roads in a manner that is in accordance with the principles for driving in traffic.',
  'pid': 3058888,
  'rank': 5,
  'score': 25.35515785217285,
  'prob': 0.06324918635213703,
  'long_text': 'Vehicular cycling | Vehicular cycling (also known as bicycle driving) is the practice of riding bicycles on roads in a manner that is in accordance with the principles for driving in traffic.'},
 {'text': 'Road cycling | Road cycling is the most widespread form of cycling. It includes recreational, racing, and utility cycling. Road cyclists are generally expected to obey the same rules and laws as other vehicle drivers or riders and may also be vehicular cyclists.',
  'pid': 3392359,
  'rank': 6,
  'score': 25.274639129638672,
  'prob': 0.058356079351563846,
  'long_text': 'Road cycling | Road cycling is the most widespread form of cycling. It includes recreational, racing, and utility cycling. Road cyclists are generally expected to obey the same rules and laws as other vehicle drivers or riders and may also be vehicular cyclists.'},
 {'text': 'Cycling South Africa | Cycling South Africa or Cycling SA is the national governing body of cycle racing in South Africa. Cycling SA is a member of the "Confédération Africaine de Cyclisme" and the "Union Cycliste Internationale" (UCI). It is affiliated to the South African Sports Confederation and Olympic Committee (SASCOC) as well as the Department of Sport and Recreation SA. Cycling South Africa regulates the five major disciplines within the sport, both amateur and professional, which include: road cycling, mountain biking, BMX biking, track cycling and para-cycling.',
  'pid': 2508026,
  'rank': 7,
  'score': 25.24260711669922,
  'prob': 0.05651643767006817,
  'long_text': 'Cycling South Africa | Cycling South Africa or Cycling SA is the national governing body of cycle racing in South Africa. Cycling SA is a member of the "Confédération Africaine de Cyclisme" and the "Union Cycliste Internationale" (UCI). It is affiliated to the South African Sports Confederation and Olympic Committee (SASCOC) as well as the Department of Sport and Recreation SA. Cycling South Africa regulates the five major disciplines within the sport, both amateur and professional, which include: road cycling, mountain biking, BMX biking, track cycling and para-cycling.'},
 {'text': 'Cycle sport | Cycle sport is competitive physical activity using bicycles. There are several categories of bicycle racing including road bicycle racing, time trialling, cyclo-cross, mountain bike racing, track cycling, BMX, and cycle speedway. Non-racing cycling sports include artistic cycling, cycle polo, freestyle BMX and mountain bike trials. The Union Cycliste Internationale (UCI) is the world governing body for cycling and international competitive cycling events. The International Human Powered Vehicle Association is the governing body for human-powered vehicles that imposes far fewer restrictions on their design than does the UCI. The UltraMarathon Cycling Association is the governing body for many ultra-distance cycling races.',
  'pid': 3394121,
  'rank': 8,
  'score': 25.170495986938477,
  'prob': 0.05258444735141742,
  'long_text': 'Cycle sport | Cycle sport is competitive physical activity using bicycles. There are several categories of bicycle racing including road bicycle racing, time trialling, cyclo-cross, mountain bike racing, track cycling, BMX, and cycle speedway. Non-racing cycling sports include artistic cycling, cycle polo, freestyle BMX and mountain bike trials. The Union Cycliste Internationale (UCI) is the world governing body for cycling and international competitive cycling events. The International Human Powered Vehicle Association is the governing body for human-powered vehicles that imposes far fewer restrictions on their design than does the UCI. The UltraMarathon Cycling Association is the governing body for many ultra-distance cycling races.'},
 {'text': "Cycling UK | Cycling UK is the brand name of the Cyclists' Touring Club or CTC. It is a charitable membership organisation supporting cyclists and promoting bicycle use. Cycling UK is registered at Companies House (as “Cyclists’ Touring Club”), and covered by company law; it is the largest such organisation in the UK. It works at a national and local level to lobby for cyclists' needs and wants, provides services to members, and organises local groups for local activism and those interested in recreational cycling. The original Cyclists' Touring Club began in the nineteenth century with a focus on amateur road cycling but these days has a much broader sphere of interest encompassing everyday transport, commuting and many forms of recreational cycling. Prior to April 2016, Cycling UK operated under the brand CTC, the national cycling charity. As of January 2007, the organisation's president was the newsreader Jon Snow.",
  'pid': 1841483,
  'rank': 9,
  'score': 25.166988372802734,
  'prob': 0.05240032450529368,
  'long_text': "Cycling UK | Cycling UK is the brand name of the Cyclists' Touring Club or CTC. It is a charitable membership organisation supporting cyclists and promoting bicycle use. Cycling UK is registered at Companies House (as “Cyclists’ Touring Club”), and covered by company law; it is the largest such organisation in the UK. It works at a national and local level to lobby for cyclists' needs and wants, provides services to members, and organises local groups for local activism and those interested in recreational cycling. The original Cyclists' Touring Club began in the nineteenth century with a focus on amateur road cycling but these days has a much broader sphere of interest encompassing everyday transport, commuting and many forms of recreational cycling. Prior to April 2016, Cycling UK operated under the brand CTC, the national cycling charity. As of January 2007, the organisation's president was the newsreader Jon Snow."},
 {'text': 'Cycling in the Netherlands | Cycling is a ubiquitous mode of transport in the Netherlands, with 36% of the people listing the bicycle as their most frequent mode of transport on a typical day as opposed to the car by 45% and public transport by 11%. Cycling has a modal share of 27% of all trips (urban and rural) nationwide. In cities this is even higher, such as Amsterdam which has 38%, though the smaller Dutch cities well exceed that: for instance Zwolle (pop. ~123,000) has 46% and the university town of Groningen (pop. ~198,000) has 31%. This high modal share for bicycle travel is enabled by excellent cycling infrastructure such as cycle paths, cycle tracks, protected intersections, ubiquitous bicycle parking and by making cycling routes shorter, quicker and more direct than car routes.',
  'pid': 1196118,
  'rank': 10,
  'score': 24.954299926757812,
  'prob': 0.0423608394724844,
  'long_text': 'Cycling in the Netherlands | Cycling is a ubiquitous mode of transport in the Netherlands, with 36% of the people listing the bicycle as their most frequent mode of transport on a typical day as opposed to the car by 45% and public transport by 11%. Cycling has a modal share of 27% of all trips (urban and rural) nationwide. In cities this is even higher, such as Amsterdam which has 38%, though the smaller Dutch cities well exceed that: for instance Zwolle (pop. ~123,000) has 46% and the university town of Groningen (pop. ~198,000) has 31%. This high modal share for bicycle travel is enabled by excellent cycling infrastructure such as cycle paths, cycle tracks, protected intersections, ubiquitous bicycle parking and by making cycling routes shorter, quicker and more direct than car routes.'}]
```


## 일반 LCEL

먼저, 일반적으로 LCEL로 간단한 RAG 파이프라인을 생성해 보겠습니다.

예시로, 다음 작업을 다뤄보겠습니다.

**작업:** 정보성 트윗을 생성하기 위한 RAG 시스템 구축.

- **입력:** 다소 복잡할 수 있는 사실 질문.
- **출력:** 검색된 정보에서 질문에 올바르게 답변하는 매력적인 트윗.

이것을 설명하기 위해 LangChain의 표현 언어(LCEL)를 사용하겠습니다. 여기서 어떤 프롬프트라도 괜찮으며, DSPy로 최종 프롬프트를 최적화할 것입니다.

이를 고려하여, 기본적인 형태로 유지하겠습니다: **주어진 {context}, 질문 {question}에 대해 트윗으로 답변하시오.**

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "DSPy"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "DSPy"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "DSPy"}]-->
# From LangChain, import standard modules for prompting.
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import RunnablePassthrough

# Just a simple prompt for this task. It's fine if it's complex too.
prompt = PromptTemplate.from_template(
    "Given {context}, answer the question `{question}` as a tweet."
)

# This is how you'd normally build a chain with LCEL. This chain does retrieval then generation (RAG).
vanilla_chain = (
    RunnablePassthrough.assign(context=retrieve) | prompt | llm | StrOutputParser()
)
```


## LCEL \<\> DSPy

LangChain을 DSPy와 함께 사용하려면 두 가지 작은 수정을 해야 합니다.

**LangChainPredict**

`prompt | llm` 대신 `dspy`의 `LangChainPredict(prompt, llm)`를 사용해야 합니다.

이는 프롬프트와 llm을 함께 묶어 최적화할 수 있는 래퍼입니다.

**LangChainModule**

이는 DSPy가 전체를 최적화할 수 있도록 최종 LCEL 체인을 래핑하는 래퍼입니다.

```python
# From DSPy, import the modules that know how to interact with LangChain LCEL.
from dspy.predict.langchain import LangChainModule, LangChainPredict

# This is how to wrap it so it behaves like a DSPy program.
# Just Replace every pattern like `prompt | llm` with `LangChainPredict(prompt, llm)`.
zeroshot_chain = (
    RunnablePassthrough.assign(context=retrieve)
    | LangChainPredict(prompt, llm)
    | StrOutputParser()
)
# Now we wrap it in LangChainModule
zeroshot_chain = LangChainModule(
    zeroshot_chain
)  # then wrap the chain in a DSPy module.
```


## 모듈 사용하기

이후에는 LangChain 실행 가능성과 DSPy 모듈로 사용할 수 있습니다!

```python
question = "In what region was Eddy Mazzoleni born?"

zeroshot_chain.invoke({"question": question})
```


```output
' Eddy Mazzoleni, born in Bergamo, Italy, is a professional road cyclist who rode for UCI ProTour Astana Team. #cyclist #Italy'
```


아, 그럴듯하네요! (기술적으로 완벽하지는 않지만: 우리는 도시가 아닌 지역을 요청했습니다. 아래에서 더 나은 결과를 얻을 수 있습니다.)

질문과 답변을 수동으로 검사하는 것은 시스템을 이해하는 데 매우 중요합니다. 그러나 좋은 시스템 설계자는 항상 작업을 반복적으로 벤치마킹하여 진행 상황을 정량화하려고 합니다!

이를 위해서는 두 가지가 필요합니다: 최대화하려는 메트릭과 시스템을 위한 (작은) 데이터셋입니다.

좋은 트윗에 대한 미리 정의된 메트릭이 있나요? 100,000개의 트윗을 수작업으로 라벨링해야 하나요? 아마도 아닐 것입니다. 그러나 생산에서 데이터를 얻기 시작할 때까지 합리적인 방법으로 할 수 있습니다!

## 데이터 로드

체인을 컴파일하기 위해 작업할 데이터셋이 필요합니다. 이 데이터셋은 원시 입력과 출력만 필요합니다. 우리의 목적을 위해 HotPotQA 데이터셋을 사용할 것입니다.

참고: 우리의 데이터셋에는 실제로 트윗이 포함되어 있지 않습니다! 질문과 답변만 있습니다. 괜찮습니다, 우리의 메트릭이 트윗 형식의 출력을 평가하는 데 신경 쓸 것입니다.

```python
import dspy
from dspy.datasets import HotPotQA

# Load the dataset.
dataset = HotPotQA(
    train_seed=1,
    train_size=200,
    eval_seed=2023,
    dev_size=200,
    test_size=0,
    keep_details=True,
)

# Tell DSPy that the 'question' field is the input. Any other fields are labels and/or metadata.
trainset = [x.without("id", "type").with_inputs("question") for x in dataset.train]
devset = [x.without("id", "type").with_inputs("question") for x in dataset.dev]
valset, devset = devset[:50], devset[50:]
```
  
```output
/Users/harrisonchase/.pyenv/versions/3.11.1/envs/langchain-3-11/lib/python3.11/site-packages/datasets/table.py:1421: FutureWarning: promote has been superseded by mode='default'.
  table = cls._concat_blocks(blocks, axis=0)
```
  
## 메트릭 정의

이제 메트릭을 정의해야 합니다. 이는 어떤 실행이 성공적이었는지 판단하는 데 사용됩니다. 여기서는 DSPy의 메트릭을 사용할 것이지만, 자신만의 메트릭을 작성할 수도 있습니다.

```python
# Define the signature for autoamtic assessments.
class Assess(dspy.Signature):
    """Assess the quality of a tweet along the specified dimension."""

    context = dspy.InputField(desc="ignore if N/A")
    assessed_text = dspy.InputField()
    assessment_question = dspy.InputField()
    assessment_answer = dspy.OutputField(desc="Yes or No")


gpt4T = dspy.OpenAI(model="gpt-4-1106-preview", max_tokens=1000, model_type="chat")
METRIC = None


def metric(gold, pred, trace=None):
    question, answer, tweet = gold.question, gold.answer, pred.output
    context = colbertv2(question, k=5)

    engaging = "Does the assessed text make for a self-contained, engaging tweet?"
    faithful = "Is the assessed text grounded in the context? Say no if it includes significant facts not in the context."
    correct = (
        f"The text above is should answer `{question}`. The gold answer is `{answer}`."
    )
    correct = f"{correct} Does the assessed text above contain the gold answer?"

    with dspy.context(lm=gpt4T):
        faithful = dspy.Predict(Assess)(
            context=context, assessed_text=tweet, assessment_question=faithful
        )
        correct = dspy.Predict(Assess)(
            context="N/A", assessed_text=tweet, assessment_question=correct
        )
        engaging = dspy.Predict(Assess)(
            context="N/A", assessed_text=tweet, assessment_question=engaging
        )

    correct, engaging, faithful = [
        m.assessment_answer.split()[0].lower() == "yes"
        for m in [correct, engaging, faithful]
    ]
    score = (correct + engaging + faithful) if correct and (len(tweet) <= 280) else 0

    if METRIC is not None:
        if METRIC == "correct":
            return correct
        if METRIC == "engaging":
            return engaging
        if METRIC == "faithful":
            return faithful

    if trace is not None:
        return score >= 3
    return score / 3.0
```


## 기준선 평가

좋습니다, 이제 LangChain LCEL 객체에서 변환된 최적화되지 않은 "제로샷" 버전을 평가해 보겠습니다.

```python
from dspy.evaluate.evaluate import Evaluate
```
  
```python
evaluate = Evaluate(
    metric=metric, devset=devset, num_threads=8, display_progress=True, display_table=5
)
evaluate(zeroshot_chain)
```
  
```output
Average Metric: 62.99999999999998 / 150  (42.0): 100%|██| 150/150 [01:14<00:00,  2.02it/s]
``````output
Average Metric: 62.99999999999998 / 150  (42.0%)
``````output

/Users/harrisonchase/.pyenv/versions/3.11.1/envs/langchain-3-11/lib/python3.11/site-packages/dspy/evaluate/evaluate.py:126: FutureWarning: DataFrame.applymap has been deprecated. Use DataFrame.map instead.
  df = df.applymap(truncate_cell)
```
  
```html
<style type="text/css">
#T_390d8 th {
  text-align: left;
}
#T_390d8 td {
  text-align: left;
}
#T_390d8_row0_col0, #T_390d8_row0_col1, #T_390d8_row0_col2, #T_390d8_row0_col3, #T_390d8_row0_col4, #T_390d8_row0_col5, #T_390d8_row1_col0, #T_390d8_row1_col1, #T_390d8_row1_col2, #T_390d8_row1_col3, #T_390d8_row1_col4, #T_390d8_row1_col5, #T_390d8_row2_col0, #T_390d8_row2_col1, #T_390d8_row2_col2, #T_390d8_row2_col3, #T_390d8_row2_col4, #T_390d8_row2_col5, #T_390d8_row3_col0, #T_390d8_row3_col1, #T_390d8_row3_col2, #T_390d8_row3_col3, #T_390d8_row3_col4, #T_390d8_row3_col5, #T_390d8_row4_col0, #T_390d8_row4_col1, #T_390d8_row4_col2, #T_390d8_row4_col3, #T_390d8_row4_col4, #T_390d8_row4_col5 {
  text-align: left;
  white-space: pre-wrap;
  word-wrap: break-word;
  max-width: 400px;
}
</style>
<table id="T_390d8">
  <thead>
    <tr>
      <th class="blank level0" >&nbsp;</th>
      <th id="T_390d8_level0_col0" class="col_heading level0 col0" >question</th>
      <th id="T_390d8_level0_col1" class="col_heading level0 col1" >answer</th>
      <th id="T_390d8_level0_col2" class="col_heading level0 col2" >gold_titles</th>
      <th id="T_390d8_level0_col3" class="col_heading level0 col3" >output</th>
      <th id="T_390d8_level0_col4" class="col_heading level0 col4" >tweet_response</th>
      <th id="T_390d8_level0_col5" class="col_heading level0 col5" >metric</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th id="T_390d8_level0_row0" class="row_heading level0 row0" >0</th>
      <td id="T_390d8_row0_col0" class="data row0 col0" >Who was a producer who produced albums for both rock bands Juke Karten and Thirty Seconds to Mars?</td>
      <td id="T_390d8_row0_col1" class="data row0 col1" >Brian Virtue</td>
      <td id="T_390d8_row0_col2" class="data row0 col2" >{'Thirty Seconds to Mars', 'Levolution (album)'}</td>
      <td id="T_390d8_row0_col3" class="data row0 col3" >Brian Virtue, who has worked with bands like Jane's Addiction and Velvet Revolver, produced albums for both Juke Kartel and Thirty Seconds to Mars. #BrianVirtue...</td>
      <td id="T_390d8_row0_col4" class="data row0 col4" >Brian Virtue, who has worked with bands like Jane's Addiction and Velvet Revolver, produced albums for both Juke Kartel and Thirty Seconds to Mars. #BrianVirtue...</td>
      <td id="T_390d8_row0_col5" class="data row0 col5" >1.0</td>
    </tr>
    <tr>
      <th id="T_390d8_level0_row1" class="row_heading level0 row1" >1</th>
      <td id="T_390d8_row1_col0" class="data row1 col0" >Are both the University of Chicago and Syracuse University public universities? </td>
      <td id="T_390d8_row1_col1" class="data row1 col1" >no</td>
      <td id="T_390d8_row1_col2" class="data row1 col2" >{'Syracuse University', 'University of Chicago'}</td>
      <td id="T_390d8_row1_col3" class="data row1 col3" > No, only Syracuse University is a public university. The University of Chicago is a private research university. #university #publicvsprivate</td>
      <td id="T_390d8_row1_col4" class="data row1 col4" > No, only Syracuse University is a public university. The University of Chicago is a private research university. #university #publicvsprivate</td>
      <td id="T_390d8_row1_col5" class="data row1 col5" >0.3333333333333333</td>
    </tr>
    <tr>
      <th id="T_390d8_level0_row2" class="row_heading level0 row2" >2</th>
      <td id="T_390d8_row2_col0" class="data row2 col0" >In what region was Eddy Mazzoleni born?</td>
      <td id="T_390d8_row2_col1" class="data row2 col1" >Lombardy, northern Italy</td>
      <td id="T_390d8_row2_col2" class="data row2 col2" >{'Eddy Mazzoleni', 'Bergamo'}</td>
      <td id="T_390d8_row2_col3" class="data row2 col3" > Eddy Mazzoleni, born in Bergamo, Italy, is a professional road cyclist who rode for UCI ProTour Astana Team. #cyclist #Italy</td>
      <td id="T_390d8_row2_col4" class="data row2 col4" > Eddy Mazzoleni, born in Bergamo, Italy, is a professional road cyclist who rode for UCI ProTour Astana Team. #cyclist #Italy</td>
      <td id="T_390d8_row2_col5" class="data row2 col5" >0.0</td>
    </tr>
    <tr>
      <th id="T_390d8_level0_row3" class="row_heading level0 row3" >3</th>
      <td id="T_390d8_row3_col0" class="data row3 col0" >Who edited the 1990 American romantic comedy film directed by Garry Marshall?</td>
      <td id="T_390d8_row3_col1" class="data row3 col1" >Raja Raymond Gosnell</td>
      <td id="T_390d8_row3_col2" class="data row3 col2" >{'Raja Gosnell', 'Pretty Woman'}</td>
      <td id="T_390d8_row3_col3" class="data row3 col3" > J. F. Lawton wrote the screenplay for Pretty Woman, the 1990 American romantic comedy film directed by Garry Marshall. #PrettyWoman #GarryMarshall #JFLawton</td>
      <td id="T_390d8_row3_col4" class="data row3 col4" > J. F. Lawton wrote the screenplay for Pretty Woman, the 1990 American romantic comedy film directed by Garry Marshall. #PrettyWoman #GarryMarshall #JFLawton</td>
      <td id="T_390d8_row3_col5" class="data row3 col5" >0.0</td>
    </tr>
    <tr>
      <th id="T_390d8_level0_row4" class="row_heading level0 row4" >4</th>
      <td id="T_390d8_row4_col0" class="data row4 col0" >Burrs Country Park railway station is what stop on the railway line that runs between Heywood and Rawtenstall</td>
      <td id="T_390d8_row4_col1" class="data row4 col1" >seventh</td>
      <td id="T_390d8_row4_col2" class="data row4 col2" >{'Burrs Country Park railway station', 'East Lancashire Railway'}</td>
      <td id="T_390d8_row4_col3" class="data row4 col3" > Burrs Country Park railway station is the seventh stop on the East Lancashire Railway line that runs between Heywood and Rawtenstall.</td>
      <td id="T_390d8_row4_col4" class="data row4 col4" > Burrs Country Park railway station is the seventh stop on the East Lancashire Railway line that runs between Heywood and Rawtenstall.</td>
      <td id="T_390d8_row4_col5" class="data row4 col5" >1.0</td>
    </tr>
  </tbody>
</table>
 
```
  

```html

<div style='
    text-align: center; 
    font-size: 16px; 
    font-weight: bold; 
    color: #555; 
    margin: 10px 0;'>
    ... 145 more rows not displayed ...
</div>
 
```
  

```output
42.0
```


좋습니다. 우리의 zeroshot_chain은 개발 세트의 150개 질문에서 약 42.00%를 기록합니다.

위 표는 몇 가지 예를 보여줍니다. 예를 들어:

- 질문: Juke Karten과 Thirty Seconds to Mars 두 록 밴드를 위해 앨범을 제작한 프로듀서는 누구인가요?
- 트윗: Brian Virtue는 Jane's Addiction과 Velvet Revolver와 함께 작업했으며, Juke Kartel과 Thirty Seconds to Mars를 위해 앨범을 제작했습니다, 보여주면서... [생략됨]
- 메트릭: 1.0 (올바르고, 충실하며, 매력적인 트윗!*)

각주: * 적어도 우리의 메트릭에 따르면, 이는 DSPy 프로그램이므로 최적화할 수 있습니다! 그러나 이는 다른 노트북의 주제입니다.

## 최적화

이제 성능을 최적화해 보겠습니다.

```python
from dspy.teleprompt import BootstrapFewShotWithRandomSearch
```
  
```python
# Set up the optimizer. We'll use very minimal hyperparameters for this example.
# Just do random search with ~3 attempts, and in each attempt, bootstrap <= 3 traces.
optimizer = BootstrapFewShotWithRandomSearch(
    metric=metric, max_bootstrapped_demos=3, num_candidate_programs=3
)

# Now use the optimizer to *compile* the chain. This could take 5-10 minutes, unless it's cached.
optimized_chain = optimizer.compile(zeroshot_chain, trainset=trainset, valset=valset)
```
  
```output
Going to sample between 1 and 3 traces per predictor.
Will attempt to train 3 candidate sets.
``````output
Average Metric: 22.33333333333334 / 50  (44.7): 100%|█████| 50/50 [00:26<00:00,  1.87it/s]
/Users/harrisonchase/.pyenv/versions/3.11.1/envs/langchain-3-11/lib/python3.11/site-packages/dspy/evaluate/evaluate.py:126: FutureWarning: DataFrame.applymap has been deprecated. Use DataFrame.map instead.
  df = df.applymap(truncate_cell)
``````output
Average Metric: 22.33333333333334 / 50  (44.7%)
Score: 44.67 for set: [0]
New best score: 44.67 for seed -3
Scores so far: [44.67]
Best score: 44.67
``````output
Average Metric: 22.33333333333334 / 50  (44.7): 100%|█████| 50/50 [00:00<00:00, 79.51it/s]
/Users/harrisonchase/.pyenv/versions/3.11.1/envs/langchain-3-11/lib/python3.11/site-packages/dspy/evaluate/evaluate.py:126: FutureWarning: DataFrame.applymap has been deprecated. Use DataFrame.map instead.
  df = df.applymap(truncate_cell)
``````output
Average Metric: 22.33333333333334 / 50  (44.7%)
Score: 44.67 for set: [16]
Scores so far: [44.67, 44.67]
Best score: 44.67
``````output
  4%|██                                                   | 8/200 [00:33<13:21,  4.18s/it]
``````output
Bootstrapped 3 full traces after 9 examples in round 0.
``````output
Average Metric: 24.666666666666668 / 50  (49.3): 100%|████| 50/50 [00:28<00:00,  1.77it/s]
/Users/harrisonchase/.pyenv/versions/3.11.1/envs/langchain-3-11/lib/python3.11/site-packages/dspy/evaluate/evaluate.py:126: FutureWarning: DataFrame.applymap has been deprecated. Use DataFrame.map instead.
  df = df.applymap(truncate_cell)
``````output
Average Metric: 24.666666666666668 / 50  (49.3%)
Score: 49.33 for set: [16]
New best score: 49.33 for seed -1
Scores so far: [44.67, 44.67, 49.33]
Best score: 49.33
Average of max per entry across top 1 scores: 0.49333333333333335
Average of max per entry across top 2 scores: 0.5533333333333335
Average of max per entry across top 3 scores: 0.5533333333333335
Average of max per entry across top 5 scores: 0.5533333333333335
Average of max per entry across top 8 scores: 0.5533333333333335
Average of max per entry across top 9999 scores: 0.5533333333333335
``````output
  6%|███                                                 | 12/200 [00:31<08:16,  2.64s/it]
``````output
Bootstrapped 2 full traces after 13 examples in round 0.
``````output
Average Metric: 25.66666666666667 / 50  (51.3): 100%|█████| 50/50 [00:25<00:00,  1.92it/s]
/Users/harrisonchase/.pyenv/versions/3.11.1/envs/langchain-3-11/lib/python3.11/site-packages/dspy/evaluate/evaluate.py:126: FutureWarning: DataFrame.applymap has been deprecated. Use DataFrame.map instead.
  df = df.applymap(truncate_cell)
``````output
Average Metric: 25.66666666666667 / 50  (51.3%)
Score: 51.33 for set: [16]
New best score: 51.33 for seed 0
Scores so far: [44.67, 44.67, 49.33, 51.33]
Best score: 51.33
Average of max per entry across top 1 scores: 0.5133333333333334
Average of max per entry across top 2 scores: 0.5666666666666668
Average of max per entry across top 3 scores: 0.6000000000000001
Average of max per entry across top 5 scores: 0.6000000000000001
Average of max per entry across top 8 scores: 0.6000000000000001
Average of max per entry across top 9999 scores: 0.6000000000000001
``````output
  0%|▎                                                    | 1/200 [00:02<08:37,  2.60s/it]
``````output
Bootstrapped 1 full traces after 2 examples in round 0.
``````output
Average Metric: 26.33333333333334 / 50  (52.7): 100%|█████| 50/50 [00:23<00:00,  2.11it/s]
/Users/harrisonchase/.pyenv/versions/3.11.1/envs/langchain-3-11/lib/python3.11/site-packages/dspy/evaluate/evaluate.py:126: FutureWarning: DataFrame.applymap has been deprecated. Use DataFrame.map instead.
  df = df.applymap(truncate_cell)
``````output
Average Metric: 26.33333333333334 / 50  (52.7%)
Score: 52.67 for set: [16]
New best score: 52.67 for seed 1
Scores so far: [44.67, 44.67, 49.33, 51.33, 52.67]
Best score: 52.67
Average of max per entry across top 1 scores: 0.5266666666666667
Average of max per entry across top 2 scores: 0.56
Average of max per entry across top 3 scores: 0.5666666666666668
Average of max per entry across top 5 scores: 0.6000000000000001
Average of max per entry across top 8 scores: 0.6000000000000001
Average of max per entry across top 9999 scores: 0.6000000000000001
``````output
  0%|▎                                                    | 1/200 [00:02<07:11,  2.17s/it]
``````output
Bootstrapped 1 full traces after 2 examples in round 0.
``````output
Average Metric: 25.666666666666668 / 50  (51.3): 100%|████| 50/50 [00:21<00:00,  2.29it/s]
``````output
Average Metric: 25.666666666666668 / 50  (51.3%)
Score: 51.33 for set: [16]
Scores so far: [44.67, 44.67, 49.33, 51.33, 52.67, 51.33]
Best score: 52.67
Average of max per entry across top 1 scores: 0.5266666666666667
Average of max per entry across top 2 scores: 0.56
Average of max per entry across top 3 scores: 0.6000000000000001
Average of max per entry across top 5 scores: 0.6133333333333334
Average of max per entry across top 8 scores: 0.6133333333333334
Average of max per entry across top 9999 scores: 0.6133333333333334
6 candidate programs found.
``````output

/Users/harrisonchase/.pyenv/versions/3.11.1/envs/langchain-3-11/lib/python3.11/site-packages/dspy/evaluate/evaluate.py:126: FutureWarning: DataFrame.applymap has been deprecated. Use DataFrame.map instead.
  df = df.applymap(truncate_cell)
```
  
## 최적화된 체인 평가

좋습니다, 얼마나 좋은가요? 제대로 평가해 보겠습니다!

```python
evaluate(optimized_chain)
```
  
```output
Average Metric: 74.66666666666666 / 150  (49.8): 100%|██| 150/150 [00:54<00:00,  2.74it/s]
``````output
Average Metric: 74.66666666666666 / 150  (49.8%)
``````output

/Users/harrisonchase/.pyenv/versions/3.11.1/envs/langchain-3-11/lib/python3.11/site-packages/dspy/evaluate/evaluate.py:126: FutureWarning: DataFrame.applymap has been deprecated. Use DataFrame.map instead.
  df = df.applymap(truncate_cell)
```
  
```html
<style type="text/css">
#T_b4366 th {
  text-align: left;
}
#T_b4366 td {
  text-align: left;
}
#T_b4366_row0_col0, #T_b4366_row0_col1, #T_b4366_row0_col2, #T_b4366_row0_col3, #T_b4366_row0_col4, #T_b4366_row0_col5, #T_b4366_row1_col0, #T_b4366_row1_col1, #T_b4366_row1_col2, #T_b4366_row1_col3, #T_b4366_row1_col4, #T_b4366_row1_col5, #T_b4366_row2_col0, #T_b4366_row2_col1, #T_b4366_row2_col2, #T_b4366_row2_col3, #T_b4366_row2_col4, #T_b4366_row2_col5, #T_b4366_row3_col0, #T_b4366_row3_col1, #T_b4366_row3_col2, #T_b4366_row3_col3, #T_b4366_row3_col4, #T_b4366_row3_col5, #T_b4366_row4_col0, #T_b4366_row4_col1, #T_b4366_row4_col2, #T_b4366_row4_col3, #T_b4366_row4_col4, #T_b4366_row4_col5 {
  text-align: left;
  white-space: pre-wrap;
  word-wrap: break-word;
  max-width: 400px;
}
</style>
<table id="T_b4366">
  <thead>
    <tr>
      <th class="blank level0" >&nbsp;</th>
      <th id="T_b4366_level0_col0" class="col_heading level0 col0" >question</th>
      <th id="T_b4366_level0_col1" class="col_heading level0 col1" >answer</th>
      <th id="T_b4366_level0_col2" class="col_heading level0 col2" >gold_titles</th>
      <th id="T_b4366_level0_col3" class="col_heading level0 col3" >output</th>
      <th id="T_b4366_level0_col4" class="col_heading level0 col4" >tweet_response</th>
      <th id="T_b4366_level0_col5" class="col_heading level0 col5" >metric</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th id="T_b4366_level0_row0" class="row_heading level0 row0" >0</th>
      <td id="T_b4366_row0_col0" class="data row0 col0" >Who was a producer who produced albums for both rock bands Juke Karten and Thirty Seconds to Mars?</td>
      <td id="T_b4366_row0_col1" class="data row0 col1" >Brian Virtue</td>
      <td id="T_b4366_row0_col2" class="data row0 col2" >{'Thirty Seconds to Mars', 'Levolution (album)'}</td>
      <td id="T_b4366_row0_col3" class="data row0 col3" >Brian Virtue, known for his work with Jane's Addiction and Velvet Revolver, produced albums for both Juke Kartel and Thirty Seconds to Mars. #BrianVirtue #Producer...</td>
      <td id="T_b4366_row0_col4" class="data row0 col4" >Brian Virtue, known for his work with Jane's Addiction and Velvet Revolver, produced albums for both Juke Kartel and Thirty Seconds to Mars. #BrianVirtue #Producer...</td>
      <td id="T_b4366_row0_col5" class="data row0 col5" >1.0</td>
    </tr>
    <tr>
      <th id="T_b4366_level0_row1" class="row_heading level0 row1" >1</th>
      <td id="T_b4366_row1_col0" class="data row1 col0" >Are both the University of Chicago and Syracuse University public universities? </td>
      <td id="T_b4366_row1_col1" class="data row1 col1" >no</td>
      <td id="T_b4366_row1_col2" class="data row1 col2" >{'Syracuse University', 'University of Chicago'}</td>
      <td id="T_b4366_row1_col3" class="data row1 col3" > No, only Northeastern Illinois University is a public state university. Syracuse University is a private research university. #University #PublicPrivate #HigherEd</td>
      <td id="T_b4366_row1_col4" class="data row1 col4" > No, only Northeastern Illinois University is a public state university. Syracuse University is a private research university. #University #PublicPrivate #HigherEd</td>
      <td id="T_b4366_row1_col5" class="data row1 col5" >0.0</td>
    </tr>
    <tr>
      <th id="T_b4366_level0_row2" class="row_heading level0 row2" >2</th>
      <td id="T_b4366_row2_col0" class="data row2 col0" >In what region was Eddy Mazzoleni born?</td>
      <td id="T_b4366_row2_col1" class="data row2 col1" >Lombardy, northern Italy</td>
      <td id="T_b4366_row2_col2" class="data row2 col2" >{'Eddy Mazzoleni', 'Bergamo'}</td>
      <td id="T_b4366_row2_col3" class="data row2 col3" > Eddy Mazzoleni, the Italian professional road cyclist, was born in Bergamo, Italy. #EddyMazzoleni #Cycling #Italy</td>
      <td id="T_b4366_row2_col4" class="data row2 col4" > Eddy Mazzoleni, the Italian professional road cyclist, was born in Bergamo, Italy. #EddyMazzoleni #Cycling #Italy</td>
      <td id="T_b4366_row2_col5" class="data row2 col5" >0.0</td>
    </tr>
    <tr>
      <th id="T_b4366_level0_row3" class="row_heading level0 row3" >3</th>
      <td id="T_b4366_row3_col0" class="data row3 col0" >Who edited the 1990 American romantic comedy film directed by Garry Marshall?</td>
      <td id="T_b4366_row3_col1" class="data row3 col1" >Raja Raymond Gosnell</td>
      <td id="T_b4366_row3_col2" class="data row3 col2" >{'Raja Gosnell', 'Pretty Woman'}</td>
      <td id="T_b4366_row3_col3" class="data row3 col3" > J. F. Lawton wrote the screenplay for Pretty Woman, the 1990 romantic comedy directed by Garry Marshall. #PrettyWoman #GarryMarshall #RomanticComedy</td>
      <td id="T_b4366_row3_col4" class="data row3 col4" > J. F. Lawton wrote the screenplay for Pretty Woman, the 1990 romantic comedy directed by Garry Marshall. #PrettyWoman #GarryMarshall #RomanticComedy</td>
      <td id="T_b4366_row3_col5" class="data row3 col5" >0.0</td>
    </tr>
    <tr>
      <th id="T_b4366_level0_row4" class="row_heading level0 row4" >4</th>
      <td id="T_b4366_row4_col0" class="data row4 col0" >Burrs Country Park railway station is what stop on the railway line that runs between Heywood and Rawtenstall</td>
      <td id="T_b4366_row4_col1" class="data row4 col1" >seventh</td>
      <td id="T_b4366_row4_col2" class="data row4 col2" >{'Burrs Country Park railway station', 'East Lancashire Railway'}</td>
      <td id="T_b4366_row4_col3" class="data row4 col3" > Burrs Country Park railway station is the seventh stop on the East Lancashire Railway, which runs between Heywood and Rawtenstall. #EastLancashireRailway #BurrsCountryPark #RailwayStation</td>
      <td id="T_b4366_row4_col4" class="data row4 col4" > Burrs Country Park railway station is the seventh stop on the East Lancashire Railway, which runs between Heywood and Rawtenstall. #EastLancashireRailway #BurrsCountryPark #RailwayStation</td>
      <td id="T_b4366_row4_col5" class="data row4 col5" >1.0</td>
    </tr>
  </tbody>
</table>
 
```
  

```html

<div style='
    text-align: center; 
    font-size: 16px; 
    font-weight: bold; 
    color: #555; 
    margin: 10px 0;'>
    ... 145 more rows not displayed ...
</div>
 
```
  
```output
49.78
```


좋습니다! 우리는 체인을 42%에서 거의 50%로 개선했습니다!

## 최적화된 체인 검사

그렇다면 실제로 무엇이 개선되었을까요? 최적화된 체인을 살펴보며 확인할 수 있습니다. 두 가지 방법으로 이를 수행할 수 있습니다.

### 사용된 프롬프트 보기

실제로 어떤 프롬프트가 사용되었는지 살펴볼 수 있습니다. 이는 `dspy.settings`를 통해 확인할 수 있습니다.

```python
prompt_used, output = dspy.settings.langchain_history[-1]
```
  

```python
print(prompt_used)
```
  
```output
Essential Instructions: Respond to the provided question based on the given context in the style of a tweet, ensuring the response is concise and within the character limit of a tweet (up to 280 characters).

---

Follow the following format.

Context: ${context}
Question: ${question}
Tweet Response: ${tweet_response}

---

Context:
[1] «Brutus (Funny Car) | Brutus is a pioneering funny car driven by Jim Liberman and prepared by crew chief Lew Arrington in the middle 1960s.»
[2] «USS Brutus (AC-15) | USS "Brutus", formerly the steamer "Peter Jebsen", was a collier in the United States Navy. She was built in 1894 at South Shields-on-Tyne, England, by John Readhead & Sons and was acquired by the U.S. Navy early in 1898 from L. F. Chapman & Company. She was renamed "Brutus" and commissioned at the Mare Island Navy Yard on 27 May 1898, with Lieutenant Vincendon L. Cottman, commanding officer and Lieutenant Randolph H. Miner, executive officer.»
[3] «Brutus Beefcake | Ed Leslie is an American semi-retired professional wrestler, best known for his work in the World Wrestling Federation (WWF) under the ring name Brutus "The Barber" Beefcake. He later worked for World Championship Wrestling (WCW) under a variety of names.»
[4] «Brutus Hamilton | Brutus Kerr Hamilton (July 19, 1900 – December 28, 1970) was an American track and field athlete, coach and athletics administrator.»
[5] «Big Brutus | Big Brutus is the nickname of the Bucyrus-Erie model 1850B electric shovel, which was the second largest of its type in operation in the 1960s and 1970s. Big Brutus is the centerpiece of a mining museum in West Mineral, Kansas where it was used in coal strip mining operations. The shovel was designed to dig from 20 to in relatively shallow coal seams.»
Question: What is the nickname for this United States drag racer who drove Brutus?
Tweet Response: Jim Liberman, also known as "Jungle Jim", drove the pioneering funny car Brutus in the 1960s. #Brutus #FunnyCar #DragRacing

---

Context:
[1] «Philip Markoff | Philip Haynes Markoff (February 12, 1986 – August 15, 2010) was an American medical student who was charged with the armed robbery and murder of Julissa Brisman in a Boston, Massachusetts, hotel on April 14, 2009, and two other armed robberies.»
[2] «Antonia Brenner | Antonia Brenner, better known as Mother Antonia (Spanish: Madre Antonia ), (December 1, 1926 – October 17, 2013) was an American Roman Catholic Religious Sister and activist who chose to reside and care for inmates at the notorious maximum-security La Mesa Prison in Tijuana, Mexico. As a result of her work, she founded a new religious institute called the Eudist Servants of the 11th Hour.»
[3] «Luzira Maximum Security Prison | Luzira Maximum Security Prison is a maximum security prison for both men and women in Uganda. As at July 2016, it is the only maximum security prison in the country and houses Uganda's death row inmates.»
[4] «Pleasant Valley State Prison | Pleasant Valley State Prison (PVSP) is a 640 acres minimum-to-maximum security state prison in Coalinga, Fresno County, California. The facility has housed convicted murderers Sirhan Sirhan, Erik Menendez, X-Raided, and Hans Reiser, among others.»
[5] «Jon-Adrian Velazquez | Jon-Adrian Velazquez is an inmate in the maximum security Sing-Sing prison in New York who is serving a 25-year sentence after being convicted of the 1998 murder of a retired police officer. His case garnered considerable attention from the media ten years after his conviction, due to a visit and support from Martin Sheen and a long-term investigation by Dateline NBC producer Dan Slepian.»
Question: Which maximum security jail housed the killer of Julissa brisman?
Tweet Response:
```
  
### 데모 보기

이것이 최적화된 방법은 프롬프트에 넣을 예시(또는 "데모")를 수집한 것입니다. 최적화된 체인을 검사하여 그것들이 무엇인지 감을 잡을 수 있습니다.

```python
demos = [
    eg
    for eg in optimized_chain.modules[0].demos
    if hasattr(eg, "augmented") and eg.augmented
]
```
  

```python
demos
```
  

```output
[Example({'augmented': True, 'question': 'What is the nickname for this United States drag racer who drove Brutus?', 'context': ['Brutus (Funny Car) | Brutus is a pioneering funny car driven by Jim Liberman and prepared by crew chief Lew Arrington in the middle 1960s.', 'USS Brutus (AC-15) | USS "Brutus", formerly the steamer "Peter Jebsen", was a collier in the United States Navy. She was built in 1894 at South Shields-on-Tyne, England, by John Readhead & Sons and was acquired by the U.S. Navy early in 1898 from L. F. Chapman & Company. She was renamed "Brutus" and commissioned at the Mare Island Navy Yard on 27 May 1898, with Lieutenant Vincendon L. Cottman, commanding officer and Lieutenant Randolph H. Miner, executive officer.', 'Brutus Beefcake | Ed Leslie is an American semi-retired professional wrestler, best known for his work in the World Wrestling Federation (WWF) under the ring name Brutus "The Barber" Beefcake. He later worked for World Championship Wrestling (WCW) under a variety of names.', 'Brutus Hamilton | Brutus Kerr Hamilton (July 19, 1900 – December 28, 1970) was an American track and field athlete, coach and athletics administrator.', 'Big Brutus | Big Brutus is the nickname of the Bucyrus-Erie model 1850B electric shovel, which was the second largest of its type in operation in the 1960s and 1970s. Big Brutus is the centerpiece of a mining museum in West Mineral, Kansas where it was used in coal strip mining operations. The shovel was designed to dig from 20 to in relatively shallow coal seams.'], 'tweet_response': ' Jim Liberman, also known as "Jungle Jim", drove the pioneering funny car Brutus in the 1960s. #Brutus #FunnyCar #DragRacing'}) (input_keys=None)]
```