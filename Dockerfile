# Use an official Python slim footprint image
FROM python:3.10-slim

# Set environment variables to optimize Python execution in containers
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files
# PYTHONUNBUFFERED: Prevents Python from buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Upgrade pip to its latest version
RUN pip install --upgrade pip --no-cache-dir

# Copy the requirements file independently from the application code
# This takes advantage of Docker's layer caching mechanism. Rebuilding the 
# image when changing code will be extremely fast if requirements don't change.
COPY requirements.txt /app/

# Install the dependencies without caching to keep the image size small
RUN pip install --no-cache-dir -r requirements.txt

# OPTIMIZATION: Pre-download DeepFace model weights during the build process.
# This prevents the first real API request from hanging while downloading the 150MB weights,
# which can cause server timeouts in production. We use a dummy 224x224 numpy array image.
RUN python -c "\
import numpy as np; \
from deepface import DeepFace; \
dummy_img = np.zeros((224, 224, 3), dtype=np.uint8); \
try: \
    print('Downloading deepface models...'); \
    DeepFace.analyze(dummy_img, actions=['age'], enforce_detection=False); \
    print('Successfully downloaded!'); \
except Exception as e: \
    print('Failed to pre-download model. Details:', e)\
"

# Copy the rest of the application code
COPY main.py /app/

# Expose the API port
EXPOSE 8000

# Start the uvicorn web server listening on 0.0.0.0
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
