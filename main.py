import json
from pprint import pprint
import os
import socket
import sys
import traceback
import paramiko
import threading

class Worker(threading.Thread):
    def __init__(self, hostname, cmd):
        threading.Thread.__init__(self)
        self.hostname = hostname
        self.cmd = cmd

    def run(self):
        # setup logging
        paramiko.util.log_to_file('demo.log')
        
        hostname = self.hostname
        cmd = self.cmd
        username = 'ouyang'
        port = 22
        
        # now connect
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((hostname, port))
        except Exception, e:
            print '*** Connect failed: ' + str(e)
            traceback.print_exc()
            sys.exit(1)
        
        try:
            t = paramiko.Transport(sock)
            try:
                t.start_client()
            except paramiko.SSHException:
                print '*** SSH negotiation failed.'
                sys.exit(1)
        
            path = os.path.join(os.environ['HOME'], '.ssh', 'id_rsa')
            try:
                key = paramiko.RSAKey.from_private_key_file(path)
            except paramiko.PasswordRequiredException:
                password = getpass.getpass('RSA key password: ')
                key = paramiko.RSAKey.from_private_key_file(path, password)
            t.auth_publickey(username, key)
            if not t.is_authenticated():
                print '*** Authentication failed. :('
                t.close()
                sys.exit(1)
        
            chan = t.open_session()
            chan.exec_command(cmd)
            chan.recv_exit_status()
            chan.close()
            t.close()
        
        except Exception, e:
            print '*** Caught exception: ' + str(e.__class__) + ': ' + str(e)
            traceback.print_exc()
            try:
                t.close()
            except:
                pass
            sys.exit(1)

def main():
    cmd = 'bench/hackbench/hackbench 10 thread 3000 > ./ssh.log'
    json_file = open('config.json')
    config = json.load(json_file)
    json_file.close()
    pprint(config)

    thread_test = Worker(config["localhost"]["ip"], cmd)
    thread_test.start()
    thread_test.join()
    #for guest in config["guest"]:
    #    remote_exec(guest["ip"], cmd)

if __name__ == "__main__":
    main()

