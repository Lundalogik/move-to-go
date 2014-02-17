# encoding: utf-8
module FruitToLime
    class Tag
    	def serialize_name
            "Tag"
        end
    	attr_accessor :value
    	def initialize(val=nil)
    		if val
    			@value = val
    		end
    	end
  		def to_xml
  			varn = serialize_name
            "<#{varn}>#{ @value.to_s.encode('utf-8').encode(:xml => :text) }</#{varn}>"
  		end
  		def to_s
            return "tag: '#{@value}'"
        end
        def ==(other)
        	if other.respond_to?(:value)
            	return @value == other.value
            else
            	return false
            end
        end
    end 
end