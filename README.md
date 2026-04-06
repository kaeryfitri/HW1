# Age Prediction API

A simple FastAPI server for predicting age from facial images. This uses the `deepface` library to perform face detection and age prediction.

## Project Structure

```
age-prediction-fastapi/
├── main.py              # Main application code with FastAPI routing
├── requirements.txt     # Python package dependencies
└── README.md            # This file
```

## Setup & Running the Server

1. **Create a virtual environment (Optional but Recommended)**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On macOS/Linux
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
   *(Note: DeepFace uses pre-trained weights which it will automatically download (~150MB) on the very first API request).*

3. **Start the FastAPI server**:
   ```bash
   uvicorn main:app --reload
   ```

4. **Test the API**:
   - Open your web browser and navigate to: http://127.0.0.1:8000/docs
   - This opens the interactive **Swagger UI** automatically provided by FastAPI.
   - Click on the `POST /predict_age/` route, click **"Try it out"**, upload an image containing a face, and click **"Execute"**.
   - You will see a JSON response with the predicted age.
