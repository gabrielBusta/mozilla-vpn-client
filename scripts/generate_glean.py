#! /usr/bin/env python3
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

import os.path
import yaml
import subprocess

print("Parsing the metrics.yaml file...")
if not os.path.isfile('glean/metrics.yaml'):
  print('Unable to find glean/metrics.yaml')
  exit(1)

yaml_file = open("glean/metrics.yaml", 'r')
yaml_content = yaml.safe_load(yaml_file)

print("Generating the C++ header...")
output = open("glean/telemetry/gleansample.h", "w")
output.write("""/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// AUTOGENERATED! DO NOT EDIT!!

namespace GleanSample {

""")
def camelize(string):
    output = ''
    first = True
    for chunk in string.split('_'):
        if first:
          output += chunk
          first = False
        else:
          output += chunk[0].upper()
          output += chunk[1:]
    return output

for key in yaml_content['sample']:
   sampleName = camelize(key)
   output.write(f"constexpr const char* {sampleName} = \"{sampleName}\";\n")

output.write("""
} // GleanSample
""");
output.close();


print("Generating the Kotlin enum...")
output = open("android/src/org/mozilla/firefox/vpn/glean/GleanEvents.kt", "w")
output.write("""/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// AUTOGENERATED! DO NOT EDIT!!
package org.mozilla.firefox.vpn.glean

import android.annotation.SuppressLint

@SuppressLint("Unused")
enum class GleanEvent(val key: String) {
""")
def camelize(string):
    output = ''
    first = True
    for chunk in string.split('_'):
        if first:
          output += chunk
          first = False
        else:
          output += chunk[0].upper()
          output += chunk[1:]
    return output

for key in yaml_content['sample']:
   sampleName = camelize(key)
   output.write(f"\t {sampleName}(\"{sampleName}\"),\n")

output.write("""
} // GleanSample
""");
output.close();

print("Generating the JS modules...")
try:
  subprocess.call(["glean_parser", "translate", "glean/metrics.yaml", "glean/pings.yaml",
                   "-f", "javascript", "-o", "glean/telemetry", "--option", "platform=qt",
                   "--option", "version=0.30"])
except:
  print("glean_parser failed. Is it installed? Try with:\n\tpip3 install -r requirements.txt --user");
  exit(1)

