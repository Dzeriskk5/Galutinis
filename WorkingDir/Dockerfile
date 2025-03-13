# Use an Alpine base image
FROM alpine:3.18

# Install Python, pip, Nginx, and dependencies
RUN apk update && \
    apk add --no-cache \
    python3 \
    py3-pip \
    nginx \
    bash && \
    python3 -m ensurepip && \
    pip3 install --no-cache --upgrade pip

# Set the working directory in the container
WORKDIR /app

# Copy the application files into the container
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy Nginx configuration
COPY ./nginx.conf /etc/nginx/nginx.conf

# Expose the ports for both Python and Nginx
EXPOSE 80 8000

# Start Nginx and Python application (using direct commands)
CMD nginx && python main.py
