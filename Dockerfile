# Production Dockerfile for Construction Digital Twin
FROM python:3.11-slim

WORKDIR /app

# Install system deps (if needed later, kept minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn

# Copy project
COPY . .

# Environment defaults
ENV PORT=8001
ENV AUTO_START=1

# Expose port
EXPOSE 8001

# Gunicorn command (3 workers, 4 threads each)
CMD ["gunicorn", "-b", "0.0.0.0:${PORT}", "--workers", "3", "--threads", "4", "construction_digital_twin:app"]
