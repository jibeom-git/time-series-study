# 🛠️ 시계열 예측 연구 환경 세팅 가이드

> 작성 목적: 새로운 컴퓨터에서도 동일한 환경을 빠르게 구축하기 위한 기록  
> 작성일: 2026-04-08  
> OS: Windows 11  
> 주요 도구: uv, VSCode, Git, GitHub

---

## 📋 목차

1. [사전 준비 - Anaconda 삭제](#1-사전-준비---anaconda-삭제)
2. [uv 설치](#2-uv-설치)
3. [uv 캐시 위치 변경 (C드라이브 절약)](#3-uv-캐시-위치-변경-c드라이브-절약)
4. [프로젝트 폴더 구조 생성](#4-프로젝트-폴더-구조-생성)
5. [가상환경 생성 및 패키지 설치](#5-가상환경-생성-및-패키지-설치)
6. [VSCode 설정](#6-vscode-설정)
7. [Git & GitHub 연동](#7-git--github-연동)
8. [앞으로 실험 추가하는 방법](#8-앞으로-실험-추가하는-방법)
9. [설치된 패키지 목록](#9-설치된-패키지-목록)

---

## 1. 사전 준비 - Anaconda 삭제

기존에 Anaconda가 설치되어 있었다면 완전히 삭제해야 한다.  
Anaconda는 무겁고 uv와 충돌할 수 있기 때문이다.

### 1-1. 앱 제거
`Windows 키` → **앱 추가/제거** → **Anaconda3** 찾아서 제거

### 1-2. 남은 폴더 수동 삭제
`Windows 키 + R` → `%USERPROFILE%` 입력 후 아래 폴더 삭제:
```
C:\Users\[내이름]\anaconda3\
C:\Users\[내이름]\.conda\
C:\Users\[내이름]\.anaconda\
```

### 1-3. 환경변수 정리
`Windows 키` → **시스템 환경 변수 편집** → **환경 변수** 버튼  
`Path` 항목에서 `conda`, `anaconda` 포함된 항목 모두 삭제

### 1-4. 삭제 확인
PowerShell을 열고 아래 명령어 입력 시 "찾을 수 없음" 이 나오면 성공:
```powershell
python --version   # 명령을 찾을 수 없습니다 → 정상
conda --version    # 명령을 찾을 수 없습니다 → 정상
```

---

## 2. uv 설치

### uv란?
Python 패키지 관리 도구다. 기존의 pip, conda보다 훨씬 빠르고 현대적이다.  
- **pip**: 패키지만 설치, Python 버전 관리 불가  
- **conda**: 무겁고 느림  
- **uv**: Python 버전 + 패키지 설치를 한 번에, 속도가 10~100배 빠름

### 설치 방법
PowerShell을 **관리자 권한**으로 실행 (`우클릭 → 관리자로 실행`) 후:

```powershell
# uv 공식 설치 스크립트 실행
# irm: 인터넷에서 스크립트 다운로드
# iex: 다운로드한 스크립트 실행
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 설치 확인
```powershell
uv --version
# 예시 출력: uv 0.11.4
```

---

## 3. uv 캐시 위치 변경 (C드라이브 절약)

### 왜 필요한가?
uv는 패키지를 **글로벌 캐시**에 한 번만 저장하고, 각 프로젝트에서는 링크(바로가기)로 연결한다.  
프로젝트 10개가 같은 패키지를 써도 실제 파일은 캐시에 1개만 저장되어 공간을 절약한다.  
단, 기본 캐시 위치가 C드라이브이므로, 여유 있는 D드라이브로 변경해야 한다.

```
[D드라이브 uv 캐시] ← 실제 파일 1개만 저장
        numpy, pandas, torch ...
            ↑           ↑
          링크         링크
      [프로젝트A]   [프로젝트B]
        .venv         .venv
```

### 캐시 위치 변경 명령어
```powershell
# D드라이브에 uv 전용 캐시 폴더 생성
mkdir D:\uv-cache

# 환경변수로 캐시 위치를 D드라이브로 영구 변경
# [Environment]::SetEnvironmentVariable: Windows 환경변수를 영구적으로 설정하는 명령어
# "User": 현재 사용자에게만 적용 (시스템 전체 아님)
[Environment]::SetEnvironmentVariable("UV_CACHE_DIR", "D:\uv-cache", "User")
```

> ⚠️ 주의: `UV_PROJECT_ENVIRONMENT` 는 설정하지 않는다. 잘못 설정하면 venv 생성 오류가 난다.

### PowerShell 재시작 후 확인
```powershell
uv cache dir
# D:\uv-cache 가 출력되면 성공
```

---

## 4. 프로젝트 폴더 구조 생성

### 폴더 구조 설명
모든 시계열 모델 실험을 **하나의 프로젝트**로 관리한다 (모노레포 방식).  
시계열 모델들은 numpy, pandas, torch 등 패키지가 대부분 겹치기 때문에  
환경을 하나만 유지하는 것이 효율적이고 GitHub 포트폴리오로도 깔끔하다.

```
D:\
└── time-series-study/
    ├── .venv/                  ← 가상환경 (패키지 설치 위치)
    ├── pyproject.toml          ← 프로젝트 설정 및 패키지 목록 자동 관리
    ├── uv.lock                 ← 패키지 버전 고정 파일 (재현성 보장)
    ├── .gitignore              ← GitHub에 올리지 않을 파일 목록
    ├── README.md               ← 프로젝트 전체 소개
    ├── data/
    │   └── raw/                ← 원본 데이터셋 저장 (GitHub에는 올리지 않음)
    ├── 01_basics/              ← 시계열 기초 개념 및 EDA
    ├── 02_statistical/         ← 통계 모델 (ARIMA, SARIMA 등)
    ├── 03_ml/                  ← 머신러닝 모델 (XGBoost, RandomForest 등)
    └── 04_deep_learning/       ← 딥러닝 모델 (LSTM, Transformer 등)
```

### 생성 명령어
```powershell
# D드라이브로 이동
cd D:\

# uv init: 프로젝트 폴더 생성 + pyproject.toml, README.md 등 기본 파일 자동 생성
uv init time-series-study

# 생성된 폴더로 이동
cd time-series-study

# mkdir: 여러 폴더를 한 번에 생성
# ,(콤마)로 구분하면 여러 폴더를 동시에 만들 수 있음
mkdir data\raw, 01_basics, 02_statistical, 03_ml, 04_deep_learning

# VSCode로 현재 폴더 열기
code .
```

---

## 5. 가상환경 생성 및 패키지 설치

### 가상환경이란?
프로젝트마다 독립적인 Python 패키지 공간이다.  
예를 들어 프로젝트A는 numpy 1.x, 프로젝트B는 numpy 2.x를 쓰더라도 서로 충돌하지 않는다.  
`.venv` 폴더 안에 생성되며, 활성화하면 그 환경 안에서 작업하게 된다.

```powershell
# uv venv: 현재 프로젝트 폴더 안에 .venv 폴더로 가상환경 생성
uv venv

# 가상환경 활성화
# 활성화하면 터미널 앞에 (time-series-study) 표시가 붙음
.venv\Scripts\activate

# uv add: 패키지 설치 명령어 (pip install 과 동일한 역할이지만 훨씬 빠름)
# 설치한 패키지는 pyproject.toml에 자동으로 기록됨
uv add numpy pandas matplotlib seaborn scikit-learn statsmodels jupyter ipykernel torch
```

### 각 패키지 역할
| 패키지 | 역할 |
|---|---|
| `numpy` | 수치 계산, 배열 처리 (모든 ML의 기반) |
| `pandas` | 데이터프레임, 시계열 데이터 처리 |
| `matplotlib` | 기본 그래프 시각화 |
| `seaborn` | 통계 시각화 (matplotlib 기반, 더 예쁨) |
| `scikit-learn` | 머신러닝 모델 및 전처리 도구 |
| `statsmodels` | 통계 모델 (ARIMA 등 시계열 모델 포함) |
| `jupyter` | Jupyter Notebook 실행 |
| `ipykernel` | VSCode에서 Jupyter 커널 연결 |
| `torch` | PyTorch 딥러닝 프레임워크 (LSTM, Transformer 등) |

---

## 6. VSCode 설정

### 필수 확장 설치
`Ctrl + Shift + X` → 아래 3개 검색 후 설치:
- **Python** (Microsoft)
- **Jupyter** (Microsoft)
- **Pylance** (Microsoft)

### Python 인터프리터 연결
`Ctrl + Shift + P` → **Python: Select Interpreter** 검색 후 클릭  
목록에서 `.venv` 가 포함된 항목 선택:
```
Python 3.11.x ('.venv': venv) D:\time-series-study\.venv\...
```

### 환경 테스트
`01_basics` 폴더에 `test.ipynb` 파일 생성 후 아래 코드 실행 (`Shift + Enter`):

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import torch

print(f"numpy: {np.__version__}")
print(f"pandas: {pd.__version__}")
print(f"torch: {torch.__version__}")
print("환경 세팅 완료! 🎉")
```

---

## 7. Git & GitHub 연동

### Git이란?
코드의 변경 이력을 저장하는 버전 관리 도구다.  
GitHub는 그 이력을 인터넷에 올려서 어디서든 접근하고, 포트폴리오로 공개할 수 있게 해주는 서비스다.

### 7-1. Git 초기 설정 (최초 1회)
```powershell
# 커밋할 때 기록될 이름과 이메일 설정
git config --global user.name "본인 이름 or GitHub 닉네임"
git config --global user.email "GitHub 가입 이메일"
```

### 7-2. .gitignore 설정
GitHub에 올리면 안 되는 파일들을 지정한다.  
`.gitignore` 파일을 VSCode에서 열고 아래 내용으로 작성:

```
.venv/               ← 가상환경 (용량 크고 다른 컴퓨터에서 재생성하면 됨)
__pycache__/         ← Python 자동 생성 임시 파일
.ipynb_checkpoints/  ← Jupyter 자동 저장 임시 파일
*.pyc                ← 컴파일된 Python 파일 (자동 생성)
data/raw/            ← 원본 데이터 (용량이 크거나 민감한 데이터)
.env                 ← API 키 등 비밀 정보
```

### 7-3. GitHub 레포지토리 생성
1. [github.com](https://github.com) 접속 → 로그인
2. 우측 상단 `+` → **New repository**
3. 설정:
   - Repository name: `time-series-study`
   - Public 선택
   - **Add a README: 체크 해제** (로컬에 이미 있음)
4. **Create repository** 클릭

### 7-4. 로컬 프로젝트를 GitHub에 연결
```powershell
cd D:\time-series-study

# git init: 현재 폴더를 Git 저장소로 초기화
git init

# git add .: 현재 폴더의 모든 변경사항을 커밋 대기 상태로 올림 (스테이징)
git add .

# git commit: 스테이징된 변경사항을 하나의 버전으로 저장
# -m: 커밋 메시지 (어떤 변경인지 설명)
git commit -m "init: 프로젝트 초기 세팅"

# 브랜치 이름을 master에서 main으로 변경 (GitHub 기본 브랜치와 맞춤)
git branch -m master main

# git remote add: 로컬 저장소와 GitHub 레포를 연결
git remote add origin https://github.com/[내닉네임]/time-series-study.git

# git push: 로컬 커밋을 GitHub에 업로드
# -u origin main: 앞으로 git push 만 입력해도 자동으로 main 브랜치에 올라가도록 설정
git push -u origin main
```

---

## 8. 앞으로 실험 추가하는 방법

### 새 실험 추가할 때 흐름
```
1. 해당 폴더에 .ipynb 파일 생성 (예: 02_statistical/arima.ipynb)
2. 실험 진행
3. 결과를 README.md에 정리
4. GitHub에 커밋 & 푸시
```

### 커밋 & 푸시 명령어
```powershell
# 변경된 파일 전체 스테이징
git add .

# 커밋 (메시지는 아래 컨벤션 참고)
git commit -m "feat: ARIMA 기본 실험 추가"

# GitHub에 업로드
git push
```

### 커밋 메시지 컨벤션
| prefix | 의미 | 예시 |
|---|---|---|
| `init` | 최초 세팅 | `init: 프로젝트 초기 세팅` |
| `feat` | 새 실험/기능 추가 | `feat: LSTM 실험 추가` |
| `docs` | 문서, README 작성 | `docs: ARIMA 결과 정리` |
| `fix` | 오류 수정 | `fix: 데이터 전처리 버그 수정` |
| `refactor` | 코드 정리 | `refactor: 노트북 구조 개선` |

### 새 컴퓨터에서 시작할 때
```powershell
# GitHub에서 프로젝트 복제
git clone https://github.com/[내닉네임]/time-series-study.git
cd time-series-study

# 가상환경 재생성 (uv.lock 파일 덕분에 동일한 버전으로 설치됨)
uv venv
.venv\Scripts\activate
uv sync   # uv.lock 기반으로 패키지 자동 설치
```

---

## 9. 설치된 패키지 목록

> 설치 날짜: 2026-04-08  
> Python 버전: 3.11.0

```
numpy==2.4.4
pandas==3.0.2
matplotlib==3.10.8
seaborn==0.13.2
scikit-learn==1.8.0
statsmodels==0.14.6
jupyter==1.1.1
ipykernel==7.2.0
torch==2.11.0+cpu
```

전체 패키지 목록 확인:
```powershell
uv pip list
```

패키지 추가 설치 방법:
```powershell
# 예: prophet 추가 설치
uv add prophet
```

---

## ✅ 세팅 완료 체크리스트

- [ ] Anaconda 완전 삭제
- [ ] uv 설치 확인 (`uv --version`)
- [ ] uv 캐시 D드라이브로 이동 (`uv cache dir` → `D:\uv-cache`)
- [ ] 프로젝트 폴더 생성 (`D:\time-series-study`)
- [ ] 가상환경 생성 및 활성화 (터미널에 `(time-series-study)` 표시)
- [ ] 패키지 설치 확인 (test.ipynb 실행)
- [ ] VSCode 인터프리터 연결
- [ ] GitHub 레포 생성 및 push 완료

---

*이 가이드는 새로운 컴퓨터 세팅 시 처음부터 따라하면 동일한 환경을 재현할 수 있다.*
