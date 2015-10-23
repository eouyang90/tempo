# == Schema Information
#
# Table name: activities
#
#  id              :integer          not null, primary key
#  title           :string
#  content         :string
#  completion_time :integer
#  content_type    :string
#  link            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Activity < ActiveRecord::Base
	# Associations
	has_and_belongs_to_many :interests

	# Validations
	validates :title, presence: true
	validates :title, length: { maximum: 128 }

	validates :completion_time, numericality: { greater_than: 0,
											    less_than_or_equal_to: 60 }

  # Returns a JSON list of all activities that match the Interests provided in interests_list, with
  # completion_time less than or equal to time.
  # If interests_list is nil, it returns a JSON list of all Activities in the database.
  def self.get_activities(interests_list, time)
    activities_list = []

    if interests_list.nil?
      activities = Activity.all
    else
      activities = Activity.joins(:interests).distinct.where(interests: {name: interests_list})
    end

    if not time.nil?
      activities = activities.where("completion_time <= ?", time)
    end

    activities = activities.as_json
    return activities
  end

  # Returns a string of the form: "name = <name1> or name = <name2>"...
  # Takes in a list of Interest names
  def convert_names_to_sql_arg_string(interest_names)
    arg_string = ""

    interest_names.each do |name|
      arg_string = arg_string + "name = #{name} or "
    end

    arg_string.chomp(" or ")
    return arg_string
  end

end
