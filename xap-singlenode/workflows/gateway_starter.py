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

from cloudify.workflows import ctx
from cloudify.workflows import parameters as p

graph = ctx.graph_mode()
instance = None
for node in ctx.nodes:
    if "xap_management" == node.id:
        for i in node.instances:
            instance = i
            break
        break


sequence = graph.sequence()
ctx.logger.info("executing instance {}".format(instance))

sequence.add(
    instance.send_event('Starting to run operation'),
    instance.execute_operation("admin.commands.deploy_gateway_space"),
    instance.send_event('Done running operation'),
    instance.execute_operation("admin.commands.deploy_gateway_pu"),
    instance.send_event('Done running operation'),
    instance.execute_operation("admin.commands.deploy_rest"),
    instance.send_event('Done running operation')
)


graph.execute()