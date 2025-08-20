require 'rails_helper'

RSpec.describe RemoteLinkPaginationHelper do
  describe RemoteLinkPaginationHelper::LinkRenderer do
    let(:renderer) { described_class.new }

    describe '#link' do
      it 'adds data-remote attribute to links' do
        attributes = {}

        # Mock the parent method
        allow_any_instance_of(WillPaginate::ActionView::LinkRenderer).to receive(:link)
          .and_return('<a href="/page/2">Next</a>')

        renderer.link('Next', '/page/2', attributes)
        expect(attributes['data-remote']).to be true
      end

      it 'preserves existing attributes' do
        attributes = { 'class' => 'pagination-link' }

        allow_any_instance_of(WillPaginate::ActionView::LinkRenderer).to receive(:link)
          .and_return('<a href="/page/2">Next</a>')

        renderer.link('Next', '/page/2', attributes)

        expect(attributes['data-remote']).to be true
        expect(attributes['class']).to eq('pagination-link')
      end
    end

    describe 'inheritance' do
      it 'inherits from WillPaginate::ActionView::LinkRenderer' do
        expect(described_class).to be < WillPaginate::ActionView::LinkRenderer
      end
    end

    describe 'module structure' do
      it 'defines LinkRenderer class inside the module' do
        expect(described_class).to be_a(Class)
      end
    end
  end
end
