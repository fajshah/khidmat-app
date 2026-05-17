# Khidmat - Smart Service Booking Backend

**Khidmat** is an intelligent, AI-powered backend for a Pakistani local service booking application. Built with **FastAPI** and **Google Gemini**, it allows users to simply type or speak what they need in natural language (Urdu, Roman Urdu, or English) and automatically handles the process of finding, filtering, and ranking the best service providers for them.

---

## 🧠 AI Agent Architecture

The true power of this backend lies in its multi-agent architecture. Instead of relying on rigid, hard-coded rules, Khidmat uses a pipeline of specialized agents:

### 1. 🕵️ Intent Agent
**Goal:** Understand the user.
Users don't have to fill out complex forms. They can just say *"Mujhe kal subah G-13 mein AC technician chahiye"*. The Intent Agent uses the **Gemini 2.0 Flash API** to parse this natural language input and extract structured data:
- **Service Type:** AC Technician
- **Location:** G-13
- **Time Preference:** Morning
- **Urgency & Language detected**

### 2. 🔍 Discovery Agent
**Goal:** Find matches.
This agent acts as the database engine. It takes the structured intent from the Intent Agent and searches the providers database (`providers.json`) to find all active and available service providers in the requested area that match the specific service type.

### 3. ⭐ Ranking Agent
**Goal:** Make recommendations.
Once a list of potential providers is generated, the Ranking Agent scores them based on a weighted algorithm of **Distance** and **Ratings**. It then uses Gemini AI to generate a human-readable reasoning string explaining *why* a specific provider is the best match (e.g., *"Kamran AC Services is the best option with a 4.8 rating and is only 5.0km away."*).

---

## 🚀 API Endpoints

The API is fully documented automatically via Swagger UI. Once the server is running, visit `http://127.0.0.1:8000/docs` to test the endpoints.

- **`POST /api/request`**: The core AI endpoint. Send a natural language message and it runs the Intent -> Discovery -> Ranking pipeline.
- **`POST /api/book`**: Confirms a booking with the chosen provider and returns a Booking ID.
- **`GET /api/booking/{booking_id}`**: Fetches details for a specific booking.
- **`GET /api/providers`**: Returns the list of all service providers.

---

## 🛠️ Tech Stack
- **Framework:** FastAPI
- **AI Models:** Google Gemini 2.0 Flash (`google-genai` SDK)
- **Validation:** Pydantic
- **Server:** Uvicorn

---

## ⚙️ Setup Instructions

Follow these steps to run the backend locally:

1. **Clone the repository and navigate to the folder:**
   ```bash
   cd hackathon-backend
   ```

2. **Create and activate a virtual environment (Optional but recommended):**
   ```bash
   python -m venv venv
   venv\Scripts\activate  # Windows
   ```

3. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Environment Variables:**
   Create a `.env` file in the root directory and add your Google Gemini API key:
   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   ```

5. **Run the Server:**
   ```bash
   python -m uvicorn main:app --reload
   ```

*(Note: If you exceed the Gemini API free tier rate limits, the agents will gracefully fall back to mock data to ensure the frontend doesn't break during your presentation/testing).*

## 👥 Team
- **Areesha Furqan**
- **Syeda Farzana Shah**

---
*Built with ❤️ for the Hackathon.*
