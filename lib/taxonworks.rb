# require 'json' GeoLocate needs this; not sure if it is needed elsewhere

Dir[Rails.root.to_s + '/app/models/nomenclatural_rank/**/*.rb'].each {|file| require file }

Dir[Rails.root.to_s + '/app/models/taxon_name_relationship/**/*.rb'].each {|file| require file }



module TaxonWorks
end
