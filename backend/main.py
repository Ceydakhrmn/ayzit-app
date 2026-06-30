import os
from typing import List, Optional

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
OPENAI_BASE_URL = os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1")
AI_CHAT_MODEL = os.getenv("AI_CHAT_MODEL", "gpt-4o")
AI_CONTENT_MODEL = os.getenv("AI_CONTENT_MODEL", "gpt-4o-mini")
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "").split(",") if os.getenv("CORS_ORIGINS") else ["*"]

app = FastAPI(title="Ajanda AI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ChatMessage(BaseModel):
    role: str = Field(..., pattern="^(system|user|assistant)$")
    content: str


class ChatRequest(BaseModel):
    messages: List[ChatMessage]
    locale: Optional[str] = "tr"


class AdviceRequest(BaseModel):
    summary: str
    locale: Optional[str] = "tr"


class SummaryRequest(BaseModel):
    notes: str
    locale: Optional[str] = "tr"


@app.get("/health")
def health_check():
    return {"status": "ok"}


def _system_prompt(locale: str) -> str:
    base = (
        "You are a helpful health assistant for menstrual cycle tracking. "
        "Provide supportive, non-diagnostic guidance. "
        "If user asks for urgent or dangerous symptoms, advise seeking medical care. "
        "Keep responses concise (max 6 sentences)."
    )
    if locale == "tr":
        return (
            "Sen adet dongusu takibi icin yardimci bir saglik asistanisin. "
            "Tani koyma, sadece destekleyici ve guvenli oneriler ver. "
            "Acil veya riskli belirtilerde doktora basvurmasini oner. "
            "Yanitlarini kisa tut (en fazla 6 cumle)."
        )
    return base


def _client() -> httpx.Client:
    if not OPENAI_API_KEY:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY missing")
    return httpx.Client(
        base_url=OPENAI_BASE_URL,
        headers={"Authorization": f"Bearer {OPENAI_API_KEY}"},
        timeout=15.0,
    )


def _chat_completion(
    model: str,
    messages: List[ChatMessage],
    max_tokens: int,
) -> str:
    payload = {
        "model": model,
        "messages": [{"role": m.role, "content": m.content} for m in messages],
        "temperature": 0.5,
        "max_tokens": max_tokens,
    }
    with _client() as client:
        resp = client.post("/chat/completions", json=payload)
        if resp.status_code != 200:
            raise HTTPException(status_code=resp.status_code, detail=resp.text)
        data = resp.json()
        return data["choices"][0]["message"]["content"]


@app.post("/ai/chat")
def ai_chat(req: ChatRequest):
    system = ChatMessage(role="system", content=_system_prompt(req.locale or "tr"))
    result = _chat_completion(AI_CHAT_MODEL, [system, *req.messages], max_tokens=220)
    return {"reply": result}


@app.post("/ai/advice")
def ai_advice(req: AdviceRequest):
    system = ChatMessage(role="system", content=_system_prompt(req.locale or "tr"))
    user = ChatMessage(
        role="user",
        content=(
            "Summarize and provide short, safe advice based on: "
            + req.summary
        ),
    )
    result = _chat_completion(AI_CHAT_MODEL, [system, user], max_tokens=160)
    return {"advice": result}


@app.post("/ai/summary")
def ai_summary(req: SummaryRequest):
    system = ChatMessage(role="system", content=_system_prompt(req.locale or "tr"))
    user = ChatMessage(
        role="user",
        content=(
            "Create a short daily summary from these notes: "
            + req.notes
        ),
    )
    result = _chat_completion(AI_CONTENT_MODEL, [system, user], max_tokens=140)
    return {"summary": result}
