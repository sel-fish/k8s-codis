#!/usr/bin/env python

from jinja2 import Environment, FileSystemLoader
import os, sys

if __name__ == '__main__' :
    if len(sys.argv) <= 1:
        print "usage: renderConfigFile.py $filename $args"
        sys.exit(-1)

    THIS_DIR = os.path.dirname(os.path.abspath(__file__))
    j2_env = Environment(loader=FileSystemLoader(THIS_DIR), trim_blocks=True)

    filename = sys.argv[1]
    template = j2_env.get_template(filename)

    argnum = len(sys.argv) - 2
    args = {}

    i = 2
    while i < len(sys.argv):
        arg = sys.argv[i]
        fields = arg.split('=')

        if 2 != len(fields):
            raise Exception("illegal arg: " + arg)

        value = fields[1]
        # test is "True" or "False"
        if value == "True":
            value = True
        elif value == "False":
            value = False

        args[fields[0]] = value
        i = i + 1

    output_from_parsed_template = template.render(args)
    print output_from_parsed_template
