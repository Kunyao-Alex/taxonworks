json.partial! "import_datasets/import_dataset", import_dataset: @import_dataset, filters: @filters
json.results do
  json.partial! partial: "dataset_records/dataset_record", collection: @results, as: :dataset_record
end