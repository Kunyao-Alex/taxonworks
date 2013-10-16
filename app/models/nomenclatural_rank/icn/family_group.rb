class NomenclaturalRank::Icn::FamilyGroup < NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') if not(taxon_name.name = taxon_name.name.capitalize)
  end

  def self.valid_parents
    NomenclaturalRank::Icn::FamilyGroup.descendants + NomenclaturalRank::Icn::AboveFamilyGroup.descendants
  end
end
