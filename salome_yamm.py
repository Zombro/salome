#!/usr/bin/env python
# -*- coding: utf-8 *-
#  Copyright (C) 2017 EDF R&D
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
#

import multiprocessing
import os
import sys
sys.path.append('/opt/yamm/src')
from yamm.projects.salome.project import Project


topdirectory = os.getenv('SALOMEROOT')
if not topdirectory:
    sys.exit('Environment variable SALOMEROOT is missing')
version = os.getenv('SALOMEVERSION')
if not version:
    sys.exit('Environment variable SALOMEVERSION is missing')

version_directory = os.path.join(topdirectory, version)

def ping(host):
    """
    Returns True if host responds to a ping request
    """
    import subprocess, platform, os

    # Ping parameters as function of OS
    ping_str = "-n1" if  platform.system().lower()=="windows" else "-c1"
    args = ["ping", ping_str, host]

    # Ping
    return subprocess.call(args, stdout=open(os.devnull, 'wb')) == 0

yamm_project = Project()

# Configuration
yamm_project.set_version(version, 'public')
yamm_project.set_global_option('top_directory', topdirectory)
yamm_project.set_global_option('version_directory', version_directory)
yamm_project.set_global_option('archives_directory', '/opt/archives')
yamm_project.set_global_option('parallel_make', '%d' % multiprocessing.cpu_count())
yamm_project.set_category_option('prerequisite', 'clean_src_if_success', True)
yamm_project.set_global_option('clean_build_if_success', True)
yamm_project.set_global_option('separate_dependencies', True)
yamm_project.set_global_option('write_soft_infos', False)
yamm_project.set_global_option('use_system_version', True)
yamm_project.set_global_option('software_remove_list', ['EFICASV1', 'EFICAS', 'EFICAS_NOUVEAU', 'XDATA', 'TIX', 'MATPLOTLIB'])
for soft in ('PARAVISADDONS', 'ADAO'):
    yamm_project.set_software_option(soft, "source_type", 'archive')

if ping('forge.pleiade.edf.fr'):
    # Inside EDF network
    yamm_project.set_global_option('use_pleiade_mirrors', True)
else:
    # Outside EDF network
    yamm_project.set_global_option('proxy_server', '""')
    yamm_project.set_global_option('python_prerequisites_server', 'https://pypi.python.org')

# Execution
ret = yamm_project.start()
if ret:
    ret = yamm_project.create_appli(topdirectory, 'appli')
sys.exit(ret is False)
