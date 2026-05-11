class CreateIssues < ActiveRecord::Migration[8.1]
  def change
    create_table :issues do |t|
      t.string :title
      t.string :project_name
      t.string :status
      t.text :error_message
      t.text :stack_trace
      t.text :steps_to_reproduce
      t.text :what_i_checked
      t.text :root_cause
      t.text :fix
      t.text :prevention
      t.text :interview_summary

      t.timestamps
    end
  end
end
