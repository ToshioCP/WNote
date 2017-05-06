require 'test_helper'

class SectionTest < ActiveSupport::TestCase
# save and read test
  test "save and read data correctly" do
    prms = {heading: "heading", article_id: articles(:wnote).id}
    section1 = Section.new(prms)
    assert section1.save
    section2 = Section.find(section1.id)
    prms.each do |key,value|
      assert section2[key] == value
    end
  end
# Validation test
  test "the presence of the heading" do
# Both article_id and article are the attributes in the section object.
# So, following two assignments make the same results.
#   section.article_id = articles(:wnote).id
#   section.article = articles(:wnote)
    section = Section.new(heading: "", article: articles(:wnote))
    assert_not section.save, "Saved the note without a heading."
  end
  test "the presence of the reference to the article" do
    section = Section.new(heading: "heading")
    assert_not section.save, "Saved the note without a reference to the article."
  end
# relation test
  test "update the section_order in the article when section created" do
    article = articles(:wnote)
    section = article.sections.create(heading: "heading")
    assert Article.find(article.id).section_order.include?(section.id.to_s),
      "Section_id was not added to the section_order in the article when section was created."
  end
  test "the change of the parent article of the section" do
    section = sections(:one)
    old_section_order = section.article.section_order.dup
    old_article_id = section.article.id
    section.update(article_id: articles(:rails_howto).id) # if article_id was changed.
    new_article_id = section.article.id
    assert_not Article.find(old_article_id).section_order.include?(section.id.to_s),
      "Section_id is still in the section_order in the old article even when the section was updated."
    assert Article.find(new_article_id).section_order.include?(section.id.to_s),
      "Section_id was not added to the section_order in the new article when the section was updated."
  end
  test "the deletion of the section" do
    section = sections(:one)
    article = section.article # We assume it equals to articles(:wnote) in the fixture.
    assert_difference('Note.count', -3) do
      section.destroy
    end
# database has been updated but the variable article still has the old data.
# So, we must read the data of the article from the database to update it.
    assert_not Article.find(article.id).section_order.include?(section.id.to_s),
     "Section_id is still in the section_order even when section was deleted."
  end
end
