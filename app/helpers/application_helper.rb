module ApplicationHelper
  def paginate(collection, params = {})
    will_paginate collection, params.merge(renderer: RemoteLinkPaginationHelper::LinkRenderer)
  end

  def flash_class(type)
    case type.to_s
    when 'success'
      'bg-green-50 border-green-200 text-green-800'
    when 'danger', 'error'
      'bg-red-50 border-red-200 text-red-800'
    when 'warning'
      'bg-yellow-50 border-yellow-200 text-yellow-800'
    when 'info', 'notice'
      'bg-blue-50 border-blue-200 text-blue-800'
    else
      'bg-gray-50 border-gray-200 text-gray-800'
    end
  end

  def flash_icon(type)
    case type.to_s
    when 'success'
      content_tag :svg, class: 'w-5 h-5 text-green-400', fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor' do
        content_tag :path, nil, 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2',
                                d: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
      end
    when 'danger', 'error'
      content_tag :svg, class: 'w-5 h-5 text-red-400', fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor' do
        content_tag :path, nil, 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2',
                                d: 'M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z'
      end
    when 'warning'
      content_tag :svg, class: 'w-5 h-5 text-yellow-400', fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor' do
        warning_path = 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-' \
                       '.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z'
        content_tag :path, nil,
                    'stroke-linecap': 'round',
                    'stroke-linejoin': 'round',
                    'stroke-width': '2',
                    d: warning_path
      end
    else
      content_tag :svg, class: 'w-5 h-5 text-blue-400', fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor' do
        content_tag :path, nil, 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2',
                                d: 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z'
      end
    end
  end

  def turbo_frame_tag(id, **options, &)
    options[:id] = id
    content_tag('turbo-frame', options, &)
  end
end
