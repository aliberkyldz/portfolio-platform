# Python Hello World API

Python standart kütüphanesiyle hazırlanmış basit bir HTTP servisi.

## Çalıştırma

```powershell
python main.py
```

Ardından:

```text
http://localhost:8000/
http://localhost:8000/health
```

## Docker

```powershell
docker build -t python-hello-world .
docker run --rm -p 8000:8000 python-hello-world
```
