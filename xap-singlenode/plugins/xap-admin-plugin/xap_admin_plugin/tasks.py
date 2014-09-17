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

@operation
def deploy_grid(ctx, **kwargs):
        script = ctx.properties['script']
        script_path = ctx.download_resource(script)
        ctx.logger.info("script_path= " + script_path + " script= " + script)
        subprocess.check_call(["chmod", "777", script_path])
        ctx.logger.info("partitionssssss " + str(kwargs["partitions"]))
        output = subprocess.check_output([script_path, kwargs["grid_name"], kwargs["schema"], str(kwargs["partitions"]), str(kwargs["backups"]), str(kwargs["max_per_vm"]), str(kwargs["max_per_machine"])])
        ctx.logger.info(script_path + " output:" + output)

@operation
def undeploy_grid(ctx, **kwargs):
    script = ctx.properties['script']
    script_path = ctx.download_resource(script)
    ctx.logger.info("script_path= " + script_path + " script= " + script)
    subprocess.check_call(["chmod", "777", script_path])
    output = subprocess.check_output([script_path, kwargs["grid_name"]])
    ctx.logger.info(script_path + " output:" + output)



