import random
import shutil
import time
import os

def matrix_effect():
    columns, rows = shutil.get_terminal_size()
    characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    drops = [0] * columns

    while True:
        os.system('cls' if os.name == 'nt' else 'clear')
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
            print(f"\033[32m{line}\033[0m")
        time.sleep(0.1)

if __name__ == "__main__":
    matrix_effect()
