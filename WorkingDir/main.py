import random
import time
from flask import Flask
from flask_socketio import SocketIO
from threading import Thread

# Initializing the Flask app
app = Flask(__name__)
socketio = SocketIO(app)

# Constants for the Matrix effect
CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"
delay = 0.05  # Faster update interval for smoother movement

# Dynamic matrix size
matrix = []
MATRIX_WIDTH = 0
MATRIX_HEIGHT = 0

# Initialize a list to track the position of falling drops
drops = []

def update_matrix():
    global matrix, MATRIX_WIDTH, MATRIX_HEIGHT, drops
    while True:
        # Ensure that MATRIX_WIDTH and MATRIX_HEIGHT are non-zero
        if MATRIX_WIDTH == 0 or MATRIX_HEIGHT == 0:
            time.sleep(0.1)
            continue  # Wait until the matrix size is set

        # Generate new drops and add trails to them
        if random.random() < 0.5:  # Increased chance of new drops appearing each cycle (50%)
            for _ in range(random.randint(5, 10)):  # Randomly create 5 to 10 drops per cycle (increased)
                col = random.randint(0, MATRIX_WIDTH - 1)
                trail_length = random.randint(5, 15)  # Random trail length between 5 and 15
                drops.append({"row": 0, "col": col, "trail": [], "trail_length": trail_length})

        # Move the drops one step down and update their trails
        for drop in drops[:]:
            if drop["row"] < MATRIX_HEIGHT - 1:
                drop["row"] += 1
                # Randomize the character for the trail at the current position
                trail_char = random.choice(CHARS)
                drop["trail"].append(trail_char)  # Add a random char to the trail
                if len(drop["trail"]) > drop["trail_length"]:
                    drop["trail"].pop(0)  # Keep trail length within bounds
            else:
                drops.remove(drop)  # Remove drop when it reaches the bottom

        # Update matrix with the drops and their trails
        matrix = [[" " for _ in range(MATRIX_WIDTH)] for _ in range(MATRIX_HEIGHT)]
        for drop in drops:
            # Update the matrix with each trail segment, ensuring we are within bounds
            for i, char in enumerate(drop["trail"]):
                row = drop["row"] - len(drop["trail"]) + i + 1  # Positioning the trail vertically
                if 0 <= row < MATRIX_HEIGHT and 0 <= drop["col"] < MATRIX_WIDTH:  # Ensure row and col are within bounds
                    matrix[row][drop["col"]] = char

        # Convert matrix to string and send to the frontend
        matrix_output = "\n".join("".join(row) for row in matrix)
        socketio.emit("update_matrix", {"matrix": matrix_output})
        time.sleep(delay)


@app.route("/")
def index():
    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Matrix Rain</title>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/4.5.4/socket.io.js"></script>
        <script>
            function adjustMatrixSize() {
                var width = Math.floor(window.innerWidth / 10);
                var height = Math.floor(window.innerHeight / 20);
                fetch(`/set_size?width=${width}&height=${height}`);
            }
            window.addEventListener("resize", adjustMatrixSize);
            document.addEventListener("DOMContentLoaded", function() {
                adjustMatrixSize();
                var socket = io();
                socket.on("update_matrix", function(data) {
                    document.getElementById("matrix").innerText = data.matrix;
                });
            });
        </script>
        <style>
            body { background-color: black; color: green; font-family: monospace; white-space: pre; margin: 0; overflow: hidden; }
            pre { font-size: 18px; line-height: 20px; }
        </style>
    </head>
    <body>
        <pre id="matrix"></pre>
    </body>
    </html>
    '''


@app.route("/set_size")
def set_size():
    global matrix, MATRIX_WIDTH, MATRIX_HEIGHT, drops
    from flask import request
    MATRIX_WIDTH = int(request.args.get("width", 60))
    MATRIX_HEIGHT = int(request.args.get("height", 20))

    if MATRIX_WIDTH == 0 or MATRIX_HEIGHT == 0:
        return "Invalid matrix size", 400  # Return error if the size is zero

    # Reset drops when the size changes
    drops = []

    # Reinitialize the matrix with the new size
    matrix = [[" " for _ in range(MATRIX_WIDTH)] for _ in range(MATRIX_HEIGHT)]
    return "OK"


def start_matrix():
    thread = Thread(target=update_matrix)
    thread.daemon = True
    thread.start()


if __name__ == "__main__":
    start_matrix()
    socketio.run(app, host="0.0.0.0", port=8000, allow_unsafe_werkzeug=True)
