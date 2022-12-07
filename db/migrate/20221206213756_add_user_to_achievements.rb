class AddUserToAchievements < ActiveRecord::Migration[6.1]
  def change
    add_reference :achievements, :user, null: true, foreign_key: true
  end
end
