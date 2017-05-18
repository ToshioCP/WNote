module ApplicationHelper
  def change_locale locale
    uri = request.fullpath
    return uri unless locale =~ /en|ja/
    if uri.include?('locale')
      uri.gsub(/locale=[a-z][a-z]/, "locale=#{locale}")
    elsif uri.include?('?')
      uri+"&locale=#{locale}"
    else
      uri + "?locale=#{locale}"
    end
  end
end
