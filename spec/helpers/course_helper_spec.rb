require 'rails_helper'

RSpec.feature 'View helpers', type: :helper do
  describe "#course_has_unpublished_changes" do
    it "returns true when course has the right content_status" do
      expect(helper.course_has_unpublished_changes(build(:course, content_status: 'published_with_unpublished_changes'))).to eq(true)
    end

    it "returns false when course has a different content_status" do
      expect(helper.course_has_unpublished_changes(build(:course, content_status: 'foo'))).to eq(false)
    end
  end

  describe "#course_content_tag_content" do
    it "returns correct content" do
      expect(helper.course_content_tag_content(build(:course, content_status: 'published'))).to eq('Published')
      expect(helper.course_content_tag_content(build(:course, content_status: 'empty'))).to eq('Empty')
      expect(helper.course_content_tag_content(build(:course, content_status: 'draft'))).to eq('Draft')
      expect(helper.course_content_tag_content(build(:course, content_status: 'published_with_unpublished_changes'))).to eq('Published *')
    end
  end

  describe "#course_content_tag_css_class" do
    it "returns correct css_class" do
      expect(helper.course_content_tag_css_class(build(:course, content_status: 'published'))).to eq('phase-tag--published')
      expect(helper.course_content_tag_css_class(build(:course, content_status: 'empty'))).to eq('phase-tag--no-content')
      expect(helper.course_content_tag_css_class(build(:course, content_status: 'draft'))).to eq('phase-tag--draft')
      expect(helper.course_content_tag_css_class(build(:course, content_status: 'published_with_unpublished_changes'))).to eq('phase-tag--published')
    end
  end
end
