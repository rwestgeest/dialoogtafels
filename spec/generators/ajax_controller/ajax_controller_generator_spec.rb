require 'spec_helper'
require 'tmpdir'
require 'generators/ajax_controller/ajax_controller_generator'

describe AjaxControllerGenerator do 
  destination File.expand_path("ajax_controller_gernerator", Dir.tmpdir)
  subject { file('app/controllers/posts_controller.rb') }
  before do 
    prepare_destination
    run_generator %w{posts --orm active_record}
  end
  describe 'the controller' do
    it { should exist }
    it { should contain "class PostsController" }
  end
  describe 'the view' do 
    describe "index" do
      describe "partial" do
        subject { file('app/views/posts/_index.html.haml') }
        it { should contain "- if posts.empty?" }
        it { should contain "#post_new" }
        it { should contain "I18n.t('.empty')" }
        it { should contain "link_to I18n.t('.create_first'), new_post_path, :'data-remote' => true" }
        it { should contain "link_to I18n.t('.new'), new_post_path, :'data-remote' => true" }
        it { should contain "= render partial: 'posts/_post', collection: posts" }
      end
      describe "list entry" do
        subject { file('app/views/posts/_post.html.haml') }
        it { should exist } 
        it { should contain 'container{:id => "post_#{post.to_param}"}' }
        it { should contain "= link_to image_tag('edit.gif'), edit_post_path(post.to_param), :class => 'edit', :title => I18n.t('.edit_title'), :'data-remote' => true" }
      end
      describe "javascript" do
        subject { file('app/views/posts/index.js.erb') }
        it { should exist } 
        it { should contain "$('#posts').html('<%= escape_javascript(render(partial:\"index\", locals: {posts: @posts})) %>');" }
      end
    end
  end
end
