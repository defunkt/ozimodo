$:.unshift File.dirname(__FILE__)
require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'type_parser')

# rails' camelize
String.module_eval { def camelize() self.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase } end }

# path to fixtures
def fixture_file(file)
  File.join(File.dirname(__FILE__), 'fixtures', file)
end

# will grab files like fixtures/simple_text_fields.yml and dump the contents into a
# SimpleTextFields constant as a string
Dir[File.join(File.dirname(__FILE__), 'fixtures','*.yml')].each { |file| Object.const_set(file.split(/\/|\\/).last.split('.').first.camelize, File.read(file)) }

class TestParse < Test::Unit::TestCase
  def test_simple_text_fields
    fields = Ozimodo::TypeParser.parse(SimpleTextFields)

    assert_equal 'text', fields['quote']['type']
    assert_equal 'text', fields['author']['type']
  end

  def test_complex_text_fields
    fields = Ozimodo::TypeParser.parse(ComplexTextFields)

    assert_equal 'textarea', fields['quote']['type']
    assert_equal 30, fields['quote']['rows']
    assert_equal 20, fields['quote']['cols']
    assert_equal 'Nothing to see here.', fields['quote']['default']

    assert_equal 'textarea', fields['author']['type']

    assert_equal 'text', fields['source']['type']
    assert_equal 20, fields['source']['size'] 
  end

  def test_mix_of_simple_and_complex_fields
    fields = Ozimodo::TypeParser.parse(MixOfSimpleAndComplexFields)

    assert_equal 'text', fields['book']['type']
    assert_equal 'text', fields['context']['type']

    assert_equal 'textarea', fields['quote']['type']
    assert_equal 30, fields['quote']['rows']
    assert_equal 20, fields['quote']['cols']
    assert_equal 'Nothing to see here.', fields['quote']['default']

    assert_equal 'textarea', fields['author']['type']
  end

  def test_fields_key_is_discarded
    fields = Ozimodo::TypeParser.parse(MixOfSimpleAndComplexFields)

    assert_equal nil, fields['fields']
    assert_equal 20, fields['quote']['cols']
    assert_equal 'textarea', fields['author']['type']
    assert_equal 'text', fields['context']['type']
  end

  def test_select_fields
    fields = Ozimodo::TypeParser.parse(SelectFields)

    assert_equal 'select', fields['city']['type']
    assert_equal ['Cincinnati', 'San Francisco'], fields['city']['options']

    assert_equal 'select', fields['state']['type']

    assert fields['state']['options'].values.include?('Ohio')
    assert fields['state']['options'].keys.include?('OH')
    assert fields['state']['options'].values.include?('California')
    assert fields['state']['options'].keys.include?('CA')
  end

  def test_checkbox_fields
    fields = Ozimodo::TypeParser.parse(CheckboxFields)
   
    assert_equal 'checkbox', fields['privacy']['type'] 
    assert_equal 'Hidden', fields['privacy']['options'][0]
    assert_equal 'Everyone', fields['privacy']['options'][2]
  end

  def test_mix_of_fields
    fields = Ozimodo::TypeParser.parse(MixOfFields)

    assert_equal 'checkbox', fields['privacy']['type'] 
    assert_equal 'Hidden', fields['privacy']['options'][0]
    assert_equal 'Everyone', fields['privacy']['options'][2]

    assert_equal 'select', fields['city']['type']
    assert_equal ['Cincinnati', 'San Francisco'], fields['city']['options']

    assert_equal 'select', fields['state']['type']
    assert fields['state']['options'].values.include?('Ohio')
    assert fields['state']['options'].keys.include?('OH')

    assert_equal 'text', fields['director']['type']
    assert_equal 'text', fields['imdb']['type']

    assert_equal 'textarea', fields['quote']['type']
    assert_equal 30, fields['quote']['rows']
    assert_equal 20, fields['quote']['cols']
    assert_equal 'Nothing to see here.', fields['quote']['default']

    assert_equal 'textarea', fields['author']['type']
  end
end

class TestLoadAndParse < Test::Unit::TestCase
  def test_file_with_no_definition
    file = fixture_file('_quip.rhtml')

    fields = Ozimodo::TypeParser.parse_file(file)

    assert_equal false, fields 
  end

  def test_file_with_simple_text
    file = fixture_file('_quote.rhtml') 

    fields = Ozimodo::TypeParser.parse_file(file)

    assert_equal 'text', fields['quote']['type']
    assert_equal 'text', fields['author']['type']
  end  

  def test_file_with_complex_text 
    file = fixture_file('_image.rhtml') 

    fields = Ozimodo::TypeParser.parse_file(file)

    assert_equal 'text', fields['src']['type']
    assert_equal 'http://ozmm.org/images/typed/', fields['src']['default']

    assert_equal 'text', fields['alt']['type']

    assert_equal 'textarea', fields['blurb']['type']
  end  

  def test_file_with_mixed_fields 
    file = fixture_file('_photo.rhtml')

    fields = Ozimodo::TypeParser.parse_file(file)

    assert_equal 'text', fields['src']['type']
    assert_equal 'http://static.flickr.com/', fields['src']['default']

    assert_equal 'text', fields['alt']['type']
    assert_equal 'flickr.', fields['alt']['default']

    assert_equal 'text', fields['author']['type']
    assert_equal 'fauxtank', fields['author']['default']
    
    assert_equal 'text', fields['date']['type']

    assert_equal 'text', fields['camera']['type']
  end  
end
