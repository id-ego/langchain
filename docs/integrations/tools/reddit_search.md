---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/reddit_search.ipynb
description: 이 노트북에서는 Reddit 검색 도구의 작동 방식을 배우고, API 키 설정 및 쿼리 설정 방법을 설명합니다.
---

# Reddit 검색

이 노트북에서는 Reddit 검색 도구가 어떻게 작동하는지 배웁니다.\
먼저 아래 명령어로 praw가 설치되어 있는지 확인하세요:  

```python
%pip install --upgrade --quiet  praw
```


그런 다음 적절한 API 키와 환경 변수를 설정해야 합니다. Reddit 사용자 계정을 생성하고 자격 증명을 받아야 합니다. 따라서 https://www.reddit.com 에 가서 Reddit 사용자 계정을 생성하세요.\
그런 다음 https://www.reddit.com/prefs/apps 에 가서 앱을 생성하여 자격 증명을 받으세요.\
앱을 생성할 때 client_id와 secret을 받아야 합니다. 이제 해당 문자열을 client_id와 client_secret 변수에 붙여넣을 수 있습니다.\
참고: user_agent에는 아무 문자열이나 넣을 수 있습니다.  

```python
client_id = ""
client_secret = ""
user_agent = ""
```


```python
<!--IMPORTS:[{"imported": "RedditSearchRun", "source": "langchain_community.tools.reddit_search.tool", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.reddit_search.tool.RedditSearchRun.html", "title": "Reddit Search "}, {"imported": "RedditSearchAPIWrapper", "source": "langchain_community.utilities.reddit_search", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.reddit_search.RedditSearchAPIWrapper.html", "title": "Reddit Search "}]-->
from langchain_community.tools.reddit_search.tool import RedditSearchRun
from langchain_community.utilities.reddit_search import RedditSearchAPIWrapper

search = RedditSearchRun(
    api_wrapper=RedditSearchAPIWrapper(
        reddit_client_id=client_id,
        reddit_client_secret=client_secret,
        reddit_user_agent=user_agent,
    )
)
```


그런 다음 쿼리를 설정할 수 있습니다. 예를 들어, 어떤 서브레딧을 쿼리할지, 얼마나 많은 게시물을 반환받을지, 결과를 어떻게 정렬할지 등을 설정할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "RedditSearchSchema", "source": "langchain_community.tools.reddit_search.tool", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.reddit_search.tool.RedditSearchSchema.html", "title": "Reddit Search "}]-->
from langchain_community.tools.reddit_search.tool import RedditSearchSchema

search_params = RedditSearchSchema(
    query="beginner", sort="new", time_filter="week", subreddit="python", limit="2"
)
```


마지막으로 검색을 실행하고 결과를 얻습니다.

```python
result = search.run(tool_input=search_params.dict())
```


```python
print(result)
```


여기 결과를 출력하는 예시가 있습니다.\
참고: 서브레딧의 최신 게시물에 따라 다른 출력을 받을 수 있지만 형식은 유사해야 합니다.

> r/python 검색 결과 2개의 게시물이 발견되었습니다:
게시물 제목: 'Visual Studio Code에서 Github Copilot 설정하기'
사용자: Feisty-Recording-715
서브레딧: r/Python:
본문: 🛠️ 이 튜토리얼은 버전 관리에 대한 이해를 강화하고자 하는 초보자나 Visual Studio Code에서 GitHub 설정을 위한 빠른 참조를 찾는 경험이 있는 개발자에게 완벽합니다.
> 
> 🎓 이 비디오가 끝나면 코드베이스를 자신 있게 관리하고, 다른 사람과 협업하며, GitHub에서 오픈 소스 프로젝트에 기여할 수 있는 기술을 갖추게 됩니다.
> 
> 비디오 링크: https://youtu.be/IdT1BhrSfdo?si=mV7xVpiyuhlD8Zrw
> 
> 귀하의 피드백을 환영합니다.
게시물 URL: https://www.reddit.com/r/Python/comments/1823wr7/setup_github_copilot_in_visual_studio_code/
게시물 카테고리: N/A.
점수: 0
> 
> 게시물 제목: 'pygame과 PySide6로 만든 중국 체커 게임, 사용자 정의 봇 지원'
사용자: HenryChess
서브레딧: r/Python:
본문: GitHub 링크: https://github.com/henrychess/pygame-chinese-checkers
> 
> 이게 초보자나 중급자로 분류되는지 잘 모르겠습니다. 저는 아직 초보자 영역에 있는 것 같아서 초보자로 분류합니다.
> 
> 이것은 2~3명의 플레이어를 위한 중국 체커(aka Sternhalma) 게임입니다. 제가 작성한 봇은 주로 게임 로직 부분을 디버깅하기 위한 것이기 때문에 쉽게 이길 수 있습니다. 그러나 자신만의 사용자 정의 봇을 작성할 수 있습니다. GitHub 페이지에 가이드가 있습니다.
게시물 URL: https://www.reddit.com/r/Python/comments/181xq0u/a_chinese_checkers_game_made_with_pygame_and/
게시물 카테고리: N/A.
점수: 1

## 에이전트 체인과 도구 사용하기

Reddit 검색 기능은 다중 입력 도구로도 제공됩니다. 이 예시에서는 [문서에서 기존 코드를 수정](https://python.langchain.com/v0.1/docs/modules/memory/agent_with_memory/)하여 ChatOpenAI를 사용해 메모리가 있는 에이전트 체인을 생성합니다. 이 에이전트 체인은 Reddit에서 정보를 가져오고 이러한 게시물을 사용하여 후속 입력에 응답할 수 있습니다.

예제를 실행하려면 Reddit API 액세스 정보를 추가하고 [OpenAI API](https://help.openai.com/en/articles/4936850-where-do-i-find-my-api-key)에서 OpenAI 키를 가져오세요.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Reddit Search "}, {"imported": "StructuredChatAgent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.structured_chat.base.StructuredChatAgent.html", "title": "Reddit Search "}, {"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Reddit Search "}, {"imported": "ConversationBufferMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.buffer.ConversationBufferMemory.html", "title": "Reddit Search "}, {"imported": "ReadOnlySharedMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.readonly.ReadOnlySharedMemory.html", "title": "Reddit Search "}, {"imported": "RedditSearchRun", "source": "langchain_community.tools.reddit_search.tool", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.reddit_search.tool.RedditSearchRun.html", "title": "Reddit Search "}, {"imported": "RedditSearchAPIWrapper", "source": "langchain_community.utilities.reddit_search", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.reddit_search.RedditSearchAPIWrapper.html", "title": "Reddit Search "}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Reddit Search "}, {"imported": "Tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.simple.Tool.html", "title": "Reddit Search "}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Reddit Search "}]-->
# Adapted code from /docs/modules/agents/how_to/sharedmemory_for_tools

from langchain.agents import AgentExecutor, StructuredChatAgent
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferMemory, ReadOnlySharedMemory
from langchain_community.tools.reddit_search.tool import RedditSearchRun
from langchain_community.utilities.reddit_search import RedditSearchAPIWrapper
from langchain_core.prompts import PromptTemplate
from langchain_core.tools import Tool
from langchain_openai import ChatOpenAI

# Provide keys for Reddit
client_id = ""
client_secret = ""
user_agent = ""
# Provide key for OpenAI
openai_api_key = ""

template = """This is a conversation between a human and a bot:

{chat_history}

Write a summary of the conversation for {input}:
"""

prompt = PromptTemplate(input_variables=["input", "chat_history"], template=template)
memory = ConversationBufferMemory(memory_key="chat_history")

prefix = """Have a conversation with a human, answering the following questions as best you can. You have access to the following tools:"""
suffix = """Begin!"

{chat_history}
Question: {input}
{agent_scratchpad}"""

tools = [
    RedditSearchRun(
        api_wrapper=RedditSearchAPIWrapper(
            reddit_client_id=client_id,
            reddit_client_secret=client_secret,
            reddit_user_agent=user_agent,
        )
    )
]

prompt = StructuredChatAgent.create_prompt(
    prefix=prefix,
    tools=tools,
    suffix=suffix,
    input_variables=["input", "chat_history", "agent_scratchpad"],
)

llm = ChatOpenAI(temperature=0, openai_api_key=openai_api_key)

llm_chain = LLMChain(llm=llm, prompt=prompt)
agent = StructuredChatAgent(llm_chain=llm_chain, verbose=True, tools=tools)
agent_chain = AgentExecutor.from_agent_and_tools(
    agent=agent, verbose=True, memory=memory, tools=tools
)

# Answering the first prompt requires usage of the Reddit search tool.
agent_chain.run(input="What is the newest post on r/langchain for the week?")
# Answering the subsequent prompt uses memory.
agent_chain.run(input="Who is the author of the post?")
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)