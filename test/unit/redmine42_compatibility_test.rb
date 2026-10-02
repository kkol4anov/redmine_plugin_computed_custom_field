require File.expand_path('../../test_helper', __FILE__)

class ComputedCustomFieldRedmine42Test < ComputedCustomFieldTestCase
  def test_patches_are_idempotent
    2.times { ComputedCustomField.patch_models }
    assert_equal 1, Issue.ancestors.count(ComputedCustomField::IssuePatch)
    assert CustomField.include?(ComputedCustomField::CustomFieldPatch)
    assert CustomFieldsHelper.include?(ComputedCustomField::CustomFieldsHelperPatch)
    assert Document.include?(ComputedCustomField::ModelPatch)
    callbacks = Issue._validation_callbacks.select do |callback|
      callback.kind == :before && callback.filter == :eval_computed_fields
    end
    assert_equal 1, callbacks.size
  end

  def test_computed_issue_field_is_read_only
    field = field_with_string_format
    assert_includes issue.read_only_attribute_names, field.id.to_s
  end

  def test_value_is_recomputed_after_reloading_same_object
    field = field_with_string_format
    field.update_column(:formula, 'cfs[1]')
    record = issue
    record.custom_field_values = {1 => 'MySQL'}
    record.save!
    assert_equal 'MySQL', record.custom_field_value(field.id)
    record.reload
    record.custom_field_values = {1 => 'PostgreSQL'}
    record.save!
    assert_equal 'PostgreSQL', record.reload.custom_field_value(field.id)
  end

  def test_unavailable_source_field_is_nil
    field = field_with_string_format
    # Simulate a source removed from the object's tracker or deleted later.
    missing_id = CustomField.maximum(:id).to_i + 100
    field.update_column(:formula, "cfs[#{missing_id}].nil? ? 'missing' : 'present'")
    record = issue
    record.save!
    assert_equal 'missing', record.reload.custom_field_value(field.id)
  end

  def test_syntax_error_becomes_validation_error
    field = field_with_string_format
    field.update_column(:formula, '1 +')
    record = issue
    refute record.valid?
    assert record.errors[:base].any?
  end

  def test_unknown_field_in_formula_is_reported
    field = field_with_string_format
    field.formula = "cfs[#{CustomField.maximum(:id).to_i + 100}]"
    refute field.valid?
    assert_match(/Unknown custom field/, field.errors[:formula].join)
  end
end
