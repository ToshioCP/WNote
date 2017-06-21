module ImagesHelper

=begin rdoc
画像を表すのに画像名を@で囲む構文で対応することにする。
@を選んだのは、Markdownで使われていない文字だから。
@自身を出力したいときは@@と@を2個連続することにする。
しかし、@@@のように3個連続の場合、@自身を表す@2つのセットが前の2つなのか後の2つなのか、はっきりしなければならないので、以下のようなルールを設けた。

1. 行単位で構文解析をする
2. 先頭の文字から順に1文字ずつ調べていく
3. @が2個連続したらそれは文字の@（1個）とする
4. @の次に@以外の文字が続きその後また@が続いたら、それは画像の名前であると解釈する（@は除かれる）
5. @以外の文字はその文字自身を表す
6. 3,4,5については先頭から調べてそれぞれに一致するものが見つかるごとに結果を出力する
7. 4の解析の途中で行が終了した場合は、4の始まりの@は@自身を表す

この解析のためにメソッドparseの中では状態遷移を表す変数modeを使っている。

[mode=0] @が出る前の状態、または「@ファイル名@」が解析し終わって、はじめに戻った状態
[mode=1] @が現れた直後
[mode=2] @の次に@以外の文字列が出てから次の@（または行末）が出る間までの状態
[mode=3] 終了状態

mode=1と2を区別することによって、プログラムが分かりやすくなる。

以下に例をあげる
解析の結果文字の部分は:L、画像を表す場合は:Cとして、配列で出力を表している。

  This is @image@.  =>  [[:L, "This is "], [:C, "image"], [:L, "."]]
  This is not @@image@@.  =>  [[:L, "This is not @image@."]]
  @@image@@ translates @image@ but 1 @ is not changed.  =>  [[:L, "@image@ translates "], [:C, "image"], [:L, " but 1 @ is not changed."]]
  @ is at sign.  =>  [[:L, "@ is at sign."]]
  @@@@ is two at signs.  =>  [[:L, "@@ is two at signs."]]
  @@@sample@@@ => [[:L, "@"], [:C, "sample], [:L, "@"]]
  これは[[:C, "@sample@"]]や、[[:L, "@"], [:C, "sample@"]]ではない。前から1文字ずつ順に解析すると上記のようになる

上記例をテストするための文字列（text_to_nodesの中身を取り出して、単体でテストする）

  text = "This is @image@.\nThis is not @@image@@.\n@@image@@ translates @image@ but 1 @ is not changed.\n@ is at sign.\n@@@@ is two at signs.\n@@@sample@@@\n"
=end

  def parse(text)
    nodes = []
    text.each_line do |line|
      node = [] # output
      s = "" # buffer
      fn = "" # buffer for image file name
      mode = 0 # 0 @が出る前の状態 1 @が現れた直後 2 @の次に@以外の文字列が出て、その後次の@が出ていない状態 3 終了状態
      line.each_char do |c|
        case mode
          when 0 then
            case c
              when "@" then
                mode = 1
              when "\n" then
                if ! s.empty?
                  node << [:L, s.dup]
                  s.clear
                end
                mode = 3
              else
                s << c
                mode = 0 #変わっていないので、なくても良い
            end
          when 1 then
            case c
              when "@" then
                s << "@"
                mode = 0
              when "\n" then
                node << [:L, s+"@"]
                s.clear
                mode = 3
              else
                fn = c
                mode = 2
            end
          when 2 then
            case c
              when "@" then
                if ! s.empty?
                  node << [:L, s.dup]
                  s.clear
                end
                node << [:C, fn.dup]
                fn.clear
                mode = 0
              when "\n" then
                node << [:L, s+"@"+fn]
                s.clear
                fn.clear
                mode = 3
              else
                fn << c
                mode = 2 #変わっていないので、なくても良い
            end
          when 3 then
            #Unexpected error
          else
            #Unexpected error
        end
      end
      nodes << node
    end
    return nodes
  end

  def evaluate(nodes)
    text = ""
    nodes.each do |node|
      line = ""
      node.each do |n|
        if n[0] == :L
          line = line + n[1]
        elsif n[0] == :C
          name, width, height, cl = image_element(n[1])
          image = name ? Image.find_by(name: "#{@article.user.id}_#{name}") : nil
          if image
            w = width ? "width = \"#{width}\"" : ""
            h = height ? "height = \"#{height}\"" : ""
            c = cl ? "class = \"#{cl}\"" : ""
            line = line + "<img src=\"data:image/jpeg;base64," + Base64.strict_encode64(image.image) + "\" " + w + " " + h + " " + c + " >"
          end
        else
#          Unexpected error
        end
      end
      text = text + line + "\n"
    end
    return text
  end

  def evaluate_for_epub(nodes)
    image_ids = []
    text = ""
    nodes.each do |node|
      line = ""
      node.each do |n|
        if n[0] == :L
          line = line + n[1]
        elsif n[0] == :C
          name, width, height, cl = image_element(n[1])
          image = name ? Image.find_by(name: "#{@user.id}_#{name}") : nil
          if image
            w = width ? "width = \"#{width}\"" : ""
            h = height ? "height = \"#{height}\"" : ""
            c = cl ? "class = \"#{cl}\"" : ""
            line = line + "<img id=\"image_#{name}\" src=\"./images/b_#{name}.jpg\" " + w + " " + h + " " + c + " />"
            image_ids << image.id
          end
        else
#          Unexpected error
        end
      end
      text = text + line + "\n"
    end
    return text, image_ids
  end

# @で囲まれたイメージの部分は、「イメージ名, 幅, 高さ, クラス」となっている	。
# クラスを指定すると、Bootstrapのクラスが使える。
# 例えば、img-responsive、center-block、img-rounded、img-circle、img-thumbnail
# 幅と高さは省略できる。省略した場合はイメージのそのままのサイズで表示される。
# name, 100, 200 => イメージ名がnameで幅100高さ200
# name, 100 => イメージ名がnameで幅100高さ省略
# name,, 200 => イメージ名がnameで幅省略高さ200

  def image_element(s)
    if s =~ /\A\s*([^ ,]+?)\s*,\s*(\d+?)\s*,\s*(\d+?)\s*,([a-zA-Z0-9_ -]+?)\Z/
      return $1, $2, $3, $4
    elsif s =~ /\A\s*([^ ,]+?)\s*,\s*(\d+?)\s*,\s*(\d+?)\s*\Z/
      return $1, $2, $3, nil
    elsif s =~ /\A\s*([^ ,]+?)\s*,\s*(\d+?)\s*,\s*,([a-zA-Z0-9_ -]+?)\Z/
      return $1, $2, nil, $3
    elsif s =~ /\A\s*([^ ,]+?)\s*,\s*,\s*(\d+?)\s*,([a-zA-Z0-9_ -]+?)\Z/
      return $1, nil, $2, $3
    elsif s =~ /\A\s*([^ ,]+?)\s*,\s*(\d+?)\s*\Z/
      return $1, $2, nil, nil
    elsif s =~ /\A\s*([^ ,]+?)\s*,\s*,\s*(\d+?)\s*\Z/
      return $1, nil, $2, nil
    elsif s =~ /\A\s*([^ ,]+?)\s*,\s*,\s*,([a-zA-Z0-9_ -]+?)\Z/
      return $1, nil, nil, $2
    elsif s =~ /\A\s*([^ ,]+?)\s*\Z/
      return $1, nil, nil, nil
    else # error
     return nil, nil, nil, nil
    end
  end
end
