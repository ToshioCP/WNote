require 'test_helper'

class ImageTest < ActiveSupport::TestCase
# validation test
  test "save image" do
    image = Image.new name: '', image: ('a'*(3.megabytes)).encode('ASCII-8BIT')
    assert_not image.save, "Name is empty, but saved."
    image = Image.new name: 'big_image', image: ('a'*(3.megabytes + 1)).encode('ASCII-8BIT')
    assert_not image.save, "Big image saved."
  end
end
