
module GoImport
    class CanBecomeImmutable
        def self.immutable_accessor(name)
            define_method(name) do
                return instance_variable_get("@#{name}")
            end
            
            define_method("#{name}=") do |value|
                raise_if_immutable
                instance_variable_set("@#{name}", value)
            end
        end
        
        def raise_if_immutable
            if @is_immutable
                raise ObjectIsImmutableError
            end
        end
        
        def set_is_immutable()
            @is_immutable = true
        end

        def is_immutable()
            @is_immutable
        end
    end
end
