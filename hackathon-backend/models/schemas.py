from pydantic import BaseModel

class UserRequest(BaseModel):
    message: str

class BookingRequest(BaseModel):
    provider_id: str
    provider_name: str
    slot: str
    service: str
    user_name: str = "Guest User"