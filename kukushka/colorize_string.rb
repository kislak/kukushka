class String
  # colorization
  def colorize(color_code)
    "\033[#{color_code}m#{self}\033[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
  
  def color(f, b)
    colorize("0;#{f};#{b}")
  end  
end