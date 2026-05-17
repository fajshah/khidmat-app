from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from models.schemas import UserRequest, BookingRequest
from datetime import datetime
import uuid

from agents.intent_agent import extract_intent
from agents.discovery_agent import discover_providers
from agents.ranking_agent import rank_and_select

app = FastAPI(title="Khidmat API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)



bookings_db = {}

import os

@app.get("/api/health")
async def health_check():
    return {"message": "Khidmat API is running!", "status": "ok"}

@app.post("/api/request")
async def process_request(req: UserRequest):
    trace_log = []

    try:
        # Step 1 - Intent Agent
        trace_log.append({"step": 1, "agent": "IntentAgent", "status": "running"})
        intent = extract_intent(req.message)
        print(f">>> INTENT: {intent}") 
        trace_log.append({"step": 1, "agent": "IntentAgent", "status": "done", "output": intent})

        # Step 2 - Discovery Agent
        trace_log.append({"step": 2, "agent": "DiscoveryAgent", "status": "running"})
        discovery = discover_providers(intent)
        trace_log.append({"step": 2, "agent": "DiscoveryAgent", "status": "done", "output": discovery})

        # Step 3 - Ranking Agent
        trace_log.append({"step": 3, "agent": "RankingAgent", "status": "running"})
        ranking = rank_and_select(discovery, intent)
        trace_log.append({"step": 3, "agent": "RankingAgent", "status": "done", "output": ranking})

        return {
            "success": True,
            "user_input": req.message,
            "intent": intent,
            "providers": discovery["providers"],
            "recommended": ranking["selected"],
            "reasoning": ranking["reasoning"],
            "all_ranked": ranking["all_ranked"],
            "agent_trace": trace_log
        }
    except Exception as e:
        return {
            "success": False,
            "error": "Internal Agent Error (Likely invalid API Key)",
            "details": str(e),
            "agent_trace": trace_log
        }

@app.post("/api/book")
async def create_booking(req: BookingRequest):
    booking_id = f"BK-{str(uuid.uuid4())[:6].upper()}"
    
    booking = {
        "booking_id": booking_id,
        "provider_id": req.provider_id,
        "provider_name": req.provider_name,
        "service": req.service,
        "slot": req.slot,
        "user_name": req.user_name,
        "status": "CONFIRMED",
        "created_at": datetime.now().isoformat(),
        "reminder": f"Reminder set 1 hour before {req.slot}",
        "confirmation_message": f"Booking confirmed! {req.provider_name} aayega {req.slot} pe. Booking ID: {booking_id}"
    }
    
    bookings_db[booking_id] = booking
    
    return {"success": True, "booking": booking}

@app.get("/api/booking/{booking_id}")
async def get_booking(booking_id: str):
    booking = bookings_db.get(booking_id)
    if not booking:
        return {"success": False, "message": "Booking nahi mili"}
    return {"success": True, "booking": booking}

@app.get("/api/providers")
async def get_all_providers():
    import json, os
    path = os.path.join(os.path.dirname(__file__), "data", "providers.json")
    with open(path) as f:
        providers = json.load(f)
    return {"success": True, "providers": providers}

# Mount the static directory to serve the Flutter Web app (MUST BE AT THE END)
if os.path.isdir("static"):
    app.mount("/", StaticFiles(directory="static", html=True), name="static")