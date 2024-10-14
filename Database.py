from pymongo import MongoClient

client = MongoClient('mongodb+srv://fino:fino@cluster0.ko0stef.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0')
dbcl = client['pwrcs']
usrcolletion = dbcl['user']

