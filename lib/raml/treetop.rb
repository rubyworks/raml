require 'treetop'

=begin
class RAMLPreparser

  def parse(string)
    string.strip
    #remove_extra_spaces(remove_comments(string))
    #remove_comments(string.strip)
  end

private
  
  def remove_comments(string)
    string.gsub(/\#.*?($|\Z)/, "")
  end
  
  #def remove_extra_spaces(string)
  #  string.gsub(/\s+/, " ")
  #end

end
=end

Treetop.load File.dirname(__FILE__) + "/raml/treetop/raml"

