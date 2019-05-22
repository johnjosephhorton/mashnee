import os
import subprocess
import datetime

import tempfile
import json

from shutil import copyfile
from distutils.dir_util import copy_tree
    
from flask import Flask
from flask import render_template
from flask import send_file
from flask import request

from zillow import GetData

from db import init_app
from db import get_db


def root_dir():  # pragma: no cover
    return os.path.abspath(os.path.dirname(__file__))

def create_app():
    app = Flask(__name__, instance_relative_config=True)
    # existing code omitted

    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(app.instance_path, 'GG.sqlite'),
    )

    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    init_app(app)

    return app

app = create_app()


# Eventually, do these dynamically 
static_dir = os.path.join(root_dir(), "static")
template_dir = os.path.join(root_dir(), "templates")
report_dir = os.path.join(root_dir(), "../report")

full_db_path = os.path.join(root_dir(), "../instance/GG.sqlite")

completed_report_folder = os.path.join(root_dir(), "../completed_reports")

@app.route("/")
def hello():
    return render_template('welcome.html')

@app.route("/enter_properties")
def properties():
    urls = ['https://www.zillow.com/homedetails/210-Clipper-Rd-Bourne-MA-02532/186978102_zpid/',
         'https://www.zillow.com/homedetails/188-Captains-Row-Bourne-MA-02532/186978104_zpid/']
    return render_template("enter_properties.html", urls = urls)

@app.route("/report/<report_id>")
def report(report_id):
    d = tempfile.mkdtemp(prefix='tmp')
    copy_tree(report_dir, d) # copies the report to the temporary directory
    ## Copy over a configuration file w/ order number
    lines = ['order.number <- ' + report_id, "path.to.db <- '%s'" % full_db_path]
    with open(os.path.join(d, "analysis/config.R"),  'w') as the_file:
        the_file.write("\n".join(lines))
    cmd = ['make', '-j', '-C', os.path.join(d, "writeup"), "-B", "report.pdf"] # runs make to build the report
    build_log = subprocess.check_output(cmd)
    copyfile(os.path.join(d, "writeup/report.pdf"), os.path.join(static_dir, "report.pdf")) # copies out the report 
    static_file = os.path.join(static_dir,"report.pdf")
    return send_file(static_file, attachment_filename='report.pdf')

@app.route('/see_reports')
def see_reports():
    db = get_db()
    cur = db.cursor()
    cur.execute("select o.*, p.address from orders as o left join properties as p on o.id = p.order_id and comp = 0 order by o.id desc;")
    orders = cur.fetchall()
    print(orders)
    return render_template("reports.html", orders = orders)

@app.route("/see_comps/<order_id>")
def see_comps(order_id):
    db = get_db()
    cur = db.cursor()
    cur.execute("select p.*, u.url from properties as p join urls as u on u.id = p.url_id where p.order_id = ? and comp = 1", order_id)
    comps = cur.fetchall()
    return render_template("comps.html", comps = comps, order_id = order_id)

@app.route('/store_urls', methods=['POST'])
def handle_data():
    db = get_db()
    cur = db.cursor()
    cur.execute("INSERT INTO orders (username, property_name) VALUES ('John', 'Test');")
    db.commit()
    order_id = cur.lastrowid
    raw_urls = [x.rstrip() for x in request.form['urls'].split("\n")]
    urls = []
    for url in raw_urls:
        if url != '':
            urls.append(url)
    is_comp = False
    for url in urls:
        cur.execute("INSERT INTO urls (url, order_id) VALUES (?,?)", (url, order_id))
        url_id = cur.lastrowid
        p = GetData(url)
        address = p['streetAddress']
        state = p['state']
        city = p['city']
        latitude = p['latitude']
        longitude = p['longitude']
        yearBuilt = p['yearBuilt']
        homeType = p['homeType']
        lotSize = p['lotSize']
        square_feet = p['livingArea']
        bedrooms = p['bedrooms']
        baths = p['bathrooms']
        price = p['price']
        comp = is_comp
        is_comp = True
        fields = (url_id, address, state, city, latitude, longitude, yearBuilt, homeType, lotSize,
                     square_feet, bedrooms, baths, price, comp, order_id)
        cur.execute("""INSERT INTO properties (url_id, address, state, city, latitude, longitude, yearBuilt, homeType, lotSize, square_feet, 
                            bedrooms, baths, price, comp, order_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""", fields
                    )
        db.commit()
    return render_template("confirm_store_urls.html", order_id = order_id)

if __name__ == "__main__":
    app.run()
    
