import asyncio
import json
from aiohttp import web
from Database import usrcolletion
from funcs import verfiy_pwd,verify_hash

async def register(request):
    data = await request.json()
    fullname = data.get('fullname')
    email = data.get('email')
    password = data.gat('password')

    if usrcolletion.find_one({"email":email}):
        return web.json_response({"error":"E-Mail Is Already Registered"}, status=400)
    
    hashpawd = verify_hash(password)
    usrdata = {"fullname":fullname,"email":email,"password":hashpawd}
    usrcolletion.insert_one(usrdata)

    return web.json_response({"msg":"User Registered Successfully"})


async def login(request):
    data = await request.json()
    email = data.get('email')
    password = data.get('password')

    dbuser = usrcolletion.find_one({'email':email})

    if not dbuser or not verfiy_pwd(password,dbuser['password']):
        return web.json_response({'error':'Incorrect Credentials'},status=400)
    
    return web.json_response({"msg":"Login Successfully", "userid":str(dbuser['_id'])})
