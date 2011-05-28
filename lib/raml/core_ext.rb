class String

  # Combine with string with a newline between each.
  #
  # Examples
  #
  #   "foo" ^ "bar"  #=> "foo\nbar"
  #
  def ^(string)
    self + "\n" + string.to_s
  end

end
