import sys
import json
import time

k = 0
try:
    buff = ''
    while True:
        buff += sys.stdin.read(1)
        if buff.endswith('\n'):
            tree = json.loads(buff[:-1])
            match tree["message"]:
                case "begin":
                    pass
                case "end":
                    if "payload" in tree:
                        print("FINAL: " + tree["payload"]["data"]);
                case "exit":
                    pass
                case "update":
                    if "payload" in tree:
                        print(tree["payload"]["data"])
                case _:
                    sys.exit(-1)
            buff = ''
            k = k + 1
except KeyboardInterrupt:
   sys.stdout.flush()
   pass
