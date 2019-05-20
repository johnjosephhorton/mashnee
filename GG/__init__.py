import os
import subprocess

import tempfile
import json

from shutil import copyfile
from distutils.dir_util import copy_tree
    
from flask import Flask
from flask import render_template
from flask import send_file
from flask import request

from trulia import GetData

def root_dir():  # pragma: no cover
    return os.path.abspath(os.path.dirname(__file__))

app = Flask(__name__)


# Eventually, do these dynamically 
static_dir = os.path.join(root_dir(), "static")
template_dir = os.path.join(root_dir(), "templates")
report_dir = os.path.join(root_dir(), "../report")

@app.route("/")
def hello():
    # landing page for Galton Gauss 
    user = {'username': 'Robin'}
    return render_template('welcome.html', title = 'Home', user = user)

@app.route("/enter_properties")
def properties():
    return render_template("enter_properties.html")

@app.route("/report")
def report():
    d = tempfile.mkdtemp(prefix='tmp')
    copy_tree(report_dir, d) # copies the report to the temporary directory
    cmd = ['make', '-C', os.path.join(d, "writeup"), "-B", "report.pdf"] # runs make to build the report
    build_log = subprocess.check_output(cmd)
    copyfile(os.path.join(d, "writeup/report.pdf"), os.path.join(static_dir, "report.pdf")) # copies out the report 
    static_file = os.path.join(static_dir,"report.pdf")
    return send_file(static_file, attachment_filename='report.pdf')

@app.route('/store_urls', methods=['POST'])
def handle_data():
    target_url = request.form['target_url']
    target_data = GetData(target_url)
    url_1 = request.form['comp_url_1']
    #for url in projectpath:
    #    print(url)
    return json.dumps(target_data)
    
if __name__ == "__main__":
    app.run()
    
