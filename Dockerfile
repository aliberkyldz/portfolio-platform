FROM python:3.13-slim

WORKDIR /app

COPY main.py .

EXPOSE 8000

CMD ["python", "main.py"]
