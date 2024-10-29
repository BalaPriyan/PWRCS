import os
import threading
import uuid
import re
import qrcode
from io import BytesIO
from flask import Flask, request, jsonify, render_template,send_file
from flask_cors import CORS
from pymongo import MongoClient
from passlib.context import CryptContext
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from dotenv import load_dotenv
from bson.objectid import ObjectId
import cv2
import torch

load_dotenv()

app = Flask(__name__)
CORS(app)

app.config['JWT_SECRET_KEY'] = os.getenv("JWT_SECRET_KEY", 'asdfghjklpoiuytrewqzxcvbnm')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = 36000
jwt = JWTManager(app)

pwd_cont = CryptContext(schemes=['bcrypt'], deprecated="auto")

client = MongoClient(os.getenv("MONGO_URI", "mongodb+srv://fino:fino@cluster0.ko0stef.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"))
db = client['pwrcs']
users = db['users']

connections = {}

def verify_pwd(plain_pwd, hash_pwd):
    return pwd_cont.verify(plain_pwd, hash_pwd)

def hash_password(password):
    return pwd_cont.hash(password)

def validate_email(email):
    email_regex = r'^\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    return re.match(email_regex, email) is not None

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    fullname = data.get('fullname')
    email = data.get('email')
    password = data.get('password')

    if not (fullname and email and password):
        return jsonify({'status': 'error', 'message': 'All fields are required'}), 400

    if not validate_email(email):
        return jsonify({'status': 'error', 'message': 'Invalid email format'}), 400

    if len(password) < 6:
        return jsonify({'status': 'error', 'message': 'Password must be at least 6 characters long'}), 400

    try:
        if users.find_one({'email': email}):
            return jsonify({'status': 'error', 'message': 'User already exists'}), 400

        hashpwd = hash_password(password)
        users.insert_one({'fullname': fullname, 'email': email, 'password': hashpwd, 'credits': 0, 'history': []})
        return jsonify({'status': 'success', 'message': 'User registered successfully'}), 201
    except Exception as e:
        return jsonify({'status': 'error', 'message': f'Error registering user: {str(e)}'}), 500

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    try:
        user = users.find_one({'email': email})
        if user and verify_pwd(password, user['password']):
            access_token = create_access_token(identity={'email': email})
            return jsonify({'status': 'success', 'access_token': access_token}), 200
        return jsonify({'status': 'error', 'message': 'Invalid credentials'}), 401
    except Exception as e:
        return jsonify({'status': 'error', 'message': f'Error during login: {str(e)}'}), 500

@app.route('/getUserData', methods=['POST'])
def get_user_details():
    data = request.get_json()
    user_id = data.get('userId')

    try:
        # Fetch user data from MongoDB
        user = users.find_one({'_id': ObjectId(user_id)})
        
        if user:
            # Convert MongoDB document to dictionary and remove _id field
            user_data = {
                'fullname': user.get('fullname'),
                'email': user.get('email'),
                'credits': user.get('credits')
            }
            return jsonify({'user': user_data}), 200
        else:
            return jsonify({'message': 'User not found'}), 404

    except Exception as e:
        return jsonify({'message': 'Error fetching user data', 'error': str(e)}), 500
    

valid_qr_codes = {}

@app.route('/generate_qr', methods=['GET'])
def generate_qr():
    connection_id = str(uuid.uuid4())
    connections[connection_id] = None
    pin = '1234'  # Or generate a random PIN if needed
    valid_qr_codes[connection_id] = pin

    # Update the QR code URL to point to the new endpoint
    qr_data = f"http://10.100.3.34:5000/qr_connect?connection_id={connection_id}&pin={pin}"
    qr = qrcode.make(qr_data)
    img_io = BytesIO()
    qr.save(img_io, 'PNG')
    img_io.seek(0)

    return send_file(img_io, mimetype='image/png', as_attachment=False)

@app.route('/qr_connect', methods=['GET'])
def qr_connect():
    connection_id = request.args.get('connection_id')
    pin = request.args.get('pin')
    

    user_id = "6714f151ce6ce27288a18b69"

    if pin == '1234':
        connection_id = str(uuid.uuid4())
        connections[connection_id] = str(user_id)
        threading.Thread(target=start_detection, args=(connection_id,)).start()
        return jsonify({'message': f'Connected successfully with Connection ID: {connection_id}', 'connectionId': connection_id}), 200
    else:
        return jsonify({'message': 'Invalid PIN'}), 400


@app.route('/validate_qr', methods=['POST'])
def validate_qr():
    data = request.json
    connection_id = data.get('connection_id')
    pin = '1234'

    if connection_id in valid_qr_codes and valid_qr_codes[connection_id] == pin:
        return jsonify({'status': 'valid', 'connection_id': connection_id}), 200
    else:
        return jsonify({'status': 'invalid'}), 400



@app.route('/connect', methods=['POST'])
def connect():
    data = request.get_json()
    pin = data.get('pin')
    user_id = "6714f151ce6ce27288a18b69"

    if pin == '1234':
        connection_id = str(uuid.uuid4())
        connections[connection_id] = str(user_id)
        threading.Thread(target=start_detection, args=(connection_id,)).start()
        return jsonify({'message': f'Connected successfully with Connection ID: {connection_id}', 'connectionId': connection_id}), 200
    else:
        return jsonify({'message': 'Invalid PIN'}), 400
    

@app.route('/detect', methods=['POST'])
def on_bottle_detected():
    data = request.json
    connection_id = data.get('connection_id')
    credits = data.get('credits')

    user_id = "6714f151ce6ce27288a18b69"
    if user_id:
        users.update_one({'_id': ObjectId(user_id)}, {'$inc': {'credits': credits}})
        return jsonify({'status': 'success', 'message': f'Credits updated for user with connection ID {connection_id}.'}), 200
    return jsonify({'status': 'error', 'message': 'Invalid connection ID.'}), 404

@app.route('/credit', methods=['POST'])
def find_credit():
    data = request.json
    connection_id = data.get('connection_id')
    credits = data.get('credits')

    user_id = "6714f151ce6ce27288a18b69"
    if user_id:
        users.insert_one({'_id': ObjectId(user_id)}, {'$inc': {'credits': credits}})
        return jsonify({'status': 'success', 'message': f'Credits updated for user with connection ID {connection_id}.'}), 200
    return jsonify({'status': 'error', 'message': 'Invalid connection ID.'}), 404

@app.route('/finish', methods=['POST'])
@jwt_required()
def finish():
    data = request.json
    amount = data.get('amount')

    email = "balapriyan@gmail.com"

    if amount <= 0:
        return jsonify({'status': 'error', 'message': 'Amount must be greater than zero.'}), 400

    try:
        user = users.find_one({'email': email})
        if user:
            new_credit_balance = user.get('credits', 0) + amount
            users.update_one({'email': email}, {'$set': {'credits': new_credit_balance}})
            return jsonify({'status': 'success', 'message': f'Credit of {amount} has been added successfully.', 'new_balance': new_credit_balance}), 200
        return jsonify({'status': 'error', 'message': 'User not found.'}), 404

    except Exception as e:
        return jsonify({'status': 'error', 'message': f'Error updating credits: {str(e)}'}), 500

def start_detection(connection_id):
    model = torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True)
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1080)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

    focal_length = 400
    real_height = 0.1
    max_distance = 0.3

    credited_status = {} 

    if not cap.isOpened():
        print("Error: Could not open video stream.")
        return

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Failed to grab frame")
            break

        results = model(frame)

        for *box, conf, cls in results.xyxy[0]:
            if int(cls) == 39: 
                x1, y1, x2, y2 = map(int, box)
                width = x2 - x1
                height = y2 - y1
                
                distance = (real_height * focal_length) / height
                if distance <= max_distance and connection_id not in credited_status:
                    credits = calculate_credits(width, height)
                    
                  
                    with app.test_request_context('/detect', method='POST', json={'connection_id': connection_id, 'credits': credits}):
                        response = on_bottle_detected() 
                    
                    credited_status[connection_id] = True 
                    
                    cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                    cv2.putText(frame, f'Bottle: {conf:.2f}, Credits: {credits}', (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 0, 0), 2)

     
                    cap.release()
                    cv2.destroyAllWindows()
                    return 

        cv2.imshow('Live Plastic Bottle Detection', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()


def calculate_credits(width, height):
    area = width * height
    if area < 10000:
        return 1
    elif 10000 <= area < 20000:
        return 2
    elif 20000 <= area < 30000:
        return 3
    elif 40000 <= area < 50000:
        return 4
    elif 50000 <= area < 600000:
        return 5
    elif 60000 <= area < 70000:
        return 6
    elif 70000 <= area < 80000:
        return 7
    elif 80000 <= area < 90000:
        return 8
    elif 90000 <= area < 100000:
        return 9
    else:
        return 10

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv("PORT", 8080)), debug=True)
