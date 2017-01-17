module MoveToGo
    class Organizations < Hash
    
        def initialize(rootmodel)
            @rootmodel = rootmodel
        end

        class DuplicateSet < Array
            # Moves all data to the first organization and returns the remaining orgs
            def merge_all!()
                return self.map{ |org|
                    if org != self.first
                        self.first.move_data_from(org)
                        org
                    end
                }
                .flatten
                .compact
            end
        end

        class DuplicateSetArray < Array

            def initialize(rootmodel, array)
                @rootmodel = rootmodel
                super(array)
            end

            def map_duplicates(&block)
            
                # Send the sets to the function that will decide to keep or remove them
                # Can return Nil, a single org, empty array or an array of orgs. Compact and flatten to fix
                self
                    .map{ |duplicate_set| yield DuplicateSet.new duplicate_set}
                    .flatten
                    .compact
            end
            
        end
        
        #Finds duplicates based on supplied fields. Returns an DuplicateSetArray
        def find_duplicates_by(*raw_fields_to_check)
            # map fields to instance variable name or to class. For example :name
            # or "visiting_address.city" => [:visiting_address, :city]
            fields_to_check = raw_fields_to_check.map{ |field|
            fields = field.to_s.split(".")
            case fields.length
                when 1 then :"@#{field}"
                when 2 then [:"@#{fields[0]}",:"@#{fields[1]}"]
                else raise
            end
            } 
            # Find all posible duplicates and collect them to sets.
            possible_duplicate_sets = self
            .values
            .group_by{ |org|
                fields_to_check.map{ |field|
                case field # Some fields (Address) are accually class objects, check what we are dealing with
                    when Symbol then val = org.instance_variable_get(field)
                    when Array then val = org.instance_variable_get(field[0]).instance_variable_get(field[1])
                end
                val != nil ? val.downcase.strip : val = ''
                }
            }
            .select { |k, v| v.size > 1 }
            .values

            return DuplicateSetArray.new(@rootmodel, possible_duplicate_sets)
        end
    end
end