shared_examples_for "a_message" do
  it "should delegate to author" do
    a_message(:author => Person.new(:name => "gijs")).author_name.should == "gijs"
    a_message(:author => Person.new(:name => "harry")).author_name.should == "harry"
  end
  it "should be nil if author is nil" do
    a_message.author_name.should be_nil
  end
end

shared_examples_for "a_message_notifier" do |clazz, notification|
  prepare_scope :tenant
  let(:author) { FactoryGirl.create :person }

  it "sends a notification to the author" do
    Postman.should_receive(:schedule_message_notification) do |comment, addressee| 
      comment.should be_an_instance_of(LocationComment)
      comment.should be_persisted
      addressee.should == author
    end
    create_messaage_from(author)
  end

  context "with addressees" do
    let(:addressee1) { FactoryGirl.create :person }
    let(:addressee2) { FactoryGirl.create :person }

    it "sends a notification to the addressees" do
      Postman.should_receive(:schedule_message_notification).with(an_instance_of(LocationComment), author)
      Postman.should_receive(:schedule_message_notification).with(an_instance_of(LocationComment), addressee1)
      Postman.should_receive(:schedule_message_notification).with(an_instance_of(LocationComment), addressee2)
      create_messaage_from(author, for_addressees(addressee1, addressee2))
    end

    it "when author in addressee list, sends notification to sender once" do
      Postman.should_receive(:schedule_message_notification).with(an_instance_of(LocationComment), author).once
      create_messaage_from(author, for_addressees(author))
    end

    context "from parent" do
      let!(:parent) { create_messaage_from(author, for_addressees(addressee1)) }
      let(:replier) { FactoryGirl.create :person }
      it "sends a notification to the addressees and replie" do
        Postman.should_receive(:schedule_message_notification).with(an_instance_of(LocationComment), author)
        Postman.should_receive(:schedule_message_notification).with(an_instance_of(LocationComment), replier)
        Postman.should_receive(:schedule_message_notification).with(an_instance_of(LocationComment), addressee1)
        create_messaage_from(replier, for_no_addressees,  as_reply_to(parent))
      end
      it "when addresses set, sends a notification these addressees and replie" do
        Postman.should_receive(:schedule_message_notification).with(an_instance_of(LocationComment), replier)
        Postman.should_receive(:schedule_message_notification).with(an_instance_of(LocationComment), addressee2)
        create_messaage_from(replier, for_addressees(addressee2),  as_reply_to(parent))
      end
    end
    def for_no_addressees
      []
    end

    def for_addressees(*addressee_list)
      addressee_list.map {|addressee| addressee.id}
    end
    def as_reply_to(comment)
      comment
    end
  end
end

