import gunicorn

bind = "0.0.0.0:5000"
workers = 2
gunicorn.SERVER_SOFTWARE = 'AmazonS3'
