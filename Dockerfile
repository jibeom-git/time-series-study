FROM python:3.11-slim

WORKDIR /app

RUN pip install uv

COPY pyproject.toml .

RUN uv pip install --system numpy pandas matplotlib seaborn scikit-learn statsmodels jupyter ipykernel torch

COPY . .

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]