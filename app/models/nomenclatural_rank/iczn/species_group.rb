class NomenclaturalRank::Iczn::SpeciesGroup < NomenclaturalRank::Iczn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be lower case') unless(taxon_name.name == taxon_name.name.downcase)
  end

  def self.valid_parents
    NomenclaturalRank::Iczn::SpeciesGroup.descendants + NomenclaturalRank::Iczn::GenusGroup.descendants
  end
end
