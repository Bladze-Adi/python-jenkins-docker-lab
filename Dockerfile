# Stage 1: Base runtime environment
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY app/ ./app/

# Create a non-root user for security best practices
RUN useradd -u 8888 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

CMD ["python", "app/app.py"]
