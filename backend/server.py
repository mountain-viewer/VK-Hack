import json
import os
import sys
from flask import Flask, request, url_for
from flask import jsonify
import numpy as np
import cv2
from skimage import io
import functions
import pandas as pd
import time
import copy


from werkzeug.serving import WSGIRequestHandler

app = Flask(__name__, static_url_path='', static_folder='./')
app.config.from_object(__name__)

app.config['JSON_AS_ASCII'] = False

matches_info_db = pd.read_csv('./Data/matches_info.csv')
with open("./Data/teams_info.json") as f:
    teams_info_db = json.load(f)
    
match_info_global = {}

@app.route('/auth/get_teams', methods=['GET', 'POST'])
def get_teams():
#     print("args:", request.args)
    form = request.form.to_dict()
    print(form.keys())
    if "groups" in form:
        group_info = form["groups"].lower()
    else:
        group_info = []
    detected_teams = []
    for team in teams_info_db.keys():
        if team in group_info:
             detected_teams.append(team)
    resp = []
    for team in detected_teams:
        resp.append(teams_info_db[team])
    
    print(resp)
    if len(resp) >= 1:
        resp = resp[0]
        team = detected_teams[0]
    if len(resp) == 0:
        resp = teams_info_db["зенит"]
        team = "зенит"
        
    team_name = teams_info_db[team]["id"]
    
    resp["screen_3_logo"] = "http://95.213.37.132:5000/static/grads/{}.jpg".format(team_name.replace(" ", "_"))
    resp["screen_3_text"] = functions.return_feed_info(team)
    return jsonify(resp)


@app.route('/geo/initial_fetch', methods=['GET', 'POST'])
def get_match_info():
    input_params = request.args.to_dict()
    print(input_params["lat"])
    input_params["lat"] = float(input_params["lat"])
    input_params["lon"] = float(input_params["lon"])
    input_params["time"] = time.time()
    match_info = functions.return_closest_match_info(input_params, matches_info_db)
    match_info["match_current_time"] = int(np.clip((time.time() - match_info["match_start_time"]) // 60, 0, 90))
    global match_info_global
    match_info_global = match_info
    return jsonify(match_info)


@app.route('/geo/process_photo', methods=['GET', 'POST'])
def process_photo():
    choice = request.args["choice"]
    print("choice", choice)
    filestr = request.files['image'].read()
    nparr = np.fromstring(filestr, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    print(match_info_global)
    gifs_path = functions.generate_gifs(img, match_info_global, choice)
    io.imsave("./test.jpg", img)
    return jsonify(gifs_path)

@app.route("/<path:path>", methods=['GET'])
def images(path):
    resp = flask.make_response(open(path).read())
    resp.content_type = "image/jpeg"
    return resp


@app.route('/quiz/get_stories', methods=['GET', 'POST'])
def qiuz_process_photo():
    true_answers = request.args["true_answers"]
    if int(true_answers) < 1:
        true_answers = 1
    print(true_answers)
    team_name = request.args["team_name"]
    if team_name in ["zenit", "lokomotiv"]:
        return jsonify(["http://95.213.37.132:5000/static/quiz/{}_{}.png".format(team_name, true_answers)])
    return jsonify(["http://95.213.37.132:5000/static/quiz/other_{}.png".format(true_answers)])


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)