# Base image
FROM python:3.11-alpine@sha256:c825a02ff096b3dc3d362015f9e9f6527f66b73e11f9ad2db1f0da4e09ba7030

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN python -m pip install --upgrade pip

RUN apk update && \
    apk upgrade -i -a --update-cache && \
    apk add --no-cache su-exec

WORKDIR /usr/src/app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ .
COPY entrypoint.sh /entrypoint.sh

RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
