require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "the presence of the title" do
    article = Article.new(title: "", author: "ToshioCP", date: "22/03/2015")
    assert_not article.save, "Saved the note without a title."
  end
  test "the presence of the author" do
    article = Article.new(title: "WNote howto", author: "", date: "22/03/2015")
    assert_not article.save, "Saved the note without a author."
  end
  test "the presence of the date" do
    article = Article.new(title: "WNote howto", author: "ToshioCP", date: nil)
    assert_not article.save, "Saved the note without a date."
  end
  test "delete the desendant sections and notes when article deleted" do
    assert_difference('Section.count',-2) do
      assert_difference('Note.count',-4) do
        articles(:wnote).destroy
      end
    end
  end
end
