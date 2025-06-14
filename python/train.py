import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OrdinalEncoder
from sklearn.ensemble import HistGradientBoostingRegressor
import joblib

df = pd.read_csv("MIU_Parking_Synthetic_5000_Students.csv")
df['Date'] = pd.to_datetime(df['Date'])
df['Month'] = df['Date'].dt.month
df['Day_Num'] = df['Date'].dt.day

X = df[["Day", "Hour", "Traffic_Level", "Month", "Day_Num"]]
y = df["Predicted_FreeSpot_%"]

categorical_features = ["Day", "Hour", "Traffic_Level"]

preprocessor = ColumnTransformer([
    ("cat", OrdinalEncoder(handle_unknown="use_encoded_value", unknown_value=-1), categorical_features)
], remainder="passthrough")

hgb_pipeline = Pipeline([
    ("preprocessor", preprocessor),
    ("regressor", HistGradientBoostingRegressor(random_state=42))
])

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
hgb_pipeline.fit(X_train, y_train)

joblib.dump(hgb_pipeline, "hist_gb_pipeline.pkl")
