require 'rainbow'
require 'pp'
require_relative 'colors'
require_relative 'counter'

module DbgModule
  class Background
    include Colors

    attr_accessor :show

    def initialize
      @color = black
      @show = false
    end

    def show!
      @show = !@show
    end
  end

  class Form
    include Colors

    attr_accessor :background, :body, :text_array, :last_color

    def initialize
      @text_array = []
    end

    def bg
      @background ||= Background.new
    end

    def pp
      @text_array[-1] = PP.pp(@text_array[-1], output_string = "").chomp

      self
    end

    def add(text)
      @text_array.append text
      self
    end

    def out
      while @text_array.size > 0 do
        puts @text_array.shift
      end

      @log
    end

    def print
      puts @text_array.pop(@text_array.size).join(' ')

      @log
    end

    def colorize(value, color_name)
      # if @background&.show
      #  Rainbow(value).send(color_name).bg(@background.color)
      # else
        Rainbow(value).send(color_name)
      # end
    end
  end

  class Body < Form
    COLORS.each do |color_name|
      define_method(color_name) do
        @last_color = color_name

        @text_array[-1] = colorize(@text_array[-1], color_name)
        self
      end
    end

    def sep(symbol: '-', size: 98, color: 'yellow')
      default_sep = symbol * size

      colorized_sep = colorize(default_sep, color)

      add(colorized_sep)

      self
    end

    def step(number:, symbol: '-', size: 2, prefix_color: 'cyan', step_color: 'magenta')
      out unless @text_array.blank?

      default_prefix = symbol * size
      default_step = "# #{number}"

      colorized_prefix = colorize(default_prefix, prefix_color)
      add(colorized_prefix)

      colorized_step = colorize(default_step, step_color)
      add(colorized_step)

      print
    end

    def short_sep(symbol = '-', size = 57)
      add(symbol * size)
      self
    end

    def caller(data:, scan: '_spec.rb')
      add(data.select { |e| e.scan(scan).first.present? }).pp
      @text_array[-1] = "caller:\n#{@text_array[-1]}"
      self
    end

    def head(text, text_color = 'slateblue', sep_color = 'slateblue')
      header(text, text_color, sep_color, with_sep = false)
    end

    def title(title, text_color = 'darkgoldenrod', sep_color = 'yellow')
      Dbg.empty

      header(title, text_color, sep_color)
    end

    private

    def header(text, text_color, sep_color, with_sep = true)
      max_sep = "=" * 98

      if with_sep
        add(max_sep).send(sep_color.to_sym).out
      end

      title_size = text.length

      half_title_size = ((max_sep.length - title_size) / 2) - 1
      total_title_size = title_size + (half_title_size * 2) + 2

      last_half_title_size =
        if total_title_size.odd?
          if total_title_size > max_sep.length
            half_title_size - 1
          else
            half_title_size + 1
          end
        else
          half_title_size
        end

      half_title = "=" * half_title_size

      add(half_title.rjust(half_title_size, "=")).send(sep_color.to_sym)
      add(text).send(text_color.to_sym)
      add(half_title.rjust(last_half_title_size, "=")).send(sep_color.to_sym).print
    rescue => e
      puts '*' * 50
      puts "DBG ERROR: #{e.message}"
      puts '*' * 50
    end
  end
end

class Dbg
  cattr_accessor :counter

  include DbgModule

  def self.log
    @log ||= Body.new
  end

  def self.start_test
    log.sep.green
    log.add('START TEST').darkgoldenrod
    log.sep.green.out
    empty
  end

  def self.end_test
    empty
    log.sep.green
    log.add('END TEST').darkgoldenrod
    log.sep.green.out
  end

  def self.empty
    puts
    self
  end

  def self.counter
    @@counter ||= Counter.new
  end

  def self.list_colors
    Colors::COLORS.each do |color_name|
      log.add(color_name).send(color_name.to_sym)
    end

    log.print
  end
end
