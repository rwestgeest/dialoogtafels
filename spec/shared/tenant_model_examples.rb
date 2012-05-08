  shared_examples_for 'a_scoped_object' do |model, tenant|
    let(:model_class) { model.to_s.classify.constantize }
    let(:tenant_a) { FactoryGirl.create :tenant } 
    let(:tenant_b) { FactoryGirl.create :tenant } 

    it { should belong_to :tenant }

    describe 'finding' do
      let!(:tenant_object_aa) { create_tenant_oject! model, :tenant => tenant_a }
      let!(:tenant_object_ab) { create_tenant_oject! model, :tenant => tenant_b }
      it 'should find in scope of current tenant' do
        Tenant.current = tenant_a
        model_class.all.should == [tenant_object_aa]
        Tenant.current = tenant_b
        model_class.all.should == [tenant_object_ab]
      end
      it 'should find no persons if tenant = nil' do
        Tenant.current = nil
        model_class.all.should be_empty 
      end
    end
    describe 'creating' do
      it 'should create a person for the current tenant' do
        Tenant.current = tenant_a
        model_class.create FactoryGirl.attributes_for(model)
        model_class.last.tenant.should == tenant_a

        Tenant.current = tenant_b
        model_class.create FactoryGirl.attributes_for(model)
        model_class.last.tenant.should == tenant_b
      end
      it 'should create a person other tenant if requested' do
        Tenant.current = tenant_a
        p = model_class.new FactoryGirl.attributes_for(model)
        p.tenant_id = tenant_b.id
        p.save!
        p.should be_persisted 
        p.tenant.should == tenant_b
      end
      it "fails on creation when current tenant is not set" do
        Tenant.current = nil
        expect { create_tenant_oject! model }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end

    def create_tenant_oject! model, attr_overrides = {}
      object = model_class.new FactoryGirl.attributes_for(model)
      attr_overrides.each {|k,v| object.send(:"#{k}=", v)}
      object.save!
      object
    end

  end

