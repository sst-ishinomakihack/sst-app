module SessionsHelper
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in?
    !current_user.nil?
  end

  def signed_in_user
    redirect_to signin_url unless signed_in?
  end

  def translate_timeline(timeline_content)
    translator = GoogleTypeTranslator.new
    translator.translate(timeline_content,current_user.language)
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

    if lang_kind(query) == users_lang
      query
    else
      JSON.parse(res.body)["data"]["translations"].first["translatedText"]
    end
  end

  def lang_kind(query)
    url = URI.parse('https://translation.googleapis.com/language/translate/v2/detect')
    params = {
        q: query,
        key: "API-KEY"
    }
    url.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(url)
    JSON.parse(res.body)["data"]["detections"][0][0]["language"]
  end
end