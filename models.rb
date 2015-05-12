class User < Sequel::Model
  one_to_many :posts
end

class Topic < Sequel::Model
  one_to_many :posts
end

class Post < Sequel::Model
  many_to_one :topic
  many_to_one :user
end