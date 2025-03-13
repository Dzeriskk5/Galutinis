# Use an Alpine base image
FROM alpine:3.18

# Install Python, pip, Nginx, bash, and build dependencies
RUN apk update && \
    apk add --no-cache \
    python3 \
    py3-pip \
    nginx \
    bash \
    build-base \
    libffi-dev \
    libmagic-dev && \
    python3 -m ensurepip && \
    pip3 install --no-cache --upgrade pip

# Set the working directory in the container
WORKDIR /app

# Copy the application files into the container
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose the ports for both Python and Nginx
EXPOSE 80 8000

# Use Gunicorn to serve the app (replace `app:app` with your app's module if needed)
CMD gunicorn -w 4 -b 0.0.0.0:8000 main:app
