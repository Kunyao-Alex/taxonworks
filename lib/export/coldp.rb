require 'zip'

module Export

  # TODO: Explore https://github.com/frictionlessdata/datapackage-rb to ingest frictionless data,
  # then each module will provide a correspond method to each field
  # write tests to check for coverage (missing methods)
  # 
  # http://api.col.plus/datapackage
  # https://github.com/frictionlessdata/datapackage-rb
  # https://github.com/frictionlessdata/tableschema-rb
  #
  #
  # * Update all files formats to use tabs 
  #
  # Exports to the Catalog of Life in the new "coldp" format.
  module Coldp

    FILETYPES = %w{Description Name Synonym VernacularName}.freeze

    # @return [Scope]
    #   Should return the full set of Otus (= Taxa in CoLDP) that are to be sent.
    #   
    #
    # TODO: include options for validity, sets of tags, etc. 
    # At present otus are a mix of valid and invalid
    def self.otus(otu_id)
      o = ::Otu.find(otu_id)
      return ::Otu.none if o.taxon_name_id.nil?
      a = o.taxon_name.self_and_descendants
      ::Otu.joins(:taxon_name).where(taxon_name: a) 
    end

    def self.export(otu_id)
      otus = otus(otu_id)
      ref_csv = CSV.new('temp_ref_csv', col_sep: "\t")

      ref_csv << %w{ID citation	author year source details doi}

      # TODO: This will likely have to change, it is renamed on serving the file.
      zip_file_path = "/tmp/_#{SecureRandom.hex(8)}_coldp.zip"

      Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
        (FILETYPES - ['Name']).each do |ft| 
          m = "Export::Coldp::Files::#{ft}".safe_constantize
          zipfile.get_output_stream("#{ft}.csv") { |f| f.write m.generate(otus, ref_csv) }
        end 

        zipfile.get_output_stream('Name.csv') { |f| f.write Export::Coldp::Files::Name.generate( Otu.find(otu_id), ref_csv) }
        zipfile.get_output_stream('Taxon.csv') { |f| f.write Export::Coldp::Files::Taxon.generate( otus, otu_id, ref_csv) }

        ref_csv.rewind
        zipfile.get_output_stream('References.csv') { |f| f.write ref_csv.string }
        ref_csv.close
      end

      zip_file_path
    end 

    def self.download(otu, request = nil)
      file_path = ::Export::Coldp.export(otu.id)
      name = "coldp_otu_id_#{otu.id}_#{DateTime.now}.zip"

      ::Download.create!(
        name: "ColDP Download for #{otu.otu_name} on #{Time.now}.",
        description: 'A zip file containing CoLDP formatted data.',
        filename: name,
        source_file_path: file_path,
        request: request,
        expires: 2.days.from_now
      )
    end

    def self.download_async(otu, request = nil)
      download = ::Download.create!(
        name: "ColDP Download for #{otu.otu_name} on #{Time.now}.",
        description: 'A zip file containing CoLDP formatted data.',
        filename: "coldp_otu_id_#{otu.id}_#{DateTime.now}.zip",
        request: request,
        expires: 2.days.from_now
      )

      ColdpCreateDownloadJob.perform_later(otu, download)

      download
    end

    # TODO - perhaps a utilities file --

    # @return [Boolean]
    #   true if no parens in cached_author_year
    #   false if parens in cached_author_year
    def self.original_field(taxon_name)
      (taxon_name.type == 'Protonym') && taxon_name.is_original_name?
    end

    # There are suite of issues with TaxonWorks model
    # all tied to the fact that we do not treat original combinations (lower case)
    # as Combinations (model).  All these problems go away if/when we remodel the original Combination.
    # These problems include:
    #     * inablity to site historical usages of the protonym that are properly latinized (e.g. var or f. names as subspecies)
    #     * providing unique IDs for form/var names
    # @param taxon_name [an invalid Protonym]
    def self.reified_id(taxon_name)
      if taxon_name.original_combination_relationships.any?
        taxon_name.id.to_s + '/' + Digest::MD5.hexdigest(taxon_name.cached_original_combination)
      else
        # there is no need to MD5 the name, as it hasn't been potentially altered by original combination assertions 
        taxon_name.id.to_s
      end
    end

    # @param taxon_name [a valid Protonym or a Combination]
    def self.basionym_id(taxon_name)
      if taxon_name.type == 'Protonym'
        taxon_name.id
      elsif taxon_name.type == 'Combination'
        taxon_name.protonyms.last.id 
      else
        nil # shouldn't be hit
      end
    end

  end
end
