### Validating input

Sometimes the data in the migration file might look good at first glance, but still have logical errors in it.
You can add some logical validation in the mapping functions in `converter.rb` to do all kinds of different sanity checks.

Example from runner.rb:

```ruby
def to_history(row, rootmodel)
  history = MoveToGo::History.new()
  
  # We only want to attach history to organizations that are contained in the file.
  organization = rootmodel.find_organization_by_integration_id(row['companyID'])
  if organization.nil?
    puts 'Cound not find organization'
    return nil
  end

  # Ignore empty notes.
  text = row['note']
  if text.empty?
    puts 'Ignoring empty note'
    return nil
  end
  
  # Ignore notes written in the future.
  date = row['created date']
  if !Date.parse(date).past?
    puts 'date in the future'
    return nil
  end
  
  # Ignore notes created by Vince Vega
  coworker = rootmodel.find_coworker_by_integration_id(row['coworkerID'])
  if coworker.first_name.eql? 'Vince' && coworker.last_name.eql? 'Vega'
    puts 'Ignore notes written by Vince'
    return nil
  end
  
  history.organization = organization
  history.created_by = coworker
  history.text = text
  history.date = date

  return history
end
```
