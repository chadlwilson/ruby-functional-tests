##########################################################################
# Copyright 2022 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

step 'On new environments page' do
  new_environments_page.load
end

step 'Verify no environments present message' do
  new_environments_page.verify_no_envs_available_message
end

step 'Add new environment <env>' do |env|
  new_environments_page.add_new_environment(actual_name(env))
end

step 'Verify environment <env> is listed' do |env|
  assert_true new_environments_page.has_environment?(actual_name(env))
end

step 'Verify environment <env> is not listed' do |env|
  assert_false new_environments_page.has_environment?(actual_name(env))
end

step 'Open collapsible panel for <env>' do |env|
  new_environments_page.open_collapsible_for(actual_name(env))
end

step 'Click on edit pipeline for <env>' do |env|
  new_environments_page.edit_pipeline_association_for(actual_name(env))
end

# step 'Verify flash info message for no pipelines' do
#   new_environments_page.has_info_message("There are no pipelines available!")
# end

step 'Associate pipeline <pipeline> to environment' do |pipeline|
  new_environments_page.associate_pipeline(pipeline)
end

step 'Verify pipeline <pipelines> associated to environment <env>' do |pipelines, env|
  pipelines.split(',').collect(&:strip).each do |pipeline|
    assert_true new_environments_page.has_pipeline(pipeline, actual_name(env))
  end
end

step 'Verify pipeline <pipelines> not associated to environment <env>' do |pipelines, env|
  pipelines.split(',').collect(&:strip).each do |pipeline|
    assert_false new_environments_page.has_pipeline(pipeline, actual_name(env))
  end
end

step 'Click on edit agent for <env>' do |env|
  new_environments_page.edit_agent_association_for(actual_name(env))
end

step 'Associate all agents to the environment' do |_tmp|
  new_environments_page.associate_all_agents
end

step 'Verify agent <agent> associated to environment <env>' do |agent, env|
  new_environments_page.has_agent(agent, actual_name(env))
end

step 'Click on edit environment variable for <env>' do |env|
  new_environments_page.edit_environment_variable_for(actual_name(env))
end

step 'Add plain text environment variable name <name> value <value>' do |name, value|
  new_environments_page.add_new_plain_text_environment_variable(name, value)
end

step 'Add secure environment variable name <name> value <value>' do |name, value|
  new_environments_page.add_new_secure_environment_variable(name, value)
end

step 'Verify environment variable <variable> are available for environment <env>' do |variable, env|
	new_environments_page.verify_added_environment_variables(variable, actual_name(env))
end

step 'Delete environment <env>' do |env|
	new_environments_page.delete_environment(actual_name(env))
end

step 'Verify delete button for <env> is enabled' do |env|
  new_environments_page.has_enabled_delete_button(actual_name(env))
end

step 'Verify delete button for <env> is disabled' do |env|
  new_environments_page.has_disabled_delete_button(actual_name(env))
end

step 'Verify edit buttons for <env> are enabled' do |env|
  new_environments_page.has_enabled_edit_buttons(actual_name(env))
end

step 'Verify edit buttons for <env> are disabled' do |env|
  new_environments_page.has_disabled_edit_buttons(actual_name(env))
end

step 'Verify unavailable pipeline <pipeline> for <env>' do |pipeline, env|
  new_environments_page.has_unavailable_pipeline(pipeline, actual_name(env))
end

step 'Close pipeline association modal' do
  new_environments_page.close_modal
end


step 'Verify removing pipelines <pipelines> is not allowed - On Environments SPA' do |pipelines, env|
  pipelines.split(',').collect(&:strip).each do |pipeline|
    assert_true new_environments_page.pipelines_selection_disabled?(pipeline)
  end
end

def actual_name(env)
  scenario_state.get(env) || env
end

step 'Remove pipelines <pipelines> and save environment - On Environments SPA' do |pipelines|
  pipelines.split(',').collect(&:strip).each do |pipeline|
    new_environments_page.unselect_pipeline(pipeline)
  end
  new_environments_page.modal_save.click
end
