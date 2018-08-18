require 'net/http'
require 'uri'
require 'json'

class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    parsed_content = post_content["content"]
    translator = GoogleTypeTranslator.new
    @post = Post.new
    @post.content = translator.translate(parsed_content,current_user.language)
    @post.user_id = current_user.id
    @post.user_name = current_user.name
    @post.save

    @index_content = translator.translate(parsed_content,current_user.language)
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(
         content: post_content,
         user_id: user_id
      )
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_content
      params.require(:post).permit(:content)
    end

    def user_id
      @current_user.id
    end
end


class GoogleTypeTranslator
  def translate(query,users_lang)
    url = URI.parse('https://www.googleapis.com/language/translate/v2')
    params = {
        q: query,
        target: users_lang,
        source: lang_kind(query),
        key: "API-KEY"
    }
    url.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(url)
    JSON.parse(res.body)["data"]["translations"].first["translatedText"]
  end

  def lang_kind(query)
    url = URI.parse('https://translation.googleapis.com/language/translate/v2/detect')
    params = {
        q: query,
        key: "API-Key"
    }
    url.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(url)
    JSON.parse(res.body)["data"]["detections"][0][0]["language"]
  end
end