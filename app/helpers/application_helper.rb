module ApplicationHelper
  def change_locale locale
    uri = request.fullpath
    if uri.include?('locale')
      uri.gsub(/locale=[a-z][a-z]/, 'locale=ja')
    elsif uri.include?('?')
      uri+'&locale=ja'
    else
      uri + '?locale=ja'
    end
  end
end
