  shared_examples_for "creating_a_contributor" do |contributor_class|
    it "associates it for the tenants active project" do
      create_contributor
      contributor_class.last.project.should == Tenant.current.active_project
    end

    it "associates it for the project given if provided" do
      project = FactoryGirl.create :project
      create_contributor :project => project
      contributor_class.last.project.should == project
    end

    it "creates an person" do
      expect{ create_contributor }.to change(Person, :count).by(1)
      contributor_class.last.person.should == Person.last
    end

    context "when person already exist" do
      attr_reader :person
      before(:all) {  @person =  FactoryGirl.create :person } 

      it "reuses a person" do
        expect { create_contributor(:name => person.name, :email => person.email) }.not_to change(Person,:count)
      end

      it "resues a person disregarding the case used in email address" do
        expect { create_contributor(:name => person.name, :email => person.email.upcase) }.not_to change(Person,:count)
      end

      context "and telephone and name assigned before email" do
        let(:contributor) { contributor_class.new :name => "Harry Potter", :telephone => "call potter" }
        before do 
          contributor.email = person.email 
        end
        it "reuses the person" do
          contributor.email = person.email
        end
        it "ignores the name and phone" do
          contributor.name.should_not == "Harry Potter"
          contributor.telephone.should_not == "call potter"
        end
      end
    end

    context "when account with the same email exists for another tenant" do
      attr_reader :existing_account
      before do
        for_tenant(FactoryGirl.create :tenant) do
          @existing_account = FactoryGirl.create contributor_class.to_s.underscore
        end
      end

      it "creates a #{contributor_class}" do
        expect { create_contributor(:email => existing_account.email) }.to change(Contributor, :count).by(1)
      end

      it "creates a person " do
        expect { create_contributor(:email => existing_account.email) }.to change(Person, :count).by(1)
      end

    end

    it "creates a worker account with role conversation_leader" do
      expect{ create_contributor }.to change(Account, :count).by(1)
      Account.last.person.should == Person.last
    end

    it "sends a welcome message" do
      Postman.should_receive(:deliver).with(:account_welcome, an_instance_of(TenantAccount))
      create_contributor
    end
  end

