class AddSeverityToIssues < ActiveRecord::Migration[8.1]
  def change
    add_column :issues, :severity, :string
  end
end
