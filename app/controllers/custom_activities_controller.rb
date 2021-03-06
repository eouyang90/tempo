class CustomActivitiesController < ApplicationController
	before_action :set_custom_activity, only: [:edit_custom_activity, :destroy_custom_activity, :complete_custom_activity]

	# Create a CustomInterest in the database for the given params
	# POST /api/users/:id/custom_activities
	# Testing via curl: curl -H "Content-Type: application/json" -X POST -d '{"custom_activity": {"title": "Title", "completion_time": 10, "content": "Lorem ipsum content here!"}, "token":"<token"}' http://localhost:3000/api/users/1/custom_activities
	# Requires token authentication
	def create_custom_activity 
		json_response = {}
		status = -1
		user_id = params[:id]
		@user = User.find_by(id: user_id)
		token = params["token"]
		error_list = []
		@custom_activity = CustomActivity.new(custom_activity_params)

		if not @user.nil? # if the User exists
			if not token.nil? and user_has_permission(User.authenticate_token(token), @user.id) # if the token was provided and is valid and the user has permission
				if @custom_activity.save
						@user.add_custom_activity(@custom_activity)
						status = 1
						activity_data = @custom_activity.as_json
						json_response["custom_activity"] = activity_data
				else
					error_list = process_save_errors(@custom_activity.errors)
				end
			else
				error_list.append(ErrorMessages::AUTHORIZATION_ERROR)
        		status = -2
			end
		else
			error_list.append("Error: user ##{user_id} doesn't exist.")
		end

		json_response["status"] = status

		if status != 1
			json_response["errors"] = error_list
		end

		json_response = json_response.to_json

		respond_to do |format|
			format.json { render json: json_response }
		end
	end

	# Edit the fields of a specified CustomActivity
	# PUT /api/users/:id/custom_activities/:cid
	# Testing via curl: curl -H "Content-Type: application/json" -X PUT -d '{"custom_activity": {"title": "TITLE", "completion_time": 10, "content": "LOREM IPSUM CONTENT HERE!"}, "token":"<token>"}' http://localhost:3000/api/users/1/custom_activities/3
	# Requires token authentication
	def edit_custom_activity
		json_response = {}
		status = -1
		user_id = params[:id]
		custom_activity_id = params[:cid]
		token = params["token"]
		error_list = []
		@user = User.find_by(id: user_id)
		@custom_activity = CustomActivity.find_by(id: custom_activity_id)

		if not @user.nil? # If the User exists
			if not token.nil? and user_has_permission(User.authenticate_token(token), @user.id) # if the token was provided and is valid and the user has permission
				if not @custom_activity.nil? # If the CustomActivity exists
					if @custom_activity.belongs_to_user(@user) # the CustomActivity is okay to edit
						if @custom_activity.update(custom_activity_params) # if the update is successful
							status = 1
							json_response["custom_activity"] = @custom_activity.as_json
						else
							error_list = error_list + process_save_errors(@custom_activity.errors)
						end
					else
						error_list.append("Error: custom activity ##{custom_activity_id} doesn't belong to user ##{user_id}.")
					end
				else
					error_list.append("Error: custom activity ##{custom_activity_id} doesn't exist.")
				end
			else
				error_list.append(ErrorMessages::AUTHORIZATION_ERROR)
        		status = -2
			end
		else
			error_list.append("Error: user ##{user_id} doesn't exist.")
		end

		json_response["status"] = status

		if status != 1
			json_response["errors"] = error_list
		end

		json_response = json_response.to_json

		respond_to do |format|
			format.json { render json: json_response }
		end
	end

	# Return a JSON response with a list of all CustomActivities
	# GET /api/custom_activities
	# Testing via curl: curl -H "Content-Type: application/json" -X GET http://localhost:3000/api/custom_activities
	# TODO: only allow admins to do this
	def get_all_custom_activities
		json_response = {}
		activities_list = []
		error_list = []
		status = -1
		@activities = CustomActivity.all

		if not @activities.empty?
			status = 1
			@activities.each do |activity|
				activity_data = { "id": activity.id, "title": activity.title, "content": activity.content, "completion_time": activity.completion_time }
				activity_data = activity_data.as_json
				activities_list.append(activity_data)
			end

			json_response["custom_activities"] = activities_list
		else
			error_list.append("Error: there are no custom_activities")
		end

		if status == -1
			json_response["errors"] = error_list
		end

		json_response["status"] = status
		json_response = json_response.to_json

		respond_to do |format|
			# format.html # show.html.erb
			format.json { render json: json_response }
		end
	end

	# Deletes specified CustomActivity from database
	# DELETE /api/users/:id/custom_activities/:cid
	# Testing via curl: curl -H "Content-Type: application/json" -X DELETE -d '{"token":"<token>"}' http://localhost:3000/api/users/1/custom_activities/5
	# Requires token authentication
	def destroy_custom_activity
		json_response = {}
		error_list = []
		status = -1
		token = params["token"]
		user_id = params[:id]
		custom_activity_id = params[:cid]
		@user = User.find_by(id: user_id)
		@custom_activity = CustomActivity.find_by(id: custom_activity_id)

		if not @user.nil? # If the User exists
			if not token.nil? and user_has_permission(User.authenticate_token(token), @user.id) # if the token was provided and is valid and the user has permission
				if not @custom_activity.nil? # If the CustomActivity exists
					if @custom_activity.belongs_to_user(@user) # If this User has permision to delete the CustomActivity
						status = 1
						@custom_activity.destroy
					else
						error_list.append("Error: custom activity ##{custom_activity_id} doesn't belong to user ##{user_id}.")
					end
				else
					error_list.append("Error: custom activity ##{custom_activity_id} doesn't exists.")
				end
			else
				error_list.append(ErrorMessages::AUTHORIZATION_ERROR)
        status = -2
			end
		else
			error_list.append("Error: user ##{user_id} doesn't exist.")
		end

		if status != 1
			json_response["errors"] = error_list
		end

		json_response["status"] = status
		json_response = json_response.to_json
		
		respond_to do |format|
			format.json { render json: json_response }
		end
	end

	# Adds the CustomActivity to the User's completed_custom_activities list
	# PUT /api/custom_activities/:id/complete
	# Testing via curl: curl -H "Content-Type: application/json" -d '{ "user_id": 1 }' -X PUT http://localhost:3000/api/custom_activities/1/complete
	def complete_custom_activity
		status = -1
		json_response = {}
		error_list = []
		token = params[:token]

		user_id = params["user_id"]
		user = User.find_by(id: user_id)

		if not user.nil?
			if not token.nil? and user_has_permission(User.authenticate_token(token), user.id) # if the token was provided and is valid and the user has permission
				if not @custom_activity.nil?
					status = 1
					completed_custom_activities = user.completed_custom_activities

					if not completed_custom_activities.include? @custom_activity.id #prevent duplicates
						completed_custom_activities.push(@custom_activity.id)
						user.completed_custom_activities = completed_custom_activities
						user.save
					end

				else
					error_list.append("Error: activity does not exist")
				end
			else
				error_list.append(ErrorMessages::AUTHORIZATION_ERROR)
        status = -2
			end
		else
			error_list.append("Error: user_id is not valid")
		end		

		if status != 1
			json_response["errors"] = error_list
		end

		json_response["status"] = status
		json_response = json_response.to_json

		respond_to do |format|
			format.json { render json: json_response }
		end
	end

	# Get a User's specific CustomActivity
	# GET /api/users/:id/custom_activities/:cid/
	# Testing via curl: curl -H "Content-Type: application/json" -d '{ "token": "<token>" }' -X GET http://localhost:3000/api/users/1/custom_activities/1/
	def get_custom_activity
		status = -1
		json_response = {}
		error_list = []
		token = params[:token]
		user_id = params[:id]
		user = User.find_by(id: user_id)
		custom_activity_id = params[:cid]

		if not user.nil?
			if not token.nil? and user_has_permission(User.authenticate_token(token), user.id) # if the token was provided and is valid and the user has permission
				custom_activity = CustomActivity.find_by(id: custom_activity_id)

				if not custom_activity.nil? and user.custom_activities.include? custom_activity # if this CustomActivity belongs to the User
					status = 1
					json_response["custom_activity"] = custom_activity
				else
					error_list.append("Error: you don't have permission to view this CustomActivity.")
				end
			else
				error_list.append(ErrorMessages::AUTHORIZATION_ERROR)
        status = -2
			end
		else
			error_list.append("Error: user_id is not valid.")
		end		

		if status != 1
			json_response["errors"] = error_list
		end

		json_response["status"] = status
		json_response = json_response.to_json

		respond_to do |format|
			format.json { render json: json_response }
		end
	end






	private
	# Use callbacks to share common setup or constraints between actions.
	def set_custom_activity
		if not params[:id].nil? and params[:id].respond_to?(:to_i)
			begin
				@custom_activity = CustomActivity.find(params[:id])
			rescue ActiveRecord::RecordNotFound
    		@custom_activity = nil
    	end
		end
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def custom_activity_params
		params.require(:custom_activity).permit(:title, :completion_time, :content)
	end
end
