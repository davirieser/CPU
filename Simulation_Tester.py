#!/bin/python3

import sys

try:
    from termcolor import colored, cprint
except:
    print("Please make sure termcolor is installed")
    sys.exit(1)

silent = True

class Handler:
    def __init__(self, pattern="", handler_function=(lambda x: print(x)), multiline=False):
        self.pattern = pattern
        self.__handler = handler_function
        self.multiline = multiline

    def handle(self, data):
        self.__handler(data)

print_handlers = [
    Handler(pattern="Analyzing Package-File ", handler_function=(lambda x: cprint(f"Package : <{x}>", "blue")), multiline=True),
    Handler(pattern="Ignoring Testbench ", handler_function=(lambda x: 0), multiline=False),
    Handler(pattern="Analyzing and elobarating ", handler_function=(lambda x: cprint(f"Analyzing and elobarating : <{x}>", "yellow")), multiline=True),
    Handler(pattern="Running Simulation for ", handler_function=(lambda x: cprint(f"Running : <{x}>", "grey")), multiline=True),
    Handler(pattern="ghdl -a ", handler_function=(lambda x: cprint(f"Analyzing : <{x}>", "magenta")), multiline=True),
    Handler(pattern="ghdl -e ", handler_function=(lambda x: cprint(f"Elaborating : <{x}>", "cyan")), multiline=True),
    Handler(pattern="ghdl -r ", handler_function=(lambda x: handle_run_command(data=x, silent=False)), multiline=True)
]

silent_handlers = [
    Handler(pattern="Analyzing Package-File ", handler_function=(lambda x: 0), multiline=True),
    Handler(pattern="Ignoring Testbench ", handler_function=(lambda x: 0), multiline=False),
    Handler(pattern="Analyzing and elobarating ", handler_function=(lambda x: 0), multiline=True),
    Handler(pattern="Running Simulation for ", handler_function=(lambda x: 0), multiline=True),
    Handler(pattern="ghdl -a ", handler_function=(lambda x: 0), multiline=True),
    Handler(pattern="ghdl -e ", handler_function=(lambda x: 0), multiline=True),
    Handler(pattern="ghdl -r ", handler_function=(lambda x: handle_run_command(data=x)), multiline=True)
]

if (not silent):
    handlers = print_handlers
else:
    handlers = silent_handlers

def handle_run_command(data="", silent=True):
    global current_file
    if (data):
        for i in data.split(" "):
            if (not i.startswith("-")):
                current_file = i
        if (not silent):
            cprint(f"Running {current_file}", "green")

if __name__ == "__main__":

    multiline = ""
    current_file = ""
    error = False

    for _line in sys.stdin:
        line = multiline + _line.strip()
        handler_found = False
        for i in handlers:
            if (line.startswith(i.pattern)):
                data = line[len(i.pattern):]
                current_file = data
                if (not data.endswith("\\")):
                    i.handle(data)

                    multiline = ""

                    handler_found = True
                    break
                else:
                    multiline = line[:-1]
                    break

        if (line != ""):

            if ((not not multiline) or handler_found):
                continue

            if (current_file):
                cprint(f"Error occured in <{current_file}> : \n{line}\n", "red")
            else:
                cprint(f"Unknown Error: {line}")
            error = True

    if (error):
        sys.exit(1)
    else:
        sys.exit(0)
