# [BoozeTracker]
class BoozeTracker < Sinatra::Base
  namespace '/users' do
    # user routes are protected
    before '/*' do
      authorize
    end

    #################
    # Instance routes
    namespace '/:id' do
      before '*' do
        @current_user = User.find(params[:id])
      end

      # update result
      get '/result' do
        authorize_edit(@current_user.id)
        day = Date.parse(params[:date])
        case params[:result]
        when 'dry'
          @current_user.save_result!(day, false)
        when 'beer'
          @current_user.save_result!(day, true)
        when 'void'
          @current_user.save_result!(day, nil)
        end
        flash[:notice] = 'Successfully updated'
        redirect back
      end

      # toggle subscription for a user
      get '/toggle-subscription' do
        authorize_edit(@current_user.id)
        @current_user.toggle_subscription!
        flash[:notice] = "Subscription set to #{!user.unsubscribed}"
        redirect "/users/#{@current_user.id}"
      end

      # unsubscribe a user
      get '/unsubscribe' do
        authorize_edit(@current_user.id)
        @current_user.unsubscribe!
        flash[:notice] = "#{@current_user.name} has been unsubscribed"
        redirect "/users/#{@current_user.id}"
      end

      # show user profile
      get '' do
        @rundate = params[:date] ? Date.parse(params[:date]) : Date.today
        haml :'users/profile'
      end
    end

    ###################
    # Collection routes

    # list users
    get '' do
      @users = User.all
      haml :'users/list'
    end
  end
end
