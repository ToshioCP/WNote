require 'test_helper'

class NoteTest < ActiveSupport::TestCase
# save and read test
  test "save and read data correctly" do
    prms = {title: "title", text: "text", section_id: sections(:one).id}
    note1 = Note.new(prms)
    assert note1.save
    note2 = Note.find(note1.id)
    prms.each do |key,value|
      assert note2[key] == value
    end
  end
# validation test
  attributes = ['a title', 'a text', 'a section_id']
  attributes.each do |attribute|
    attribute2 = attribute.split(' ').at(1)
    test "the presence of the #{attribute2}" do
      note = notes(:install_rbenv)
      note[attribute2] = ''
      assert_not note.save, "Saved the note without #{attribute}."
    end
  end
# relation (to the section) test
  test "the update of the note_order" do
    section = sections(:one)
    note = section.notes.create(title: "title", text: "text")
    assert Section.find(sections(:one).id).note_order.include?(note.id.to_s),
      "The note_id was not added to the note_order in the section when the note was created."
  end
  test "the change of the parent section of the note" do
    note = notes(:install_rbenv)
    old_note_order = note.section.note_order.dup
    old_section_id = note.section.id
    note.update(section_id: sections(:two).id) # if section_id was changed.
    new_section_id = note.section.id
    assert_not Section.find(old_section_id).note_order.include?(note.id.to_s),
      "The note_id was still in the note_order in the old section even when the note was updated."
    assert Section.find(new_section_id).note_order.include?(note.id.to_s),
      "The note_id was not added to the note_order in the new section even when the note was updated."
  end
  test "the deletion of the note" do
    note = notes(:install_rbenv)
    section = note.section
    assert_difference('Image.count', -2) do
      note.destroy
    end
    assert_not Section.find(section.id).note_order.include?(note.id.to_s),
      "The note_id was still in the note_order in the section even when the note was deleted."
  end
end
