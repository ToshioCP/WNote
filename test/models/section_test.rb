require 'test_helper'

class SectionTest < ActiveSupport::TestCase
  test "the presence of the heading" do
    section = Section.new(heading: "", article: articles(:wnote))
    assert_not section.save, "Saved the note without a heading."
  end
  test "the presence of the reference to the article" do
    section = Section.new(heading: "heading")
    assert_not section.save, "Saved the note without a reference to the article."
  end
  test "update the section_order in the article when section created" do
    article = articles(:wnote)
    section = article.sections.create(heading: "heading")
    assert Article.find(article.id).section_order.include?(section.id.to_s),
      "Section_id was not added to the section_order in the article when section was created."
  end
  test "move the section_id from the section_order in the old article to the one in the new article when section was updated" do
    section = sections(:one)
    old_section_order = section.article.section_order.dup
    section.update(heading: "New Headding") # if article_id was not changed.
    assert_equal old_section_order, section.article.section_order,
      "Section_order in the article was changed when the article_id in the section was not updated."
    old_article_id = section.article.id
    section.update(article_id: articles(:rails_howto).id) # if article_id was changed.
    new_article_id = section.article.id
    assert_not_equal old_article_id, new_article_id, "Article_id was updated but not changed."
    assert_not Article.find(old_article_id).section_order.include?(section.id.to_s),
      "Section_id is still in the section_order in the old article even when the section was updated."
    assert Article.find(new_article_id).section_order.include?(section.id.to_s),
      "Section_id was not added to the section_order in the new article when the section was updated."
  end
  test "delete notes and remove the section_id in the section_order when section deleted" do
    section = sections(:one)
    article = section.article # We assume it equals to articles(:wnote) in the fixture.
    assert_difference('Note.count', -3) do
      section.destroy
    end
# database has been updated but variable article still has old data.
# So, we must read database again to get updated data.
    assert_not Article.find(article.id).section_order.include?(section.id.to_s),
     "Section_id is still in the section_order even when section was deleted."
  end
end
