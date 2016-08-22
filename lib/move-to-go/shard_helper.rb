module MoveToGo
    class ShardHelper

            attr_accessor :shards, :current_shard_count, :current_shard

            def initialize(shard_size = nil)
                @shard_size = shard_size || 25000
                setup()
            end

            def shard_model(model)
                @current_shard.settings = model.settings

                model.coworkers.each{ |key, coworker|
                    if coworker.integration_id != "migrator"
                        add_coworker(coworker)
                    end
                }
                model.organizations.each{|key, org| add_organization(org)}
                model.deals.each{|key, deal| add_deal(deal)}
                model.histories.each{|key, history| add_history(history)}
                add_documents(model.documents)

                return_value = @shards
                setup()
                return return_value
            end

            private
            def setup()
                @current_shard = MoveToGo::RootModel.new
                @shards = [@current_shard]
                @current_shard_count = 0
            end

            private
            def add_history(history)
                check_or_create_new_chard()
                @current_shard.add_history(history)
                @current_shard_count += 1
            end

            private
            def add_deal(deal)
                check_or_create_new_chard()
                @current_shard.add_deal(deal)
                @current_shard_count += 1
            end

            private
            def add_coworker(coworker)
                check_or_create_new_chard()
                @current_shard.add_coworker(coworker)
                @current_shard_count += 1
            end

            private
            def add_organization(org)
                check_or_create_new_chard()
                if org.employees != nil
                    @current_shard_count += org.employees.length
                end
                @current_shard.add_organization(org)
                @current_shard_count += 1
            end

            private
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
                    @current_shard = MoveToGo::RootModel.new
                    @shards.push(@current_shard)
                    @current_shard_count = 0
                end
            end
    end
end
