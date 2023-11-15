require 'rainbow'
require 'pp'
require_relative 'colors'

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
      @text_array.append text; self
    end
  
    def out
      while @text_array.size > 0 do
        puts @text_array.shift
      end
    end
  
    def print
      puts @text_array.pop(@text_array.size).join(' ')
    end
  
    def colorize(value, color_name)
      if @background&.show
        Rainbow(value).send(color_name).bg(@background.color)
      else
        Rainbow(value).send(color_name)
      end
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
  
    def sep(symbol = '-', size = 98)
      add(symbol * size)
      self
    end

    def title(title, text_color = 'darkgoldenrod', sep_color = 'yellow')
      Dbg.empty
      title_sep = "=" * 98
      title_size = title.length

      half_title_size = ((title_sep.length - title_size) / 2) - 1
      total_title_size = title_size + (half_title_size * 2) + 2

      last_half_title_size =
        if total_title_size.odd?
          if total_title_size > title_sep.length
            half_title_size - 1
          else
            half_title_size + 1
          end
        else
          half_title_size
        end

      half_title = "=" * half_title_size
      add(title_sep).send(sep_color.to_sym).out
      add(half_title.rjust(half_title_size, "=")).send(sep_color.to_sym)
      add(title).send(text_color.to_sym)
      add(half_title.rjust(last_half_title_size, "=")).send(sep_color.to_sym).print
    rescue => e
      puts '*' * 50
      puts "DBG ERROR: #{e.message}"
      puts '*' * 50
    end
  
    def caller(data:, scan: '_spec.rb')
      add(data.select { |e| e.scan(scan).first.present? }).pp
      @text_array[-1] = "caller:\n#{@text_array[-1]}"
      self
    end
  end
end

class Dbg
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

  def self.list_colors
    Colors::COLORS.each do |color_name|
      log.add(color_name).send(color_name.to_sym)
    end

    log.print
  end
end
