require 'spec_helper'

describe Message do
  it { should validate_presence_of :body }
  it { should validate_presence_of :author }

  context 'with tenant scope' do
    prepare_scope :tenant
    describe "ancestry" do
      let(:person) { FactoryGirl.create :person }
      let(:parent_comment) { FactoryGirl.create :location_comment, :subject => "my subject" }

      it "has no parent id" do
        parent_comment.parent_id.should be_nil
      end
      describe "adding comment to comment" do
        let!(:child) { parent_comment.create_child :body => "child body", author: person }
        it "makes it available as child" do
          parent_comment.children.should include(child)
        end 
        it "has the correct reference" do
          child.reference.should == parent_comment.reference
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

    describe "propose as a addressee" do
      let(:message) { FactoryGirl.create :location_comment }
      let(:any_other_person) { FactoryGirl.create :person }
      subject{ message } 
      it { should_not be_propose_as_addressee(any_other_person) }
      it { should be_propose_as_addressee(message.author) }
      context "for child" do
        let(:child_author) { FactoryGirl.create :person }
        let!(:child_message) { message.create_child(body: "body", author: child_author) }
        subject { child_message }
        it { should be_propose_as_addressee(child_message.author) }
        it { should be_propose_as_addressee(message.author) }
        it { should_not be_propose_as_addressee(any_other_person) }
        it "should have parents addresse as proposed addresse" do
          parents_addressee = FactoryGirl.create :person 
          message.set_addressees [parents_addressee]
          message.save
          child_message.should be_propose_as_addressee(parents_addressee)
        end
      end
    end
  end
end
