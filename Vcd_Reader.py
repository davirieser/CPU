
import sys
import json
import pprint
import regex

import warnings
from enum import Enum

pp = pprint.PrettyPrinter(indent=4)

time_scale_regex = regex.compile(r"\s*(?P<value>[0-9]+)\s*(?P<scale>[a-zA-Z]+)")

class Wire:
    def __init__(
        self,
        name = "Unknown Signal",
        identifier = "Unknown Identifier",
        type = "Unknown Type",
        scope = "top"
    ):
        self.__name = name
        self.__identifier = identifier
        self.__type = type
        self.__data = []
        self.__scope = scope
        return

    def append_data(self, new_data):
        self.__data.append(new_data)

    def return_name(self):
        return self.__name

    def return_type(self):
        return self.__type

    def return_identifier(self):
        return self.__identifier

    def return_data(self):
        return self.__data

    def return_scope(self):
        return self.__scope

    def format(self, print_data = False):
        if print_data:
            return f"{self.__name} ({self.__type}) <{self.__identifier}> in {self.__scope} : {self.__data}"
        else:
            return f"{self.__name} ({self.__type}) <{self.__identifier}> in {self.__scope}"

    def from_string(scope = "top", string="$var reg 1 ! test $end"):
        stripped = string.rstrip("\r\n")
        if (stripped.startswith("$var") and stripped.endswith("$end")):
            split = stripped[5:-5].split(" ")
            i = split[3].find("[")
            if (i != -1):
                name = split[3][:i]
                type = split[3][i:]
            else:
                name = split[3]
                type = "boolean"
            return Wire(
                name = name,
                identifier = split[2],
                type = type,
                scope = scope
            )
        else:
            warnings.warn(f"Unconvertable Signal : {string}")
            return

class WireType(Enum):
    Signal = 0
    Array = 1

class StandardLogic(Enum):
    Uninitialized = 0
    Unknown = 1
    Low = 2
    High = 3
    HighImpedance = 4
    Weak = 5
    WeakLow = 6
    WeakHigh = 7
    DontCare = 8

    def from_string(string):
        if (string == 'X'):
            return StandardLogic.Unknown
        elif (string == '0'):
            return StandardLogic.Low
        elif (string == '1'):
            return StandardLogic.High
        elif (string == 'Z'):
            return StandardLogic.HighImpedance
        elif (string == 'W'):
            return StandardLogic.Weak
        elif (string == 'L'):
            return StandardLogic.WeakLow
        elif (string == 'H'):
            return StandardLogic.WeakHigh
        elif (string == '-'):
            return StandardLogic.DontCare
        else:
            return StandardLogic.Uninitialized

    def to_string(self):
        if (self == StandardLogic.Unknown):
            return 'X'
        elif (self == StandardLogic.Low):
            return '0'
        elif (self == StandardLogic.High):
            return '1'
        elif (self == StandardLogic.HighImpedance):
            return 'Z'
        elif (self == StandardLogic.Weak):
            return 'W'
        elif (self == StandardLogic.WeakLow):
            return 'L'
        elif (self == StandardLogic.WeakHigh):
            return 'H'
        elif (self == StandardLogic.DontCare):
            return '-'
        else:
            return "U"

def analyze_file(file_name, file_contents):

    if file_name.endswith(".vcd"):
        return analyze_vcd_file(file_contents)
    else:
        warnings.warn("Can't analyze \"." + file_name.split(".")[-1] + "\"-File")
        return []

def analyze_vcd_file(file_contents):

    # Remove last line which is only Newline
    lines = iter(file_contents.split("\n")[:-1])

    variables = []
    current_scope = "top"

    timescale = 1e-15 #  Default to 1 fs

    section = "headers"

    current_time = 0

    while True:
        try:
            line = next(lines)
        except:
            break
        if (section == "headers"):
            split = line.split(" ")
            if (split[0] == "$var"):
                variables.append(Wire.from_string(current_scope, line))
            elif (split[0] == "$timescale"):
                timescale = to_timescale(next(lines))
            elif (split[0] == "$scope"):
                current_scope = split[2]
            elif (split[0] == "$enddefinitions"):
                section = "content"
            else:
                # Ignore
                pass
        elif (section == "content"):
            if (line.startswith("#")):
                current_time = int(line.rstrip("\r\n")[1:]) * timescale
            elif (line.startswith("b")):
                data = []
                for i in line.rstrip("\r\n")[1:-2]:
                    data.append(StandardLogic.from_string(i))
                identifier = line.rstrip("\r\n")[-1]

                for i in variables:
                    if (identifier == i.return_identifier()):
                        i.append_data({current_time: data})
                        break
            else:
                data = line.rstrip("\r\n")[0]
                identifier = line.rstrip("\r\n")[1]

                for i in variables:
                    if (identifier == i.return_identifier()):
                        i.append_data({current_time: data})
                        break

    return variables

def to_timescale(string):
    matches = time_scale_regex.match(string)
    value = int(matches.group("value"))
    scale = matches.group("scale")
    if (scale == "f"):
        return value * 1e-15
    elif(scale == "p"):
        return value * 1e-12
    elif(scale == "n"):
        return value * 1e-9
    elif(scale == "u"):
        return value * 1e-6
    elif(scale == "m"):
        return value * 1e-3
    elif(scale == "sec"):
        return value
    elif(scale == "min"):
        return value * 60
    elif(scale == "hr"):
        return value * 60 * 60
    return 1e-15 # Return 1 fs as Default

if __name__ == "__main__":

    if (len(sys.argv) > 1):

        for i in sys.argv[1:]:

            with open(i, "r") as f:

                lines = f.read()

                variables = analyze_file(i, lines)

                for i in variables:
                    print(i.format())

                print()

    else:
        print("Please supply VCD or GHW Files to analyze")
