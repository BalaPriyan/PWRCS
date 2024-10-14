from pydantic import BaseModel
from passlib.context import CryptContext


#Hashing System For Password
pwd_cont = CryptContext(schemes=['bcrypt'], deprecated="auto") #Text To Hash

def verfiy_pwd(plain_pwd,hash_pwd):#Verifying Password
    return pwd_cont.verify(plain_pwd,hash_pwd)

def verify_hash(password):#Hasjing The Password
    return pwd_cont.hash(password)


#Models For login And Sign Up
class UserCreate(BaseModel):#Register New User
    fullname: str
    email: str
    password: str

class LoginUser(BaseModel):#Login To Existing User
    email: str
    password: str