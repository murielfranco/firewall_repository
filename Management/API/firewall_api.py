#!/usr/bin/env python

import os
import json
from flask import jsonify
from eve import Eve
from eve.auth import BasicAuth, requires_auth
from subprocess import check_output, call
import time

# Verify status of os.system call
verify_status = lambda status: True if status == 0 else False

class FENDEAuth(BasicAuth):
    """username:password@link"""

    def check_auth(
            self, username, password, allowed_roles,
            resource, method):

        return username == 'fende' and \
               password == 'fende'


app = Eve()

@app.after_request
def after_request(response):
    response.headers.set('Access-Control-Allow-Original', '*')
    return response

@app.route('/drop/input/<input_addr>/<output_addr>')
@requires_auth(FENDEAuth)
def dropInput(input_addr, output_addr):
    status = os.system("iptables -I INPUT -i %s -s %s -j DROP" % (input_addr, output_addr))
    return jsonify({'success': verify_status(status)})

@app.route('/delete/input/<input_addr>/<output_addr>')
@requires_auth(FENDEAuth)
def deleteInput(input_addr, output_addr):
    status = os.system("iptables -D INPUT -i %s -s %s -j DROP" % (input_addr, output_addr))
    return jsonify({'success': verify_status(status)})

@app.route('/accept/port/<dport>/<protocol>')
@requires_auth(FENDEAuth)
def acceptPort(dport, protocol):
    status = os.system("iptables -A INPUT -p %s --dport %s -j ACCEPT" % (protocol, dport))
    return jsonify({'success': verify_status(status)})

@app.route('/clean')
@requires_auth(FENDEAuth)
def cleanRules():
    status = os.system("iptables -F")
    return jsonify({'success': verify_status(status)})

@app.route('/list')
@requires_auth(FENDEAuth)
def listRules():
    response = os.popen("iptables -L -v -n").read() # Return all rules
    content = response.replace('\n','<br>')
    return content


if __name__=='__main__':
    app.run(host='0.0.0.0', port=9999)

