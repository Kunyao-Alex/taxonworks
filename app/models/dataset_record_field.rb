class DatasetRecordField < ApplicationRecord
  include Shared::IsData

  belongs_to :import_dataset # To speed up queries, normally should be get from dataset_record
  belongs_to :dataset_record
  belongs_to :project # Security purposes only (avoid leaks)

  VALUE_INDEX_LIMIT = 1000

  def dataset_record_type
    DatasetRecordField.decode_record_type(self.encoded_dataset_record_type)
  end

  def dataset_record_type=(type)
    self.encoded_dataset_record_type = DatasetRecordField.encode_record_type(type)
  end

  def self.at(position)
    where(position: position)
  end

  def self.with_value(value)
    where(indexed_column_value(value).eq(value))
  end

  def self.with_prefix_value(prefix)
    where(indexed_column_value(prefix).matches("#{prefix.gsub(/([%_\[\\])/, '\\\\\1')}%"))
  end

  def self.with_record_type(type)
    where(
      encoded_dataset_record_type: DatasetRecordField.encode_record_type(core_record_type)
    )
  end

  class << self
    def indexed_column_value(value)
      if value.length <= VALUE_INDEX_LIMIT
        Arel::Nodes::NamedFunction.new("substr", [arel_table[:value], 1, VALUE_INDEX_LIMIT])
      else
        arel_table[:value]
      end
    end

    def encode_record_type(type)
      ENCODED_TYPES_LUT.fetch(type.name)
    end

    def decode_record_type(encoded_type)
      ENCODED_TYPES_LUT.fetch(encoded_type)
    end

    private

    # Unfortunately DatasetRecord.descendants is empty on ActiveJob context, so have to list classes explicitly
    DATASET_RECORD_DESCENDANTS = [
      DatasetRecord::DarwinCore::Extension,
      DatasetRecord::DarwinCore::Occurrence,
      DatasetRecord::DarwinCore::Taxon
    ]

    ENCODED_TYPES_LUT = DatasetRecord.descendants.map(&:name).inject({}) do |lut, type|
      digest = Digest::MD5.hexdigest(type).last(32/4).to_i(16) & (2**31 - 1)
      lut.merge({type => digest, digest => type})
    end

    if ENCODED_TYPES_LUT.values.uniq.length < ENCODED_TYPES_LUT.values.length
      raise "FATAL: Some DatasetRecord types have same digest encoding."
    end
  end
end
