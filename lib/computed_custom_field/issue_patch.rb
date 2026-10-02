module ComputedCustomField
  module IssuePatch
    def read_only_attribute_names(user = nil)
      # Keep workflow restrictions and prevent UI/API writes to computed fields.
      cf_ids = IssueCustomField.where(is_computed: true).pluck(:id).map(&:to_s)
      (super(user) + cf_ids).uniq
    end
  end
end
