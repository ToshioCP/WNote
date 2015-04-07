require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  test "the presence of the title" do
    note = Note.new(title: "", text: "Text is not empty.", section_id: sections(:one).id)
    assert_not note.save, "Saved the note without a title."
  end
  test "the presence of the text" do
    note = Note.new(title: "title is not empty", text: "", section_id: sections(:one).id)
    assert_not note.save, "Saved the note without a text."
  end
# Every note must belong to the section.
  test "the presence of the reference to the section" do
    note = Note.new(title: "title", text: "text is not empty.", section_id: nil)
    assert_not note.save, "Saved the note without a reference to the section."
  end
  test "update the note_order in the parent section when note was created" do
    section = sections(:one)
    note = section.notes.create(title: "title", text: "text")
    assert Section.find(section.id).note_order.include?(note.id.to_s),
      "Note_id was not added to the note_order in the section when the note was created."
  end
  test "move the note_id from the note_order in the old section to the one in the new section when note was updated" do

    note = notes(:install_rbenv)
    old_note_order = note.section.note_order.dup
    note.update(title: "New Title") # if section was not changed.
    assert_equal old_note_order, note.section.note_order,
      "note_order in the section was changed when the section_id in the note was not updated."
    old_section_id = note.section.id
    note.update(section_id: sections(:two).id) # if section_id was changed.
    new_section_id = note.section.id
    assert_not_equal old_section_id, new_section_id, "Section_id was updated but not changed."
    assert_not Section.find(old_section_id).note_order.include?(note.id.to_s),
      "Note_id is still in the note_order in the old section even when the note was updated."
    assert Section.find(new_section_id).note_order.include?(note.id.to_s),
      "Note_id was not added to the note_order in the new section when the note was updated."
  end
  test "remove the note_id in the note_order when note was deleted" do
    note = notes(:install_rbenv)
    section = sections(:one)
    note.destroy
    assert_not Section.find(section.id).note_order.include?(note.id.to_s),
      "Note_id is still in the note_order in the section even when the note was deleted."
  end
end
