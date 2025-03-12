import random
import shutil
import time
import os
from flask import Flask, render_template_string

app = Flask(__name__)

# This will hold the matrix effect as a string
matrix_output = ""

def matrix_effect():
    global matrix_output
    columns, rows = shutil.get_terminal_size()
    characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    drops = [0] * columns

    while True:
        lines = []
        for i in range(rows):
            line = ""
            for j in range(columns):
                if random.random() > 0.975:
                    drops[j] = 0
                if drops[j] == 0:
                    line += random.choice(characters)
                else:
                    line += " "
                drops[j] += 1
            lines.append(line)
        matrix_output = "<br>".join(lines)
        time.sleep(0.1)

@app.route("/")
def index():
    return render_template_string("<pre>{{ matrix_output }}</pre>", matrix_output=matrix_output)

if __name__ == "__main__":
    from threading import Thread
    # Run the matrix effect in a separate thread to not block the Flask app
    thread = Thread(target=matrix_effect)
    thread.daemon = True
    thread.start()
    
    # Run Flask on port 8000
    app.run(host="0.0.0.0", port=8000)
