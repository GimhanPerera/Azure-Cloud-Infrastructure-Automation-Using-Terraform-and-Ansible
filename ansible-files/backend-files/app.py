from flask import Flask, request, jsonify
import psycopg2
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from flask_cors import CORS

import os

app = Flask(__name__)
CORS(app)

#KEY_VAULT_URL = "https://<your-keyvault-name>.vault.azure.net/"
KEY_VAULT_URL = os.getenv("KEY_VAULT_URL")

credential = DefaultAzureCredential()
client = SecretClient(vault_url=KEY_VAULT_URL, credential=credential)

def get_db_config():
    return {
        "host": client.get_secret("db-host").value,
        "database": client.get_secret("db-name").value,
        "user": client.get_secret("db-user").value,
        "password": client.get_secret("db-password").value
    }

def get_conn():
    config = get_db_config()
    return psycopg2.connect(**config)

# Health Check
@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200

# Get all fruits
@app.route("/api/fruits", methods=["GET"])
def get_fruits():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT id, name, price FROM fruits")
    rows = cur.fetchall()
    cur.close()
    conn.close()

    fruits = [{"id": r[0], "name": r[1], "price": float(r[2])} for r in rows]
    return jsonify(fruits)

# Add fruit
@app.route("/api/fruits", methods=["POST"])
def add_fruit():
    data = request.json
    name = data.get("name")
    price = data.get("price")

    conn = get_conn()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO fruits (name, price) VALUES (%s, %s) RETURNING id",
        (name, price)
    )
    new_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()

    return jsonify({"id": new_id, "name": name, "price": price}), 201

# Update fruit
@app.route("/api/fruits/<int:id>", methods=["PUT"])
def update_fruit(id):
    data = request.json
    name = data.get("name")
    price = data.get("price")

    conn = get_conn()
    cur = conn.cursor()
    cur.execute(
        "UPDATE fruits SET name=%s, price=%s WHERE id=%s",
        (name, price, id)
    )
    conn.commit()
    cur.close()
    conn.close()

    return jsonify({"message": "updated"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=5000)

