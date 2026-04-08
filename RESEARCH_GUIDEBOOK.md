# 시계열 예측 연구 글로벌 가이드북
### 초보자를 위한 환경 세팅부터 실험 진행까지

> 작성일: 2026-04-08  
> 작성자: jibeom-git  
> 목적: 어떤 컴퓨터에서도 동일한 환경을 재현하고, 연구 흐름을 처음부터 끝까지 혼자 진행할 수 있도록 기록한 가이드

---

## 목차

1. [전체 그림 이해하기](#1-전체-그림-이해하기)
2. [환경 세팅 (uv)](#2-환경-세팅-uv)
3. [프로젝트 구조](#3-프로젝트-구조)
4. [Git & GitHub 사용법](#4-git--github-사용법)
5. [Docker 기초](#5-docker-기초)
6. [시계열 EDA 가이드](#6-시계열-eda-가이드)
7. [학습 모니터링 & 평가 지표](#7-학습-모니터링--평가-지표)
8. [새로운 실험을 시작할 때 체크리스트](#8-새로운-실험을-시작할-때-체크리스트)
9. [자주 만나는 오류와 해결법](#9-자주-만나는-오류와-해결법)
10. [앞으로 공부할 것들 로드맵](#10-앞으로-공부할-것들-로드맵)

---

## 1. 전체 그림 이해하기

연구자가 실험을 진행하는 큰 흐름은 아래와 같다.

```
[환경 세팅]
uv로 Python 환경 구성
      ↓
[데이터 이해 - EDA]
데이터를 보고, 트렌드/주기성/정상성 파악
      ↓
[모델 선택]
EDA 결과를 근거로 어떤 모델을 쓸지 결정
      ↓
[모델 학습]
학습하면서 Loss 곡선으로 과적합 여부 확인
      ↓
[성능 평가]
MAE, RMSE, MAPE, R²로 수치화
      ↓
[결과 비교]
baseline(ARIMA) 대비 얼마나 좋아졌는지 비교
      ↓
[기록]
Git commit → GitHub push → 연구 일지로 남김
      ↓
[배포/재현]
Docker로 환경 포장 → 어느 서버에서든 동일 실행
```

각 도구가 무슨 역할인지 한 줄로 정리하면:

| 도구 | 역할 | 비유 |
|---|---|---|
| **uv** | 패키지 관리, Python 환경 | 요리 재료 준비 |
| **Git** | 버전 관리, 코드 이력 | 게임 세이브 포인트 |
| **GitHub** | 인터넷 백업, 포트폴리오 | 클라우드 저장소 |
| **Docker** | 환경 포장, 서버 배포 | 이사할 때 짐 박스 |
| **Jupyter** | 실험 노트북 | 실험 노트 |

---

## 2. 환경 세팅 (uv)

### uv란?

Python 패키지를 설치하고 관리하는 도구다. 기존의 pip, conda보다 10~100배 빠르고, Python 버전 관리까지 한 번에 된다.

### uv 설치 (Windows)

PowerShell을 **관리자 권한**으로 실행한 뒤:

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

설치 확인:
```powershell
uv --version
# uv 0.11.x 가 출력되면 성공
```

### C드라이브 절약 - 캐시 위치 변경

uv는 패키지를 캐시에 한 번만 저장하고 여러 프로젝트에서 링크로 공유한다. 기본 위치가 C드라이브이므로 D드라이브로 옮긴다.

```powershell
mkdir D:\uv-cache

# 캐시 위치를 영구적으로 D드라이브로 변경
[Environment]::SetEnvironmentVariable("UV_CACHE_DIR", "D:\uv-cache", "User")
```

PowerShell 재시작 후 확인:
```powershell
uv cache dir
# D:\uv-cache 가 출력되면 성공
```

> ⚠️ 주의: `UV_PROJECT_ENVIRONMENT` 는 설정하지 않는다. 설정하면 venv 생성 오류가 난다.

### 새 프로젝트 시작하는 법

```powershell
# 1. 프로젝트 생성
cd D:\
uv init 프로젝트이름
cd 프로젝트이름

# 2. 가상환경 생성
# .venv 폴더가 만들어지고 그 안에 패키지들이 설치됨
uv venv

# 3. 가상환경 활성화
# 활성화하면 터미널 앞에 (프로젝트이름) 표시가 붙음
.venv\Scripts\activate

# 4. 패키지 설치
uv add numpy pandas matplotlib scikit-learn
```

### 다른 컴퓨터에서 같은 환경 재현하기

```powershell
# GitHub에서 프로젝트 받기
git clone https://github.com/jibeom-git/time-series-study.git
cd time-series-study

# uv.lock 파일 기반으로 동일한 버전의 패키지 자동 설치
uv venv
.venv\Scripts\activate
uv sync
```

`uv.lock` 파일이 패키지 버전을 딱 고정해두기 때문에 어느 컴퓨터에서든 완전히 동일한 환경이 만들어진다.

### 자주 쓰는 uv 명령어

```powershell
uv add 패키지명          # 패키지 설치
uv remove 패키지명       # 패키지 제거
uv pip list              # 설치된 패키지 목록 확인
uv sync                  # uv.lock 기반으로 환경 동기화
uv cache dir             # 캐시 위치 확인
uv python list           # 설치된 Python 버전 목록
uv python install 3.12   # Python 3.12 설치
```

### 설치된 패키지 목록 (현재 프로젝트 기준)

```
numpy==2.4.4          # 수치 계산, 배열
pandas==3.0.2         # 데이터프레임, 시계열
matplotlib==3.10.8    # 시각화
seaborn==0.13.2       # 통계 시각화
scikit-learn==1.8.0   # 머신러닝
statsmodels==0.14.6   # ARIMA 등 통계 모델
jupyter==1.1.1        # 노트북 실행
ipykernel==7.2.0      # VSCode Jupyter 커널
torch==2.11.0+cpu     # PyTorch 딥러닝
```

---

## 3. 프로젝트 구조

### 왜 폴더 구조가 중요한가

실험이 10개, 20개로 늘어나면 파일이 뒤죽박죽된다. 처음부터 구조를 잡아두면 나중에 GitHub 포트폴리오로도 보기 좋고, 논문 쓸 때 파일 찾기도 쉽다.

### 현재 프로젝트 구조

```
D:\time-series-study\
├── .venv\                    ← 가상환경 (GitHub에 올리지 않음)
├── data\
│   └── raw\                  ← 원본 데이터 (GitHub에 올리지 않음)
├── 01_basics\                ← 시계열 기초 개념, EDA
│   └── 01_eda.ipynb
├── 02_statistical\           ← ARIMA, SARIMA 등 통계 모델
├── 03_ml\                    ← XGBoost, RandomForest 등
├── 04_deep_learning\         ← LSTM, Transformer 등
├── .gitignore                ← GitHub에 올리지 않을 파일 목록
├── pyproject.toml            ← 패키지 목록 자동 관리
├── uv.lock                   ← 패키지 버전 고정 파일
└── README.md                 ← 프로젝트 소개
```

### .gitignore 내용

GitHub에 올리면 안 되는 것들을 여기서 지정한다.

```
.venv/               # 가상환경 (용량 크고 다른 컴퓨터에서 재생성하면 됨)
__pycache__/         # Python 자동 생성 임시 파일
.ipynb_checkpoints/  # Jupyter 자동 저장 임시 파일
*.pyc                # 컴파일된 Python 파일
data/raw/            # 원본 데이터 (용량이 크거나 민감할 수 있음)
.env                 # API 키 등 비밀 정보
```

### 새 실험 폴더를 추가할 때

```powershell
# 예: Transformer 실험 추가
mkdir D:\time-series-study\04_deep_learning\transformer
```

폴더 안에는 이런 구조를 권장한다:
```
transformer\
├── README.md          ← 실험 목적, 결과 요약
├── model.ipynb        ← 모델 코드
└── results\           ← 그래프, 수치 결과 저장
```

---

## 4. Git & GitHub 사용법

### Git이란?

코드의 변경 이력을 저장하는 도구다. 게임 세이브 포인트처럼, 언제든 과거 상태로 돌아갈 수 있다.

### Git의 3가지 공간

```
[Working Directory]  →  git add  →  [Staging Area]  →  git commit  →  [Repository]
내 컴퓨터 폴더                        커밋 대기실                         버전 저장소
파일을 수정하는 곳                    찍을 사진 고르는 곳                  스냅샷이 쌓이는 곳
```

### 최초 1회 설정

```powershell
git config --global user.name "본인 이름 or GitHub 닉네임"
git config --global user.email "GitHub 가입 이메일"
```

### 매일 쓰는 Git 명령어

```powershell
# 현재 상태 확인 (뭐가 바뀌었는지)
git status

# 전체 파일 스테이징
git add .

# 특정 파일만 스테이징
git add 파일명.ipynb

# 커밋 (스냅샷 저장)
git commit -m "feat: ARIMA 실험 추가"

# GitHub에 업로드
git push

# 커밋 이력 확인
git log --oneline

# GitHub에서 최신 내용 받아오기 (다른 컴퓨터에서 작업했을 때)
git pull
```

### 커밋 메시지 규칙

일관된 메시지 형식을 쓰면 나중에 이력을 보기 편하다.

| prefix | 의미 | 예시 |
|---|---|---|
| `init` | 최초 세팅 | `init: 프로젝트 초기 세팅` |
| `feat` | 새 실험/기능 추가 | `feat: LSTM 실험 추가` |
| `docs` | 문서, README 작성 | `docs: ARIMA 결과 정리` |
| `fix` | 오류 수정 | `fix: 데이터 전처리 버그 수정` |
| `refactor` | 코드 정리 | `refactor: 노트북 구조 개선` |
| `exp` | 실험 결과 업데이트 | `exp: learning rate 0.001 결과` |

### 연구 일지로 활용하는 법

실험할 때마다 커밋하면 자동으로 연구 일지가 된다.

```
2026-04-08  init: 프로젝트 초기 세팅
2026-04-09  feat: 전력 데이터 EDA 완료
2026-04-10  feat: ARIMA(2,0,2) 첫 실험
2026-04-11  exp: ARIMA 파라미터 튜닝 결과
2026-04-12  feat: LSTM 모델 추가
```

GitHub에서 이 이력이 그대로 포트폴리오가 된다.

### GitHub 레포지토리 새로 만들기

1. github.com 접속 → `+` → New repository
2. Repository name 입력
3. Public 선택
4. **Add a README: 체크 해제** (로컬과 충돌 방지)
5. Create repository

```powershell
cd D:\새프로젝트
git init
git add .
git commit -m "init: 초기 세팅"
git branch -m master main
git remote add origin https://github.com/jibeom-git/새프로젝트.git
git push -u origin main
```

---

## 5. Docker 기초

### Docker란?

환경 자체를 통째로 포장해서 어디서든 똑같이 실행할 수 있게 해주는 도구다.

```
문제: 내 컴퓨터(Python 3.11, Windows)에서 잘 되는데
      서버(Python 3.9, Ubuntu)에서 오류가 난다.

해결: Docker로 Python 3.11 + 모든 패키지를 하나의 박스에 담는다.
      그 박스를 서버에 가져가서 실행하면 완전히 동일한 환경이 된다.
```

### Docker의 3가지 핵심 개념

| 개념 | 비유 | 설명 |
|---|---|---|
| **Dockerfile** | 레시피 | 환경 구성 명령어를 텍스트로 정의한 파일 |
| **Image** | 완성된 라면 봉지 | Dockerfile로 만든 완성된 패키지 |
| **Container** | 끓이고 있는 라면 | Image를 실제로 실행한 것 |

### Docker 설치

docker.com/products/docker-desktop 에서 Windows용 다운로드 후 설치.

```powershell
docker --version
# Docker version 27.x.x 가 출력되면 성공
```

### Dockerfile 작성법

프로젝트 루트(`D:\time-series-study\`)에 `Dockerfile` 파일을 만든다. (확장자 없음)

```dockerfile
# 베이스 이미지: Python 3.11이 설치된 깨끗한 리눅스 환경
FROM python:3.11-slim

# 컨테이너 안에서 작업할 폴더 지정
WORKDIR /app

# uv 설치
RUN pip install uv

# 패키지 목록 파일 먼저 복사 (캐시 효율을 위해 코드보다 먼저 복사)
COPY pyproject.toml .

# 패키지 설치
RUN uv pip install --system numpy pandas matplotlib seaborn \
    scikit-learn statsmodels jupyter ipykernel torch

# 내 코드 전체 복사
COPY . .

# Jupyter가 사용할 포트 번호 명시
EXPOSE 8888

# 컨테이너 시작 시 Jupyter 자동 실행
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", \
     "--no-browser", "--allow-root"]
```

### Docker 기본 명령어

```powershell
# 이미지 빌드 (-t: 이름 지정, .: 현재 폴더의 Dockerfile 사용)
docker build -t time-series-study .

# 컨테이너 실행
# -p: 포트 연결 (내컴퓨터:컨테이너)
# -v: 폴더 연결 (내폴더:컨테이너폴더) - 파일 공유
docker run -p 8888:8888 -v D:\time-series-study:/app time-series-study

# 실행 중인 컨테이너 목록
docker ps

# 모든 컨테이너 목록 (멈춘 것 포함)
docker ps -a

# 컨테이너 멈추기
docker stop 컨테이너ID

# 이미지 목록 확인
docker images

# 이미지 삭제
docker rmi 이미지이름
```

### 서버에 배포할 때 흐름

```powershell
# 1. Docker Hub에 이미지 올리기
docker login
docker tag time-series-study jibeom-git/time-series-study:v1.0
docker push jibeom-git/time-series-study:v1.0

# 2. 서버에서 받아서 실행
docker pull jibeom-git/time-series-study:v1.0
docker run -p 8888:8888 jibeom-git/time-series-study:v1.0
```

---

## 6. 시계열 EDA 가이드

### EDA란?

Exploratory Data Analysis, 탐색적 데이터 분석이다. 모델을 돌리기 전에 데이터를 충분히 이해하는 과정이다.

**EDA를 안 하면 생기는 문제:**
- 왜 이 모델을 선택했는지 설명 못 함
- 결과가 좋은지 나쁜지 판단 기준이 없음
- 논문 심사에서 "데이터 분석 근거가 없다"는 지적을 받음

### 연구자가 시계열 데이터에서 확인하는 것들

#### 1단계: 기초 통계 확인

```python
print(df.shape)        # 데이터 크기 (행, 열)
print(df.describe())   # count, mean, std, min, max, 25%, 50%, 75%
print(df.isnull().sum()) # 결측치 개수
```

각 수치의 의미:

| 항목 | 의미 | 연구자가 보는 것 |
|---|---|---|
| `count` | 총 데이터 수 | 예상 개수와 맞는지 확인 (결측치 탐지) |
| `mean` | 평균값 | 전체 수준 파악 |
| `std` | 표준편차 | 변동성 크기 (std/mean = 변동계수) |
| `min/max` | 최솟값/최댓값 | 이상치 존재 여부 |
| `25%~75%` | 사분위수 | 데이터의 절반이 이 범위에 있음 |

#### 2단계: 시각화로 패턴 파악

```python
# 전체 기간 → 트렌드 확인
# 1개월 확대 → 주간 패턴 확인
# 1주일 확대 → 일간 패턴 확인
df.loc['2022-07-01':'2022-07-31'].plot()
```

**연구자가 이 그래프에서 보는 것:**
- 전체: 장기 트렌드가 있나? 증가/감소/정체?
- 1개월: 주말마다 낮아지는 패턴이 있나?
- 1주일: 낮/밤 패턴이 보이나?

#### 3단계: 주기성 분석

```python
# 시간대별, 요일별, 월별 평균
df.groupby(df.index.hour)['column'].mean().plot(kind='bar')
df.groupby(df.index.dayofweek)['column'].mean().plot(kind='bar')
df.groupby(df.index.month)['column'].mean().plot(kind='bar')
```

**이 그래프에서 알 수 있는 것:**
- 피크 시간대 → 어떤 lag feature가 중요한지
- 요일 차이가 크면 → 요일 변수를 feature로 추가해야 함
- 월별 차이가 크면 → 계절성 처리 필요

#### 4단계: 정상성 검정 (ADF Test)

**정상성이란?** 평균과 분산이 시간에 따라 일정한 상태. ARIMA 같은 통계 모델은 정상성이 필요하다.

```python
from statsmodels.tsa.stattools import adfuller

result = adfuller(df['column'])
print(f"p-value: {result[1]:.4f}")

# p-value < 0.05 → 정상성 있음 → ARIMA 바로 사용 가능
# p-value >= 0.05 → 비정상 → 차분(differencing) 후 재검정
```

**비정상 시계열을 그냥 모델에 넣으면?**  
계수가 엉터리로 추정된다. R²=0.99가 나와도 실제론 쓸모없는 모델이 된다. 이걸 **허구 회귀(spurious regression)**라고 한다.

차분이 필요한 경우:
```python
df_diff = df['column'].diff().dropna()  # 1차 차분
result = adfuller(df_diff)              # 다시 검정
```

#### 5단계: ACF / PACF 분석

ARIMA의 파라미터 (p, d, q)를 데이터에서 직접 읽어내는 방법이다.

```python
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf

plot_acf(df['column'], lags=48)   # 자기상관함수
plot_pacf(df['column'], lags=48)  # 편자기상관함수
```

**읽는 법:**
- 파란 음영 밖으로 튀어나온 막대 = 통계적으로 유의미한 상관
- ACF가 특정 lag에서 크게 튀면 → 그 주기성이 있다는 증거
- PACF가 lag=k 이후 음영 안으로 들어오면 → p=k 로 설정

**ARIMA(p, d, q) 파라미터 결정:**

| 파라미터 | 의미 | 어디서 읽나 |
|---|---|---|
| p | 몇 시간 전까지 볼 건지 | PACF가 음영 밖으로 튀는 마지막 lag |
| d | 차분 횟수 | ADF 검정 결과 (정상이면 0) |
| q | 오차를 몇 개 볼 건지 | ACF가 음영 안으로 들어오는 시점 |

### EDA 결과로 논문에 쓰는 표현

```
"ADF 검정 결과 p-value < 0.05로 귀무가설을 기각하여
 본 시계열은 정상성을 만족한다."

"ACF 분석 결과 lag=24에서 유의미한 자기상관이 확인되어
 일간 주기성이 존재함을 확인하였다."

"요일별 평균 전력 사용량 분석 결과 평일 대비 주말에
 약 11% 낮은 사용량을 보여 요일 변수를 feature로 채택하였다."
```

---

## 7. 학습 모니터링 & 평가 지표

### 학습 Loss 곡선 읽는 법

모델 학습 시 Train Loss와 Validation Loss를 함께 그려야 한다.

**정상 학습:**
```
Train Loss:  내려감
Val Loss:    함께 내려감 (약간의 간격은 정상)
→ 학습이 잘 되고 있음
```

**과적합 (Overfitting):**
```
Train Loss:  계속 내려감
Val Loss:    어느 순간부터 올라감
→ 훈련 데이터의 노이즈까지 외워버린 상태
→ Val Loss가 올라가기 시작하는 시점에서 멈춰야 함
→ Early Stopping 기법 사용
```

**학습 안 됨 (Underfitting):**
```
Train Loss:  거의 안 내려감 (수평)
Val Loss:    거의 안 내려감 (수평)
→ 모델이 데이터에서 아무것도 못 배우는 상태
→ 모델이 너무 단순하거나, learning rate가 잘못됐거나, 전처리 오류
```

### Early Stopping 코드 (PyTorch 기준)

```python
best_val_loss = float('inf')
patience = 10        # 몇 epoch 동안 개선이 없으면 멈출지
patience_counter = 0

for epoch in range(max_epochs):
    train_loss = train(model, train_loader)
    val_loss   = evaluate(model, val_loader)

    if val_loss < best_val_loss:
        best_val_loss    = val_loss
        patience_counter = 0
        torch.save(model.state_dict(), 'best_model.pth')  # 가장 좋은 모델 저장
    else:
        patience_counter += 1
        if patience_counter >= patience:
            print(f"Early stopping at epoch {epoch}")
            break
```

### 평가 지표 완전 정리

```python
import numpy as np

actual    = [200, 250, 230]
predicted = [195, 245, 235]

# MAE: 평균 절대 오차. 이해하기 쉬운 기본 지표
mae  = np.mean(np.abs(np.array(actual) - np.array(predicted)))

# RMSE: 평균 제곱근 오차. 큰 오차에 더 민감
rmse = np.sqrt(np.mean((np.array(actual) - np.array(predicted))**2))

# MAPE: 평균 절대 백분율 오차. % 단위라 다른 데이터와 비교 가능
mape = np.mean(np.abs((np.array(actual) - np.array(predicted)) / np.array(actual))) * 100

# R²: 결정계수. 모델이 분산을 얼마나 설명하는지
ss_res = np.sum((np.array(actual) - np.array(predicted))**2)
ss_tot = np.sum((np.array(actual) - np.mean(actual))**2)
r2     = 1 - (ss_res / ss_tot)
```

**지표별 판단 기준:**

| 지표 | 좋은 기준 | 특징 |
|---|---|---|
| MAE | 작을수록 좋음 | 이해하기 쉬움. 기본 보고 지표 |
| RMSE | 작을수록 좋음 | 큰 오차에 민감. 전력 피크 예측 등 |
| MAPE | 5% 이하: 우수, 10% 이하: 양호 | % 단위. 데이터 스케일 무관 |
| R² | 0.9 이상: 좋음 | 1에 가까울수록 좋음 |

### 잔차 플롯 읽는 법

잔차 = 실제값 - 예측값

```python
residuals = actual - predicted
plt.bar(range(len(residuals)), residuals)
plt.axhline(y=0, color='black')
```

**좋은 모델의 잔차 조건:**
1. 0을 중심으로 무작위로 분포 (패턴이 없어야 함)
2. 특정 방향으로 치우치지 않음 (편향 없음)
3. 특정 구간에서만 크지 않음 (등분산성)

특정 구간에서 잔차가 크게 튀면 → 그 구간 데이터를 더 분석해야 한다.

### 논문에서 결과를 보고하는 방식

```
단일 지표만 쓰지 않는다.
반드시 비교 대상(baseline)이 있어야 한다.

예시:
┌──────────────┬────────┬────────┬────────┐
│ 모델         │  MAE   │  RMSE  │  MAPE  │
├──────────────┼────────┼────────┼────────┤
│ ARIMA(기준)  │ 12.34  │ 15.67  │  5.4%  │
│ LSTM         │  8.21  │ 10.33  │  3.6%  │
│ Transformer  │  7.45  │  9.87  │  3.2%  │
└──────────────┴────────┴────────┴────────┘

"제안 모델(Transformer)의 MAE는 7.45로, 기존 ARIMA 대비
 39.6% 개선되었으며, RMSE와 MAPE 역시 각각 37.1%, 40.7% 향상되었다."
```

---

## 8. 새로운 실험을 시작할 때 체크리스트

실험을 시작하기 전에 아래를 순서대로 확인한다.

### 데이터 확인 체크리스트

```
□ 데이터 크기 확인 (df.shape)
□ 기간 확인 (index.min(), index.max())
□ 결측치 확인 (df.isnull().sum())
□ 기초 통계 확인 (df.describe())
□ 전체 시계열 시각화 (트렌드 확인)
□ 주기성 시각화 (시간대/요일/월별)
□ 정상성 검정 (ADF Test)
□ ACF/PACF 분석
```

### 모델 선택 가이드

| 상황 | 추천 모델 |
|---|---|
| 정상 시계열 + 단순 패턴 | ARIMA |
| 계절성이 있음 | SARIMA |
| 외부 변수가 있음 | ARIMAX, XGBoost |
| 비선형 패턴이 강함 | LSTM |
| 장기 의존성이 있음 | Transformer |
| 빠른 baseline 필요 | ARIMA 먼저 |

**항상 ARIMA를 baseline으로 먼저 돌리고, 이후 복잡한 모델과 비교한다.**

### 실험 후 기록 체크리스트

```
□ 실험 조건 기록 (모델, 파라미터, 데이터 기간)
□ 평가 지표 기록 (MAE, RMSE, MAPE, R²)
□ Loss 곡선 이미지 저장
□ 실제값 vs 예측값 그래프 저장
□ 잔차 플롯 저장
□ README.md에 결과 요약
□ git commit → git push
```

### 실험 README.md 템플릿

각 실험 폴더에 아래 템플릿으로 README를 작성한다.

```markdown
## 실험명: ARIMA 기본 실험

### 목적
전력 사용량 데이터에 ARIMA 모델을 적용하여 baseline 성능을 확인한다.

### 데이터
- 기간: 2022-01-01 ~ 2023-12-31
- 주기: 1시간
- 특징: 일간/주간 주기성 존재, 정상 시계열 확인

### 모델 설정
- 모델: ARIMA(2, 0, 2)
- 훈련/검증 분리: 80% / 20%

### 결과
| 지표 | 값 |
|---|---|
| MAE | 12.34 MW |
| RMSE | 15.67 MW |
| MAPE | 5.4% |
| R² | 0.87 |

### 결론
MAPE 5.4%로 양호한 수준이나, 피크 시간대(오전 7~9시)에서
잔차가 크게 발생함. LSTM 모델로 개선 가능성 있음.
```

---

## 9. 자주 만나는 오류와 해결법

### Python/패키지 오류

**F401: imported but unused**
```
경고 수준. 오류 아님.
→ 안 쓰는 import 줄을 지우거나
→ 줄 끝에 # noqa: F401 추가
```

**KeyError: '2022-07' (pandas 3.x)**
```python
# 잘못된 방법 (pandas 2.x에서만 됨)
df['2022-07']

# 올바른 방법
df.loc['2022-07-01':'2022-07-31']
```

**ModuleNotFoundError: No module named 'xxx'**
```powershell
# 가상환경이 활성화되어 있는지 확인
# 터미널 앞에 (time-series-study) 표시가 있어야 함
.venv\Scripts\activate

# 패키지 설치
uv add 패키지명
```

### Git 오류

**error: src refspec main does not match any**
```powershell
# 브랜치 이름 확인
git branch
# master로 되어 있으면 main으로 변경
git branch -m master main
git push -u origin main
```

**remote: Repository not found**
```powershell
# remote 주소 확인
git remote -v
# 잘못된 주소면 교체
git remote remove origin
git remote add origin https://github.com/jibeom-git/올바른주소.git
```

### Docker 오류

**error: Failed to create virtual environment (A directory already exists)**
```powershell
# UV_PROJECT_ENVIRONMENT 환경변수 제거
[Environment]::SetEnvironmentVariable("UV_PROJECT_ENVIRONMENT", $null, "User")
# PowerShell 재시작 후 다시 시도
uv venv
```

---

## 10. 앞으로 공부할 것들 로드맵

### 단기 (지금 ~ 1개월)

```
□ ARIMA 모델 실습
  - ARIMA(p, d, q) 파라미터 의미 이해
  - 전력 데이터에 적용 및 결과 해석
  - baseline 성능 기록

□ 데이터 전처리
  - 결측치 처리 (보간법, 제거 등)
  - 정규화 (MinMax, Standard Scaler)
  - Train/Validation/Test 분리 방법
```

### 중기 (1~3개월)

```
□ 머신러닝 모델
  - XGBoost: lag feature 만들기
  - Random Forest: feature importance 해석
  - ARIMA 대비 성능 비교

□ 딥러닝 기초
  - LSTM 구조 이해
  - PyTorch로 시계열 모델 구현
  - 하이퍼파라미터 튜닝
```

### 장기 (3개월 이후, 석사 진학 대비)

```
□ 최신 모델
  - Transformer 기반 시계열 모델
    (Informer, Autoformer, PatchTST)
  - Foundation Model (TimesFM, Moirai)

□ 논문 읽기 & 재현
  - 유명 시계열 논문 구현
  - 자신의 데이터에 적용

□ 실제 데이터 연구
  - 공공데이터 포털에서 실제 전력 데이터 사용
  - 한국전력 OPEN API 활용

□ 서버 배포
  - Docker로 모델 서버에 올리기
  - AWS / GCP 기초
```

### 추천 학습 자료

**데이터:**
- 공공데이터 포털 (data.go.kr) - 전력, 기상 등 실제 데이터
- UCI ML Repository - 다양한 시계열 데이터셋
- Kaggle - 시계열 경진대회 데이터

**논문:**
- Attention Is All You Need (Transformer 원본)
- Informer: Beyond Efficient Transformer for Long Sequence Time-Series Forecasting
- Are Transformers Effective for Time Series Forecasting?

**라이브러리:**
- `statsmodels` - ARIMA, SARIMA
- `prophet` - Facebook 시계열 모델 (설치: `uv add prophet`)
- `neuralforecast` - 딥러닝 시계열 모델 모음
- `darts` - 시계열 통합 라이브러리

---

## 빠른 참고 명령어 모음

```powershell
# ── 환경 ──
uv venv                          # 가상환경 생성
.venv\Scripts\activate           # 가상환경 활성화
uv add 패키지                     # 패키지 설치
uv sync                          # lock 파일로 환경 동기화

# ── Git ──
git status                       # 변경 사항 확인
git add .                        # 전체 스테이징
git commit -m "feat: 내용"       # 커밋
git push                         # GitHub 업로드
git pull                         # GitHub에서 받아오기
git log --oneline                # 커밋 이력 확인

# ── Docker ──
docker build -t 이름 .           # 이미지 빌드
docker run -p 8888:8888 이름     # 컨테이너 실행
docker ps                        # 실행 중인 컨테이너 확인
docker images                    # 이미지 목록 확인

# ── Jupyter ──
jupyter notebook                 # 브라우저에서 Jupyter 실행
```

---

*이 가이드는 실험이 쌓일수록 계속 업데이트한다.*  
*마지막 업데이트: 2026-04-08*
