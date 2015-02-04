########
# Copyright (c) 2014 GigaSpaces Technologies Ltd. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and

# * limitations under the License.
from cloudify.decorators import operation
import subprocess
import urllib
import os


@operation
def deploy_grid(ctx, **kwargs):
    script = kwargs['script']
    script_path = ctx.download_resource(script)
    subprocess.check_call(["chmod", "777", script_path])
    output = subprocess.check_output(
        [script_path, kwargs["grid_name"], kwargs["schema"], str(kwargs["partitions"]), str(kwargs["backups"]),
         str(kwargs["max_per_vm"]), str(kwargs["max_per_machine"])])
    ctx.logger.info(script_path + " output:" + output)


@operation
def undeploy_grid(ctx, **kwargs):
    script = kwargs['script']
    script_path = ctx.download_resource(script)
    subprocess.check_call(["chmod", "777", script_path])
    output = subprocess.check_output([script_path, kwargs["grid_name"]])
    ctx.logger.info(script_path + " output:" + output)


@operation
def deploy_pu(ctx, **kwargs):
    script = kwargs['script']
    script_path = ctx.download_resource(script)
    tmp_pus = '/tmp/pus'
    if not os.path.exists(tmp_pus):
        os.makedirs(tmp_pus)
    jar_name = kwargs["pu_url"].split("/")[-1]

    pu_location = tmp_pus + '/' + jar_name
    urllib.urlretrieve(kwargs["pu_url"], pu_location)
    subprocess.check_call(["chmod", "777", script_path])
    if kwargs["override_pu_name"] != {}:
        pu_name = kwargs["override_pu_name"]
    else:
        pu_name = jar_name.split(".jar")[0]

    output = subprocess.check_output([script_path, pu_location, pu_name, kwargs["schema"],
                                      str(kwargs["partitions"]), str(kwargs["backups"]), str(kwargs["max_per_vm"]),
                                      str(kwargs["max_per_machine"])])
    ctx.logger.info(script_path + " output:" + output)

