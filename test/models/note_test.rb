require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  test "the presence of the title" do
    note = Note.new(title: "", text: "Text is not empty.")
    assert_not note.save, "Saved the note without a title."
  end
  test "the presence of the text" do
    note = Note.new(title: "title is not empty", text: "")
    assert_not note.save, "Saved the note without a text."
  end
end
