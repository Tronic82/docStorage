FROM python:3.9.12-buster

WORKDIR /usr/src/app

COPY source/ ./

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 80

CMD exec gunicorn -b :80 --workers 3 --threads 8 --timeout 0 main:app