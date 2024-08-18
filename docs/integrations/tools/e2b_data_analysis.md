---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/e2b_data_analysis.ipynb
description: E2B 데이터 분석 샌드박스는 안전한 코드 실행 환경을 제공하며, Python 코드 실행 및 파일 분석을 지원합니다.
---

# E2B 데이터 분석

[E2B의 클라우드 환경](https://e2b.dev)은 LLM을 위한 훌륭한 런타임 샌드박스입니다.

E2B의 데이터 분석 샌드박스는 샌드박스 환경에서 안전하게 코드를 실행할 수 있도록 합니다. 이는 코드 인터프리터와 같은 도구를 구축하거나 ChatGPT와 같은 고급 데이터 분석에 이상적입니다.

E2B 데이터 분석 샌드박스를 사용하면 다음을 수행할 수 있습니다:
- Python 코드 실행
- matplotlib를 통한 차트 생성
- 런타임 중에 Python 패키지 동적으로 설치
- 런타임 중에 시스템 패키지 동적으로 설치
- 셸 명령 실행
- 파일 업로드 및 다운로드

우리는 E2B의 데이터 분석 샌드박스를 사용하여 업로드된 파일에 대한 분석을 수행할 간단한 OpenAI 에이전트를 만들 것입니다.

OpenAI API 키와 [E2B API 키를 여기서](https://e2b.dev/docs/getting-started/api-key) 얻고 이를 환경 변수로 설정하세요.

전체 API 문서는 [여기](https://e2b.dev/docs)에서 확인할 수 있습니다.

시작하려면 `e2b`를 설치해야 합니다:

```python
%pip install --upgrade --quiet  langchain e2b langchain-community
```


```python
<!--IMPORTS:[{"imported": "E2BDataAnalysisTool", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.e2b_data_analysis.tool.E2BDataAnalysisTool.html", "title": "E2B Data Analysis"}]-->
from langchain_community.tools import E2BDataAnalysisTool
```


```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "E2B Data Analysis"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "E2B Data Analysis"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "E2B Data Analysis"}]-->
import os

from langchain.agents import AgentType, initialize_agent
from langchain_openai import ChatOpenAI

os.environ["E2B_API_KEY"] = "<E2B_API_KEY>"
os.environ["OPENAI_API_KEY"] = "<OPENAI_API_KEY>"
```


`E2BDataAnalysisTool`의 인스턴스를 생성할 때, 샌드박스의 출력을 수신하기 위해 콜백을 전달할 수 있습니다. 이는 예를 들어, 더 반응적인 UI를 만들 때 유용합니다. 특히 LLM의 스트리밍 출력과 결합할 때 그렇습니다.

```python
# Artifacts are charts created by matplotlib when `plt.show()` is called
def save_artifact(artifact):
    print("New matplotlib chart generated:", artifact.name)
    # Download the artifact as `bytes` and leave it up to the user to display them (on frontend, for example)
    file = artifact.download()
    basename = os.path.basename(artifact.name)

    # Save the chart to the `charts` directory
    with open(f"./charts/{basename}", "wb") as f:
        f.write(file)


e2b_data_analysis_tool = E2BDataAnalysisTool(
    # Pass environment variables to the sandbox
    env_vars={"MY_SECRET": "secret_value"},
    on_stdout=lambda stdout: print("stdout:", stdout),
    on_stderr=lambda stderr: print("stderr:", stderr),
    on_artifact=save_artifact,
)
```


샌드박스에 예제 CSV 데이터 파일을 업로드하여 에이전트로 분석할 수 있습니다. 예를 들어 Netflix TV 쇼에 대한 [이 파일](https://storage.googleapis.com/e2b-examples/netflix.csv)을 사용할 수 있습니다.

```python
with open("./netflix.csv") as f:
    remote_path = e2b_data_analysis_tool.upload_file(
        file=f,
        description="Data about Netflix tv shows including their title, category, director, release date, casting, age rating, etc.",
    )
    print(remote_path)
```

```output
name='netflix.csv' remote_path='/home/user/netflix.csv' description='Data about Netflix tv shows including their title, category, director, release date, casting, age rating, etc.'
```

`Tool` 객체를 생성하고 Langchain 에이전트를 초기화합니다.

```python
tools = [e2b_data_analysis_tool.as_tool()]

llm = ChatOpenAI(model="gpt-4", temperature=0)
agent = initialize_agent(
    tools,
    llm,
    agent=AgentType.OPENAI_FUNCTIONS,
    verbose=True,
    handle_parsing_errors=True,
)
```


이제 이전에 업로드한 CSV 파일에 대해 에이전트에게 질문할 수 있습니다.

```python
agent.run(
    "What are the 5 longest movies on netflix released between 2000 and 2010? Create a chart with their lengths."
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `e2b_data_analysis` with `{'python_code': "import pandas as pd\n\n# Load the data\nnetflix_data = pd.read_csv('/home/user/netflix.csv')\n\n# Convert the 'release_year' column to integer\nnetflix_data['release_year'] = netflix_data['release_year'].astype(int)\n\n# Filter the data for movies released between 2000 and 2010\nfiltered_data = netflix_data[(netflix_data['release_year'] >= 2000) & (netflix_data['release_year'] <= 2010) & (netflix_data['type'] == 'Movie')]\n\n# Remove rows where 'duration' is not available\nfiltered_data = filtered_data[filtered_data['duration'].notna()]\n\n# Convert the 'duration' column to integer\nfiltered_data['duration'] = filtered_data['duration'].str.replace(' min','').astype(int)\n\n# Get the top 5 longest movies\nlongest_movies = filtered_data.nlargest(5, 'duration')\n\n# Create a bar chart\nimport matplotlib.pyplot as plt\n\nplt.figure(figsize=(10,5))\nplt.barh(longest_movies['title'], longest_movies['duration'], color='skyblue')\nplt.xlabel('Duration (minutes)')\nplt.title('Top 5 Longest Movies on Netflix (2000-2010)')\nplt.gca().invert_yaxis()\nplt.savefig('/home/user/longest_movies.png')\n\nlongest_movies[['title', 'duration']]"}`


[0mstdout:                              title  duration
stdout: 1019                        Lagaan       224
stdout: 4573                  Jodhaa Akbar       214
stdout: 2731      Kabhi Khushi Kabhie Gham       209
stdout: 2632  No Direction Home: Bob Dylan       208
stdout: 2126          What's Your Raashee?       203
[36;1m[1;3m{'stdout': "                             title  duration\n1019                        Lagaan       224\n4573                  Jodhaa Akbar       214\n2731      Kabhi Khushi Kabhie Gham       209\n2632  No Direction Home: Bob Dylan       208\n2126          What's Your Raashee?       203", 'stderr': ''}[0m[32;1m[1;3mThe 5 longest movies on Netflix released between 2000 and 2010 are:

1. Lagaan - 224 minutes
2. Jodhaa Akbar - 214 minutes
3. Kabhi Khushi Kabhie Gham - 209 minutes
4. No Direction Home: Bob Dylan - 208 minutes
5. What's Your Raashee? - 203 minutes

Here is the chart showing their lengths:

![Longest Movies](sandbox:/home/user/longest_movies.png)[0m

[1m> Finished chain.[0m
```


```output
"The 5 longest movies on Netflix released between 2000 and 2010 are:\n\n1. Lagaan - 224 minutes\n2. Jodhaa Akbar - 214 minutes\n3. Kabhi Khushi Kabhie Gham - 209 minutes\n4. No Direction Home: Bob Dylan - 208 minutes\n5. What's Your Raashee? - 203 minutes\n\nHere is the chart showing their lengths:\n\n![Longest Movies](sandbox:/home/user/longest_movies.png)"
```


E2B는 또한 런타임 중에 다음과 같이 Python 및 시스템( `apt`를 통해) 패키지를 동적으로 설치할 수 있도록 합니다:

```python
# Install Python package
e2b_data_analysis_tool.install_python_packages("pandas")
```

```output
stdout: Requirement already satisfied: pandas in /usr/local/lib/python3.10/dist-packages (2.1.1)
stdout: Requirement already satisfied: python-dateutil>=2.8.2 in /usr/local/lib/python3.10/dist-packages (from pandas) (2.8.2)
stdout: Requirement already satisfied: pytz>=2020.1 in /usr/local/lib/python3.10/dist-packages (from pandas) (2023.3.post1)
stdout: Requirement already satisfied: numpy>=1.22.4 in /usr/local/lib/python3.10/dist-packages (from pandas) (1.26.1)
stdout: Requirement already satisfied: tzdata>=2022.1 in /usr/local/lib/python3.10/dist-packages (from pandas) (2023.3)
stdout: Requirement already satisfied: six>=1.5 in /usr/local/lib/python3.10/dist-packages (from python-dateutil>=2.8.2->pandas) (1.16.0)
```

또한, 다음과 같이 샌드박스에서 파일을 다운로드할 수 있습니다:

```python
# The path is a remote path in the sandbox
files_in_bytes = e2b_data_analysis_tool.download_file("/home/user/netflix.csv")
```


마지막으로, `run_command`를 통해 샌드박스 내에서 모든 셸 명령을 실행할 수 있습니다.

```python
# Install SQLite
e2b_data_analysis_tool.run_command("sudo apt update")
e2b_data_analysis_tool.install_system_packages("sqlite3")

# Check the SQLite version
output = e2b_data_analysis_tool.run_command("sqlite3 --version")
print("version: ", output["stdout"])
print("error: ", output["stderr"])
print("exit code: ", output["exit_code"])
```

```output
stderr: 
stderr: WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
stderr: 
stdout: Hit:1 http://security.ubuntu.com/ubuntu jammy-security InRelease
stdout: Hit:2 http://archive.ubuntu.com/ubuntu jammy InRelease
stdout: Hit:3 http://archive.ubuntu.com/ubuntu jammy-updates InRelease
stdout: Hit:4 http://archive.ubuntu.com/ubuntu jammy-backports InRelease
stdout: Reading package lists...
stdout: Building dependency tree...
stdout: Reading state information...
stdout: All packages are up to date.
stdout: Reading package lists...
stdout: Building dependency tree...
stdout: Reading state information...
stdout: Suggested packages:
stdout:   sqlite3-doc
stdout: The following NEW packages will be installed:
stdout:   sqlite3
stdout: 0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
stdout: Need to get 768 kB of archives.
stdout: After this operation, 1873 kB of additional disk space will be used.
stdout: Get:1 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 sqlite3 amd64 3.37.2-2ubuntu0.1 [768 kB]
stderr: debconf: delaying package configuration, since apt-utils is not installed
stdout: Fetched 768 kB in 0s (2258 kB/s)
stdout: Selecting previously unselected package sqlite3.
(Reading database ... 23999 files and directories currently installed.)
stdout: Preparing to unpack .../sqlite3_3.37.2-2ubuntu0.1_amd64.deb ...
stdout: Unpacking sqlite3 (3.37.2-2ubuntu0.1) ...
stdout: Setting up sqlite3 (3.37.2-2ubuntu0.1) ...
stdout: 3.37.2 2022-01-06 13:25:41 872ba256cbf61d9290b571c0e6d82a20c224ca3ad82971edc46b29818d5dalt1
version:  3.37.2 2022-01-06 13:25:41 872ba256cbf61d9290b571c0e6d82a20c224ca3ad82971edc46b29818d5dalt1
error:  
exit code:  0
```

에이전트가 작업을 마치면 샌드박스를 닫는 것을 잊지 마세요.

```python
e2b_data_analysis_tool.close()
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)