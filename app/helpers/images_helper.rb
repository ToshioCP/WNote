module ImagesHelper

# 画像を表すのに画像名を@で囲む構文で対応することにする。
# @を選んだのは、Markdownで使われていない文字だから。
# @自身を出力したいときもあるので、以下のようなルールを設けた
#
# 1. 行単位で構文解析をする
# 2. @で画像名を囲むパターンがなければ、その行はそのまま出力される
# 3. @で画像を囲むパターンがある行については、次のように対応する
# 3-1. @@のように、アットマークが2つ続いたら、それは1つの@(アットマーク自身）を表すものとする
# 3-2. 1個の@は画像名を囲んでいる場合は、画像を表す部分であると認識する
# 3-3. 先頭から上記3-2で解析して、@が1つ残った場合は、それは画像ではないので、@自身を表す
# 以下に例をあげる
# 解析の結果文字の部分は:L、画像を表す場合は:Cとなっている

# This is @image@.  =>  [[:L, "This is "], [:C, "image"], [:L, "."]]
# This is not @@image@@.  =>  [[:L, "This is not @image@."]]
# @@image@@ translates @image@ but 1 @ is not changed.  =>  [[:L, "@image@ translates "], [:C, "image"], [:L, " but 1 @ is not changed."]]
# @ is at sign.  =>  [[:L, "@ is at sign."]]
# @@ is two at signs.  =>  [[:L, "@@ is two at signs."]]

# 上記例をテストするための文字列（text_to_nodesの中身を取り出して、単体でテストする）
# text = "This is @image@.\nThis is not @@image@@.\n@@image@@ translates @image@ but 1 @ is not changed.\n@ is at sign.\n@@ is two at signs.\n"

  def parse(text)
    nodes = []
    text.each_line do |line|
      if ! (line =~ /@.+@/)
        node = []
        node[0] = [:L, line.chomp]
      else
    # 字句解析
        temp = line.chomp.split /@@/
        temp.map! {|t| t.split /@/}
        tokens = []
        temp.each do |t1|
          t1.each do |t2|
            tokens << [:L, t2]
            tokens << [:C, '@']
          end
          tokens.delete_at(tokens.length-1)
          tokens << [:L, '@']
        end
        tokens.delete_at(tokens.length-1)
    # 構文解析
        node = []
        s = ""
        mode = :start
        tokens.each do |t|
          case t[0]
            when :L then
              s = s + t[1]
              if mode != :C
                mode = :L
              end
            when :C then
              if mode == :C
                node << [:C, s]
#               if s == "" then "Syntax error" end
                s = ""
                mode = :start
              else
                if s != ""
                  node << [:L, s]
                end
                s = ""
                mode = :C
              end
            else
#             Unexpexcted error
           end
        end
        if mode == :C
          s = '@' + s
          if node[node.length-1][0] == :L
            node[node.length-1][1] << s
          else
            node << [:L, s]
          end
        elsif mode == :L
          node << [:L, s]
        else
#          do nothing. maybe mode == :start
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
          image = name ? Image.find_by(note_id: @note.id, name: name) : nil
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
