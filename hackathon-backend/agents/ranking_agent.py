import os
import json
from dotenv import load_dotenv
from google import genai
from pydantic import BaseModel, Field

load_dotenv(override=True)

class RankedProvider(BaseModel):
    name: str
    rating: float
    distance_km: float
    score: float

class RankingResult(BaseModel):
    selected_provider_id: str | None = Field(description="The ID of the single best provider chosen. Null if no providers are available.")
    reasoning: str = Field(description="A clear, human-readable explanation of why this provider was chosen over others (e.g., 'Ali AC Services was chosen because they have the highest rating (4.8) and are very close (2.1 km).').")
    all_ranked: list[RankedProvider] = Field(description="The list of providers scored and ranked from best to worst.")

def rank_and_select(discovery_result: dict, intent: dict) -> dict:
    providers = discovery_result.get("providers", [])

    if not providers:
        return {
            "agent": "RankingAgent",
            "selected": None,
            "reasoning": "We couldn't find any available providers matching your request in this area at the moment.",
            "all_ranked": []
        }

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY is not set in the environment.")
        
    client = genai.Client(api_key=api_key)
    
    prompt = f"""
    You are a decision-making Ranking Agent. You have received a list of available service providers that match the user's intent.
    Your task is to rank these providers and select the absolute best one based on distance (closer is better), rating (higher is better), and any urgency.
    
    User Intent:
    {json.dumps(intent, indent=2)}
    
    Discovered Providers:
    {json.dumps(providers, indent=2)}
    
    Rank the providers and choose the best one. Provide a clear reasoning string explaining why you chose them.
    """
    
    try:
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
            config=genai.types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=RankingResult,
            ),
        )
        
        parsed = response.parsed
        
        # Find the selected provider object
        selected_provider = next((p for p in providers if p["id"] == parsed.selected_provider_id), None)
        
        # Fallback if ID mismatch
        if not selected_provider and providers:
            selected_provider = providers[0]
            
        return {
            "agent": "RankingAgent",
            "selected": selected_provider,
            "reasoning": parsed.reasoning,
            "all_ranked": [rp.model_dump() for rp in parsed.all_ranked]
        }
        
    except Exception as e:
        print(f"Error in RankingAgent: {e}")
        # Basic mathematical fallback
        def score(p):
            rating_score = p.get("rating", 0) * 20
            distance_score = max(0, 100 - p.get("distance_km", 10) * 10)
            return (rating_score * 0.6) + (distance_score * 0.4)

        ranked = sorted(providers, key=score, reverse=True)
        best = ranked[0]
        
        return {
            "agent": "RankingAgent (Fallback)",
            "selected": best,
            "reasoning": f"Automatically selected {best['name']} based on optimal distance and rating fallback formula.",
            "all_ranked": [
                {
                    "name": p["name"],
                    "rating": p.get("rating", 0),
                    "distance_km": p.get("distance_km", 0),
                    "score": round(score(p), 1)
                } for p in ranked
            ]
        }