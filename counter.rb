class Counter
  def initialize
    @counter = 0
  end

  def get_counter
    @counter
  end

  def counter=(val)
    @counter = val
  end

  def inc
    @counter += 1
  end

  def out
    print Rainbow("counter : ").darkgoldenrod
    print Rainbow(@counter).yellow
    puts
  end

  def run
    inc
    out
  end
end
