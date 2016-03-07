module GoImport
    class ShardHelper
            def initialize(model, shard_size=25000)
                @shards = []
                @shard_size = shard_size
                @current_shard = GoImport::RootModel.new
                @current_shard_count = 0
                @current_shard.configuration = model.configuration
            end

            def get_shards()
                if not @current_shard_count == 0
                    @shards.push(@current_shard)
                    return shards
                end
            end

            def add_coworker(coworker)
                check_or_create_new_chard()
                @current_shard.add_coworker(coworker)
                @current_shard_count += 1
            end

            def add_note(note)
                check_or_create_new_chard()
                @current_shard.add_note(note)
                @current_shard_count += 1
            end

            def add_deal(deal)
                check_or_create_new_chard()
                @current_shard.add_deal(deal)
                @current_shard_count += 1
            end

            def add_organization(org)
                check_or_create_new_chard()
                if org.employees != nil
                    @current_shard_count += org.employees.length
                end
                @current_shard.add_organization(org)
                @current_shard_count += 1 
            end

            def add_documents(doc)
                    doc.files.each{|file| add_file(file)}
                    doc.links.each{|link| add_link(link)}
            end

            private
            def add_file(file)
                check_or_create_new_chard()
                @current_shard.add_file(file)
                @current_shard_count += 1 
            end

            private
            def add_link(link)
                check_or_create_new_chard()
                @current_shard.add_link(link)
                @current_shard_count += 1 
            end
            
            private
            def check_or_create_new_chard()
                if @current_shard_count > @shard_size
                    @shards.push(@current_shard)
                    puts "New chard created (#{shards.length})"
                    @current_shard = GoImport::RootModel.new
                    @current_shard_count = 0
                end
            end
    end
end
