from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime
import pandas as pd
import joblib

# Load the trained model
model = joblib.load("hist_gb_pipeline.pkl")

# Initialize FastAPI app
app = FastAPI()

# Input format
class PredictRequest(BaseModel):
    timestamp: str  # Expected format: "YYYY-MM-DD HH:MM"

# Traffic level inference logic
def infer_traffic_level(day: str, hour_str: str) -> str:
    hour = int(hour_str.split(':')[0])
    minute = int(hour_str.split(':')[1])
    time_val = hour + minute / 60
    if day in ["Monday", "Wednesday"] and time_val <= 13:
        return "High"
    elif time_val <= 13:
        return "Medium"
    else:
        return "Low"

# Prediction endpoint
@app.post("/predict")
def predict_availability(request: PredictRequest):
    dt = datetime.strptime(request.timestamp, "%Y-%m-%d %H:%M")
    day = dt.strftime("%A")
    hour = f"{dt.hour}:{dt.minute:02d}"
    traffic = infer_traffic_level(day, hour)

    input_df = pd.DataFrame([{
        "Day": day,
        "Hour": hour,
        "Traffic_Level": traffic,
        "Month": dt.month,
        "Day_Num": dt.day
    }])

    prediction = model.predict(input_df)[0]
    return {"predicted_percent": round(prediction, 2)}
