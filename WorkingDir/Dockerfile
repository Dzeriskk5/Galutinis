# Use a base Python image
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the application files into the container
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port your application will run on (if any)
EXPOSE 8000

# Command to run the application
CMD ["python", "main.py"]