require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#paginate' do
    let(:collection) { double('collection') }
    let(:custom_params) { { previous_label: 'Anterior', next_label: 'Próximo' } }

    it 'calls will_paginate with custom renderer' do
      expect(helper).to receive(:will_paginate).with(
        collection,
        custom_params.merge(renderer: RemoteLinkPaginationHelper::LinkRenderer)
      )

      helper.paginate(collection, custom_params)
    end

    it 'works with empty params' do
      expect(helper).to receive(:will_paginate).with(
        collection,
        hash_including(renderer: RemoteLinkPaginationHelper::LinkRenderer)
      )

      helper.paginate(collection)
    end

    it 'merges custom params with renderer' do
      expect(helper).to receive(:will_paginate).with(
        collection,
        hash_including(
          renderer: RemoteLinkPaginationHelper::LinkRenderer,
          previous_label: 'Anterior'
        )
      )

      helper.paginate(collection, previous_label: 'Anterior')
    end
  end

  describe '#flash_class' do
    it 'returns green classes for success' do
      result = helper.flash_class('success')
      expect(result).to eq('bg-green-50 border-green-200 text-green-800')
    end

    it 'returns red classes for danger' do
      result = helper.flash_class('danger')
      expect(result).to eq('bg-red-50 border-red-200 text-red-800')
    end

    it 'returns red classes for error' do
      result = helper.flash_class('error')
      expect(result).to eq('bg-red-50 border-red-200 text-red-800')
    end

    it 'returns yellow classes for warning' do
      result = helper.flash_class('warning')
      expect(result).to eq('bg-yellow-50 border-yellow-200 text-yellow-800')
    end

    it 'returns blue classes for info' do
      result = helper.flash_class('info')
      expect(result).to eq('bg-blue-50 border-blue-200 text-blue-800')
    end

    it 'returns blue classes for notice' do
      result = helper.flash_class('notice')
      expect(result).to eq('bg-blue-50 border-blue-200 text-blue-800')
    end

    it 'returns gray classes for unknown types' do
      result = helper.flash_class('unknown')
      expect(result).to eq('bg-gray-50 border-gray-200 text-gray-800')
    end

    it 'handles symbol types' do
      result = helper.flash_class(:success)
      expect(result).to eq('bg-green-50 border-green-200 text-green-800')
    end

    it 'handles nil type' do
      result = helper.flash_class(nil)
      expect(result).to eq('bg-gray-50 border-gray-200 text-gray-800')
    end
  end

  describe '#flash_icon' do
    it 'returns success checkmark icon for success' do
      result = helper.flash_icon('success')

      expect(result).to include('<svg')
      expect(result).to include('text-green-400')
      expect(result).to include('M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z')
    end

    it 'returns error exclamation icon for danger' do
      result = helper.flash_icon('danger')

      expect(result).to include('<svg')
      expect(result).to include('text-red-400')
      expect(result).to include('M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z')
    end

    it 'returns error exclamation icon for error' do
      result = helper.flash_icon('error')

      expect(result).to include('<svg')
      expect(result).to include('text-red-400')
      expect(result).to include('M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z')
    end

    it 'returns warning triangle icon for warning' do
      result = helper.flash_icon('warning')

      expect(result).to include('<svg')
      expect(result).to include('text-yellow-400')
      warning_svg_path = 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-' \
                         '.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z'
      expect(result).to include(warning_svg_path)
    end

    it 'returns info circle icon for unknown types' do
      result = helper.flash_icon('unknown')

      expect(result).to include('<svg')
      expect(result).to include('text-blue-400')
      expect(result).to include('M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z')
    end

    it 'handles symbol types' do
      result = helper.flash_icon(:success)

      expect(result).to include('text-green-400')
    end

    it 'handles nil type' do
      result = helper.flash_icon(nil)

      expect(result).to include('text-blue-400')
    end

    it 'returns valid HTML structure' do
      result = helper.flash_icon('success')

      expect(result).to include('w-5 h-5')
      expect(result).to include('fill="none"')
      expect(result).to include('viewBox="0 0 24 24"')
      expect(result).to include('stroke="currentColor"')
      expect(result).to include('stroke-linecap="round"')
      expect(result).to include('stroke-linejoin="round"')
      expect(result).to include('stroke-width="2"')
    end
  end

  describe '#turbo_frame_tag' do
    it 'creates a turbo-frame tag with id' do
      result = helper.turbo_frame_tag('test-frame') { 'Content' }

      expect(result).to include('<turbo-frame')
      expect(result).to include('id="test-frame"')
      expect(result).to include('Content')
      expect(result).to include('</turbo-frame>')
    end

    it 'accepts additional options' do
      result = helper.turbo_frame_tag('test-frame', class: 'custom-class', src: '/path') { 'Content' }

      expect(result).to include('id="test-frame"')
      expect(result).to include('class="custom-class"')
      expect(result).to include('src="/path"')
    end

    it 'works with empty block' do
      result = helper.turbo_frame_tag('empty-frame') {}

      expect(result).to include('<turbo-frame')
      expect(result).to include('id="empty-frame"')
      expect(result).to include('</turbo-frame>')
    end

    it 'overwrites id if provided in options' do
      result = helper.turbo_frame_tag('frame1', id: 'frame2') { 'Content' }

      # The method sets options[:id] = id, so it should be 'frame1'
      expect(result).to include('id="frame1"')
      expect(result).not_to include('id="frame2"')
    end

    it 'handles complex content' do
      content = '<div class="inner">Complex HTML</div>'.html_safe
      result = helper.turbo_frame_tag('complex-frame') { content }

      expect(result).to include('<turbo-frame')
      expect(result).to include('id="complex-frame"')
      expect(result).to include('<div class="inner">Complex HTML</div>')
      expect(result).to include('</turbo-frame>')
    end
  end

  describe 'integration tests' do
    it 'flash helpers work together' do
      flash_type = 'success'
      css_class = helper.flash_class(flash_type)
      icon = helper.flash_icon(flash_type)

      expect(css_class).to include('green')
      expect(icon).to include('green')
    end

    it 'handles all flash types consistently' do
      types = %w[success danger error warning info notice unknown]

      types.each do |type|
        css_class = helper.flash_class(type)
        icon = helper.flash_icon(type)

        expect(css_class).to be_a(String)
        expect(css_class).not_to be_empty
        expect(icon).to include('<svg')
      end
    end
  end
end
