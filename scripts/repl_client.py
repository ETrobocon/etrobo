#!/usr/bin/env python3
#  repl_client.py : MicroPython REPL client for Spike Hub
# Author: jtFuruhata
# Copyright (c) 2022 ETロボコン実行委員会, Released under the MIT license
# See LICENSE  

import serial
import sys
import time

# const REPL control commands
ENTER_REPL = '>>> REPL' # enter REPL paste mode
EXEC_REPL  = '=== EXEC' # execute paste commands

RAW_REPL   = b'\x01' # turn onto raw REPL mode
NORMAL_REPL= b'\x02' # turn onto normal REPL mode
CANCEL     = b'\x03' # cancel execution
SOFT_RESET = b'\x04' # do soft reset or exec pasted statements
PASTE      = b'\x05' # turn onto paste mode

# catch args
ttyd = '/dev/ttyACM0'
cmds = ''
tout = 0
if len(sys.argv) > 1:
    ttyd = sys.argv[1]
if len(sys.argv) > 2:
    cmds = sys.argv[2]
if len(sys.argv) > 3:
    tout = int(sys.argv[3])

# connect to REPL console if possible
try:
    tty = serial.Serial(ttyd)
except serial.SerialException:
    print('Spike Hub is disconnected.')
    sys.exit(1)
tty.write_timeout = 1
tty.timeout = 0.1

# emit command
def emitCommand(cmd='', timeout=3):
    try:
        result = ''
        prompt = '=== '
        if cmd == ENTER_REPL:
            tty.write(CANCEL)
            tty.write(PASTE)
            prompt = '=== '
        elif cmd == EXEC_REPL:
            tty.write(SOFT_RESET)
            prompt = '>>> '
        else:
            tty.write((cmd+'\r\n').encode())
        # waiting for response
        while tty.in_waiting < 3 and timeout > 0:
            time.sleep(0.001)
        # read response
        start = time.time()
        while (time.time() - start) < timeout:
            if tty.in_waiting > 0:
                start = time.time()
                response = tty.readline().decode()
                if response.startswith(prompt):
                    start = 0
                    response = response[3:]
                elif response.strip() != cmd.strip():
                    result += response
            time.sleep(0.001)
        if start > 0:
            raise serial.SerialTimeoutException
        return result
    except Exception as e:
        tb = sys.exc_info()[2]
        print(e.with_traceback(tb))
        raise serial.SerialTimeoutException

# main block
try:
    response = emitCommand(cmds, 3 if tout == 0 else tout)
    if len(response.split()) > 0:
        print(response)
except serial.SerialTimeoutException:
    print("WARNING: REPL response timeout or an error is occured")
    sys.exit(1)
