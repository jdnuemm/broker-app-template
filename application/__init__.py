import os
from flask import Flask, render_template, g
app = Flask(__name__)
app.config.from_envvar('SETTINGS')


@app.before_request
def before_request():
    g.config = app.config


@app.route('/')
def index():
    return render_template('index.html')
