module AdminHelper
  def write_field(type, field, hash, post)
    options = Hash.new

    method = case hash['type']
             when 'textarea'
               options[:cols] = hash['cols'] || 46
               options[:rows] = hash['rows'] || 10
               'text_area_tag'
             when 'select'
               hash['options'] = hash['options'].is_a?(Hash) ? hash['options'].invert : hash['options']
               selected = post.post_type == type ? post.content.send(field) : nil
               content = options_for_select(hash['options'], selected)
               'select_tag'
             when 'checkbox'
               content = hash['options']
               'checkbox_tag'
             else
               options[:size] = hash['size'] || 40
               'text_field_tag'
             end

    content ||= if post.new_record? 
                  (hash['default'] ? hash['default'] : '')
                elsif post.post_type == type
                  post.content.send(field)
                else
                  ''
                end

    send(method, "yaml[#{type}][#{field}]", content, options)
  end
end
