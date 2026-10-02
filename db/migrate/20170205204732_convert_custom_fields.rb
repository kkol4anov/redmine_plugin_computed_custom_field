class ConvertCustomFields < ActiveRecord::Migration[4.2]
  # Do not run current CustomField callbacks while converting the retired
  # 'computed' format. That format is no longer registered in Redmine.
  class LegacyCustomField < ActiveRecord::Base
    self.table_name = 'custom_fields'
    self.inheritance_column = :_type_disabled
    store :format_store
  end

  def up
    LegacyCustomField.reset_column_information
    LegacyCustomField.where(field_format: 'computed').find_each do |field|
      output_format = field.format_store[:output_format]
      format = case output_format
               when 'integer'
                 'int'
               when 'percentage'
                 'float'
               else
                 output_format
               end
      # update_all quotes values through the configured adapter (Mysql2).
      LegacyCustomField.where(id: field.id).update_all(
        formula: field.format_store[:formula],
        is_computed: true,
        field_format: format
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          'Restore the database backup to recover legacy computed fields'
  end
end
