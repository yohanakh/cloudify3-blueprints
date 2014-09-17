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
from cloudify.decorators import workflow


@workflow
def deploy_grid(ctx, grid_name, schema, partitions, backups, max_per_vm, max_per_machine, **kwargs):
    graph = ctx.graph_mode()
    for node in ctx.nodes:
        ctx.logger.info(node.type_hierarchy)
        if "xap_mgmt" in node.id:
            for instance in node.instances:
                ctx.logger.info("adding task " + grid_name)
                ctx.logger.info(schema)
                ctx.logger.info(backups)
                graph.add_task(instance.execute_operation("admin.commands.deploy_grid",
                                                          kwargs={'grid_name':grid_name, 'schema':schema,'partitions':partitions, 'backups':backups,
                                                                  'max_per_vm':max_per_vm, 'max_per_machine':max_per_machine}))
    return graph.execute()

@workflow
def undeploy_grid(ctx, grid_name, **kwargs):
    graph = ctx.graph_mode()
    for node in ctx.nodes:
        ctx.logger.info(node.type_hierarchy)
        if "xap_mgmt" in node.id:
            for instance in node.instances:
                ctx.logger.info("adding task " + grid_name)
                graph.add_task(instance.execute_operation("admin.commands.undeploy_grid",
                                                          kwargs={'grid_name':grid_name}))
    return graph.execute()


