require_relative "my_sqlite_request.rb"


=begin
    Select col from data
    Select * from data
    Select col from data where
    Select * from data where
    Select col from data where join data on col1 = col2 
    select col from data where condition order by col asc

    update data where condition

    delete data where condition

    insert data where condition
=end


csvr = MySqliteRequest.new
puts "1 ========================================================================"
puts "SELECT weight FROM data"
puts
csvr.from("data.csv").select("weight").run

puts "2 ========================================================================"
puts "SELECT * FROM nba_player_data WHERE weight = 999"
puts
csvr.from("nba_player_data.csv").select("*").where("weight",999).run

puts "3 ========================================================================"
puts "SELECT * FROM nba_player_data WHERE weight = 240"
puts
csvr.from("nba_player_data.csv").select("*").where("weight",240).run

puts "4 ========================================================================"
puts "SELECT name, year_start FROM data WHERE year_start = 2017"
puts
csvr.from("data.csv").select("name", "year_start").where("year_start", 2017).run

puts "5 ========================================================================"
puts "SELECT * FROM data JOIN data_to_join ON name = player"
puts
csvr.from("data.csv").select("*").join("name","data_to_join.csv","player").run


puts "6 ========================================================================"
puts "SELECT * FROM data JOIN data_to_join ON name = player WHERE weight = 240"
puts
csvr.from("data.csv").select("*").join("name","data_to_join.csv","player").where("weight",240).run

puts "7 ========================================================================"
puts "SELECT name, player FROM data JOIN data_to_join ON name = player"
puts
csvr.from("data.csv").select("name", "player").join("name","data_to_join.csv","player").run

puts "8 ============================== DELETE BY STRING ========================================="
puts "DELETE FROM data WHERE name = 'Alaa Abdelnaby'"
puts
csvr.delete.from("data.csv").where("name", "Alaa Abdelnaby").run

puts "9 ============================== DELETE BY INT =================================="
puts "DELETE FROM data WHERE year_start = 1969"
puts
csvr.delete.from("data.csv").where("year_start", 1969).run

#UPDATE data.csv SET college = "University of California, Santa Cruz", name = "Connor" WHERE name = "Alex Abrines"
hash = {:college=>"University of California, Santa Cruz", :name=>"Connor"}
puts "10 ============================== UPDATE BY STRING ============================"
puts "UPDATE data.csv SET college = \"University of California, Santa Cruz\", name = \"Connor\" WHERE name = 'Alex Abrines';"
puts 
csvr.update("data.csv").set(hash).where("name", "Alex Abrines").run

#UPDATE data.csv SET college = "University of California, Santa Cruz", name = "Connor" WHERE year_start = 1998
hash = {:college=>"University of California, Santa Cruz", :name=>"Connor"}
puts "11 ============================== UPDATE BY INT ==============================="
puts "UPDATE data.csv SET college = \"University of California, Santa Cruz\", name = \"Connor\" WHERE year_start = 1998;"
puts 
csvr.update("data.csv").set(hash).where("year_start", 1998).run

#INSERT INTO data.csv VALUES ("Thanh N", 1996, 2022, F-C, 5-7, 143, "Oct 1, 1996", "Alameda College")
hash1 = {:name=>"Thanh N", :year_start=>1996, :year_end=>2022, :position=>"F-C", :height=>"5-7", :weight=>140, :birth_date=>"Oct 1, 1996", :college=>"College of Alameda"}
puts "12 ======================= INSERT DATA =================================="
puts "INSERT INTO data.csv VALUES (\"Thanh N\", 1996, 2022, F-C, 5-7, 143, \"Oct 1, 1996\", \"Alameda College\") "
puts 
csvr.insert("data").values(hash1).run

puts "13 =============================="
puts "SELECT * FROM data WHERE weight = 225 ORDER BY name asc"
puts
csvr.from("data").select("*").where("weight",225).order("name","asc").run





