require "sinatra"
require "tilt/erubis"
require "sinatra/reloader" if development?

before do
  @toc = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |line, idx|
      "<p id=paragraph#{idx}>#{line}</p>"
    end.join
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @toc[number-1]

  redirect "/" unless (1..@toc.size).cover? number

  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/show/:name" do
  params[:name]
end

def each_chapter
  @toc.each_with_index do |name, idx|
    number = idx + 1
    content = File.read("data/chp#{number}.txt")
    yield number, name, content
  end
end

def chapters_matching(query)
  result = []

  return result unless query

  each_chapter do |number, name, content|
    matches = {}
    content.split("\n\n").each_with_index do |paragraph, idx|
      matches[idx] = paragraph if paragraph.include?(query)
    end
    result << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  result
end

get "/search" do
  @result = chapters_matching(params[:query])
  erb :search
end