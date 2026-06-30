# Backend (FastAPI)

## Setup

1) Create venv and install deps:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

2) Add environment variables:

- Copy `.env.example` to `.env`
- Set `OPENAI_API_KEY`

3) Run server:

```powershell
uvicorn main:app --reload --port 8000
```

## Endpoints

- `GET /health`
- `POST /ai/chat`
- `POST /ai/advice`
- `POST /ai/summary`

## Notes

- The OpenAI API key must stay on the server.
- The client (Flutter) should call this backend.
