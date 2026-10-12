""" Gernetate documentation for config """
from pathlib import Path
import re
import subprocess as sp
from typing import List
import uuid
from jinja2 import Environment, FileSystemLoader

# pylint: disable=W1401

DOCKER_REPO = 'blcdsdockerregistry/openms-thirdparty:2.7.0pre'
MODULE_COMMANDS = {
        'find_features': {
            'command': 'FeatureFinderIdentification',
            'path': 'modules/find_features.nf'
        },
        'align_featureXML': {
            'command': 'MapAlignerIdentification',
            'path': 'modules/align_featureXML.nf'
        },
        'align_idXML': {
            'command': 'MapAlignerIdentification',
            'path': 'modules/align_idXML.nf'
        },
        'transform_rt': {
            'command': 'MapRTTransformer',
            'path': 'modules/transform_rt.nf'
        },
        'link_features': {
            'command': 'FeatureLinkerUnlabeledQT',
            'path': 'modules/link_features.nf'
        },
        'resolve_conflict': {
            'command': 'IDConflictResolver',
            'path': 'modules/resolve_conflict.nf'
        },
        'quantify_peptides': {
            'command': 'ProteinQuantifier',
            'path': 'modules/quantify_peptides.nf'
        }
    }

def get_command_args(path:Path):
    """ Read NF module source code and extract the arguments needed. """
    with open(path, 'rt') as handle:
        scopes = ['PARAMETER_MAPPER', 'FLAG_MAPPER']
        args = {}
        cur = None
        content = ''
        for line in handle:
            line = line.rstrip()
            if not cur:
                for scope in scopes:
                    if line.lstrip().startswith(scope):
                        cur = scope
                        break
            if not cur:
                continue
            content += line
            if line.endswith(']'):
                content = content.split('=')[1].strip().strip('[]').split(',')
                if content != [':']:
                    for item in content:
                        pattern = re.compile(r"'(.+)':\s*'(.+)'")
                        match = pattern.search(item)
                        val = match.group(1)
                        key = match.group(2)
                        args[key] = val
                if cur == 'FLAG_MAPPER':
                    return args
                cur = None
                content = ''
        return args

def wrap_text(val:str, width:int):
    """ Wrap text to certain width """
    left = val.split(' ')
    right = []
    while len(' '.join(left)) > width:
        right.append(left.pop(-1))
    right.reverse()
    return ' '.join(left), ' '.join(right)

def get_command_desc(command:str, args:List[str], docker_name, prefix:str=None):
    """ Get the paramter name, type, and description for the specified OpenMS
    command/program """
    # pylint: disable=R0914
    cmd = f"docker exec {docker_name} {command} --helphelp"
    print(cmd)
    res = sp.run(cmd, shell=True, capture_output=True, check=False)
    message = res.stderr.decode('utf-8')
    arg_desc = []
    for line in message.split('\n'):
        line = line.strip()
        if not line.startswith('-'):
            continue
        pattern1 = re.compile(r'^(-.+) <(.+?)>\*?\s+(.+)$')
        match = pattern1.search(line)
        if match:
            arg = match.group(1)
            _type = match.group(2)
            desc = match.group(3)
        else:
            pattern2 = re.compile(r'^(-\S+)\s+?(.+)$')
            match = pattern2.search(line)
            if not match:
                raise ValueError
            arg = match.group(1)
            _type = 'bool'
            desc = match.group(2)
        if not arg in args:
            continue
        if _type == 'decoy_string':
            _type = 'str'
        param = args[arg]
        if prefix:
            param = param.replace(prefix, '<>')
        arg_desc.append([param, f"({arg})", _type, desc])
    width_param = max(len(x[0]) for x in arg_desc)
    width_arg = max(len(x[1]) for x in arg_desc)
    width_type = max(len(x[2]) for x in arg_desc)

    width_arg = max([width_param, width_arg])

    width_desc = 100 - 13 - width_arg - width_type

    widths = [width_arg + 3, width_type + 3, width_desc + 3]

    table:List[List[List[str]]] = []
    for param in arg_desc:
        table.append([])
        left, param[3] = wrap_text(param[3], width_desc)
        table[-1].append([
            param[0].ljust(width_arg), param[2].ljust(width_type),
            left.ljust(width_desc)
        ])
        left, param[3] = wrap_text(param[3], width_desc)
        table[-1].append([
            param[1].ljust(width_arg), ' ' * width_type, left.ljust(width_desc)
        ])
        while len(param[3]) > width_desc:
            left, param[3] = wrap_text(param[3], width_desc)
            table[-1].append([
                ' ' * width_arg, ' ' * width_type, left.ljust(width_desc)
            ])
        table[-1].append([
            ' ' * width_arg, ' ' * width_type, param[3].ljust(width_desc)
        ])

    return widths, table

class OpenMSDockerImage():
    """ Open MS Docker Image """
    def __init__(self, repo:str):
        """ Constructure """
        self.repo = repo
        self.docker_id = str(uuid.uuid4())[:8]
    def __enter__(self):
        """ enter """
        docker_id = self.docker_id
        cmd = f"docker run -it -d --name {docker_id} {DOCKER_REPO}"
        sp.run(cmd, shell=True, check=False)
        return docker_id
    def __exit__(self, _type, value, traceback):
        """ exit """
        cmd = f"docker container rm -f {self.docker_id}"
        sp.run(cmd, shell=True, check=False)


def get_params_data(modules:dict):
    """ get params data """
    docker_id = str(uuid.uuid4())[:8]
    cmd = f"docker run -it -d --name {docker_id} {DOCKER_REPO}"
    sp.run(cmd, shell=True, check=False)

    data = {}
    with OpenMSDockerImage(DOCKER_REPO) as container:
        for module in modules.keys():
            command = modules[module]['command']
            path = modules[module]['path']
            if 'prefix' in modules[module]:
                prefix = modules[module]['prefix']
            else:
                prefix = None
            args = get_command_args(path)
            widths, params = get_command_desc(command, args, container, prefix)
            data[module] = {'widths': widths, 'params': params}
    return data

def render_params_rst():
    """ render template """
    env = Environment(loader=FileSystemLoader('docs/partials'))
    template = env.get_template('_params.rst')
    data = get_params_data(MODULE_COMMANDS)
    print(data.keys())
    rendered = template.render(data=data)
    with open('docs/params.rst', "w") as handle:
        handle.write(rendered)

if __name__ == '__main__':
    render_params_rst()
