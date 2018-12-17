#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2018, David Baumann <daBONDi@users.noreply.github.com>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

DOCUMENTATION = '''
---
module: win_printer_driver
version_added: "2.3"
short_description: Manage Windows Printer Driver
description: |
     Manage Windows Printer Driver
options:
  inf_file:
    description:
      - Path to the inf file
    required: true
    default: null
    aliases: []
  driver_name:
    description:
     - Name of the Driver specified in INF File
    required: true
    default: null
    aliases: []
  printer_env
    description:
      - For what Printenvironment the Driver is for
    choices:
      - "x86"
      - "x64"
    default: "x64"
  state:
    description:
      - If present driver will be installed, if absent driver will be removed
    choices:
      - "present"
      - "absent"
    default: "present
author: David Baumann
'''

EXAMPLES = '''
- name: "Install Printer Driver"
  win_printer_driver:
        inf_file: "c:/data/hp-upd-pcl6-x86-6.6.0.23029/hpcu215c.inf"
        driver_name: "HP Universal Printing PCL 6 (v6.6.0)"
        printer_env: "x64"
'''
