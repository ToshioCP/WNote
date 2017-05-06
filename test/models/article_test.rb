require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  attributes = ['a title', 'an author', 'a language', 'a modified_datetime', 'an identifier_uuid']
# This loop has 5 tests.
  attributes.each do |attribute|
    attribute2 = attribute.split(' ').at(1)
    test "the presence of the #{attribute2}" do
      article = articles(:wnote)
#      String is OK in the argument as well as Symbol.
#      String ====> article[attribute2] = ''
#      Symbol ====> article[attribute2.intern] = ''
      article[attribute2] = ''
      assert_not article.save, "Saved the article without #{attribute}."
    end
  end

  test "delete the desendant sections and notes when article deleted" do
    assert_difference('Section.count',-2) do
      assert_difference('Note.count',-4) do
        articles(:wnote).destroy
      end
    end
  end
end
