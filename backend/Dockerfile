FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /code

# system deps
RUN apt-get update && apt-get install -y build-essential gcc libpq-dev curl && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . /code

# make entrypoint executable
RUN chmod +x /code/docker-entrypoint.sh

EXPOSE 8000
CMD ["/code/docker-entrypoint.sh"]
