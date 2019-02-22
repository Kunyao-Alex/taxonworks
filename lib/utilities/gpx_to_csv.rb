module Utilities::GPXToCSV

  # convert a GPX file to a bespoke tab-seperated CSV file

  # @param [GPX::GPXFile] gpx_file
  # @param [Hash] csv_options
  # @return [CSV]
  def self.gpx_to_csv(gpx_file, csv_options = {col_sep: "\t", headers: true, encoding: 'UTF-8', write_headers: true})
    gpx_headers = %w(name geojson start_date end_date)
    csv_string = CSV.generate(csv_options) do |csv|
      csv << gpx_headers

      gpx_file.waypoints.each do |waypoint|
        json = %({type : Point, coordinates : [#{waypoint.lon}, #{waypoint.lat}, #{waypoint.ele}]})
        csv << [waypoint.name,
                json]
        csv
      end

      gpx_file.routes.each do |route|
        start_time = route.points.first.time
        end_time = route.points.last.time
        coordinates = []
        route.points.each do |point|
          coordinates << [point.lon, point.lat, point.elevation]
        end
        json = %({type : LineString, coordinates : #{coordinates}})

        csv << [route.name,
                json,
                start_time,
                end_time]
      end

      gpx_file.tracks.each do |track|
        start_time = track.points.first.time
        end_time = track.points.last.time
        coordinates = []
        track.points.each do |point|
          coordinates << [point.lon, point.lat, point.elevation]
        end
        json = %({type : LineString, coordinates : #{coordinates}})

        csv << [track.name,
                json,
                start_time,
                end_time]
      end
    end
    csv = CSV.parse(csv_string, csv_options)
    csv
  end
end

# gpx = GPX::GPXFile.new(:gpx_file => '/Users/tuckerjd/src/taxonworks/spec/files/batch/collecting_event/test.gpx')
# Utilities::GPXToCSV.gpx_to_csv(gpx)
