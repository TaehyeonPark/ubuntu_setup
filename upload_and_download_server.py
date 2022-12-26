from flask import *
from flask_compress import *
from flask_cors import *
import os

app = Flask(__name__, template_folder='viewer')
app.secret_key = os.urandom(24)
Compress(app)
CORS(app)
path = "/backups"
destination="/download/"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload():
    files = []
    for i in request.files:
        file = request.files[i]
        file.save(destination + os.path.join(file.filename))
    return 'ok'

@app.route('/download', methods=['POST', 'GET'])
def download():
    file = request.args.get('file')
    dir = os.listdir(path)
    if file == None:
        return {'files': dir}
    else:
        if file in dir:
            return send_file(path + '/{}'.format(file))
        else:
            return {'files': dir}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
