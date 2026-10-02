module ComputedCustomField
  # rubocop:disable Lint/UselessAssignment, Security/Eval
  class FormulaValidator < ActiveModel::Validator
    def validate(record)
      object = custom_field_instance(record)
      define_validate_record_method(object)
      object.validate_record record
    rescue StandardError, SyntaxError => e
      record.errors[:formula] << e.message
    end

    private

    def custom_field_instance(record)
      record.class.customized_class.new
    end

    def define_validate_record_method(object)
      def object.validate_record(record)
        grouped_cfs = CustomField.all.group_by(&:id)
        cf_ids = record.formula.scan(/cfs\[(\d+)\]/).flatten.map(&:to_i)
        cfs = cf_ids.each_with_object({}) do |cf_id, hash|
          field = Array(grouped_cfs[cf_id]).first
          raise ArgumentError, "Unknown custom field: #{cf_id}" unless field
          hash[cf_id] = field.cast_value '1'
        end
        eval record.formula
      end
    end
  end
  # rubocop:enable Lint/UselessAssignment, Security/Eval
end
