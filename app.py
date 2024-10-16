from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from pymongo import MongoClient
import asyncio
import websockets
from passlib.context import CryptContext

# Hashing System For Password
pwd_cont = CryptContext(schemes=['bcrypt'], deprecated="auto")  # Text To Hash

def verfiy_pwd(plain_pwd, hash_pwd):  # Verifying Password
    return pwd_cont.verify(plain_pwd, hash_pwd)

def verify_hash(password):  # Hashing The Password
    return pwd_cont.hash(password)
#import object_detection  # Import your plastic detection script

app = Flask(__name__)
CORS(app)  # Allow cross-origin requests

# MongoDB setup
client = MongoClient("mongodb+srv://fino:fino@cluster0.ko0stef.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
db = client['pwrcs']
users = db['users']


@app.route('/')
def home():
    return render_template('index.html')






# WebSocket server
#async def detect_plastic(websocket, path):
 #   user_data = await websocket.recv()
 #   user_data = json.loads(user_data)
 #   email = user_data['email']

    # Run the object detection to detect plastic type
#    plastic_type = object_detection.detect()
#    credits = assign_credits(plastic_type)

    # Send plastic detection result and credits to the mobile app
#    await websocket.send(json.dumps({
#        'plastic_type': plastic_type,
#        'credits': credits
#    }))

    # Wait for the 'Finish' signal from the mobile app
#    finish_signal = await websocket.recv()
#    if finish_signal == 'finish':
        # Update user credits in MongoDB
#        users.update_one(
#            {'email': email},
#            {'$inc': {'credits': credits}, '$push': {'history': {'plastic_type': plastic_type, 'credits': credits}}}
#        )
#        await websocket.send(json.dumps({'status': 'success', 'message': 'Credits updated'}))

#def assign_credits(plastic_type):
#    credit_map = {'PET': 10, 'HDPE': 15, 'PVC': 5}
 #   return credit_map.get(plastic_type, 0)

# REST API for user registration and login
@app.route('/register', methods=['POST'])
def register():
    data = request.json
    fullname = data['fullname']
    email = data['email']
    password = data['password']

    # Check if user already exists
    if users.find_one({'email': email}):
        return jsonify({'status': 'error', 'message': 'User already exists'}), 400

    # Create a new user
    hashpwd = verify_hash(password)  # Corrected variable name
    users.insert_one({'fullname': fullname, 'email': email, 'password': hashpwd, 'credits': 0, 'history': []})
    return jsonify({'status': 'success', 'message': 'User registered successfully'}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data['email']
    password = data['password']

    user = users.find_one({'email': email})
    if user and verfiy_pwd(password, user['password']):  # Verifying hashed password
        return jsonify({'status': 'success', 'credits': user['credits'], 'history': user['history']}), 200
    return jsonify({'status': 'error', 'message': 'Invalid credentials'}), 400

# Start the Flask server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

# Start the WebSocket server
#start_server = websockets.serve(detect_plastic, "0.0.0.0", 5678)
#asyncio.get_event_loop().run_until_complete(start_server)
#asyncio.get_event_loop().run_forever()
