from fastapi import FastApi
app = FastApi()

@app.get("/")
def read_root():
    return {"hello": "world"}

@app.get("/health")
def health():
    return {"status": "ok"}