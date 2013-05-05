require 'rubygems'
require 'sinatra'
require 'data_mapper'

SITE TITLE = "Recall App"
SITE DESCRIPTION = "remember me"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @notes = Note.all :order => :id.desc
  @title = 'All Notes'
  erb :home
end

post '/' do
  note = Note.new
  note.content = params[:content]
  note.created_at = Time.now
  note.updated_at = Time.now
  note.save
  redirect '/'
end

get '/rss.xml' do
  @notes = Note.all :order => :id.desc
  builder :rss
end

get '/:id/edit' do
  @note = Note.get params[:id]
  @title = "Edit note"
  erb :edit
end

put '/:id' do
  note = Note.get params[:id]
  note.content = params[:content]
  note.complete = params[:complete] ? true : false
  note.updated_at = Time.now
  note.save
  redirect '/'
end

get '/:id/delete' do
  @note = Note.get params[:id]
  @title = "Confirm Deletion"
  erb :delete
end

delete '/:id' do
  note = Note.get params[:id]
  note.destroy
  redirect '/'
end

get '/:id/complete' do
  note = Note.get params[:id]
  note.complete = note.complete ? 0 : 1
  note.updated_at = Time.now
  note.save
  redirect '/'
end