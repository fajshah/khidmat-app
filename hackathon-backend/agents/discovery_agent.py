import os
import json
from dotenv import load_dotenv
from google import genai
from pydantic import BaseModel, Field

load_dotenv(override=True)

class ProviderResult(BaseModel):
    service_searched: str = Field(description="The finalized service category that was searched for.")
    location_searched: str = Field(description="The finalized location that was searched for.")
    provider_ids: list[str] = Field(description="A list of provider IDs that best match the intent. Must be an empty list if none match.")

def discover_providers(intent: dict) -> dict:
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    providers_path = os.path.join(base_dir, "data", "providers.json")
    
    with open(providers_path, "r", encoding="utf-8") as f:
        all_providers = json.load(f)
        
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY is not set in the environment.")
        
    client = genai.Client(api_key=api_key)
    
    # Filter only available providers to save token context
    available_providers = [p for p in all_providers if p.get("available", True)]
    
    prompt = f"""
    You are a service discovery agent. Your job is to match a user's service intent with the best available service providers.
    
    User Intent:
    {json.dumps(intent, indent=2)}
    
    Available Providers Database:
    {json.dumps(available_providers, indent=2)}
    
    Based on the 'service_type' and 'location' in the User Intent, identify which providers from the Database are a relevant match.
    If the location is 'not specified', match primarily on the service type.
    Return the list of matched provider IDs.
    """
    
    try:
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
            config=genai.types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=ProviderResult,
            ),
        )
        
        parsed = response.parsed
        
        # Retrieve the actual provider objects based on the returned IDs
        matched_providers = [p for p in available_providers if p["id"] in parsed.provider_ids]
        
        # If the LLM failed to match any but we have providers, do a basic fallback just in case
        if not matched_providers and available_providers:
             service_type = intent.get("service_type", "").lower()
             if service_type == "unknown" or not service_type:
                 matched_providers = available_providers
             else:
                 matched_providers = [p for p in available_providers if service_type in p["service"].lower()]
        
        return {
            "agent": "DiscoveryAgent",
            "service_searched": parsed.service_searched,
            "location_searched": parsed.location_searched,
            "providers_found": len(matched_providers),
            "providers": matched_providers
        }
        
    except Exception as e:
        print(f"Error in DiscoveryAgent: {e}")
        service_type = intent.get("service_type", "").lower()
        if service_type == "unknown" or not service_type:
            matched_providers = available_providers
        else:
            matched_providers = [p for p in available_providers if service_type in p["service"].lower()]
        return {
            "agent": f"DiscoveryAgent (Fallback) - Error: {e}",
            "service_searched": intent.get("service_type", ""),
            "location_searched": intent.get("location", ""),
            "providers_found": len(matched_providers),
            "providers": matched_providers
        }