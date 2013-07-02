import os
import socket
import sys
import traceback
import paramiko

def remote_exec(hostname, cmd):
    # setup logging
    paramiko.util.log_to_file('demo.log')
    
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

if __name__ == "__main__":
    cmd = 'bench/hackbench/hackbench 10 thread 3000 > ./ssh.log'
    remote_exec('127.0.0.1', cmd)
