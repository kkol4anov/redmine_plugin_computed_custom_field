Redmine::Plugin.register :computed_custom_field do
  name 'Computed custom field'
  author 'Yakov Annikov / Konstantin Kolchanov'
  url 'https://github.com/kkol4anov/redmine_plugin_computed_custom_field'
  description ''
  version '1.0.0.rc1'
  requires_redmine version_or_higher: '4.2.0'
  settings default: {}
end

# Hooks are registered once; reloadable models and helpers are patched on each
# Rails prepare cycle (including the first application boot).
require 'computed_custom_field/hooks'

Rails.application.config.to_prepare do
  require_dependency 'computed_custom_field'
  ComputedCustomField.patch_models
end
