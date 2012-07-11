require 'spec_helper'

describe City::TodosController do
  render_views 
  prepare_scope :tenant
  login_as :coordinator

  attr_reader :location
  before(:all) { @location = FactoryGirl.create :location }

  let(:todo) { FactoryGirl.create :location_todo, :project => location.project }

  def with_location_scope(request_parameters = {})
    {:location_id => location.to_param }.merge(request_parameters)
  end

  context "without supplying a location" do
    it { xhr(:get, :index); should respond_with(404) }
    it { xhr(:put, :update, :id => "1", :checked => "true"); should respond_with(404) }
  end

  describe "GET 'index'" do
    before { xhr :get, 'index', with_location_scope }
    it "returns http success" do
      response.should be_success
    end

    it "assigs the location" do
      assigns[:location].should == location
    end
  end

  describe "PUT 'update'" do
    def update(todo, checked = true)
      xhr :put, :update, with_location_scope(:id => todo, :checked => checked ? 'true' : 'false')
    end
    context "when checking" do
      before { update(todo.to_param) }
      it "updates the todo" do
        todo.should be_done_for_location(location)
      end 
      it "assigns all todos" do
        assigns[:todos].should == [todo]
      end
    end
    context "when unchecking" do
      before { location.tick_done(todo.id); update(todo.to_param, false) }
      it "updates the todo" do
        todo.should_not be_done_for_location(location)
      end 
      it "assigns all todos" do
        assigns[:todos].should == [todo]
      end
    end
  end

end
