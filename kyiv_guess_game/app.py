from flask import Flask, render_template, request, jsonify
import folium
import sqlite3
import random

app = Flask(__name__)

def create_database():
    conn = sqlite3.connect('game_results.db')
    cursor = conn.cursor()
    cursor.execute('''CREATE TABLE IF NOT EXISTS results (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        player_name TEXT,
                        score INTEGER,
                        time_taken REAL
                      )''')
    conn.commit()
    conn.close()

create_database()

# Dummy data for locations and images
locations = [
    {"name": "Майдан Незалежності", "lat": 50.4501, "lon": 30.5234, "image": "maidan.jpg"},
    {"name": "Андріївський узвіз", "lat": 50.4587, "lon": 30.5155, "image": "andriyivskyy.jpg"},
    {"name": "Золоті ворота", "lat": 50.4483, "lon": 30.5139, "image": "golden_gate.jpg"}
]

@app.route('/')
def index():
    # Select a random location for the game
    location = random.choice(locations)
    return render_template('index.html', location=location)

@app.route('/submit', methods=['POST'])
def submit():
    data = request.json
    lat = data['lat']
    lon = data['lon']
    location_name = data['location_name']
    time_taken = data['time_taken']

    # Calculate score (dummy logic: check proximity)
    correct_location = next(loc for loc in locations if loc['name'] == location_name)
    distance = ((correct_location['lat'] - lat) ** 2 + (correct_location['lon'] - lon) ** 2) ** 0.5
    score = max(0, int((1 - distance) * 100))

    # Save result in the database
    conn = sqlite3.connect('game_results.db')
    cursor = conn.cursor()
    cursor.execute('INSERT INTO results (player_name, score, time_taken) VALUES (?, ?, ?)',
                   (data['player_name'], score, time_taken))
    conn.commit()
    conn.close()

    return jsonify({"score": score, "message": "Результат збережено!"})

@app.route('/results')
def results():
    conn = sqlite3.connect('game_results.db')
    cursor = conn.cursor()
    cursor.execute('SELECT player_name, score, time_taken FROM results ORDER BY score DESC LIMIT 10')
    results = cursor.fetchall()
    conn.close()
    return render_template('results.html', results=results)

if __name__ == '__main__':
    app.run(debug=True)
