import os
import json
from dotenv import load_dotenv
from google import genai
from pydantic import BaseModel, Field

load_dotenv(override=True)

class IntentResult(BaseModel):
    service_type: str = Field(description="The specific service requested, e.g., 'ac technician', 'plumber', 'electrician'. Infer from context if not explicitly mentioned.")
    location: str = Field(description="The specific location or area mentioned, e.g., 'G-13', 'DHA', 'Gulshan'. If none, use 'not specified'.")
    time_preference: str = Field(description="The preferred time of day, e.g., 'morning', 'afternoon', 'evening', 'flexible'. Defaults to 'flexible' if unspecified.")
    urgency: str = Field(description="The urgency of the request. Either 'urgent' or 'normal'.")
    language_detected: str = Field(description="The language of the user's input, e.g., 'urdu', 'roman_urdu', 'english'.")

def extract_intent(user_input: str) -> dict:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY is not set in the environment.")
        
    client = genai.Client(api_key=api_key)
    
    prompt = f"""
    You are an expert intent extraction agent for a home services booking application (Khidmat).
    Your job is to analyze the user's input, which may be in English, Urdu, or Roman Urdu, and extract the exact service requirements.
    
    User Input: "{user_input}"
    
    Extract the information exactly as specified in the schema.
    """
    
    try:
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
            config=genai.types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=IntentResult,
            ),
        )
        
        # Convert Pydantic object to dictionary
        result = response.parsed.model_dump()
        result["raw_input"] = user_input
        result["agent"] = "IntentAgent"
        
        return result
        
    except Exception as e:
        print(f"Error in IntentAgent: {e}")
        
        # Intelligent Fallback using basic keyword matching if API fails
        fallback_service = "unknown"
        lower_input = user_input.lower()
        if "ac" in lower_input or "cooling" in lower_input:
            fallback_service = "ac technician"
        elif "plumb" in lower_input or "pipe" in lower_input or "leak" in lower_input:
            fallback_service = "plumber"
        elif "electric" in lower_input or "bijli" in lower_input or "wire" in lower_input:
            fallback_service = "electrician"
        elif "tutor" in lower_input or "parha" in lower_input or "teach" in lower_input:
            fallback_service = "tutor"
        elif "clean" in lower_input or "safai" in lower_input or "maid" in lower_input:
            fallback_service = "cleaner"
            
        return {
            "service_type": fallback_service,
            "location": "not specified",
            "time_preference": "flexible",
            "urgency": "normal",
            "language_detected": "unknown",
            "raw_input": user_input,
            "agent": "IntentAgent (Fallback)"
        }