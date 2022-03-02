# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
"""
This Transform adds the ability to do use replacement-optizmiation
based on the hash of input files.
Usage:
optimization:
    hashIndex:
       - a.cpp
       - /some/src/b.ts 
       - c.sh
- It will generate a hash(a,b,c)
- It will add the result of this task to the index under: hashIndex.<hash>
- It will add hashIndex.<hash> to the optimization list.
Therefore, unless it's dependencies or the input files change,
the last task result will be used.
"""

from taskgraph.transforms.base import TransformSequence
import hashlib
import pathlib

transforms = TransformSequence()

REPO_DIR = pathlib.Path(__file__).parent.parent.parent.parent
BLOCK_SIZE = 65536 # Read in blocks of 65k, in case bigger files are input.

def resolveFileName(file):
    return REPO_DIR.joinpath(pathlib.Path(file)) 


@transforms.add
def addHashIndex(config, tasks):
    for task in tasks:
        if not task.__contains__("optimization"):
            yield task
            continue
        if not task["optimization"].__contains__("hashIndex"):
            yield task
            continue
        opt = task.pop("optimization")
        hashIndex = opt.pop("hashIndex")

        file_hash = hashlib.sha256() 
        for filename in hashIndex:
            filepath = resolveFileName(filename)
            with open(filepath, 'rb') as f:
                fb = f.read(BLOCK_SIZE) 
                while len(fb) > 0: 
                    file_hash.update(fb) 
                    fb = f.read(BLOCK_SIZE)
        sha = file_hash.hexdigest()

        namespace = f"mozillavpn.v2.mozilla-vpn-client.hashIndex.{sha}"
        route=f"index.{namespace}"
        task["optimization"]= {
            "index-search": [namespace]
        }
        currentLevel = int(config.params["level"]) 
        # We may use index-opt to Read a task with the same hash
        # But not try to create one :), no scopes yet >:(
        if 3 >= currentLevel:
                yield task
                return
        if task.__contains__("routes"):
            task["routes"].append(namespace)
        else:
            task["routes"] = [route]
        yield task