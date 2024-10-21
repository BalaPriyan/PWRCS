from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from pymongo import MongoClient
from passlib.context import CryptContext
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity

# Flask app setup
app = Flask(__name__)
CORS(app)  # Allow cross-origin requests

# Secret key for JWT
app.config['JWT_SECRET_KEY'] = 'asdfghjklpoiuytrewqzxcvbnm'  # Change this to a random secret key
jwt = JWTManager(app)

# Hashing System For Password
pwd_cont = CryptContext(schemes=['bcrypt'], deprecated="auto")  # Text To Hash

def verfiy_pwd(plain_pwd, hash_pwd):  # Verifying Password
    return pwd_cont.verify(plain_pwd, hash_pwd)

def verify_hash(password):  # Hashing The Password
    return pwd_cont.hash(password)

# MongoDB setup
client = MongoClient("mongodb+srv://fino:fino@cluster0.ko0stef.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
db = client['pwrcs']
users = db['users']

@app.route('/')
def home():
    return render_template('index.html')

# REST API for user registration
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
    hashpwd = verify_hash(password)  # Hash the password
    users.insert_one({'fullname': fullname, 'email': email, 'password': hashpwd, 'credits': 0, 'history': []})
    return jsonify({'status': 'success', 'message': 'User registered successfully'}), 201

# REST API for user login
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data['email']
    password = data['password']

    user = users.find_one({'email': email})
    if user and verfiy_pwd(password, user['password']):  # Verifying hashed password
        access_token = create_access_token(identity={'email': email})  # Generate JWT token
        return jsonify({'status': 'success', 'access_token': access_token}), 200
    return jsonify({'status': 'error', 'message': 'Invalid credentials'}), 400

# Protected route to retrieve user data (requires a valid JWT)
@app.route('/getUserData', methods=['POST'])
@jwt_required()  # JWT protection
def get_user_data():
    current_user = get_jwt_identity()  # Get the current user's identity from JWT
    user = users.find_one({'email': current_user['email']}, {'_id': 0})  # Exclude '_id' field from the response

    if user:
        return jsonify(user), 200  # Return user data as JSON
    return jsonify({'status': 'error', 'message': 'User not found'}), 404

# Start the Flask server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
