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

  def svg_icon name
    return "" unless name.instance_of? String
    case name
    when "arrow-up"
      tag.svg(xmlns: "http://www.w3.org/2000/svg", width: "16", height: "16", fill: "currentColor",\
              class: "bi bi-arrow-up", viewBox: "0 0 16 16", aria_hidden: "true") do
        tag.path fill_rule: "evenodd",\
              d: "M8 15a.5.5 0 0 0 .5-.5V2.707l3.146 3.147a.5.5 0 0 0 .708-.708l-4-4a.5.5 0 0 0-.708 0l-4 4a.5.5 0 1 0 .708.708L7.5 2.707V14.5a.5.5 0 0 0 .5.5z"
      end
    when "arrow-left"
      tag.svg(xmlns: "http://www.w3.org/2000/svg", width: "16", height: "16", fill: "currentColor",\
              class: "bi bi-arrow-left", viewBox: "0 0 16 16", aria_hidden: "true") do
        tag.path fill_rule: "evenodd",\
              d: "M15 8a.5.5 0 0 0-.5-.5H2.707l3.147-3.146a.5.5 0 1 0-.708-.708l-4 4a.5.5 0 0 0 0 .708l4 4a.5.5 0 0 0 .708-.708L2.707 8.5H14.5A.5.5 0 0 0 15 8z"
      end
    when "arrow-right"
      tag.svg(xmlns: "http://www.w3.org/2000/svg", width: "16", height: "16", fill: "currentColor",\
              class: "bi bi-arrow-right", viewBox: "0 0 16 16", aria_hidden: "true") do
        tag.path fill_rule: "evenodd",\
              d: "M1 8a.5.5 0 0 1 .5-.5h11.793l-3.147-3.146a.5.5 0 0 1 .708-.708l4 4a.5.5 0 0 1 0 .708l-4 4a.5.5 0 0 1-.708-.708L13.293 8.5H1.5A.5.5 0 0 1 1 8z"
      end
    else
      ""
    end
  end
end
