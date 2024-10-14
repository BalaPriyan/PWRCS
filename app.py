from aiohttp import web
from byroute import register,login

app = web.Application()
app.router.add_post('/register',register)
app.router.add_post('/login',login)

if __name__ == "__main__":
    web.run_app(app,host='0.0.0.0',port=8080)
