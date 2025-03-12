# Use a base Python image
FROM python:3.9-slim-buster

# Install Nginx
RUN apt-get update && apt-get install -y nginx && apt-get clean

# Set the working directory in the container
WORKDIR /app

# Copy the application files into the container
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Configure Nginx (optional: add your custom nginx configuration)
COPY nginx.conf /etc/nginx/nginx.conf

# Expose the ports for both Python and Nginx
EXPOSE 8000 80

# Start both Nginx and the Python application
CMD service nginx start && python main.py
