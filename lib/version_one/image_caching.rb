module VersionOne
module ImageCaching
  def self.image_url(image_name)
    ImageCacheBaseUrl + image_name
  end
  
  def self.for_url_code(image_name)
    ImageCacheBaseUrl + image_name
  end
  def self.on(city)
    CityImagesCache.on(city)
  end
    
  ImageCacheBaseUrl = '/images/cache/'
  TransparentImageFilePath = ImageCaching::image_url "transparent.png"

  
  class CityImagesCache
    def self.on(city)
      url_code = city && city.url_code || "default"
      self.new do 
        add_image :header_background , preloaded("#{url_code}_header_background.png")
        add_image :city_name_right , preloaded("#{url_code}_city_name_right.png")
      end
    end
    
    def initialize (&configuration_block)
      @images = {}
      instance_eval &configuration_block if block_given?
      @images.default = transparent_image
    end
    
    def add_image image_symbol, cached_image
      @images[image_symbol] = cached_image
    end
    
    
    def method_missing(method, *args, &block)
      @images[method].get_url 
    end
    
    def preloaded(image_name)
      CachedImage.with_name(image_name)
    end
    
    private 
    def transparent_image
      @transparent_image ||= CachedImage.transparent() 
    end
    
  end
  
  class CachedImage

    def self.transparent
      self.new(TransparentImageFilePath)
    end
    
    def self.with_name(image_name)
      self.new(ImageCaching.image_url(image_name))
    end
    
    def initialize(image_path)
      @image_path = image_path
    end
    
    def get_url(file_checker = self)
      if file_checker.exists?
        @image_path
      else
        TransparentImageFilePath
      end
    end
    
    def exists?
      return File.exists?("#{Rails.root}/public" + @image_path)
    end
   
  end
  
end
end
