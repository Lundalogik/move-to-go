module GoImport
    class ShardHelper
            attr_accessor :shards, :current_shard_count
            def initialize(shard_size=25000)
                @shard_size = shard_size
                @current_shard = GoImport::RootModel.new
                @shards = [@current_shard]
                @current_shard_count = 0
            end

            def shard_model(model)
                @current_shard.configuration = model.configuration
                @current_shard.coworkers = model.coworkers
                @current_shard_count = model.coworkers.length

                model.organizations.each{|key, org| add_organization(org)}
                model.deals.each{|key, deal| add_deal(deal)}
                model.notes.each{|key, note| add_note(note)}
                add_documents(model.documents)

            end

            def get_shards()
                return @shards
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
                    @current_shard = GoImport::RootModel.new
                    @shards.push(@current_shard)
                    @current_shard_count = 0
                end
            end
    end
end
