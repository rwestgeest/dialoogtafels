require 'spec_helper'

describe LocationComment do
  it_should_behave_like 'a_scoped_object', :location_comment
  it { should validate_presence_of :body }
  it { should validate_presence_of :location }
  it { should validate_presence_of :author }

  context 'with tenant scope' do
    prepare_scope :tenant
    describe "ancestry" do
      let(:person) { FactoryGirl.create :person }
      let(:parent_comment) { FactoryGirl.create :location_comment }
      let(:location) { parent_comment.location }

      describe "adding comment to comment" do
        let!(:child) { parent_comment.create_child :body => "child body", author: person }
        it "makes it available as child" do
          parent_comment.children.should include(child)
        end 
        it "has the correct location" do
          child.location.should == parent_comment.location
        end 
      end 
    end
  end
end
