
from __future__ import print_function

import os
from flask import Flask, json
import redis
import astropy.io
import astropy.io.ascii

redis_server = os.getenv("REDIS_HOST") or "127.0.0.1"
redis_conn = redis.StrictRedis(redis_server)

app = Flask(__name__)

def load_field_table(filename):
    f = astropy.io.ascii.read(filename, format="fixed_width", delimiter="|")
    field_dict = {field: (ra, dec) for field, ra, dec in zip(f['ID'], f['RA'], f['Dec'])}
    return field_dict

field_dict = load_field_table("ZTF_Fields.txt")


@app.route("/raw_visits")
def raw_visits():
    visits = redis_conn.zrevrangebyscore("visits", "+inf", "-inf", start=0, num=10)
    return json.dumps([str(x, 'utf-8') for x in visits])

@app.route("/visits")
def visits():
    field_names = ['alertcount', 'field', 'filter', 'programid', 'firstseen', 'lastseen']
    visit_ids = redis_conn.zrevrangebyscore("visits", "+inf", "-inf", start=0, num=20)
    combined_visits = []
    for visit_id in visit_ids:
        visit_out = {}
        visit_out['visit'] = str(visit_id, 'utf-8')
        for field_name in field_names:
            field_string = "{:s}_{:s}".format(str(visit_id, 'utf-8'), field_name)
            bytes_out = redis_conn.get(field_string)
            visit_out[field_name] = str(redis_conn.get(field_string),'utf-8') if bytes_out else ""
            if field_name == 'field':
                field_int = int(visit_out[field_name])
                visit_out['RA'], visit_out['Dec'] = field_dict[field_int]
        combined_visits.append(visit_out)

    return json.dumps(combined_visits)


@app.route('/')
def static_file():
    return app.send_static_file('index.html')
