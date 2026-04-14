FROM python:3.9-slim

WORKDIR /app

COPY . /app

RUN pip install flask pymysql \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    --no-cache-dir \
    --progress-bar off

CMD ["python", "app.py"]
