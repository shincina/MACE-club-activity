import os
class Config:
    SECRET_KEY = 'mace_secret_2024'
    MYSQL_HOST = 'localhost'
    MYSQL_USER = 'root'
    MYSQL_PASSWORD = 'Shincina1$'
    MYSQL_DB = 'mace_activity_db'
    MYSQL_CURSORCLASS = 'DictCursor'


    BASE_DIR = os.path.abspath(os.path.dirname(__file__))

    UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
    MAX_CONTENT_LENGTH = 5 * 1024 * 1024
    ALLOWED_EXTENSIONS = {'pdf', 'png', 'jpg', 'jpeg'}