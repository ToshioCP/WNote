require 'test_helper'

class SectionTest < ActiveSupport::TestCase
  test "the presence of the heading" do
    section = Section.new(heading: "", article: articles(:one))
    assert_not section.save, "Saved the note without a heading."
  end
  test "the presence of the reference to the article" do
    section = Section.new(heading: "heading")
    assert_not section.save, "Saved the note without a reference to the article."
  end
end
