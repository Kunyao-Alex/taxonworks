# taxonID
# areaID
# area
# gazetteer
# status
# referenceID
# remarks
#
module Export::Coldp::Files::Distribution

  def self.reference_id(content)
    i = content.sources.pluck(:id)
    return i.join(',') if i.any?
    nil
  end

  def self.generate(otus, reference_csv = nil )
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        taxonID
        areaID
        area
        gazetteer
        status
        referenceID
        remarks
      }

      otus.joins(:asserted_distributions).distinct.each do |o|
        o.asserted_distributions.each do |ad|

          ga = GeographicArea.find(ad.geographic_area_id)
          if !ga.iso_3166_a3.blank?
            gazetteer = 'iso'
            area_id = ga.iso_3166_a3
            area = ga.iso_3166_a3
          elsif !ga.iso_3166_a2.blank?
            gazetteer = 'iso'
            area_id = ga.iso_3166_a2
            area = ga.iso_3166_a2
          elsif !ga.tdwgID.blank?
            gazetteer = 'tdwg'
            area_id = ga.tdwgID.gsub(/^[0-9]{1,2}(.+)$/, '\1')  # fixes mismatch in TW vs CoL TDWG identifiers
            area = area_id
          else
            gazetteer = 'text'
            area_id = nil
            area = ga.name
          end

          sources = ad.sources.load
          reference_ids = sources.collect{|a| a.id}.join(',')
          csv << [
            o.id,
            area_id,
            area,
            gazetteer,
            nil,
            reference_ids,
            nil
          ]

          Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv) if reference_csv
        end
      end
    end
  end
end
