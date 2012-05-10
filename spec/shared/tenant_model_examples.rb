  shared_examples_for 'a_scoped_object' do |model|
    let(:model_class) { model.to_s.classify.constantize }
    let(:tenant_a) { FactoryGirl.create :tenant } 
    let(:tenant_b) { FactoryGirl.create :tenant } 

    it { should belong_to :tenant }

    describe "finding" do
      let!(:object_in_tenant_a) { for_tenant(tenant_a) { FactoryGirl.create model } }
      let!(:object_in_tenant_b) { for_tenant(tenant_b) { FactoryGirl.create model } }
      it "should find in scope of current tenant"  do
        Tenant.current = tenant_a
        model_class.all.should include object_in_tenant_a
        model_class.all.should_not include object_in_tenant_b
        Tenant.current = tenant_b
        model_class.all.should include object_in_tenant_b
        model_class.all.should_not include object_in_tenant_a
      end
      it "should find no #{model}s if tenant = nil" do
        Tenant.current = nil
        model_class.all.should be_empty 
      end
    end
    describe "creating" do
      it "should create a #{model} for the current tenant" do
        Tenant.current = tenant_a
        FactoryGirl.create model
        model_class.last.tenant.should == tenant_a

        Tenant.current = tenant_b
        FactoryGirl.create model
        model_class.last.tenant.should == tenant_b
      end
      it "fails on creation when current tenant is not set" do
        Tenant.current = nil
        expect { FactoryGirl.create model }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end

  end

