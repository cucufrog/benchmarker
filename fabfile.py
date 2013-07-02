from fabric.api import *

env.user="ouyang"

def list_hosts():
    print env.hosts

def ping():
    run("hostname")

@parallel
def cmd(cmd):
    run(cmd)

def serial_cmd(cmd):
    run(cmd)

def sudo_cmd(cmd):
    sudo(cmd)
