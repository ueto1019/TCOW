class CreateWorkTimes < ActiveRecord::Migration[6.1]
  def change
    create_table :work_times do |t|
      t.string :employee_id, null: false
      t.integer :year
      t.integer :month
      t.datetime :clock_in
      t.datetime :clock_out
      t.float :worked_time

      t.timestamps
    end
  end
end
