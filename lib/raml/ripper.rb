require 'pp'
require 'ripper'

def ptree(tree)
  t = []
  tree.each do |tag, rest|
    case rest
    when Array
      t << ptree(rest)
    else
      t << [tag, *rest] if /^@/ =~ tag.to_s
    end
  end
  t
end

src = File.read(ARGV[0])

tree = Ripper::SexpBuilder.new(src).parse

pp ptree(tree)

