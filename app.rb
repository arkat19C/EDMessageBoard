require 'bundler'
Bundler.require

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/main.db')
require './models.rb'

use Rack::Session::Cookie, :key => 'rack.session',
    :expire_after => 2592000,
    :secret => SecureRandom.hex(64)

get "/" do
  redirect '/landing.erb'
end

get "/user/signout" do
  session[:id] = nil
  erb :landing
end

get "/landing.erb" do
  @message = session[:notice]
  session[:notice] = nil
  erb :landing
end

get "/topic/:id" do
  @topic = Topic.first(:id => params[:id])
  @posts = @topic.posts
  erb :posts
end

get "/signup.erb" do
  @message = session[:notice]
  session[:notice] = nil
  erb :signup
end

get "/topics.erb" do
  @t = Topic.all
  if session[:notice] == nil
    if session[:first]
      @username = User.first(:id => session[:id]).username
      @message = "Welcome to the forum, #{@username}!"
    end
  else
    @message = session[:notice]
  end
  session[:notice] = nil
  session[:first] = false
  erb :topics
end

get '/user/:id/posts' do
  @message = nil
  u = User.first(:id => params[:id])
  @user_posts = u.posts
  erb :userposts
end

get '/user_search' do
  u = User.first(:username => params[:username_search])
  if u
    @message = ""
    redirect "user/#{u.id}/posts"
  else
    @message = "Sorry, that username doesn't exist."
    @users = User.all
    erb :users
  end

end

get "/users.erb" do
  @users = User.all
  erb :users
end

get "/topic/:id/addpost.erb" do
  @topic = Topic.first(:id => params[:id])
  @t_id = @topic.id
  erb :addpost
end

get '/post/:p_id/post-content.erb' do
  @post = Post.first(:id => params[:p_id])
  erb :post_content
end

post "/user/signup" do
  if User.where(:username => params[:username]).empty?
    if params[:password] == params[:password_confirm]
      u = User.new
      u.username = params[:username]
      u.password = BCrypt::Password.create(params[:password])
      u.secQuestion = params[:sec_q]
      u.secAnswer = params[:sec_a]
      u.save
      session[:id] = u.id
      session[:first] = true
      redirect '/topics.erb'
    else
      session[:notice] = "Sorry, your passoword confirmation does not match the first input."
      redirect '/signup.erb'
    end
  else
    session[:notice] = "Sorry, but there is already a user with that username."
    redirect '/signup.erb'
  end
end

post "/user/login" do
  u = User.first(:username => params[:username_signin])
  if u && BCrypt::Password.new(u.password) == params[:password_signin]
    session[:id] = u.id
    session[:first] = true
    redirect '/topics.erb'
  else
    session[:notice] = "That username and password set doesn't match anything in our database. Try again!"
    redirect '/'
  end
end

post "/topic/create" do
  if params[:topic] == ""
    session[:notice] = "Sorry, the topic must have a name."
  else
    t = Topic.new
    t.topic = params[:topic]
    t.save
  end
  redirect '/topics.erb'
end

post "/topic/:id/post/create" do
  @topic = Topic.first(:id => params[:id])
  @time = Time.now.asctime
  p = Post.new
  p.time = @time
  p.author = User.first(:id => session[:id]).username
  p.title = params[:post_title]
  p.content = params[:post_content]
  p.user_id = session[:id]
  p.topic_id = params[:id]
  p.save
  redirect "/topic/#{@topic.id}"
end