FROM python:3.11

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install git.
RUN apt-get update && apt-get install -y git

# Clone the repository from GitHub.
RUN git clone https://github.com/UPB-SysSec/DPYProxy.git .

# Download dependencies as a separate step to take advantage of Docker's caching.
RUN pip install -r requirements.txt

# Run the web service on container startup.
# Change parameters in docker-compose.yml
ENTRYPOINT ["python3", "main.py"]