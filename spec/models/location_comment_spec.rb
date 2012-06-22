require 'spec_helper'

describe LocationComment do
  it_should_behave_like 'a_scoped_object', :location_comment
  it { should validate_presence_of :body }
  it { should validate_presence_of :location }
  it { should validate_presence_of :author }

  def a_comment(attributes = {})
    LocationComment.new(attributes)
  end
  describe "author_name" do
    it "should delegate to author" do
      a_comment(:author => Person.new(:name => "gijs")).author_name.should == "gijs"
      a_comment(:author => Person.new(:name => "harry")).author_name.should == "harry"
    end
    it "should be nil if author is nil" do
      a_comment.author_name.should be_nil
    end
  end
  context 'with tenant scope' do
    prepare_scope :tenant
    describe "ancestry" do
      let(:person) { FactoryGirl.create :person }
      let(:parent_comment) { FactoryGirl.create :location_comment, :subject => "my subject" }
      let(:location) { parent_comment.location }

      it "has no parent id" do
        parent_comment.parent_id.should be_nil
      end
      describe "adding comment to comment" do
        let!(:child) { parent_comment.create_child :body => "child body", author: person }
        it "makes it available as child" do
          parent_comment.children.should include(child)
        end 
        it "has the correct location" do
          child.location.should == parent_comment.location
        end 
        it "has parents_id as parent_id" do
          child.parent_id.should == parent_comment.id
        end
      end 
      describe "parent_subject" do
        subject { parent_comment.parent_subject} 
        it { should == parent_comment.subject } 

        describe "of child" do
          let!(:child) { parent_comment.create_child(:body => "child", author: person) } 
          it "is a reaction to the parent comments subject" do
            child.parent_subject.should == I18n.t('location_comment.reaction_to', :subject => parent_comment.subject)
          end
          describe "of childs child" do
            let(:childs_child) { child.create_child(:body => "childschild", author: person) } 
            it "is a recation to the parents parents subject" do
              childs_child.parent_subject.should == I18n.t('location_comment.reaction_to', :subject => parent_comment.subject)
            end
          end
        end
      end
    end
  end

end
