from fastapi import FastAPI, UploadFile, File, HTTPException
import cv2
import numpy as np
from deepface import DeepFace

app = FastAPI(
    title="Age Prediction API",
    description="A simple API to predict age from uploaded face images.",
    version="1.0.0"
)

@app.post("/predict_age/")
async def predict_age(file: UploadFile = File(...)):
    # Validate that an image is being uploaded
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image.")

    try:
        # Read the image bits directly into memory
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if img is None:
            raise HTTPException(status_code=400, detail="Error decoding image.")

        # DeepFace analyze supports passing a numpy array (BGR format, which is the default for cv2)
        # We specify actions=['age'] to selectively run age prediction
        results = DeepFace.analyze(img_path=img, actions=['age'], enforce_detection=True)
        
        # DeepFace may return a list if multiple faces are detected. 
        # We'll take the first face detected for simplicity.
        if isinstance(results, list):
            age = results[0]['age']
        else:
            age = results['age']

        return {
            "filename": file.filename, 
            "predicted_age": age
        }

    except ValueError as ve:
        # Raised by DeepFace if no face is detected (when enforce_detection=True)
        raise HTTPException(status_code=400, detail=f"Face detection failed: {str(ve)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
