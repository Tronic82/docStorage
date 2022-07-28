from flask import Flask

def create_app():
    app = Flask(__name__)

    app.config.update(
    #set max content to 1MB
    MAX_CONTENT_LENGTH=8 * 1024 * 1024,
    ALLOWED_EXTENSIONS=set(['png', 'jpg', 'jpeg', 'gif', 'pdf', 'txt'])
    )

    return app