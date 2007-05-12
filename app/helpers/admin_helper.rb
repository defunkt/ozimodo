module AdminHelper
  def write_field(type, field, hash, post, form)
    options = Hash.new

    method = case hash['type']
             when 'textarea'
               options[:cols] = hash['cols'] || 46
               options[:rows] = hash['rows'] || 10
               'text_area'
             when 'select'
               hash['options'] = hash['options'].is_a?(Hash) ? hash['options'].invert : hash['options']
               selected = post.post_type == type ? post.content.send(field) : nil
               content = options_for_select(hash['options'], selected)
               'select'
             when 'checkbox'
               content = hash['options']
               'checkbox'
             else
               options[:size] = hash['size'] || 40
               'text_field'
             end

    content ||= if post.new_record? 
                  (hash['default'] ? hash['default'] : '')
                elsif post.post_type == type
                  post.content.send(field)
                else
                  nil
                end
    
    #arguments_hash = content || content != '' ? options : content.merge(options)
    #method + field + arguments_hash.to_s
    #send(method, field, content, options)
    form.send(method, field, options)
  end
end
