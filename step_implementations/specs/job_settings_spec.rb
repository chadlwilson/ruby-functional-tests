##########################################################################
# Copyright 2022 Thoughtworks, Inc.
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

step 'On Job settings page of pipeline <pipeline_name> stage <stage_name> job <job_name>' do |pipeline_name, stage_name, job_name|
  job_settings_page.load(pipeline_name: scenario_state.get(pipeline_name), stage_name: stage_name, job_name: job_name)
end

step 'Open <tab_id> tab - On Job settings page' do |tab_id|
  job_settings_page.on_tab(tab_id)
end

step 'Add artifact of type <type>' do |type|
  job_settings_page.publish_artifact_type.select type
  job_settings_page.add_artifact.click
end

step 'Save external artifact with values <key_value>' do |key_value|
  key_value.split(',').each do |field|
    job_settings_page.fill_external_form(field)
  end
  general_settings_page.global_save.click
end

step 'Save <type> artifact with values <key_value>' do |type, key_value|
  key_value.split(',').each do |field|
    job_settings_page.fill_form(type, field)
  end
  general_settings_page.global_save.click
end

step 'Save artifact with values <key_value> at <index>' do |key_value, index|
  key_value.split(',').each do |field|
    publish_artifacts_view.fill_form_with_index(field, index)
  end
  publish_artifacts_view.save_publish_artifacts.click
end

step 'Add task <task_name>' do |task|
  job_settings_page.add_new_task_of_type task
end

step 'Move task <task_index> up' do |task_index|
  job_settings_page.move_task_up task_index
end

step 'Move task <task_index> down' do |task_index|
  job_settings_page.move_task_down task_index
end

step 'Select artifact type <a_type> pipeline <p_name> stage <s_name> job <j_name> artifact id <a_id> path <path>' do |a_type, p_name, s_name, j_name, a_id, path|
  job_settings_page.external_artifact.click
  job_settings_page.task_pipeline.set scenario_state.get(p_name)
  job_settings_page.task_stage.set s_name
  job_settings_page.task_job.set j_name
  job_settings_page.task_artifact_id.set a_id
  job_settings_page.task_configuration_path.set path
end

step 'Save task details' do
  job_settings_page.task_save.click
end

step 'Set target to <target> with working directory <working_directory>' do |target, working_directory|
  job_settings_page.configure_rake_task(target, working_directory)
end

step 'Set on Cancel task <task> and command <command> - Already on Task edit popup' do |task, command|
  job_settings_page.configure_on_cancel_more_task(task, command)
end

step 'Set More task - Command as <command> argument as <arglist> working directory as <working_directory> runIfConditions as <run_conditions> - Already on Task edit popup' do |command, arglist, working_directory, run_conditions|
  job_settings_page.configure_more_task(command, arglist, working_directory, run_conditions)
end

step 'verifyTask <table>' do |table|
  table.rows.each do |row|
    (1..table.columns.length - 1).each do |column_Header|
      row_number = row['Order_no'].to_i
      col_name   = table.columns[column_Header]
      assert_true job_settings_page.get_cell_value_from_table(row_number, col_name, row[col_name]), "Failure on row #{row_number} for col '#{col_name}'"
    end
  end
end

step 'Delete task <task_no>' do |task_no|
  job_settings_page.delete_task(task_no)
end

step 'Verify no task with command <command> exists' do |command|
  assert_true job_settings_page.verify_task_with_command_is_not_exists(command)
end

step 'Verify artifact with type as <type> source as <src> and destination as <dest>  exists for <job> in <stage>' do |type, src, dest, job, stage|
  artifact = "#{type}:#{src}:#{dest}"
  assert_true publish_artifacts_view.verify_artifact_exist(scenario_state.self_pipeline, artifact, stage, job)
end

step 'Verify no <task> task with command <command> exists in <job> under <stage> for pipeline <pipeline>' do |task, command, job, stage, pipeline|
  assert_true job_settings_page.verify_task_with_command_is_not_exist_in_config(task, command, job, stage, pipeline)
end

step 'setTask <table>' do |table|
  table.rows.each do |row|
    job_settings_page.set_task(row['TaskType'], row['Target'], row['BuildFile'], row['WorkingDirectory'], row['RunIf-View'])
  end
end

step 'VerifyFieldsOnTaskList <table>' do |table|
  table.rows.each do |row|
    (1..table.columns.length - 1).each do |column_name|
      element = table.columns[column_name]
      job_settings_page.click_on_task_by_index(row['TaskIndex'].to_i)
      value = job_settings_page.send(element).value
      job_settings_page.task_cancel.click
      assert_equal row[table.columns[column_name]], value
    end
  end
end

step 'EditTaskWithOnCancel <table>' do |table|
  table.rows.each do |row|
    job_settings_page.click_on_task_by_index(row['TaskIndex'].to_i)
    job_settings_page.edit_task_with_on_cancel(row['task_build_file'], row['task_target'], row['task_working_directory'], row['On_Cancel_TaskType'], row['On_Cancel_Build_File'], row['On_Cancel_Target'], row['On_Cancel_Working_Dir'])
  end
end

step 'ArtifactSetAndValidate <table>' do |table|
  table.rows.each do |row|
    publish_artifacts_view.remove_all_artifacts
    job_settings_page.publish_artifact_type.select "Build"
    job_settings_page.add_artifact.click
    publish_artifacts_view.single_source.set(row['source'])
    publish_artifacts_view.single_destination.set(row['destination'])
    general_settings_page.global_save.click
    if row['messageForSource'] != ""
      source_error_msg = publish_artifacts_view.verify_source_error_message
      assert_equal row['messageForSource'], source_error_msg
    end
    if row['messageForDestination'] != ""
      dest_error_msg = publish_artifacts_view.verify_destination_error_message
      assert_equal row['messageForDestination'], dest_error_msg
    end
    save_status = row['saveStatus']
    if save_status.start_with?("ERROR::")
      save_status_msg = general_settings_page.error_message.text
      save_status     = save_status[7..-1]
    else
      save_status_msg = general_settings_page.get_message
    end
    assert_true save_status_msg.include?(save_status), "Expected '#{save_status_msg}' to contain '#{save_status}'"
  end
end

step 'SetEnvironmentVariablesForJob <table>' do |table|
  table.rows.each do |row|
    job_settings_page.add_parameter(row['name'], row['value'])
    general_settings_page.add_parameter_button.click
  end
end

step 'Check run multiple instance with <instance>' do |instance|
  job_settings_page.set_multiple_instance_with(instance)
end

step 'Verify error message <message> is shown - Already On Job Edit Page' do |message|
  values   = message.split(':')
  expected = new_pipeline_dashboard_page.sanitize_message(values[1])
  if values[0] === 'Job-Name'
    actual = job_settings_page.error_message_for_job_name
  elsif values[0] === 'Command'
    actual = job_settings_page.error_message_for_command
  else
    actual = job_settings_page.error_messages
  end
  assert_true actual.include?(expected), "Expected '#{expected}' to be a part of '#{actual}'"
end

step 'Verify that job is named <job>' do |job|
  assert_true job_settings_page.job_name.value.include? job
end

step 'Enter custom tab name <tab> with path <path>' do |tab, path|
  job_settings_page.set_custom_tab(tab, path)
end

step 'Verify error message <error_message> on name on tab <tab_index>' do |error_message, tab_index|
  assert_true job_settings_page.tab_error(tab_index).include? error_message
end

step 'Set job as <job> - On Job settings page' do |job|
  job_settings_page.job_name.set job
end

step 'set run type as <run_type>' do |run_type|
  job_settings_page.set_run_type(run_type)
end

step 'Verify dropdown contains <dropdown>' do |dropdown|
  drop_down_content = job_settings_page.get_dropdown
  dropdown.split(',').each {|drpdwn|
    assert_true drop_down_content.include?(drpdwn), "Expected - #{drpdwn}, Actual - #{drop_down_content}"
  }
end

step 'Select <resource> from the dropdown' do |resource|
  job_settings_page.select_resouce_from_dropdown resource
end

step 'Open task <number>' do |number|
  job_settings_page.select_task number
end

step 'Set command as <command> - On Job Setting Page' do |command|
  job_settings_page.task_commands.set command
end

step 'Set Working directory as <dir>' do |dir|
  job_settings_page.task_working_directory.set dir
end

step 'Override job time out with <time> minutes' do |time|
  job_settings_page.override_job_time_out(time)
end

step 'Select never option' do ||
  job_settings_page.set_never.click
end

step 'set job resources as <resources>' do |resources|
  job_settings_page.resources_on_popup.set resources
end

step 'Verify default echo task exists' do
  assert_equal 1, job_settings_page.total_tasks
end

step 'Set task pipeline as <pipeline>' do |pipeline|
  job_settings_page.task_pipeline.set(new_pipeline_dashboard_page.sanitize_message(pipeline), rapid: false)
end

step 'Set task job as <job>' do |job|
  job_settings_page.task_job.set job
end

step 'Set task stage as <stage>' do |stage|
  job_settings_page.task_stage.set stage
end

step 'Set task source file as <source_file>' do |source_file|
  job_settings_page.task_source_file.set source_file
end

step 'Check source is a file option' do ||
  job_settings_page.is_source_a_file.click
end

step 'Set task destination as <dest_dir>' do |dest_dir|
  job_settings_page.task_dest_dir.set dest_dir
end

step 'Uncheck source is a file option' do ||
  job_settings_page.is_source_a_file.click
end

step 'Verify error message <message> is shown for working directory' do |message|
  assert_true job_settings_page.error_message_for_working_dir === new_pipeline_dashboard_page.sanitize_message(message)
end

step 'Verify error message <message> is shown for job name' do |message|
  assert_true job_settings_page.error_message_for_job_name === new_pipeline_dashboard_page.sanitize_message(message)
end

step 'Verify error message <message> is shown for source' do |message|
  assert_true job_settings_page.error_message_for_source === new_pipeline_dashboard_page.sanitize_message(message)
end

step "Start creating external artifact with artifact id as <artifact_id> and store id as <store_id>" do |artifact_id, store_id|
  job_settings_page.artifact_id.set artifact_id
  job_settings_page.store_id.select store_id
end

step "Add a custom tab" do
  job_settings_page.add_custom_tab_button.click
end

step 'Set command as <command> - Already on Add New Job popup' do |command|
  job_settings_page.task_commands.set command
end
