FROM python:3.7-alpine

RUN adduser -D adpublisher

WORKDIR /home/adpublisher

COPY requirements.txt requirements.txt
RUN python -m venv venv
RUN venv/bin/pip install -r requirements.txt
RUN venv/bin/pip install gunicorn

COPY app.py app.py
COPY boot.sh boot.sh
COPY data/ data/
COPY templates/ templates/

RUN chown -R adpublisher:adpublisher ./
USER adpublisher

EXPOSE 5000
ENTRYPOINT ["./boot.sh"]
