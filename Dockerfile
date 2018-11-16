FROM python:3.7-alpine

RUN mkdir -p /deploy/app
COPY app /deploy/app
COPY gunicorn_config.py /deploy/gunicorn_config.py
RUN pip install -r /deploy/app/requirements.txt
RUN pip install gunicorn
WORKDIR /deploy/app

EXPOSE 5000
CMD ["gunicorn", "--config", "/deploy/gunicorn_config.py", "--access-logfile", "-", "--error-logfile", "-", "kindle-ads:app"]
