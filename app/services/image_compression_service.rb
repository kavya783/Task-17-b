require "mini_magick"
require "tempfile"

class ImageCompressionService
  MAX_SIZE = 1.megabyte
  MIN_QUALITY = 25
  BASE_WIDTH = 1200
  BASE_HEIGHT = 1200

  def self.compress(uploaded_file)
    filename = if uploaded_file.respond_to?(:original_filename)
                 uploaded_file.original_filename
               else
                 File.basename(uploaded_file.path)
               end

    size = if uploaded_file.respond_to?(:size)
             uploaded_file.size
           else
             File.size(uploaded_file.path)
           end

    puts "Original file: #{filename} (#{size} bytes)"

    temp_file = Tempfile.new(["compressed", ".jpg"])
    temp_file.binmode

    quality = 85
    resize_width = BASE_WIDTH
    resize_height = BASE_HEIGHT

    loop do
      image = MiniMagick::Image.open(uploaded_file.path)
      image.auto_orient
      image.resize "#{resize_width}x#{resize_height}>"
      image.strip
      image.format "jpg"
      image.quality quality.to_s
      image.interlace "Plane"
      image.write(temp_file.path)

      compressed_size = File.size(temp_file.path)
      puts "Quality=#{quality}, Resize=#{resize_width}x#{resize_height}, Compressed Size=#{compressed_size}"

      break if compressed_size <= MAX_SIZE || (quality <= MIN_QUALITY && resize_width <= 600 && resize_height <= 600)

      if quality > MIN_QUALITY
        quality -= 10
      else
        resize_width = (resize_width * 0.9).to_i
        resize_height = (resize_height * 0.9).to_i
      end
    end

    puts "FINAL FILE: #{temp_file.path}"
    puts "FINAL SIZE: #{File.size(temp_file.path)}"

    temp_file
  end
end