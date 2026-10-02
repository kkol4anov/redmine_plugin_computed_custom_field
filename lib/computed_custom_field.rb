module ComputedCustomField
  def self.patch_models
    require_dependency 'custom_field'
    require_dependency 'custom_fields_helper'
    require_dependency 'computed_custom_field/formula_validator'
    require_dependency 'computed_custom_field/custom_field_patch'
    require_dependency 'computed_custom_field/custom_fields_helper_patch'
    require_dependency 'computed_custom_field/model_patch'
    require_dependency 'computed_custom_field/issue_patch'

    CustomField.include(CustomFieldPatch) unless CustomField.include?(CustomFieldPatch)
    unless CustomFieldsHelper.include?(CustomFieldsHelperPatch)
      CustomFieldsHelper.include(CustomFieldsHelperPatch)
    end

    # Enumeration covers priorities, document categories and time activities.
    %w[Document Enumeration Group Issue Project TimeEntry User Version].each do |name|
      require_dependency name.underscore
      model = name.constantize
      model.include(ModelPatch) unless model.include?(ModelPatch)
    end
    Issue.prepend(IssuePatch) unless Issue.ancestors.include?(IssuePatch)
  end
end
